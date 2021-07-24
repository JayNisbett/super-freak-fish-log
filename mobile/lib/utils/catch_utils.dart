import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/image_picker_page.dart';
import '../time_manager.dart';
import '../widgets/field.dart';
import '../widgets/input_controller.dart';
import '../widgets/multi_measurement_input.dart';
import 'date_time_utils.dart';
import 'protobuf_utils.dart';
import 'string_utils.dart';

// Unique IDs for each catch field. These are stored in the database and
// should not be changed.
final catchFieldIdAngler = Id()..uuid = "d1568a03-c34f-4840-b032-b0b3077847d3";
final catchFieldIdBait = Id()..uuid = "916e26ae-9448-4cef-b518-cfe4b4c1e5e8";
final catchFieldIdPeriod = Id()..uuid = "5ad83f1a-cc8f-48c4-a5bb-5394abd2e1f8";
final catchFieldIdFishingSpot = Id()
  ..uuid = "2e4e6124-6fc8-4a60-b8f3-b42debd97a99";
final catchFieldIdImages = Id()..uuid = "cb268ed0-59e2-469e-9279-a74e15ff42e8";
final catchFieldIdMethods = Id()..uuid = "b494335f-a9fb-4c1b-b4ec-40658645ef12";
final catchFieldIdSpecies = Id()..uuid = "7c4a5178-4e3b-4b97-ac69-b4a5439c4d94";
final catchFieldIdTimestamp = Id()
  ..uuid = "dbe382be-b219-4703-af11-a8ce16a191b7";
final catchFieldIdFavorite = Id()
  ..uuid = "a12f6861-475f-475a-af29-c4fc6fe0a0bc";
final catchFieldIdCatchAndRelease = Id()
  ..uuid = "075fc6d5-b9b4-4377-b87d-a706287e1ffc";
final catchFieldIdSeason = Id()..uuid = "a2b00262-d130-45ce-b30b-f6e4f2d5baf5";
final catchFieldIdWaterClarity = Id()
  ..uuid = "ca035b3d-323c-44a6-a112-bede7177aeb2";
final catchFieldIdWaterDepth = Id()
  ..uuid = "c8a58e5f-19a1-430e-9d84-5a7b1bb96c3a";
final catchFieldIdWaterTemperature = Id()
  ..uuid = "eb66a49b-4add-43e1-b057-e95a5854fad8";
final catchFieldIdLength = Id()..uuid = "03ff0695-e160-4446-8f93-ba86d1ad1095";
final catchFieldIdWeight = Id()..uuid = "ca5e1447-7aa4-4508-870c-ce8dcd1d656e";
final catchFieldIdQuantity = Id()
  ..uuid = "8ed48dab-b5c3-4430-a702-aa336aea0f5a";
final catchFieldIdNotes = Id()..uuid = "a5ad6270-e131-40ad-b281-e1a4d838bf47";
final catchFieldIdAtmosphere = Id()
  ..uuid = "93f2a6bc-fb18-43a1-92c1-18c727440257";
final catchFieldIdTide = Id()..uuid = "5443a6ba-1860-4818-8b15-a6125121f451";

