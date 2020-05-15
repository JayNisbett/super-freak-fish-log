import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';

class SpeciesListPage extends StatelessWidget {
  final bool Function(BuildContext, Species) onPicked;

  SpeciesListPage.picker({
    this.onPicked,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    SpeciesManager speciesManager = SpeciesManager.of(context);
    List<Species> species = speciesManager.entityList;

    return EntityListenerBuilder<Species>(
      manager: speciesManager,
      builder: (context) => ManageableListPage<Species>(
        title: _picking
            ? Text(Strings.of(context).speciesListPagePickerTitle)
            : Text(Strings.of(context).speciesListPageTitle),
        itemCount: species.length,
        itemBuilder: (context, i) => ManageableListPageItemModel(
          child: Text(species[i].name),
          value: species[i],
        ),
        searchSettings: ManageableListPageSearchSettings(
          hint: Strings.of(context).speciesListPageSearchHint,
          onStart: () {
            // TODO
          },
        ),
        pickerSettings: _picking
            ? ManageableListPageSinglePickerSettings<Species>(
                onPicked: onPicked,
              )
            : null,
        itemManager: ManageableListPageItemManager(
          deleteText: (context, species) => InsertedBoldText(
            text: Strings.of(context).speciesListPageConfirmDelete,
            args: [species.name],
          ),
          deleteItem: (context, species) async {
            if (!await speciesManager.delete(species)) {
              showErrorDialog(
                context: context,
                description: Text(format(Strings.of(context)
                    .speciesListPageCatchDeleteError, [species.name])),
              );
            }
          },
          addPageBuilder: () => SaveSpeciesPage(),
          editPageBuilder: (species) => SaveSpeciesPage.edit(species),
        ),
      ),
    );
  }
}