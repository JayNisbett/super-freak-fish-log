import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';

class BaitCategoryListPage extends StatelessWidget {
  final bool Function(BuildContext, BaitCategory) onPicked;
  final BaitCategory initialValue;

  BaitCategoryListPage() : onPicked = null, initialValue = null;

  BaitCategoryListPage.picker({
    @required this.onPicked,
    this.initialValue,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    BaitCategoryManager baitCategoryManager = BaitCategoryManager.of(context);

    return ManageableListPage<BaitCategory>(
      titleBuilder: _picking
          ? (_) => Text(Strings.of(context).baitCategoryListPagePickerTitle)
          : (categories) => Text(format(Strings.of(context)
              .baitCategoryListPageTitle, [categories.length])),
      itemBuilder: (context, category) => ManageableListPageItemModel(
        child: PrimaryLabel(category.name),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitCategoryListPageSearchHint,
        noResultsMessage:
            Strings.of(context).baitCategoryListPageNoSearchResults,
      ),
      pickerSettings: _picking
          ? ManageableListPagePickerSettings<BaitCategory>(
              initialValues: { initialValue },
              onPicked: (context, categories) =>
                  onPicked(context, categories?.first),
            )
          : null,
      itemManager: ManageableListPageItemManager<BaitCategory>(
        listenerManagers: [ baitCategoryManager ],
        loadItems: (query) =>
            baitCategoryManager.listSortedByName(filter: query),
        deleteWidget: (context, category) =>
            Text(baitCategoryManager.deleteMessage(context, category)),
        deleteItem: (context, category) =>
            baitCategoryManager.delete(category.id),
        addPageBuilder: () => SaveBaitCategoryPage(),
        editPageBuilder: (category) => SaveBaitCategoryPage.edit(category),
      ),
    );
  }
}