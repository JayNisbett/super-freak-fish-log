import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../trip_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_item.dart';
import 'save_trip_page.dart';
import 'trip_page.dart';

class TripListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var tripManager = TripManager.of(context);

    return ManageableListPage<Trip>(
      titleBuilder: (trips) => Text(
        format(Strings.of(context).tripListPageTitle, [trips.length]),
      ),
      forceCenterTitle: true,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).tripListPageSearchHint,
      ),
      itemBuilder: (context, trip) =>
          _buildListItem(context, tripManager, trip),
      itemsHaveThumbnail: true,
      itemManager: ManageableListPageItemManager<Trip>(
        listenerManagers: [
          tripManager,
        ],
        loadItems: (query) => tripManager.listSortedByName(filter: query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.public,
          title: Strings.of(context).tripListPageEmptyListTitle,
          description: Strings.of(context).tripListPageEmptyListDescription,
        ),
        deleteWidget: (context, trip) =>
            Text(tripManager.deleteMessage(context, trip)),
        deleteItem: (context, cat) => tripManager.delete(cat.id),
        addPageBuilder: () => const SaveTripPage(),
        detailPageBuilder: (trip) => TripPage(trip),
        editPageBuilder: (trip) => SaveTripPage.edit(trip),
      ),
    );
  }

  ManageableListPageItemModel _buildListItem(
      BuildContext context, TripManager tripManager, Trip trip) {
    var date = trip.elapsedDisplayValue(context);

    String? title;
    String? subtitle;
    if (isNotEmpty(trip.name)) {
      title = trip.name;
      subtitle = date;
    } else {
      title = date;
    }

    var images = tripManager.allImageNames(trip);

    var numberOfCatches = tripManager.numberOfCatches(trip);
    var subtitle2 = formatNumberOfCatches(context, numberOfCatches);
    var subtitle2Style = styleSuccess;
    if (numberOfCatches <= 0) {
      subtitle2 = Strings.of(context).tripSkunked;
      subtitle2Style = styleError;
    }

    return ManageableListPageItemModel(
      child: ManageableListImageItem(
        imageName: images.isNotEmpty ? images.first : null,
        title: title,
        subtitle: subtitle,
        subtitle2: subtitle2,
        subtitle2Style: subtitle2Style,
      ),
    );
  }
}
