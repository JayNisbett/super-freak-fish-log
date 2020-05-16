import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/thumbnail.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A page that is able to manage a list of a given type, [T]. The page includes
/// an optional [SearchBar] and can be used a single or multi-item picker.
class ManageableListPage<T> extends StatefulWidget {
  /// See [SliverChildBuilderDelegate.childCount].
  final int itemCount;

  /// See [ManageableListPageItemModel].
  final ManageableListPageItemModel<T> Function(BuildContext, int) itemBuilder;

  /// If non-null, items in the list can be added, deleted, and modified.
  ///
  /// See [ManageableListPageItemManager].
  final ManageableListPageItemManager<T> itemManager;

  /// See [SliverAppBar.title].
  final Widget title;

  /// If true, adds additional padding between search icon and search text so
  /// the search text is horizontally aligned with an item's main text.
  /// Defaults to false. If an item has a thumbnail, the [Thumbnail.listItem]
  /// constructor should be used.
  final bool itemsHaveThumbnail;

  /// If true, forces the [AppBar] title to the center of the screen. Defaults
  /// to false.
  ///
  /// See [SliverAppBar.centerTitle].
  final bool forceCenterTitle;

  /// If non-null, the [ManageableListPage] acts like a picker.
  ///
  /// See [ManageableListPageSinglePickerSettings].
  /// See [ManageableListPageMultiPickerSettings].
  final ManageableListPagePickerSettings<T> pickerSettings;

  /// If non-null, the [ManageableListPage] includes a [SearchBar] in the
  /// [AppBar].
  ///
  /// See [ManageableListPageSearchSettings].
  final ManageableListPageSearchSettings searchSettings;

  ManageableListPage({
    @required this.itemCount,
    @required this.itemBuilder,
    this.title,
    this.itemsHaveThumbnail = false,
    this.forceCenterTitle = false,
    this.pickerSettings,
    this.searchSettings,
    @required this.itemManager,
  }) : assert(itemBuilder != null),
       assert(itemCount != null),
       assert(itemManager != null);

  @override
  _ManageableListPageState<T> createState() => _ManageableListPageState<T>();
}

class _ManageableListPageState<T> extends State<ManageableListPage<T>> {
  final double _appBarExpandedHeight = 100.0;
  final double _searchBarHeight = 40.0;

  /// Additional padding required to line up search text with [ListItem] text.
  final double _thumbSearchTextOffset = 24.0;

  bool _editing = false;
  Set<T> _selectedValues = {};
  _ViewingState _viewingState = _ViewingState.viewing;

  bool get _pickingMulti => _viewingState == _ViewingState.pickingMulti;
  bool get _pickingSingle => _viewingState == _ViewingState.pickingSingle;
  bool get _hasSearch => widget.searchSettings != null;
  bool get _editable => widget.itemManager.editPageBuilder != null;

  @override
  void initState() {
    super.initState();

    if (widget.pickerSettings != null) {
      _viewingState = widget.pickerSettings.multi
          ? _ViewingState.pickingMulti : _ViewingState.pickingSingle;
      _selectedValues = Set.of(widget.pickerSettings.initialValues);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceElevated: true,
            floating: true,
            pinned: false,
            snap: true,
            title: widget.title,
            actions: _buildActions(),
            expandedHeight: _hasSearch ? _appBarExpandedHeight : 0.0,
            flexibleSpace: _buildSearchBar(),
            centerTitle: widget.forceCenterTitle,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              _buildItem,
              childCount: widget.itemCount,
            ),
          ),
        ],
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
          child: Container(
            height: _searchBarHeight,
            child: SearchBar(
              hint: widget.searchSettings.hint,
              leadingPadding: widget.itemsHaveThumbnail
                  ? _thumbSearchTextOffset : null,
              elevated: false,
              onTap: widget.searchSettings.onStart,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    List<Widget> result = [];

    if (_pickingMulti && _editable) {
      // If picking multiple items, use overflow menu for "Add" and "Edit"
      // options.
      result..add(ActionButton.done(
        condensed: true,
        onPressed: () {
          if (_editing) {
            setEditingUpdateState(false);
          } else {
            _finishPicking(_selectedValues);
          }
        },
      ))..add(PopupMenuButton<_OverflowOption>(
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => [
          PopupMenuItem<_OverflowOption>(
            value: _OverflowOption.add,
            child: Text(Strings.of(context).add),
          ),
          PopupMenuItem<_OverflowOption>(
            value: _OverflowOption.edit,
            child: Text(Strings.of(context).edit),
            enabled: !_editing,
          ),
        ],
        onSelected: (option) {
          switch (option) {
            case _OverflowOption.add:
              present(context, widget.itemManager.addPageBuilder());
              break;
            case _OverflowOption.edit:
              setEditingUpdateState(true);
              break;
          }
        },
      ));
    } else {
      if (_editing) {
        result.add(ActionButton.done(
          condensed: true,
          onPressed: () => setEditingUpdateState(false),
        ));
      } else if (_editable) {
        // Only include the edit button if the items can be modified.
        result.add(ActionButton.edit(
          condensed: true,
          onPressed: () => setEditingUpdateState(true),
        ));
      }

      // Always include the "Add" button.
      result.add(IconButton(
        icon: Icon(Icons.add),
        onPressed: () =>
            present(context, widget.itemManager.addPageBuilder()),
      ));
    }

    return result;
  }

  Widget _buildItem(BuildContext context, int i) {
    ManageableListPageItemModel<T> item = widget.itemBuilder(context, i);

    if (!item.editable) {
      // If this item can't be edited, return it; we don't want to use a
      // ManageableListItem.
      return item.child;
    }

    Widget trailing = RightChevronIcon();
    if (_pickingMulti) {
      trailing = PaddedCheckbox(
        checked: _selectedValues.contains(item.value),
        onChanged: (checked) {
          setState(() {
            if (_selectedValues.contains(item.value)) {
              _selectedValues.remove(item.value);
            } else {
              _selectedValues.add(item.value);
            }
          });
        },
      );
    } else if (_pickingSingle || widget.itemManager.detailPageBuilder == null) {
      // Don't know detail disclosure indicator if we're picking a single
      // value, or if there isn't any detail to show.
      trailing = Empty();
    }

    return ManageableListItem(
      child: item.child,
      editing: _editing,
      deleteMessageBuilder: (context) =>
          widget.itemManager.deleteText(context, item.value),
      onConfirmDelete: () => widget.itemManager.deleteItem(context, item.value),
      onTap: () {
        if (_pickingMulti && !_editing) {
          // Taps are consumed by trailing checkbox in this case.
          return;
        }

        if (_editing) {
          push(context, widget.itemManager.editPageBuilder(item.value));
        } else if (_pickingSingle) {
          _finishPicking({item.value});
        } else if (widget.itemManager.detailPageBuilder != null) {
          push(context, widget.itemManager.detailPageBuilder(item.value));
        }
      },
      trailing: trailing,
    );
  }

  void setEditingUpdateState(bool editing) => setState(() {
    _editing = editing;
  });

  void _finishPicking(Set<T> pickedValues) {
    if (widget.pickerSettings.onFinishedPicking(context, pickedValues)) {
      Navigator.of(context).pop();
    }
  }
}

