import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../utils/search_timer.dart';
import '../widgets/button.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/list_item.dart';
import '../widgets/search_bar.dart';
import '../widgets/widget.dart';

/// A page that is able to manage a list of a given type, [T]. The page includes
/// an optional [SearchBar] and can be used a single or multi-item picker.
///
/// For a simpler picker, see [PickerPage].
class ManageableListPage<T> extends StatefulWidget {
  /// See [ManageableListPageItemModel].
  final ManageableListPageItemModel Function(BuildContext, T) itemBuilder;

  /// See [ManageableListPageItemManager].
  final ManageableListPageItemManager<T> itemManager;

  /// See [SliverAppBar.title].
  final Widget Function(List<T>) titleBuilder;

  /// Shown when [pickerSettings] is not null.
  ///
  /// See [SliverAppBar.title].
  final Widget Function(List<T>) pickerTitleBuilder;

  /// A custom widget to show as the leading widget in a [SliverAppBar].
  final Widget appBarLeading;

  /// If true, adds additional padding between search icon and search text so
  /// the search text is horizontally aligned with an item's main text.
  /// Defaults to false. If an item has a thumbnail, the [Photo.listThumbnail]
  /// constructor should be used.
  final bool itemsHaveThumbnail;

  /// If true, forces the [AppBar] title to the center of the screen. Defaults
  /// to false.
  ///
  /// See [SliverAppBar.centerTitle].
  final bool forceCenterTitle;

  /// If non-null, the [ManageableListPage] acts like a picker.
  final ManageableListPagePickerSettings<T> pickerSettings;

  /// If non-null, the [ManageableListPage] includes a [SearchBar] in the
  /// [AppBar].
  ///
  /// See [ManageableListPageSearchDelegate].
  final ManageableListPageSearchDelegate searchDelegate;

  ManageableListPage({
    @required this.itemManager,
    @required this.itemBuilder,
    this.titleBuilder,
    this.pickerTitleBuilder,
    this.appBarLeading,
    this.itemsHaveThumbnail = false,
    this.forceCenterTitle = false,
    this.pickerSettings,
    this.searchDelegate,
  })  : assert(itemBuilder != null),
        assert(itemManager != null);

  @override
  _ManageableListPageState<T> createState() => _ManageableListPageState<T>();
}

class _ManageableListPageState<T> extends State<ManageableListPage<T>> {
  static const IconData _iconCheck = Icons.check;
  static const IconData _iconAdd = Icons.add;

  static const _appBarExpandedHeight = 100.0;

  /// Additional padding required to line up search text with [ListItem] text.
  static const _thumbSearchTextOffset = 24.0;

  GlobalKey<SliverAnimatedListState> _animatedListKey =
      GlobalKey<SliverAnimatedListState>();
  _AnimatedListModel<T> _animatedList;

  SearchTimer _searchTimer;
  bool _isEditing = false;
  Set<T> _selectedValues = {};
  _ViewingState _viewingState = _ViewingState.viewing;
  String _searchText;

  bool get _isViewing => _viewingState == _ViewingState.viewing;

  bool get _isPickingMulti => _viewingState == _ViewingState.pickingMulti;

  bool get _isPickingSingle => _viewingState == _ViewingState.pickingSingle;

  bool get _isPicking => _isPickingMulti || _isPickingSingle;

  bool get _hasSearch => widget.searchDelegate != null;

  bool get _hasDetailPage => widget.itemManager.detailPageBuilder != null;

  bool get _isEditable => widget.itemManager.editPageBuilder != null;

  bool get _isAddable => widget.itemManager.addPageBuilder != null;

  @override
  void initState() {
    super.initState();

    if (widget.pickerSettings != null) {
      _viewingState = widget.pickerSettings.isMulti
          ? _ViewingState.pickingMulti
          : _ViewingState.pickingSingle;
      _selectedValues = Set.of(widget.pickerSettings.initialValues);
    }

    _searchTimer = SearchTimer(() => setState(_syncAnimatedList));
  }

  @override
  void dispose() {
    super.dispose();
    _searchTimer.finish();
  }

  Widget build(BuildContext context) {
    if (widget.itemManager?.listenerManagers == null) {
      return _buildScaffold(context);
    }

    return EntityListenerBuilder(
      managers: widget.itemManager.listenerManagers,
      builder: _buildScaffold,
      onAdd: _onEntityAdded,
      onDelete: _onEntityDeleted,
      onUpdate: _onEntitiesUpdated,
      onClear: _onEntitiesCleared,
    );
  }

