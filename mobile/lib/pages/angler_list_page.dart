import 'package:flutter/material.dart';

import '../angler_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import 'save_angler_page.dart';

class AnglerListPage extends StatelessWidget {
  final ManageableListPagePickerSettings<Angler>? pickerSettings;

  AnglerListPage({
    this.pickerSettings,
  });

  @override
  Widget build(BuildContext context) {
    var anglerManager = AnglerManager.of(context);

    return ManageableListPage<Angler>(
      titleBuilder: (anglers) => Text(
        format(Strings.of(context).anglerListPageTitle, [anglers.length]),
      ),
      pickerTitleBuilder: (_) =>
          Text(Strings.of(context).anglerListPagePickerTitle),
      itemBuilder: (context, angler) => ManageableListPageItemModel(
        child: PrimaryLabel(angler.name),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).anglerListPageSearchHint,
      ),
      pickerSettings: pickerSettings,
      itemManager: ManageableListPageItemManager<Angler>(
        listenerManagers: [anglerManager],
        loadItems: (query) => anglerManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.person,
          title: Strings.of(context).anglerListPageEmptyListTitle,
          description: Strings.of(context).anglerListPageEmptyListDescription,
        ),
        deleteWidget: (context, angler) =>
            Text(anglerManager.deleteMessage(context, angler)),
        deleteItem: (context, angler) => anglerManager.delete(angler.id),
        addPageBuilder: () => SaveAnglerPage(),
        editPageBuilder: (angler) => SaveAnglerPage.edit(angler),
      ),
    );
  }
}