/// Returns all catch fields, sorted by how they are rendered on a
/// [SaveCatchPage].
List<Field> allCatchFields(BuildContext context) {
  return [
    Field(
      id: catchFieldIdTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).catchFieldDateTime,
      controller: TimestampInputController(TimeManager.of(context)),
    ),
    Field(
      id: catchFieldIdPeriod,
      name: (context) => Strings.of(context).catchFieldPeriod,
      description: (context) => Strings.of(context).catchFieldPeriodDescription,
      controller: InputController<Period>(),
    ),
    Field(
      id: catchFieldIdSeason,
      name: (context) => Strings.of(context).catchFieldSeason,
      description: (context) => Strings.of(context).catchFieldSeasonDescription,
      controller: InputController<Season>(),
    ),
    Field(
      id: catchFieldIdSpecies,
      isRemovable: false,
      name: (context) => Strings.of(context).catchFieldSpecies,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdBait,
      name: (context) => Strings.of(context).catchFieldBaitLabel,
      controller: SetInputController<Id>(),
    ),
    Field(
      id: catchFieldIdImages,
      name: (context) => Strings.of(context).catchFieldImages,
      controller: ListInputController<PickedImage>(),
    ),
    Field(
      id: catchFieldIdFishingSpot,
      name: (context) => Strings.of(context).catchFieldFishingSpot,
      description: (context) =>
          Strings.of(context).catchFieldFishingSpotDescription,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdAngler,
      name: (context) => Strings.of(context).catchFieldAnglerLabel,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdCatchAndRelease,
      name: (context) => Strings.of(context).catchFieldCatchAndRelease,
      description: (context) =>
          Strings.of(context).catchFieldCatchAndReleaseDescription,
      controller: BoolInputController(),
    ),
    Field(
      id: catchFieldIdFavorite,
      name: (context) => Strings.of(context).catchFieldFavorite,
      controller: BoolInputController(),
    ),
    Field(
      id: catchFieldIdMethods,
      name: (context) => Strings.of(context).catchFieldMethodsLabel,
      description: (context) =>
          Strings.of(context).catchFieldMethodsDescription,
      controller: SetInputController<Id>(),
    ),
    Field(
      id: catchFieldIdAtmosphere,
      name: (context) => Strings.of(context).catchFieldAtmosphere,
      controller: InputController<Atmosphere>(),
    ),
    Field(
      id: catchFieldIdTide,
      name: (context) => Strings.of(context).catchFieldTide,
      controller: InputController<Tide>(),
    ),
    Field(
      id: catchFieldIdWaterClarity,
      name: (context) => Strings.of(context).catchFieldWaterClarityLabel,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdWaterDepth,
      name: (context) => Strings.of(context).catchFieldWaterDepthLabel,
      controller:
          MultiMeasurementInputSpec.waterDepth(context).newInputController(),
    ),
    Field(
      id: catchFieldIdWaterTemperature,
      name: (context) => Strings.of(context).catchFieldWaterTemperatureLabel,
      controller: MultiMeasurementInputSpec.waterTemperature(context)
          .newInputController(),
    ),
    Field(
      id: catchFieldIdLength,
      name: (context) => Strings.of(context).catchFieldLengthLabel,
      controller:
          MultiMeasurementInputSpec.length(context).newInputController(),
    ),
    Field(
      id: catchFieldIdWeight,
      name: (context) => Strings.of(context).catchFieldWeightLabel,
      controller:
          MultiMeasurementInputSpec.weight(context).newInputController(),
    ),
    Field(
      id: catchFieldIdQuantity,
      name: (context) => Strings.of(context).catchFieldQuantityLabel,
      description: (context) =>
          Strings.of(context).catchFieldQuantityDescription,
      controller: NumberInputController(),
    ),
    Field(
      id: catchFieldIdNotes,
      name: (context) => Strings.of(context).catchFieldNotesLabel,
      controller: TextInputController(),
    ),
  ];
}

/// Returns all catch fields sorted alphabetically.
List<Field> allCatchFieldsSorted(BuildContext context) {
  var fields = allCatchFields(context);
  fields.sort((lhs, rhs) => lhs.name!(context).compareTo(rhs.name!(context)));
  return fields;
}

bool catchFilterMatchesPeriod(BuildContext context, String filter, Catch cat) {
  return cat.hasPeriod() &&
      containsTrimmedLowerCase(cat.period.displayName(context), filter);
}

bool catchFilterMatchesSeason(BuildContext context, String filter, Catch cat) {
  return cat.hasSeason() &&
      containsTrimmedLowerCase(cat.season.displayName(context), filter);
}

bool catchFilterMatchesFavorite(
    BuildContext context, String filter, Catch cat) {
  return cat.hasIsFavorite() &&
      cat.isFavorite &&
      containsTrimmedLowerCase(Strings.of(context).keywordsFavorite, filter);
}

bool catchFilterMatchesCatchAndRelease(
    BuildContext context, String filter, Catch cat) {
  return cat.hasWasCatchAndRelease() &&
      cat.wasCatchAndRelease &&
      containsTrimmedLowerCase(
          Strings.of(context).keywordsCatchAndRelease, filter);
}