  Widget _buildScaffold(BuildContext context) {
    _initAnimatedListIfNeeded();

    // Disable editing if there are no items in the list.
    if (_animatedList.isEmpty) {
      _isEditing = false;
    }

    // If picking an option isn't required, show a "None" option.
    var showClearOption = _isPicking && !widget.pickerSettings.isRequired;

    // +2 for "None" and divider.
    var clearOptionOffset = showClearOption ? 2 : 0;

    Widget emptyWidget = Empty();
    if (widget.itemManager.emptyItemsSettings != null &&
        (widget.searchDelegate == null ||
            (isEmpty(_searchText) && _animatedList.isEmpty))) {
      emptyWidget = EmptyListPlaceholder.static(
        title: widget.itemManager.emptyItemsSettings.title,
        description: widget.itemManager.emptyItemsSettings.description,
        descriptionIcon: _isAddable ? _iconAdd : null,
        icon: widget.itemManager.emptyItemsSettings.icon,
      );
    } else if (isNotEmpty(_searchText)) {
      emptyWidget = EmptyListPlaceholder.noSearchResults(
        context,
        scrollable: false,
      );
    }

    return WillPopScope(
      onWillPop: () {
        if (_isPickingMulti) {
          _finishPicking(_selectedValues);
        }
        return Future.value(true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              forceElevated: true,
              floating: true,
              pinned: false,
              snap: true,
              title: _isPicking
                  ? widget.pickerTitleBuilder?.call(_animatedList.items) ??
                      Empty()
                  : widget.titleBuilder?.call(_animatedList.items) ?? Empty(),
              actions: _buildActions(_animatedList.items),
              expandedHeight: _hasSearch ? _appBarExpandedHeight : 0.0,
              flexibleSpace: _buildSearchBar(),
              centerTitle: widget.forceCenterTitle,
              leading: widget.appBarLeading,
            ),
            SliverSafeArea(
              top: false,
              // TODO: Use a sliver animated switcher when available - https://github.com/flutter/flutter/issues/64069
              sliver: SliverVisibility(
                visible: _animatedList.isNotEmpty,
                sliver: SliverAnimatedList(
                  key: _animatedListKey,
                  initialItemCount: _animatedList.length + clearOptionOffset,
                  itemBuilder: (context, i, animation) {
                    if (showClearOption) {
                      if (i == 0) {
                        return _buildNoneItem(context, _animatedList.items);
                      } else if (i == 1) {
                        return MinDivider();
                      }
                    }
                    return _buildItem(context,
                        _animatedList[i - clearOptionOffset], animation);
                  },
                ),
                replacementSliver: SliverFillRemaining(
                  fillOverscroll: true,
                  hasScrollBody: false,
                  child: Center(
                    child: emptyWidget,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_hasSearch) {
      return null;
    }

    return FlexibleSpaceBar(
      background: Padding(
        padding: EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          bottom: paddingSmall,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SearchBar(
            text: _searchText,
            hint: widget.searchDelegate.hint,
            leadingPadding:
                widget.itemsHaveThumbnail ? _thumbSearchTextOffset : null,
            elevated: false,
            delegate: InputSearchBarDelegate((text) {
              _searchText = text;
              _searchTimer.reset(_searchText);
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(List<T> items) {
    var result = <Widget>[];

    if (items.isNotEmpty) {
      if (_isEditing) {
        result.add(ActionButton.done(
          condensed: _isAddable,
          onPressed: () => _setEditingUpdateState(isEditing: false),
        ));
      } else if (_isEditable) {
        // Only include the edit button if the items can be modified.
        result.add(ActionButton.edit(
          condensed: _isAddable,
          onPressed: () => _setEditingUpdateState(isEditing: true),
        ));
      }
    }

    // Only include the add button if new items can be added.
    if (_isAddable) {
      result.add(IconButton(
        icon: Icon(_iconAdd),
        onPressed: () => present(context, widget.itemManager.addPageBuilder()),
      ));
    }

    return result;
  }

  Widget _buildNoneItem(BuildContext context, List<T> items) {
    String label;
    Widget trailing;
    VoidCallback onTap;
    if (_isPickingSingle) {
      label = Strings.of(context).none;
      trailing = _selectedValues.isEmpty ? Icon(_iconCheck) : null;
      onTap = () => _finishPicking({});
    } else if (_isPickingMulti) {
      label = Strings.of(context).all;
      trailing = PaddedCheckbox(
        checked: widget.pickerSettings.containsAll?.call(_selectedValues) ??
            _selectedValues.containsAll(items),
        onChanged: (checked) => setState(() {
          if (checked) {
            _selectedValues = items.toSet();
          } else {
            _selectedValues.clear();
          }
        }),
      );
      onTap = null;
    }

    return ManageableListItem(
      editing: false,
      child: Text(label),
      onTapDeleteButton: () => false,
      onTap: onTap,
      trailing: trailing,
    );
  }

  Widget _buildItem(
      BuildContext context, T itemValue, Animation<double> animation) {
    var item = widget.itemBuilder(context, itemValue);

    if (!item.editable && !item.selectable) {
      // If this item can't be edited or selected, return it; we don't want
      // to use a ManageableListItem.
      return item.child;
    }

    Widget trailing = RightChevronIcon();
    if (_isPickingMulti) {
      trailing = PaddedCheckbox(
        checked: _isItemSelected(itemValue),
        onChanged: (checked) {
          setState(() {
            if (_isItemSelected(itemValue)) {
              _selectedValues.remove(itemValue);
            } else {
              _selectedValues.add(itemValue);
            }
          });
        },
      );
    } else if (_isPickingSingle ||
        widget.itemManager.detailPageBuilder == null) {
      // Don't show detail disclosure indicator if we're picking a single
      // value, or if there isn't any detail to show.
      trailing = _isItemSelected(itemValue) ? Icon(_iconCheck) : Empty();
    }

    var canEdit = _isEditing && item.editable;
    var enabled = !_isEditing || canEdit;

    var listItem = ManageableListItem(
      child: item.child,
      editing: canEdit,
      enabled: enabled,
      deleteMessageBuilder: (context) =>
          widget.itemManager.deleteWidget(context, itemValue),
      onConfirmDelete: () => widget.itemManager.deleteItem(context, itemValue),
      onTap: !enabled || (_isViewing && !_hasDetailPage && !canEdit)
          ? null
          : () {
              if (_isPickingMulti && !canEdit) {
                // Taps are consumed by trailing checkbox in this case.
                return;
              }

              if (canEdit) {
                present(context, widget.itemManager.editPageBuilder(itemValue));
              } else if (_isPickingSingle) {
                _finishPicking({itemValue});
              } else if (widget.itemManager.detailPageBuilder != null) {
                push(context, widget.itemManager.detailPageBuilder(itemValue));
              }
            },
      onTapDeleteButton: widget.itemManager.onTapDeleteButton == null
          ? null
          : () => widget.itemManager.onTapDeleteButton(itemValue),
      trailing: trailing,
    );

    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: listItem,
    );
  }

  void _setEditingUpdateState({bool isEditing}) {
    setState(() {
      _isEditing = isEditing;
    });
  }

  void _finishPicking(Set<T> pickedValues) {
    if (widget.pickerSettings.onPicked(context, pickedValues)) {
      Navigator.of(context).pop();
    }
  }

  bool _isItemSelected(T item) {
    // Most, if not all, uses of ManageableListPage use model objects with an
    // "id" property. Google Protocol Buffers don't have inheritance, though,
    // so we can't use a parent or abstract class in place of T. Instead, we
    // explicitly try to access the "id" property and if an error is thrown,
    // fallback on Set.contains().
    try {
      for (var value in _selectedValues) {
        if ((value as dynamic).id == (item as dynamic).id) {
          return true;
        }
      }
      // ignore: avoid_catching_errors
    } on Error catch (_) {
      return _selectedValues.contains(item);
    }

    return false;
  }

  /// Sync's the animated list model with the database list.
  void _syncAnimatedList() {
    // Resetting the list's key will force it to rebuild it's state with the
    // new list of items.
    _animatedListKey = GlobalKey<SliverAnimatedListState>();
    _animatedList.resetItems(
        _animatedListKey, widget.itemManager.loadItems(_searchText));
  }

  void _initAnimatedListIfNeeded() {
    if (_animatedList != null) {
      return;
    }

    _animatedList = _AnimatedListModel(
      listKey: _animatedListKey,
      initialItems: widget.itemManager.loadItems(_searchText),
      removedItemBuilder: _buildItem,
    );
  }

  void _onEntityAdded(dynamic entity) {
    // Get an updated item list. This includes the new item added.
    var items = widget.itemManager.loadItems(_searchText);

    // Don't animate any entity additions if it isn't an entity associated
    // with this ManageableListPage.
    if (!(entity is T)) {
      return;
    }

    _animatedList.insert(
        min(_animatedList.length, items.indexOf(entity)), entity);
  }

  void _onEntityDeleted(dynamic entity) {
    if (entity is T) {
      _animatedList.removeAt(_animatedList.indexOf(entity));
    }
  }

  void _onEntitiesUpdated(List<dynamic> entities) {
    _syncAnimatedList();
  }

  void _onEntitiesCleared() {
    _syncAnimatedList();
  }
}

/// A convenience class for storing the properties related to when a
/// [ManageableListPage] is being used to pick items from a list.
class ManageableListPagePickerSettings<T> {
  /// Invoked when picking has finished. Returning true will pop the picker
  /// from the current [Navigator]. [pickedItems] is guaranteed to have one
  /// and only one item if [isMulti] is false, otherwise includes all items that
  /// were picked. If [isRequired] is false, and "None" is selected,
  /// [pickedItems] is an empty [Set].
  final bool Function(BuildContext context, Set<T> pickedItems) onPicked;

  final Set<T> initialValues;
  final bool isMulti;

  /// When false (default), a "None" option is displayed at the top of the
  /// picker for single pickers, allowing users to "clear" the active selection,
  /// if there is one. If [isMulti] is true, a "Select all" or "Deselect all"
  /// checkbox option is displayed.
  final bool isRequired;

  /// A function that returns true if the given [selectedItems] contains all
  /// of the available options. If null, [Set.containsAll] is used. Note that
  /// this should only be used when [T] is [dynamic].
  ///
  /// This property only applies when [isMulti] is true.
  final bool Function(Set<T> selectedItems) containsAll;

  ManageableListPagePickerSettings({
    @required this.onPicked,
    Set<T> initialValues,
    this.isMulti = true,
    this.isRequired = false,
    this.containsAll,
  })  : assert(onPicked != null),
        initialValues = initialValues ?? const {};

  ManageableListPagePickerSettings.single({
    bool Function(BuildContext, T) onPicked,
    T initialValue,
    bool isRequired = false,
  }) : this(
          onPicked: (context, items) =>
              onPicked(context, items.isEmpty ? null : items.first),
          initialValues: initialValue == null ? null : {initialValue},
          isMulti: false,
          isRequired: isRequired,
          containsAll: null,
        );

  ManageableListPagePickerSettings copyWith({
    bool Function(BuildContext, Set<T>) onPicked,
    Set<T> initialValues,
    bool isMulti,
    bool isRequired,
    bool Function(Set<T>) containsAll,
  }) {
    return ManageableListPagePickerSettings(
      onPicked: onPicked ?? this.onPicked,
      initialValues: initialValues ?? this.initialValues,
      isMulti: isMulti ?? this.isMulti,
      isRequired: isRequired ?? this.isRequired,
      containsAll: containsAll ?? this.containsAll,
    );
  }
}

/// A convenience class for storing the properties of an optional [SearchBar] in
/// the [AppBar] of a [ManageableListPage].
class ManageableListPageSearchDelegate {
  /// The search hint text.
  final String hint;

  ManageableListPageSearchDelegate({
    @required this.hint,
  }) : assert(isNotEmpty(hint));
}

/// A convenient class for storing properties for a single item in a
/// [ManageableListPage].
class ManageableListPageItemModel {
  /// True if this item can be edited; false otherwise. This may be false for
  /// section headers or dividers. Defaults to true.
  final bool editable;

  final bool selectable;

  /// The child of item. [Padding] is added automatically, as is a trailing
  /// [RightChevronIcon] or [CheckBox] depending on the situation. This
  /// is most commonly a [Text] widget.
  final Widget child;

  ManageableListPageItemModel({
    @required this.child,
    this.editable = true,
    this.selectable = true,
  }) : assert(child != null);
}

/// A convenient class for storing properties for related to a widget to show
/// when a [ManageableListPage] has an empty model list.
class ManageableListPageEmptyListSettings {
  final String title;
  final String description;
  final IconData icon;

  ManageableListPageEmptyListSettings({
    @required this.title,
    @required this.description,
    @required this.icon,
  })  : assert(isNotEmpty(title)),
        assert(isNotEmpty(description)),
        assert(icon != null);
}

/// A convenience class for storing properties related to adding, deleting, and
/// editing of items in a [ManageableListPage].
///
/// [T] is the type of object being managed, and must be the same type used
/// when instantiating [ManageableListPage].
class ManageableListPageItemManager<T> {
  /// Invoked when the widget tree needs to be rebuilt. Required so data is
  /// almost the most up to date from the database. The passed in [String] is
  /// the text in the [SearchBar].
  final List<T> Function(String) loadItems;

  /// Settings used to populate a widget when [loadItems] returns an empty list.
  final ManageableListPageEmptyListSettings emptyItemsSettings;

  /// The [Widget] to display is a delete confirmation dialog. This should be
  /// some kind of [Text] widget.
  final Widget Function(BuildContext, T) deleteWidget;

  /// Invoked when the user confirms the delete operation. This method should
  /// actually delete the item [T] from the database.
  final void Function(BuildContext, T) deleteItem;

  /// See [ManageableListItem.onTapDeleteButton].
  final bool Function(T) onTapDeleteButton;

  /// Invoked when the "Add" button is pressed. The [Widget] returned by this
  /// function is presented in the current navigator.
  final Widget Function() addPageBuilder;

  /// If non-null, will rebuild the [ManageableListPage] when one
  /// of the [EntityManager] objects is notified of updates. In most cases,
  /// this [List] will only have one value.
  final List<EntityManager> listenerManagers;

  /// If non-null, is invoked when an item is tapped while not in "editing"
  /// mode. The [Widget] returned by this function is pushed to the current
  /// navigator, and should be a page that shows details of [T].
  final Widget Function(T) detailPageBuilder;

  /// If non-null, is invoked when an item is tapped while in "editing" mode.
  /// The [Widget] returned by this function is pushed to the current navigator,
  /// and should be a page that allows editing of [T].
  ///
  /// If null, editing is disabled for the [ManageableListPage].
  final Widget Function(T) editPageBuilder;

  ManageableListPageItemManager({
    @required this.loadItems,
    @required this.deleteWidget,
    @required this.deleteItem,
    this.emptyItemsSettings,
    this.addPageBuilder,
    this.listenerManagers,
    this.editPageBuilder,
    this.detailPageBuilder,
    this.onTapDeleteButton,
  })  : assert(loadItems != null),
        assert(deleteWidget != null),
        assert(deleteItem != null),
        assert(listenerManagers == null || listenerManagers.isNotEmpty);
}

enum _ViewingState {
  pickingSingle,
  pickingMulti,
  viewing,
}

/// Keeps a Dart [List] in sync with an [AnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
///
/// Derived from https://api.flutter.dev/flutter/widgets/SliverAnimatedList-class.html
/// sample project.
class _AnimatedListModel<T> {
  GlobalKey<SliverAnimatedListState> listKey;
  final Widget Function(BuildContext, T, Animation<double>) removedItemBuilder;
  final List<T> _items;

  _AnimatedListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    List<T> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = List.of(initialItems) ?? [];

  SliverAnimatedListState get _animatedList => listKey.currentState;

  List<T> get items => _items;

  int get length => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  void insert(int index, T item) {
    _items.insert(index, item);

    // Note that _animatedList could be null here if there are no items in the
    // list. In this case, we want to update the underlying data model, but
    // do not animate the insertion.
    _animatedList?.insertItem(index, duration: defaultAnimationDuration);
  }

  T removeAt(int index) {
    var removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
        (context, animation) =>
            removedItemBuilder(context, removedItem, animation),
        duration: defaultAnimationDuration,
      );
    }
    return removedItem;
  }

  int indexOf(T item) => _items.indexOf(item);

  T operator [](int index) => _items[index];

  void resetItems(GlobalKey<SliverAnimatedListState> newKey, List<T> newItems) {
    listKey = newKey;
    _items.clear();
    _items.addAll(List.of(newItems));
  }
}
