import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/add_catch_journey.dart';
import '../pages/catch_page.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_catch_page.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/photo.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class CatchListPage extends StatelessWidget {
  /// If false, catches cannot be added. Defaults to true.
  final bool enableAdding;

  /// If not-null, shows only the catches within [dateRange].
  final DateRange dateRange;

  /// If set, shows only the catches whose ID is included in [catchIds].
  final Set<Id> catchIds;

  /// If set, shows only the catches whose species is included in [speciesIds].
  final Set<Id> speciesIds;

  /// If set, shows only the catches whose fishingSpot is included in
  /// [fishingSpotIds].
  final Set<Id> fishingSpotIds;

  /// If set, shows only the catches whose bait is included in [baitIds].
  final Set<Id> baitIds;

  bool get filtered =>
      dateRange != null ||
      catchIds.isNotEmpty ||
      speciesIds.isNotEmpty ||
      fishingSpotIds.isNotEmpty ||
      baitIds.isNotEmpty;

  CatchListPage({
    this.enableAdding = true,
    this.dateRange,
    this.catchIds = const {},
    this.baitIds = const {},
    this.fishingSpotIds = const {},
    this.speciesIds = const {},
  })  : assert(enableAdding != null),
        assert(catchIds != null),
        assert(baitIds != null),
        assert(fishingSpotIds != null),
        assert(speciesIds != null);

  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);
    var baitManager = BaitManager.of(context);
    var catchManager = CatchManager.of(context);
    var fishingSpotManager = FishingSpotManager.of(context);
    var speciesManager = SpeciesManager.of(context);

    return ManageableListPage<Catch>(
      titleBuilder: (catches) => Text(
        format(Strings.of(context).catchListPageTitle, [catches.length]),
      ),
      forceCenterTitle: true,
      searchDelegate: ListPageSearchDelegate(
        hint: Strings.of(context).catchListPageSearchHint,
        noResultsMessage: Strings.of(context).catchListPageNoSearchResults,
      ),
      itemBuilder: _buildListItem,
      itemsHaveThumbnail: true,
      itemManager: ManageableListPageItemManager<Catch>(
        listenerManagers: [
          baitCategoryManager,
          baitManager,
          catchManager,
          fishingSpotManager,
          speciesManager,
        ],
        loadItems: (query) => catchManager.catchesSortedByTimestamp(
          context,
          filter: query,
          dateRange: dateRange,
          catchIds: catchIds,
          speciesIds: speciesIds,
          fishingSpotIds: fishingSpotIds,
          baitIds: baitIds,
        ),
        deleteWidget: (context, cat) =>
            Text(catchManager.deleteMessage(context, cat)),
        deleteItem: (context, cat) => catchManager.delete(cat.id),
        addPageBuilder: enableAdding ? () => AddCatchJourney() : null,
        detailPageBuilder: (cat) => CatchPage(cat.id),
        editPageBuilder: (cat) => SaveCatchPage.edit(cat),
      ),
    );
  }

  ManageableListPageItemModel _buildListItem(BuildContext context, Catch cat) {
    var baitManager = BaitManager.of(context);
    var fishingSpotManager = FishingSpotManager.of(context);
    var speciesManager = SpeciesManager.of(context);

    Widget subtitle2 = Empty();

    var fishingSpot = fishingSpotManager.entity(cat.fishingSpotId);
    if (fishingSpot != null && isNotEmpty(fishingSpot.name)) {
      // Use fishing spot name as subtitle if available.
      subtitle2 = SubtitleLabel(fishingSpot.name);
    } else {
      // Fallback on bait as a subtitle.
      var bait = baitManager.entity(cat.baitId);
      if (bait != null) {
        subtitle2 = SubtitleLabel(baitManager.formatNameWithCategory(bait));
      }
    }

    return ManageableListPageItemModel(
      child: Row(
        children: [
          Photo.listThumbnail(
            cat.imageNames.isNotEmpty ? cat.imageNames.first : null,
          ),
          Container(width: paddingWidget),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryLabel(speciesManager.entity(cat.speciesId).name),
                SubtitleLabel(formatTimestamp(context, cat.timestamp)),
                subtitle2,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
