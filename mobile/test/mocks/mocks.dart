import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as map;
import 'package:mobile/angler_manager.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/atmosphere_fetcher.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/preference_manager.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:mobile/wrappers/drive_api_wrapper.dart';
import 'package:mobile/wrappers/file_picker_wrapper.dart';
import 'package:mobile/wrappers/google_sign_in_wrapper.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/image_compress_wrapper.dart';
import 'package:mobile/wrappers/image_picker_wrapper.dart';
import 'package:mobile/wrappers/purchases_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';
import 'package:mobile/wrappers/photo_manager_wrapper.dart';
import 'package:mobile/wrappers/services_wrapper.dart';
import 'package:mobile/wrappers/shared_preferences_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sqflite/sqflite.dart';

import 'mocks.mocks.dart';

// TODO: Remove generation - https://github.com/dart-lang/mockito/issues/347

Trip_CatchesPerEntity newInputItemShim(dynamic pickerItem) =>
    Trip_CatchesPerEntity();

@GenerateMocks([AnglerManager])
@GenerateMocks([AppManager])
@GenerateMocks([], customMocks: [MockSpec<map.ArgumentCallbacks>()])
@GenerateMocks([AtmosphereFetcher])
@GenerateMocks([AuthClient])
@GenerateMocks([BackupRestoreManager])
@GenerateMocks([BaitCategoryManager])
@GenerateMocks([BaitManager])
@GenerateMocks([BodyOfWaterManager])
@GenerateMocks([CatchManager])
@GenerateMocks([CustomEntityManager])
@GenerateMocks([drive.DriveApi])
@GenerateMocks([drive.FileList])
@GenerateMocks([drive.FilesResource])
@GenerateMocks([DriveApiWrapper])
@GenerateMocks([FishingSpotManager])
@GenerateMocks([GoogleSignIn])
@GenerateMocks([GoogleSignInAccount])
@GenerateMocks([ImageManager])
@GenerateMocks([IOSink])
@GenerateMocks([LocalDatabaseManager])
@GenerateMocks([LocationMonitor])
@GenerateMocks([MethodManager])
@GenerateMocks([PreferenceManager])
@GenerateMocks([PropertiesManager])
@GenerateMocks([ReportManager])
@GenerateMocks([SpeciesManager])
@GenerateMocks([SubscriptionManager])
@GenerateMocks([TimeManager])
@GenerateMocks([TripManager])
@GenerateMocks([UserPreferenceManager])
@GenerateMocks([WaterClarityManager])
@GenerateMocks([FilePickerWrapper])
@GenerateMocks([], customMocks: [MockSpec<GlobalKey>()])
@GenerateMocks([GoogleSignInWrapper])
@GenerateMocks([HttpWrapper])
@GenerateMocks([ImageCompressWrapper])
@GenerateMocks([IoWrapper])
@GenerateMocks([map.MapboxMapController])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([PathProviderWrapper])
@GenerateMocks([PermissionHandlerWrapper])
@GenerateMocks([PhotoManagerWrapper])
@GenerateMocks([PurchasesWrapper])
@GenerateMocks([ServicesWrapper])
@GenerateMocks([SharedPreferencesWrapper])
@GenerateMocks([UrlLauncherWrapper])
@GenerateMocks([AssetPathEntity])
@GenerateMocks([Batch])
@GenerateMocks([Completer])
@GenerateMocks([Database])
@GenerateMocks([Directory])
@GenerateMocks([EntitlementInfo])
@GenerateMocks([EntitlementInfos])
@GenerateMocks([], customMocks: [MockSpec<EntityListener>()])
@GenerateMocks([FileSystemEntity])
@GenerateMocks([LegacyImporter])
@GenerateMocks([LogInResult])
@GenerateMocks([MethodChannel])
@GenerateMocks([NameValidator])
@GenerateMocks([NavigatorObserver])
@GenerateMocks([Offering])
@GenerateMocks([Offerings])
@GenerateMocks([Package])
@GenerateMocks([Product])
@GenerateMocks([PurchaserInfo])
@GenerateMocks([], customMocks: [
  MockSpec<QuantityPickerInputDelegate>(
    fallbackGenerators: {
      #newInputItem: newInputItemShim,
    },
  )
])
@GenerateMocks([Response])
@GenerateMocks([], customMocks: [MockSpec<StreamSubscription>()])
// @GenerateMocks can't generate mock because of an internal type used in API.
class MockFile extends Mock implements File {
  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: "") as String);

  @override
  Future<bool> exists() => (super.noSuchMethod(Invocation.method(#exists, []),
      returnValue: Future.value(false)) as Future<bool>);

  @override
  bool existsSync() => (super.noSuchMethod(Invocation.method(#existsSync, []),
      returnValue: false) as bool);

  @override
  Future<Uint8List> readAsBytes() => (super.noSuchMethod(
      Invocation.method(#readAsBytes, []),
      returnValue: Future.value(Uint8List.fromList([]))) as Future<Uint8List>);

  @override
  Stream<Uint8List> openRead([int? start, int? end]) => (super.noSuchMethod(
      Invocation.method(#openRead, [
        start,
        end,
      ]),
      returnValue: Stream.value(Uint8List.fromList([]))) as Stream<Uint8List>);

  @override
  int lengthSync() =>
      (super.noSuchMethod(Invocation.method(#lengthSync, []), returnValue: 0)
          as int);

  @override
  IOSink openWrite({
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  }) =>
      super.noSuchMethod(
        Invocation.method(#openWrite, [], {
          #mode: mode,
          #encoding: encoding,
        }),
        returnValue: IOSink(StreamController()),
      );

  @override
  Future<File> writeAsBytes(
    List<int>? bytes, {
    bool? flush,
    FileMode? mode,
  }) {
    return (super.noSuchMethod(
        Invocation.method(#writeAsBytes, [
          bytes
        ], {
          #flush: flush,
          #mode: mode,
        }),
        returnValue: Future.value(File(""))) as Future<File>);
  }
}

// @GenerateMocks produces a conflict where the wrong PickedFile class is used
// (one from unsupported.dart and one from io.dart in the image_picker library).
class MockImagePickerWrapper extends Mock implements ImagePickerWrapper {
  @override
  Future<XFile?> pickImage(ImageSource? source) =>
      super.noSuchMethod(Invocation.method(#getImage, [source]),
          returnValue: Future.value(null)) as Future<XFile?>;
}

// @GenerateMocks can't generate mock because of an internal type used in API.
class MockStream<T> extends Mock implements Stream<T> {
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return (super.noSuchMethod(
      Invocation.method(#listen, [
        onData
      ], {
        #onError: onError,
        #onDone: onDone,
        #cancelOnError: cancelOnError,
      }),
      returnValue: MockStreamSubscription<T>(),
    ) as StreamSubscription<T>);
  }

  @override
  Future<List<T>> toList() => super.noSuchMethod(Invocation.method(#list, []),
      returnValue: Future.value(<T>[])) as Future<List<T>>;
}

// Mockito can't stub the == operator, which makes it impossible to use mocks
// created with Mockito in a Set.
// https://github.com/dart-lang/mockito/issues/365
class MockAssetEntity extends AssetEntity {
  final String fileName;
  final DateTime? dateTime;
  final LatLng? latLngAsync;

  int latLngAsyncCalls = 0;

  MockAssetEntity({
    required this.fileName,
    String? id,
    this.dateTime,
    this.latLngAsync,
    LatLng? latLngLegacy,
  }) : super(
          id: id ?? fileName,
          typeInt: AssetType.image.index,
          width: 50,
          height: 50,
          latitude: latLngLegacy?.latitude,
          longitude: latLngLegacy?.longitude,
        );

  @override
  DateTime get createDateTime => dateTime ?? DateTime.now();

  @override
  Future<Uint8List?> get thumbData =>
      Future.value(File("test/resources/$fileName").readAsBytesSync());

  @override
  Future<LatLng> latlngAsync() {
    latLngAsyncCalls++;
    return Future.value(latLngAsync ?? const LatLng(latitude: 0, longitude: 0));
  }

  @override
  Future<File?> get originFile =>
      Future.value(File("test/resources/$fileName"));
}

void main() {}
