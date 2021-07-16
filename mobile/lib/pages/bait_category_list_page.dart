import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_bait_category_page.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';

class BaitCategoryListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<BaitCategory>? pickerSettings;

  BaitCategoryListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);

    return ManageableListPage<BaitCategory>(
      titleBuilder: (categories) => Text(
        format(
            Strings.of(context).baitCategoryListPageTitle, [categories.length]),
      ),
      itemBuilder: (context, category) => ManageableListPageItemModel(
        child: Text(category.name, style: stylePrimary(context)),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).baitCategoryListPageSearchHint,
      ),
      pickerSettings: pickerSettings?.copyWith(
        title: Text(Strings.of(context).pickerTitleBaitCategory),
      ),
      itemManager: ManageableListPageItemManager<BaitCategory>(
        listenerManagers: [baitCategoryManager],
        loadItems: (query) =>
            baitCategoryManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: CustomIcons.baitCategories,
          title: Strings.of(context).baitCategoryListPageEmptyListTitle,
          description:
              Strings.of(context).baitCategoryListPageEmptyListDescription,
        ),
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
