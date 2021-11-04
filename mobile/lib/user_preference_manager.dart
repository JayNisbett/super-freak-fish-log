import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'preference_manager.dart';

class UserPreferenceManager extends PreferenceManager {
  static UserPreferenceManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).userPreferenceManager;

  static const _keyAtmosphereFieldIds = "atmosphere_field_ids";
  static const _keyBaitVariantFieldIds = "bait_variant_field_ids";
  static const _keyCatchFieldIds = "catch_field_ids";
  static const _keyTripFieldIds = "trip_field_ids";
  static const _keyCatchLengthSystem = "catch_length_system";
  static const _keyCatchWeightSystem = "catch_weight_system";
  static const _keyWaterDepthSystem = "water_depth_system";
  static const _keyWaterTemperatureSystem = "water_temperature_system";
  static const _keyAirTemperatureSystem = "air_temperature_system";
  static const _keyAirPressureSystem = "air_pressure_system";
  static const _keyAirVisibilitySystem = "air_visibility_system";
  static const _keyWindSpeedSystem = "wind_speed_system";
  static const _keyAutoFetchAtmosphere = "auto_fetch_atmosphere";

  static const _keyRateTimerStartedAt = "rate_timer_started_at";
  static const _keyDidRateApp = "did_rate_app";
  static const _keyDidOnboard = "did_onboard";
  static const _keyIsPro = "is_pro";

  static const _keySelectedReportId = "selected_report_id";

  UserPreferenceManager(AppManager appManager) : super(appManager);

  @override
  String get tableName => "user_preference";

  @override
  String get firestoreDocPath => authManager.firestoreDocPath;

  @override
  bool get enableFirestore => true;

  @override
  bool get shouldUseFirestore => true;

  @override
  void onUpgradeToPro() {
    // Nothing to do. User preferences are always stored on the cloud,
    // regardless of subscription status.
  }

  Future<void> setAtmosphereFieldIds(List<Id> ids) =>
      putIdCollection(_keyAtmosphereFieldIds, ids);

  List<Id> get atmosphereFieldIds => idList(_keyAtmosphereFieldIds);

  Future<void> setBaitVariantFieldIds(List<Id> ids) =>
      putIdCollection(_keyBaitVariantFieldIds, ids);

  List<Id> get baitVariantFieldIds => idList(_keyBaitVariantFieldIds);

  Future<void> setCatchFieldIds(List<Id> ids) =>
      putIdCollection(_keyCatchFieldIds, ids);

  List<Id> get catchFieldIds => idList(_keyCatchFieldIds);

  Future<void> setTripFieldIds(List<Id> ids) =>
      putIdCollection(_keyTripFieldIds, ids);

  List<Id> get tripFieldIds => idList(_keyTripFieldIds);

  Future<void> setCatchLengthSystem(MeasurementSystem? system) =>
      put(_keyCatchLengthSystem, system?.value);

  MeasurementSystem? get catchLengthSystem =>
      MeasurementSystem.valueOf(preferences[_keyCatchLengthSystem] ?? -1);

  Future<void> setCatchWeightSystem(MeasurementSystem? system) =>
      put(_keyCatchWeightSystem, system?.value);

  MeasurementSystem? get catchWeightSystem =>
      MeasurementSystem.valueOf(preferences[_keyCatchWeightSystem] ?? -1);

  Future<void> setWaterDepthSystem(MeasurementSystem? system) =>
      put(_keyWaterDepthSystem, system?.value);

  MeasurementSystem? get waterDepthSystem =>
      MeasurementSystem.valueOf(preferences[_keyWaterDepthSystem] ?? -1);

  Future<void> setWaterTemperatureSystem(MeasurementSystem? system) =>
      put(_keyWaterTemperatureSystem, system?.value);

  MeasurementSystem? get waterTemperatureSystem =>
      MeasurementSystem.valueOf(preferences[_keyWaterTemperatureSystem] ?? -1);

  Future<void> setAirTemperatureSystem(MeasurementSystem? system) =>
      put(_keyAirTemperatureSystem, system?.value);

  MeasurementSystem? get airTemperatureSystem =>
      MeasurementSystem.valueOf(preferences[_keyAirTemperatureSystem] ?? -1);

  Future<void> setAirPressureSystem(MeasurementSystem? system) =>
      put(_keyAirPressureSystem, system?.value);

  MeasurementSystem? get airPressureSystem =>
      MeasurementSystem.valueOf(preferences[_keyAirPressureSystem] ?? -1);

  Future<void> setAirVisibilitySystem(MeasurementSystem? system) =>
      put(_keyAirVisibilitySystem, system?.value);

  MeasurementSystem? get airVisibilitySystem =>
      MeasurementSystem.valueOf(preferences[_keyAirVisibilitySystem] ?? -1);

  Future<void> setWindSpeedSystem(MeasurementSystem? system) =>
      put(_keyWindSpeedSystem, system?.value);

  MeasurementSystem? get windSpeedSystem =>
      MeasurementSystem.valueOf(preferences[_keyWindSpeedSystem] ?? -1);

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoFetchAtmosphere(bool autoFetch) =>
      put(_keyAutoFetchAtmosphere, autoFetch);

  bool get autoFetchAtmosphere => preferences[_keyAutoFetchAtmosphere] ?? false;

  Future<void> setRateTimerStartedAt(int? timestamp) =>
      put(_keyRateTimerStartedAt, timestamp);

  int? get rateTimerStartedAt => preferences[_keyRateTimerStartedAt];

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidRateApp(bool rated) => put(_keyDidRateApp, rated);

  bool get didRateApp => preferences[_keyDidRateApp] ?? false;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidOnboard(bool onboarded) => put(_keyDidOnboard, onboarded);

  bool get didOnboard => preferences[_keyDidOnboard] ?? false;

  Future<void> setSelectedReportId(Id? id) => putId(_keySelectedReportId, id);

  Id? get selectedReportId => id(_keySelectedReportId);

  /// Returns true if the user has been configured as pro. This will override
  /// any in-app purchase setting and can only be set in the Firebase console.
  bool get isPro => preferences[_keyIsPro] ?? false;
}
