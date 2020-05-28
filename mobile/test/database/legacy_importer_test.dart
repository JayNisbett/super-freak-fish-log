import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}
class MockImageManager extends Mock implements ImageManager {}

void main() {
  AppManager appManager;
  BaitCategoryManager baitCategoryManager;
  BaitManager baitManager;
  CatchManager catchManager;
  DataManager dataManager;
  FishingSpotManager fishingSpotManager;
  ImageManager imageManager;
  SpeciesManager speciesManager;

  setUp(() {
    appManager = MockAppManager();

    dataManager = MockDataManager();
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.dataManager).thenReturn(dataManager);

    imageManager = MockImageManager();
    when(imageManager.save(any, any)).thenAnswer((_) => Future.value());
    when(appManager.imageManager).thenReturn(imageManager);

    baitCategoryManager = BaitCategoryManager(appManager);
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    catchManager = CatchManager(appManager);
    when(appManager.catchManager).thenReturn(catchManager);

    speciesManager = SpeciesManager(appManager);
    when(appManager.speciesManager).thenReturn(speciesManager);
  });

  group("Error cases", () {
    test("Missing journal key", () async {
      LegacyImporter(appManager, Map()).start()
          .catchError(expectAsync1((error) {
            expect(error, equals(LegacyImporterError.missingJournal));
          }));
    });

    test("Missing userDefines key", () async {
      var json = {
        "journal": {
        }
      };

      LegacyImporter(appManager, json).start().catchError(expectAsync1((error) {
        expect(error, equals(LegacyImporterError.missingUserDefines));
      }));
    });
  });

  test("Import legacy iOS", () async {
    File file = File("test/resources/backups/legacy_ios_real.json");
    var json = jsonDecode(file.readAsStringSync());

    await LegacyImporter(appManager, json).start();

    // Bait categories were never added to Anglers' Log iOS, so none should
    // be added here.
    expect(baitCategoryManager.entityCount, 0);
    expect(baitManager.entityCount, 87);
    expect(catchManager.entityCount, 167);
    expect(fishingSpotManager.entityCount, 94);
    expect(speciesManager.entityCount, 28);
  });

  test("Import legacy Android", () async {
    File file = File("test/resources/backups/legacy_android_real.json");
    var json = jsonDecode(file.readAsStringSync());

    await LegacyImporter(appManager, json).start();

    expect(baitCategoryManager.entityCount, 3);
    expect(baitManager.entityCount, 72);
    expect(catchManager.entityCount, 133);
    expect(fishingSpotManager.entityCount, 75);
    expect(speciesManager.entityCount, 26);
  });

  test("Empty user defines", () async {
    File file = File("test/resources/backups/legacy_empty_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();
    expect(baitCategoryManager.entityCount, 0);
    expect(baitManager.entityCount, 0);
    expect(catchManager.entityCount, 0);
    expect(fishingSpotManager.entityCount, 0);
    expect(speciesManager.entityCount, 0);
  });

  testWidgets("Import iOS catches", (WidgetTester tester) async {
    File file = File("test/resources/backups/legacy_ios_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<Catch> catches;
    await tester.pumpWidget(Testable((context) {
      catches = catchManager.catchesSortedByTimestamp(context);
      return Empty();
    }));

    expect(catches, isNotNull);
    expect(catches.length, 4);

    expect(catches[0].dateTime, DateTime(2019, 8, 13, 0, 44));
    expect(catches[0].speciesId, isNotEmpty);
    expect(speciesManager.entity(id: catches[0].speciesId).name,
        "Carp - Common");
    expect(catches[0].baitId, isNotEmpty);
    expect(baitManager.entity(id: catches[0].baitId).name, "Corn");
    expect(catches[0].fishingSpotId, isNotEmpty);
    expect(fishingSpotManager.entity(id: catches[0].fishingSpotId).name,
        "Tennessee River - Sequoyah Hills Park");

    expect(catches[1].dateTime, DateTime(2019, 8, 12, 12, 44));
    expect(catches[2].dateTime, DateTime(2019, 8, 11, 8, 44));
    expect(catches[3].dateTime, DateTime(2019, 8, 10, 20, 44));
  });

  test("Import iOS locations", () async {
    File file = File("test/resources/backups/legacy_ios_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<FishingSpot> fishingSpots = fishingSpotManager.entityList;
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Tennessee River - Sequoyah Hills Park");
    expect(fishingSpots.first.lat, 35.928575);
    expect(fishingSpots.first.lng, -83.974535);
  });

  test("Import iOS baits", () async {
    File file = File("test/resources/backups/legacy_ios_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<Bait> baits = baitManager.entityList;
    expect(baits, isNotNull);
    expect(baits.length, 1);
    expect(baits.first.name, "Corn");
    expect(baits.first.hasCategory, false);
  });

  test("Import iOS species", () async {
    File file = File("test/resources/backups/legacy_ios_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<Species> species = speciesManager.entityList;
    expect(species, isNotNull);
    expect(species.length, 1);
    expect(species.first.name, "Carp - Common");
  });

  test("Import Android catches", () async {
    File file = File("test/resources/backups/legacy_android_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<Catch> catches = catchManager.entityList;
    expect(catches, isNotNull);
    expect(catches.length, 1);

    expect(catches.first.dateTime, DateTime(2017, 10, 11, 17, 19, 19, 420));
    expect(catches.first.speciesId, isNotEmpty);
    expect(speciesManager.entity(id: catches[0].speciesId).name,
        "Trout - Rainbow");
    expect(catches.first.baitId, isNotEmpty);
    expect(baitManager.entity(id: catches[0].baitId).name,
        "Rapala F-7 - Brown Trout");
    expect(catches.first.fishingSpotId, isNotEmpty);
    expect(fishingSpotManager.entity(id: catches[0].fishingSpotId).name,
        "Bow River - Sewer Run");
  });

  test("Import Android locations", () async {
    File file = File("test/resources/backups/legacy_android_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<FishingSpot> fishingSpots = fishingSpotManager.entityList;
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Bow River - Sewer Run");
    expect(fishingSpots.first.lat, 50.943077);
    expect(fishingSpots.first.lng, -114.013481);
  });

  test("Import Android baits", () async {
    File file = File("test/resources/backups/legacy_android_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<Bait> baits = baitManager.entityListSortedByName();
    expect(baits, isNotNull);
    expect(baits.length, 2);

    expect(baits[0].name, "Rapala F-7 - Brown Trout");
    expect(baits[0].hasCategory, true);
    expect(baitCategoryManager.entity(id: baits[0].categoryId).name,
        "Other");

    expect(baits[1].name, "Z-Man");
    expect(baits[1].hasCategory, false);
  });

  test("Import Android species", () async {
    File file = File("test/resources/backups/legacy_android_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<Species> species = speciesManager.entityList;
    expect(species, isNotNull);
    expect(species.length, 1);
    expect(species.first.name, "Trout - Rainbow");
  });

  test("Import Android bait categories", () async {
    File file = File("test/resources/backups/legacy_android_entities.json");
    var json = jsonDecode(file.readAsStringSync());
    await LegacyImporter(appManager, json).start();

    List<BaitCategory> categories = baitCategoryManager.entityList;
    expect(categories, isNotNull);
    expect(categories.length, 1);
    expect(categories.first.id, "b860cddd-dc47-48a2-8d02-c8112a2ed5eb");
    expect(categories.first.name, "Other");
  });
}