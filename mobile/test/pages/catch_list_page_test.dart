import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);

    when(appManager.catchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baitIds: anyNamed("baitIds"),
    )).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
        ..baitId = randomId(),
    ]);

    when(appManager.speciesManager.entity(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Steelhead");
  });

  testWidgets("Adding disabled", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(
        enableAdding: false,
      ),
      appManager: appManager,
    ));
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Adding enabled", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(
        enableAdding: true,
      ),
      appManager: appManager,
    ));
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("Fishing spot with name used as subtitle", (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot()
      ..id = randomId()
      ..name = "Baskets"
      ..lat = 1.234567
      ..lng = 7.654321);
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(),
      appManager: appManager,
    ));

    expect(find.text("Baskets"), findsOneWidget);
  });

  testWidgets("Null fishing spot uses bait as subtitle", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Roe Bag");
    when(appManager.baitManager.formatNameWithCategory(any))
        .thenReturn("Roe Bag");
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(),
      appManager: appManager,
    ));

    expect(find.text("Roe Bag"), findsOneWidget);
  });

  testWidgets("Fishing spot without name uses bait as subtitle",
      (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot()
      ..id = randomId()
      ..lat = 1.234567
      ..lng = 7.654321);
    when(appManager.baitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Roe Bag");
    when(appManager.baitManager.formatNameWithCategory(any))
        .thenReturn("Roe Bag");
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(),
      appManager: appManager,
    ));

    expect(find.text("Roe Bag"), findsOneWidget);
  });

  testWidgets("No subtitle if bait and fishing spot are null", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(),
      appManager: appManager,
    ));
    // 1 widget for the timestamp subtitle on one row.
    expect(find.byType(SubtitleLabel), findsOneWidget);
  });
}
