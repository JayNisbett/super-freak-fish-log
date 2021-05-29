import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../mocks/mocks.mocks.dart';
import '../test_utils.dart';

void main() {
  group("Id", () {
    test("Invalid input", () {
      expect(() => parseId(""), throwsAssertionError);
      expect(() => parseId("zzz"), throwsFormatException);
      expect(() => parseId("b860cddd-dc47-48a2-8d02-c8112a2ed5eb"), isNotNull);
      expect(randomId(), isNotNull);
    });

    /// Tests that the [Id] object can be used as a key in a [Map]. No matter
    /// the structure of [Id], it needs to be equatable.
    test("Id used in Map", () {
      var uuid0 = randomId().uuid;
      var uuid1 = randomId().uuid;
      var uuid2 = randomId().uuid;

      var map = <Id, int>{
        Id()..uuid = uuid0: 5,
        Id()..uuid = uuid1: 10,
        Id()..uuid = uuid2: 15,
      };

      expect(map[Id()..uuid = String.fromCharCodes(uuid0.codeUnits)], 5);
      expect(map[Id()..uuid = String.fromCharCodes(uuid1.codeUnits)], 10);
      expect(map[Id()..uuid = String.fromCharCodes(uuid2.codeUnits)], 15);
      expect(map[randomId()], isNull);
    });
  });

  group("entityValuesCount", () {
    test("Empty entities", () {
      expect(entityValuesCount<Catch>([], randomId(), (_) => []), 0);
    });

    test("Empty getValues", () {
      expect(
        entityValuesCount<Catch>(
            [Catch()..id = randomId()], randomId(), (_) => []),
        0,
      );
    });

    test("0 count", () {
      var cat = Catch()..id = randomId();
      cat.customEntityValues
          .add(CustomEntityValue()..customEntityId = randomId());
      expect(
        entityValuesCount<Catch>(
            [cat], randomId(), (cat) => cat.customEntityValues),
        0,
      );
    });

    test("Greater than 0 count", () {
      var cat = Catch()..id = randomId();

      var customId1 = randomId();
      var customId2 = randomId();
      cat.customEntityValues
        ..add(CustomEntityValue()..customEntityId = customId1)
        ..add(CustomEntityValue()..customEntityId = customId2);

      expect(
        entityValuesCount<Catch>(
            [cat], randomId(), (cat) => cat.customEntityValues),
        0,
      );
      expect(
        entityValuesCount<Catch>(
            [cat], customId1, (cat) => cat.customEntityValues),
        1,
      );
      expect(
        entityValuesCount<Catch>(
            [cat], customId2, (cat) => cat.customEntityValues),
        1,
      );
    });
  });

  group("entityValuesMatchesFilter", () {
    var customEntityManager = MockCustomEntityManager();
    when(customEntityManager.matchesFilter(any, any)).thenReturn(false);

    test("Empty or null filter", () {
      expect(filterMatchesEntityValues([], "", customEntityManager), isTrue);
      expect(filterMatchesEntityValues([], null, customEntityManager), isTrue);
    });

    test("Empty values", () {
      expect(filterMatchesEntityValues([], "Filter", customEntityManager),
          isFalse);
    });

    test("Null values", () {
      expect(
        filterMatchesEntityValues(
            [CustomEntityValue()..value = ""], "Filter", customEntityManager),
        isFalse,
      );
    });

    test("Values value matches filter", () {
      expect(
        filterMatchesEntityValues(
            [CustomEntityValue()..value = "A filter value"],
            "Filter",
            customEntityManager),
        isTrue,
      );
    });
  });

  group("entityValuesFromMap", () {
    test("Input", () {
      expect(entityValuesFromMap({}), []);
      expect(entityValuesFromMap(null), []);
    });

    test("Parse values", () {
      var id1 = randomId();
      var id2 = randomId();
      var id3 = randomId();

      expect(
        entityValuesFromMap({
          randomId(): null,
          randomId(): "",
          id1: "Value 1",
          id2: "Value 2",
          id3: "Value 3",
        }),
        [
          CustomEntityValue()
            ..customEntityId = id1
            ..value = "Value 1",
          CustomEntityValue()
            ..customEntityId = id2
            ..value = "Value 2",
          CustomEntityValue()
            ..customEntityId = id3
            ..value = "Value 3",
        ],
      );
    });
  });

  group("valueForCustomEntityType", () {
    test("Number", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.number, CustomEntityValue()..value = "50"),
        "50",
      );
    });

    test("Text", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.text, CustomEntityValue()..value = "50"),
        "50",
      );
    });

    test("Bool without context", () {
      expect(
        valueForCustomEntityType(
            CustomEntity_Type.boolean, CustomEntityValue()..value = "1"),
        isTrue,
      );
    });

    testWidgets("Bool with context", (tester) async {
      expect(
        valueForCustomEntityType(CustomEntity_Type.boolean,
            CustomEntityValue()..value = "1", await buildContext(tester)),
        "Yes",
      );
      expect(
        valueForCustomEntityType(CustomEntity_Type.boolean,
            CustomEntityValue()..value = "0", await buildContext(tester)),
        "No",
      );
    });
  });

  group("Collections entity ID or object", () {
    test("Non-GeneratedMessage item calls List.indexOf", () {
      expect(indexOfEntityIdOrOther(["String", 12, 15.4], 12), 1);
      expect(containsEntityIdOrOther(["String", 12, 15.4], 12), isTrue);
    });

    test("Non-GeneratedMessage list items with GeneratedMessage item", () {
      expect(indexOfEntityIdOrOther(["String", 12, Catch()], Catch()), 2);
      expect(containsEntityIdOrOther(["String", 12, 15.4], Catch()), isFalse);
    });

    test("ID is found", () {
      var cat = Catch()..id = randomId();
      expect(indexOfEntityIdOrOther([cat, 12, Catch()], cat), 0);
      expect(containsEntityIdOrOther(["String", 12, cat], cat), isTrue);
    });
  });

  group("parseId", () {
    test("Input", () {
      expect(() => parseId(""), throwsAssertionError);
    });

    test("Bad UUID string", () {
      expect(() => parseId("XYZ"), throwsFormatException);
    });

    test("Good UUID string", () {
      var id = parseId(Uuid().v1());
      expect(id, isNotNull);
      expect(id.uuid, isNotEmpty);
    });
  });

  group("FishingSpots", () {
    testWidgets("Spot with name", (tester) async {
      expect(
        (FishingSpot()
              ..id = randomId()
              ..name = "Test Name"
              ..lat = 0.0
              ..lng = 0.0)
            .displayName(await buildContext(tester)),
        "Test Name",
      );
    });

    testWidgets("Spot without name", (tester) async {
      expect(
        (FishingSpot()
              ..id = randomId()
              ..lat = 0.0
              ..lng = 0.0)
            .displayName(await buildContext(tester)),
        "Lat: 0.000000, Lng: 0.000000",
      );
    });
  });

  group("Measurements", () {
    testWidgets("displayValue without units", (tester) async {
      var context = await buildContext(tester);
      var measurement = Measurement(value: 10);
      expect(measurement.displayValue(context), "10");
    });

    testWidgets("displayValue with units", (tester) async {
      var context = await buildContext(tester);

      // With space between value and unit.
      var measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      expect(measurement.displayValue(context), "10 lbs");

      // Without space between value and unit.
      measurement = Measurement(
        unit: Unit.fahrenheit,
        value: 10,
      );
      expect(measurement.displayValue(context), "10\u00B0F");
    });

    test("stringValue", () {
      // Whole number.
      var measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      expect(measurement.stringValue, "10");

      // Floating number.
      measurement = Measurement(
        unit: Unit.pounds,
        value: 10.5,
      );
      expect(measurement.stringValue, "10.5");

      // Whole floating number.
      measurement = Measurement(
        unit: Unit.pounds,
        value: 10.0,
      );
      expect(measurement.stringValue, "10");
    });

    test("toSystem", () {
      // No change in system.
      var measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      expect(
          measurement, measurement.toSystem(MeasurementSystem.imperial_whole));

      // Change system.
      measurement = Measurement(
        unit: Unit.pounds,
        value: 10,
      ).toSystem(MeasurementSystem.metric);
      expect(measurement.unit, Unit.kilograms);
      expect(measurement.value, 10);
    });

    test("Comparing different units returns false", () {
      var pounds = Measurement(
        unit: Unit.pounds,
        value: 10,
      );
      var kilograms = Measurement(
        unit: Unit.kilograms,
        value: 5,
      );

      expect(kilograms < pounds, isFalse);
      expect(kilograms <= pounds, isFalse);
      expect(pounds > kilograms, isFalse);
      expect(pounds >= kilograms, isFalse);
    });

    test("Comparing same units returns correct result", () {
      var pounds = Measurement(
        unit: Unit.kilograms,
        value: 10,
      );
      var kilograms = Measurement(
        unit: Unit.kilograms,
        value: 5,
      );

      expect(kilograms < pounds, isTrue);
      expect(kilograms <= pounds, isTrue);
      expect(pounds > kilograms, isTrue);
      expect(pounds >= kilograms, isTrue);
    });
  });

  group("MultiMeasurements", () {
    testWidgets("displayValue for inches", (tester) async {
      var context = await buildContext(tester);

      // No fraction.
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10,
        ),
      );
      expect(measurement.displayValue(context), "10 in");

      // Fraction.
      measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10,
        ),
        fractionValue: Measurement(
          value: 0.5,
        ),
      );
      expect(measurement.displayValue(context), "10 \u00BD in");

      // Fraction without unit.
      measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10,
        ),
        fractionValue: Measurement(
          value: 0.5,
        ),
      );
      expect(measurement.displayValue(context), "10 \u00BD in");
    });

    testWidgets("displayValue general", (tester) async {
      var context = await buildContext(tester);

      // No fraction.
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
      );
      expect(measurement.displayValue(context), "10 ft");

      // Fraction.
      measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      expect(measurement.displayValue(context), "10 lbs 8 oz");
    });

    test("toSystem", () {
      // No change in system.
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 5,
        ),
      );
      expect(
          measurement, measurement.toSystem(MeasurementSystem.imperial_whole));

      // Change system.
      measurement = measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 5,
        ),
      ).toSystem(MeasurementSystem.metric);
      expect(measurement.system, MeasurementSystem.metric);
      expect(measurement.mainValue.unit, Unit.meters);
      expect(measurement.mainValue.value, 10);
      expect(measurement.fractionValue.unit, Unit.centimeters);
      expect(measurement.fractionValue.value, 5);
    });

    test("Comparing equals", () {
      var measurement = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
      );
      expect(measurement < measurement, isFalse);
      expect(measurement <= measurement, isTrue);
      expect(measurement > measurement, isFalse);
      expect(measurement >= measurement, isTrue);
    });

    test("Comparing different systems always returns false", () {
      var metric = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      );
      var imperial = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
      );
      expect(metric < imperial, isFalse);
      expect(metric <= imperial, isFalse);
      expect(metric > imperial, isFalse);
      expect(metric >= imperial, isFalse);
    });

    test("Imperial whole and imperial decimal are still comparable", () {
      // Equals.
      var whole = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      var decimal = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10.5,
        ),
      );
      expect(whole < decimal, isFalse);
      expect(whole <= decimal, isTrue);
      expect(whole > decimal, isFalse);
      expect(whole >= decimal, isTrue);

      // Left hand side is smaller.
      whole = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 5,
        ),
      );
      decimal = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 10.5,
        ),
      );
      expect(whole < decimal, isTrue);
      expect(whole <= decimal, isTrue);
      expect(whole > decimal, isFalse);
      expect(whole >= decimal, isFalse);

      // Right hand side is smaller.
      whole = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      decimal = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10.25,
        ),
      );
      expect(whole < decimal, isFalse);
      expect(whole <= decimal, isFalse);
      expect(whole > decimal, isTrue);
      expect(whole >= decimal, isTrue);
    });

    test("Comparing main values", () {
      var ten = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      );
      var fifteen = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 15,
        ),
      );
      expect(ten < fifteen, isTrue);
      expect(ten <= fifteen, isTrue);
      expect(ten > fifteen, isFalse);
      expect(ten >= fifteen, isFalse);
    });

    test("Comparing fraction values when mains are equal", () {
      var smaller = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 5,
        ),
      );
      var larger = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 10,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 8,
        ),
      );
      expect(smaller < larger, isTrue);
      expect(smaller <= larger, isTrue);
      expect(smaller > larger, isFalse);
      expect(smaller >= larger, isFalse);
    });
  });

  group("NumberFilters", () {
    test("isSet", () {
      // No boundary.
      var filter = NumberFilter();
      expect(filter.isSet, isFalse);

      // Neither from or to is set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
      );
      expect(filter.isSet, isFalse);

      // Just from set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.isSet, isTrue);

      // Just to set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.isSet, isTrue);

      // Both set.
      filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.isSet, isTrue);
    });

    testWidgets("Any displayValue", (tester) async {
      var filter = NumberFilter(
        boundary: NumberBoundary.number_boundary_any,
      );
      expect(filter.displayValue(await buildContext(tester)), "Any");
    });

    testWidgets("Signed displayValue", (tester) async {
      var filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.displayValue(await buildContext(tester)), "> 10");
    });

    testWidgets("Range displayValue", (tester) async {
      // Both from and to set.
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        ),
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(filter.displayValue(await buildContext(tester)), "5 - 10");

      // Only one set.
      filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        ),
      );
      expect(filter.displayValue(await buildContext(tester)), "Any");
    });

    testWidgets("Invalid start value in displayValue", (tester) async {
      var filter = NumberFilter(
        boundary: NumberBoundary.greater_than,
      );
      expect(filter.displayValue(await buildContext(tester)), "Any");
    });

    test("Range containsMultiMeasurement", () {
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        ),
        to: MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        ),
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 5,
          ),
        )),
        isTrue,
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 10,
          ),
        )),
        isTrue,
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 8,
          ),
        )),
        isTrue,
      );
      expect(
        filter.containsMultiMeasurement(MultiMeasurement(
          mainValue: Measurement(
            value: 13,
          ),
        )),
        isFalse,
      );
    });

    test("containsMeasurement", () {
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 5,
          ),
        ),
        to: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 10,
          ),
        ),
      );
      expect(filter.containsMeasurement(Measurement(value: 13)), isFalse);
    });

    test("containsInt", () {
      var filter = NumberFilter(
        boundary: NumberBoundary.range,
        from: MultiMeasurement(mainValue: Measurement(value: 5)),
        to: MultiMeasurement(mainValue: Measurement(value: 10)),
      );
      expect(filter.containsInt(5), isTrue);
      expect(filter.containsInt(10), isTrue);
      expect(filter.containsInt(8), isTrue);
      expect(filter.containsInt(13), isFalse);
    });
  });
}
