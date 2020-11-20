import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_page.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_bait_page.dart';
import '../res/dimen.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class BaitListPage extends StatefulWidget {
  final bool Function(BuildContext, Set<Bait>) onPicked;
  final bool multiPicker;
  final Set<Bait> initialValues;

  BaitListPage()
      : onPicked = null,
        multiPicker = false,
        initialValues = null;

  BaitListPage.picker({
    @required this.onPicked,
    this.multiPicker = false,
    this.initialValues = const {},
  }) : assert(onPicked != null);

  @override
  _BaitListPageState createState() => _BaitListPageState();
}

class _BaitListPageState extends State<BaitListPage> {
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);

  bool get _picking => widget.onPicked != null;

  @override
  Widget build(BuildContext context) {
    return ManageableListPage<dynamic>(
      titleBuilder: _picking
          ? (_) => Text(Strings.of(context).baitListPagePickerTitle)
          : (baits) => Text(format(Strings.of(context).baitListPageTitle,
              [baits.whereType<Bait>().length])),
      forceCenterTitle: !_picking,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitListPageSearchHint,
        noResultsMessage: Strings.of(context).baitListPageNoSearchResults,
      ),
      pickerSettings: _picking
          ? ManageableListPagePickerSettings<dynamic>(
              onPicked: (context, items) => widget.onPicked(
                context,
                items.map((e) => (e as Bait)).toSet(),
              ),
              multi: widget.multiPicker,
              initialValues: widget.initialValues,
            )
          : null,
      itemBuilder: (context, item) {
        if (item is BaitCategory) {
          return ManageableListPageItemModel(
            editable: false,
            selectable: false,
            child: Padding(
              padding: insetsDefault,
              child: HeadingLabel(item.name),
            ),
          );
        } else if (item is Bait) {
          return ManageableListPageItemModel(
            child: PrimaryLabel(item.name),
          );
        } else {
          return ManageableListPageItemModel(
            editable: false,
            selectable: false,
            child: item,
          );
        }
      },
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          _baitCategoryManager,
          _baitManager,
        ],
        loadItems: _buildItems,
        deleteWidget: (context, bait) =>
            Text(_baitManager.deleteMessage(context, bait)),
        deleteItem: (context, bait) => _baitManager.delete(bait),
        addPageBuilder: () => SaveBaitPage(),
        detailPageBuilder: (bait) => BaitPage(bait.id),
        editPageBuilder: (bait) => SaveBaitPage.edit(bait),
      ),
    );
  }

  List<dynamic> _buildItems(String query) {
    var result = <dynamic>[];

    var categories = List.from(_baitCategoryManager.listSortedByName());
    var baits = _baitManager.filteredList(query);

    // Add a category for baits that don't have a category. This is purposely
    // added to the end of the sorted list.
    var noCategory = BaitCategory()
      ..id = randomId()
      ..name = Strings.of(context).baitListPageOtherCategory;
    categories.add(noCategory);

    // First, organize baits in to category collections.
    var map = <Id, List<Bait>>{};
    for (var bait in baits) {
      var id = bait.hasBaitCategoryId() ? bait.baitCategoryId : noCategory.id;
      map.putIfAbsent(id, () => []);
      map[id].add(bait);
    }

    // Next, iterate categories and create list items.
    for (var i = 0; i < categories.length; i++) {
      BaitCategory category = categories[i];

      // Skip categories that don't have any baits.
      if (!map.containsKey(category.id) || map[category.id].isEmpty) {
        continue;
      }

      // Add a divider between categories; skip first one.
      if (result.isNotEmpty) {
        result.add(MinDivider());
      }

      result.add(category);
      map[category.id].sort((lhs, rhs) => lhs.name.compareTo(rhs.name));
      result.addAll(map[category.id]);
    }

    return result;
  }
}