bool catchFilterMatchesTimestamp(
    BuildContext context, String filter, Catch cat) {
  return cat.hasTimestamp() &&
      containsTrimmedLowerCase(
          timestampToSearchString(context, cat.timestamp.toInt()), filter);
}

bool _catchFilterMatchesMultiMeasurement(BuildContext context,
    MultiMeasurement measurement, bool hasValue, String filter) {
  if (!hasValue) {
    return false;
  }

  var searchString = "${measurement.displayValue(context)} "
      "${measurement.filterString(context)}";

  return containsTrimmedLowerCase(searchString, filter);
}

bool catchFilterMatchesWaterDepth(
    BuildContext context, String filter, Catch cat) {
  return _catchFilterMatchesMultiMeasurement(
      context, cat.waterDepth, cat.hasWaterDepth(), filter);
}

bool catchFilterMatchesWaterTemperature(
    BuildContext context, String filter, Catch cat) {
  return _catchFilterMatchesMultiMeasurement(
      context, cat.waterTemperature, cat.hasWaterTemperature(), filter);
}

bool catchFilterMatchesLength(BuildContext context, String filter, Catch cat) {
  return _catchFilterMatchesMultiMeasurement(
      context, cat.length, cat.hasLength(), filter);
}

bool catchFilterMatchesWeight(BuildContext context, String filter, Catch cat) {
  return _catchFilterMatchesMultiMeasurement(
      context, cat.weight, cat.hasWeight(), filter);
}

bool catchFilterMatchesQuantity(
    BuildContext context, String filter, Catch cat) {
  return cat.hasQuantity() &&
      containsTrimmedLowerCase(cat.quantity.toString(), filter);
}

bool catchFilterMatchesNotes(BuildContext context, String filter, Catch cat) {
  return cat.hasNotes() && containsTrimmedLowerCase(cat.notes, filter);
}

bool catchFilterMatchesAtmosphere(
    BuildContext context, String filter, Catch cat) {
  if (!cat.hasAtmosphere()) {
    return false;
  }

  var atmosphere = cat.atmosphere;
  var searchString = "";

  if (atmosphere.hasTemperature()) {
    searchString += " ${atmosphere.temperature.displayValue(context)}";
    searchString += " ${atmosphere.temperature.filterString(context)}";
  }

  if (atmosphere.hasWindSpeed()) {
    searchString += " ${atmosphere.windSpeed.displayValue(context)}";
    searchString += " ${atmosphere.windSpeed.filterString(context)}";
  }

  if (atmosphere.hasPressure()) {
    searchString += " ${atmosphere.pressure.displayValue(context)}";
    searchString += " ${atmosphere.pressure.filterString(context)}";
  }

  if (atmosphere.hasVisibility()) {
    searchString += " ${atmosphere.visibility.displayValue(context)}";
    searchString += " ${atmosphere.visibility.filterString(context)}";
  }

  if (atmosphere.skyConditions.isNotEmpty) {
    searchString += " ${atmosphere.skyConditions.join(" ")}";
  }

  if (atmosphere.hasWindDirection()) {
    searchString += " ${atmosphere.windDirection.filterString(context)}";
    searchString += " ${Strings.of(context).keywordsWindDirection}";
  }

  if (atmosphere.hasHumidity()) {
    searchString += " ${atmosphere.humidity.filterString(context)}";
    searchString += " ${Strings.of(context).keywordsAirHumidity}";
  }

  if (atmosphere.hasMoonPhase()) {
    searchString += " ${atmosphere.moonPhase.displayName(context)}";
    searchString += " ${Strings.of(context).keywordsMoon}";
  }

  if (atmosphere.hasSunsetTimestamp()) {
    searchString += " ${Strings.of(context).keywordsSunset}";
  }

  if (atmosphere.hasSunriseTimestamp()) {
    searchString += " ${Strings.of(context).keywordsSunrise}";
  }

  return containsTrimmedLowerCase(searchString, filter);
}

bool catchFilterMatchesTide(BuildContext context, String filter, Catch cat) {
  if (!cat.hasTide()) {
    return false;
  }

  var searchString = cat.tide.displayValue(context, useChipName: true);
  return isNotEmpty(searchString) &&
      containsTrimmedLowerCase(searchString!, filter);
}