enum _ViewingState {
  pickingSingle, pickingMulti, viewing
}

abstract class ManageableListPagePickerSettings<T> {
  final Set<T> initialValues;

  ManageableListPagePickerSettings({
    this.initialValues = const {},
  });

  bool get multi;

  /// Invoked when picking has finished. Returning true will pop the picker
  /// from the current [Navigator].
  bool onFinishedPicking(BuildContext context, Set<T> pickedValues);
}

/// A convenience class to indicate a single-item picker.
class ManageableListPageSinglePickerSettings<T>
    extends ManageableListPagePickerSettings<T>
{
  /// See [ManageableListPagePickerSettings.onFinishedPicking].
  final bool Function(BuildContext context, T) onPicked;

  ManageableListPageSinglePickerSettings({
    this.onPicked,
  }) : super(
    initialValues: {},
  );

  @override
  bool get multi => false;

  @override
  bool onFinishedPicking(BuildContext context, Set<T> pickedValues) {
    return onPicked?.call(context, pickedValues.first);
  }
}

/// A convenience class to indicate a multi-item picker.
class ManageableListPageMultiPickerSettings<T>
    extends ManageableListPagePickerSettings<T>
{
  /// See [ManageableListPagePickerSettings.onFinishedPicking].
  final bool Function(BuildContext context, Set<T>) onPicked;

  ManageableListPageMultiPickerSettings({
    Set<T> initialValues = const {},
    this.onPicked,
  }) : super(
    initialValues: initialValues,
  );

  @override
  bool get multi => true;

  @override
  bool onFinishedPicking(BuildContext context, Set<T> pickedValues) {
    return onPicked?.call(context, pickedValues);
  }
}

/// A convenience class for storing the properties of an option [SearchBar] in
/// the [AppBar] of a [ManageableListPage].
class ManageableListPageSearchSettings {
  /// The search hint text.
  final String hint;

  /// Invoked when the [SearchBar] is tapped.
  final VoidCallback onStart;

  ManageableListPageSearchSettings({
    @required this.hint,
    @required this.onStart,
  }) : assert(isNotEmpty(hint)),
       assert(onStart != null);
}

/// A convenient class for storing properties for a single item in a
/// [ManageableListPage].
class ManageableListPageItemModel<T> {
  /// True if this item can be edited; false otherwise. This may be false for
  /// section headers or dividers. Defaults to true.
  final bool editable;

  /// The child of item. [Padding] is added automatically, as is a trailing
  /// [RightChevronIcon] or [CheckBox] depending on the situation. This
  /// is most commonly a [Text] widget.
  final Widget child;

  /// The value of the item, required for picking.
  final T value;

  ManageableListPageItemModel({
    @required this.child,
    @required this.value,
    this.editable = true,
  }) : assert(child != null),
       assert(value != null);
}

/// A convenience class to handle the adding, deleting, and editing of an item
/// in a [ManageableListPage].
class ManageableListPageItemManager<T> {
  /// The [Widget] to display is a delete confirmation dialog. This should be
  /// some kind of [Text] widget.
  final Widget Function(BuildContext, T) deleteText;

  /// Invoked when the user confirms the delete operation. This method should
  /// actually delete the item [T] from the database.
  final void Function(BuildContext, T) deleteItem;

  /// Invoked when the "Add" button is pressed. The [Widget] returned by this
  /// function is presented in the current navigator.
  final Widget Function() addPageBuilder;

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
    @required this.deleteText,
    @required this.deleteItem,
    @required this.addPageBuilder,
    this.editPageBuilder,
    this.detailPageBuilder,
  }) : assert(deleteText != null),
       assert(deleteItem != null),
       assert(addPageBuilder != null),
       assert(editPageBuilder != null);
}

enum _OverflowOption {
  add, edit
}