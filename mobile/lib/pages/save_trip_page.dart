import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/pages/body_of_water_list_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/gps_trail_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:mobile/widgets/field.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../app_manager.dart';
import '../atmosphere_fetcher.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../time_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/trip_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';
import '../widgets/time_zone_input.dart';
import 'angler_list_page.dart';
import 'species_list_page.dart';

class SaveTripPage extends StatefulWidget {
  final Trip? oldTrip;

  const SaveTripPage() : oldTrip = null;

  const SaveTripPage.edit(this.oldTrip);

  @override
  SaveTripPageState createState() => SaveTripPageState();
}

class SaveTripPageState extends State<SaveTripPage> {
  // Unique IDs for each field. These are stored in the database and should not
  // be changed.
  static final _idStartTimestamp =
      Id(uuid: "0f012ca1-aae3-4aec-86e2-d85479eb6d66");
  static final _idEndTimestamp =
      Id(uuid: "c6afa4ff-add6-4a01-b69a-ba6f9b456c85");
  static final _idTimeZone = Id(uuid: "205933d4-27f5-4917-ae92-08366a469963");
  static final _idName = Id(uuid: "d9a83fa6-926d-474d-8ddf-8d0e044d2ea4");
  static final _idImages = Id(uuid: "8c593cbb-4782-49c7-b540-0c22d8175b3f");
  static final _idCatches = Id(uuid: "0806fcc4-5d77-44b4-85e2-ebc066f37e12");
  static final _idBodiesOfWater =
      Id(uuid: "45c91a90-62d1-47fe-b360-c5494a265ef6");
  static final _idCatchesPerFishingSpot =
      Id(uuid: "70d19321-1cc7-4842-b7e4-252ce79f18d0");
  static final _idCatchesPerAngler =
      Id(uuid: "20288727-76f3-49fc-a975-0d740931e3a4");
  static final _idCatchesPerSpecies =
      Id(uuid: "d7864201-af18-464a-8815-571aa6f82f8c");
  static final _idCatchesPerBait =
      Id(uuid: "ad35c21c-13cb-486b-812d-6315d0bf5004");
  static final _idNotes = Id(uuid: "3d3bc3c9-e316-49fe-8427-ae344dffe38e");
  static final _idAtmosphere = Id(uuid: "b7f6ad7f-e1b8-4e15-b29c-688429787dd9");
  static final _idGpsTrails = tripIdGpsTrails;

  final _log = const Log("SaveTripPage");
  final Map<Id, Field> _fields = {};
  final Set<String> _catchImages = {};

  List<CustomEntityValue> _customEntityValues = [];
  bool _userDidChangeStartTime = false;
  bool _userDidChangeEndTime = false;
  bool _userDidChangeCatchesPerFishingSpot = false;
  bool _userDidChangeCatchesPerAngler = false;
  bool _userDidChangeCatchesPerBait = false;
  bool _userDidChangeCatchesPerSpecies = false;

  Trip? get _oldTrip => widget.oldTrip;

  bool get _isEditing => _oldTrip != null;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  AppManager get _appManager => AppManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GpsTrailManager get _gpsTrailManager => GpsTrailManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  CurrentDateTimeInputController get _startTimestampController =>
      _fields[_idStartTimestamp]!.controller as CurrentDateTimeInputController;

  CurrentDateTimeInputController get _endTimestampController =>
      _fields[_idEndTimestamp]!.controller as CurrentDateTimeInputController;

  TimeZoneInputController get _timeZoneController =>
      _fields[_idTimeZone]!.controller as TimeZoneInputController;

  TextInputController get _nameController =>
      _fields[_idName]!.controller as TextInputController;

  ImagesInputController get _imagesController =>
      _fields[_idImages]!.controller as ImagesInputController;

  SetInputController<Id> get _catchesController =>
      _fields[_idCatches]!.controller as SetInputController<Id>;

  SetInputController<Id> get _bodiesOfWaterController =>
      _fields[_idBodiesOfWater]!.controller as SetInputController<Id>;

  InputController<Atmosphere> get _atmosphereController =>
      _fields[_idAtmosphere]!.controller as InputController<Atmosphere>;

  TextInputController get _notesController =>
      _fields[_idNotes]!.controller as TextInputController;

  SetInputController<Trip_CatchesPerEntity> get _speciesCatchesController =>
      _fields[_idCatchesPerSpecies]!.controller
          as SetInputController<Trip_CatchesPerEntity>;

  SetInputController<Trip_CatchesPerEntity> get _anglerCatchesController =>
      _fields[_idCatchesPerAngler]!.controller
          as SetInputController<Trip_CatchesPerEntity>;

  SetInputController<Trip_CatchesPerEntity> get _fishingSpotCatchesController =>
      _fields[_idCatchesPerFishingSpot]!.controller
          as SetInputController<Trip_CatchesPerEntity>;

  SetInputController<Trip_CatchesPerBait> get _baitCatchesController =>
      _fields[_idCatchesPerBait]!.controller
          as SetInputController<Trip_CatchesPerBait>;

  SetInputController<Id> get _gpsTrailsController =>
      _fields[_idGpsTrails]!.controller as SetInputController<Id>;

  @override
  void initState() {
    super.initState();

    _fields[_idCatches] = Field(
      id: _idCatches,
      name: (context) => Strings.of(context).entityNameCatches,
      description: (context) => Strings.of(context).saveTripPageCatchesDesc,
      controller: SetInputController<Id>(),
    );

    _fields[_idBodiesOfWater] = Field(
      id: _idBodiesOfWater,
      name: (context) => Strings.of(context).entityNameBodiesOfWater,
      controller: SetInputController<Id>(),
    );

    _fields[_idStartTimestamp] = Field(
      id: _idStartTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).saveTripPageStartDateTime,
      controller: CurrentDateTimeInputController(context),
    );

    _fields[_idEndTimestamp] = Field(
      id: _idEndTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).saveTripPageEndDateTime,
      controller: CurrentDateTimeInputController(context),
    );

    _fields[_idTimeZone] = Field(
      id: _idTimeZone,
      name: (context) => Strings.of(context).timeZoneInputLabel,
      description: (context) => Strings.of(context).timeZoneInputDescription,
      controller: TimeZoneInputController(context),
    );

    _fields[_idName] = Field(
      id: _idName,
      name: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(),
    );

    _fields[_idNotes] = Field(
      id: _idNotes,
      name: (context) => Strings.of(context).inputNotesLabel,
      controller: TextInputController(),
    );

    _fields[_idImages] = Field(
      id: _idImages,
      name: (context) => Strings.of(context).inputPhotosLabel,
      controller: ImagesInputController(),
    );

    _fields[_idAtmosphere] = Field(
      id: _idAtmosphere,
      name: (context) => Strings.of(context).inputAtmosphere,
      controller: InputController<Atmosphere>(),
    );

    _fields[_idCatchesPerAngler] = Field(
      id: _idCatchesPerAngler,
      name: (context) => Strings.of(context).tripCatchesPerAngler,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    );

    _fields[_idCatchesPerBait] = Field(
      id: _idCatchesPerBait,
      name: (context) => Strings.of(context).tripCatchesPerBait,
      controller: SetInputController<Trip_CatchesPerBait>(),
    );

    _fields[_idCatchesPerFishingSpot] = Field(
      id: _idCatchesPerFishingSpot,
      name: (context) => Strings.of(context).tripCatchesPerFishingSpot,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    );

    _fields[_idCatchesPerSpecies] = Field(
      id: _idCatchesPerSpecies,
      name: (context) => Strings.of(context).tripCatchesPerSpecies,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    );

    _fields[_idGpsTrails] = Field(
      id: _idGpsTrails,
      name: (context) => Strings.of(context).entityNameGpsTrails,
      controller: SetInputController<Id>(),
    );

    if (_isEditing) {
      _startTimestampController.value = _oldTrip!.startDateTime(context);
      _endTimestampController.value = _oldTrip!.endDateTime(context);
      _timeZoneController.value = _oldTrip!.timeZone;
      _nameController.value = _oldTrip!.hasName() ? _oldTrip!.name : null;
      _catchesController.value = _oldTrip!.catchIds.toSet();
      _bodiesOfWaterController.value = _oldTrip!.bodyOfWaterIds.toSet();
      _atmosphereController.value =
          _oldTrip!.hasAtmosphere() ? _oldTrip!.atmosphere : null;
      _notesController.value = _oldTrip!.hasNotes() ? _oldTrip!.notes : null;
      _speciesCatchesController.value = _oldTrip!.catchesPerSpecies.toSet();
      _anglerCatchesController.value = _oldTrip!.catchesPerAngler.toSet();
      _fishingSpotCatchesController.value =
          _oldTrip!.catchesPerFishingSpot.toSet();
      _baitCatchesController.value = _oldTrip!.catchesPerBait.toSet();
      _customEntityValues = _oldTrip!.customEntityValues;
      _gpsTrailsController.value = _oldTrip!.gpsTrailIds.toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO #800: Remove addition of timestamp IDs when there are no more 2.2.0
    //  users.
    // There is a bug when updating from 2.2.0 to 2.3.1 where the timestamps
    // are not editable and can't be selected in the field manager.
    var trackedIds = _userPreferenceManager.tripFieldIds.toSet();
    if (trackedIds.isNotEmpty) {
      trackedIds
        ..add(_idStartTimestamp)
        ..add(_idEndTimestamp);
    }

    return EditableFormPage(
      title: Text(_isEditing
          ? Strings.of(context).saveTripPageEditTitle
          : Strings.of(context).saveTripPageNewTitle),
      padding: insetsZero,
      runSpacing: 0,
      fields: _fields,
      trackedFieldIds: trackedIds,
      customEntityValues: _customEntityValues,
      showTopCustomFieldPadding: false,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferenceManager.setTripFieldIds(ids.toList()),
      onSave: _save,
    );
  }

  Widget _buildField(Id id) {
    if (id == _idStartTimestamp) {
      return _buildStartTime();
    } else if (id == _idEndTimestamp) {
      return _buildEndTime();
    } else if (id == _idTimeZone) {
      return _buildTimeZone();
    } else if (id == _idName) {
      return _buildName();
    } else if (id == _idImages) {
      return _buildImages();
    } else if (id == _idCatchesPerFishingSpot) {
      return _buildCatchesPerFishingSpot();
    } else if (id == _idCatchesPerAngler) {
      return _buildCatchesPerAngler();
    } else if (id == _idCatchesPerBait) {
      return _buildCatchesPerBait();
    } else if (id == _idCatchesPerSpecies) {
      return _buildCatchesPerSpecies();
    } else if (id == _idNotes) {
      return _buildNotes();
    } else if (id == _idCatches) {
      return _buildCatches();
    } else if (id == _idBodiesOfWater) {
      return _buildBodiesOfWater();
    } else if (id == _idAtmosphere) {
      return _buildAtmosphere();
    } else if (id == _idGpsTrails) {
      return _buildGpsTrails();
    } else {
      _log.e(StackTrace.current, "Unknown input key: $id");
      return const Empty();
    }
  }

  Widget _buildStartTime() {
    return Padding(
      padding: insetsVerticalSmall,
      child: _DateTimeAllDayPicker(
        controller: _startTimestampController,
        dateLabel: Strings.of(context).saveTripPageStartDate,
        timeLabel: Strings.of(context).saveTripPageStartDate,
        onChange: () => setState(() => _userDidChangeStartTime = true),
      ),
    );
  }

  Widget _buildEndTime() {
    return Padding(
      padding: insetsVerticalSmall,
      child: _DateTimeAllDayPicker(
        controller: _endTimestampController,
        dateLabel: Strings.of(context).saveTripPageEndDate,
        timeLabel: Strings.of(context).saveTripPageEndDate,
        onChange: () => setState(() => _userDidChangeEndTime = true),
      ),
    );
  }

  Widget _buildTimeZone() {
    return TimeZoneInput(
      controller: _timeZoneController,
      onPicked: () {
        _startTimestampController.timeZone = _timeZoneController.value;
        _endTimestampController.timeZone = _timeZoneController.value;
      },
    );
  }

  Widget _buildName() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: TextInput.name(
        context,
        controller: _nameController,
      ),
    );
  }

  Widget _buildImages() {
    // Convert to and from a Set to ensure all duplicates are removed.
    var images = Set<String>.of(_oldTrip?.imageNames ?? [])
      ..addAll(_catchImages);

    return ImageInput(
      initialImageNames: images.toList(),
      controller: _imagesController,
    );
  }

  Widget _buildCatchesPerFishingSpot() {
    return QuantityPickerInput<FishingSpot, Trip_CatchesPerEntity>(
      title: Strings.of(context).tripCatchesPerFishingSpot,
      delegate: FishingSpotQuantityPickerInputDelegate(
        manager: _fishingSpotManager,
        controller: _fishingSpotCatchesController,
        didUpdateValue: () => _userDidChangeCatchesPerFishingSpot = true,
      ),
    );
  }

  Widget _buildCatchesPerAngler() {
    return QuantityPickerInput<Angler, Trip_CatchesPerEntity>(
      title: Strings.of(context).tripCatchesPerAngler,
      delegate: EntityQuantityPickerInputDelegate<Angler>(
        manager: _anglerManager,
        controller: _anglerCatchesController,
        listPageBuilder: (settings) => AnglerListPage(pickerSettings: settings),
        didUpdateValue: () => _userDidChangeCatchesPerAngler = true,
      ),
    );
  }

  Widget _buildCatchesPerBait() {
    return QuantityPickerInput(
      title: Strings.of(context).tripCatchesPerBait,
      delegate: BaitQuantityPickerInputDelegate(
        baitManager: _baitManager,
        controller: _baitCatchesController,
        didUpdateValue: () => _userDidChangeCatchesPerBait = true,
      ),
    );
  }

  Widget _buildCatchesPerSpecies() {
    return QuantityPickerInput<Species, Trip_CatchesPerEntity>(
      title: Strings.of(context).tripCatchesPerSpecies,
      delegate: EntityQuantityPickerInputDelegate<Species>(
        manager: _speciesManager,
        controller: _speciesCatchesController,
        listPageBuilder: (settings) =>
            SpeciesListPage(pickerSettings: settings),
        didUpdateValue: () => _userDidChangeCatchesPerSpecies = true,
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: TextInput.description(
        context,
        title: Strings.of(context).inputNotesLabel,
        controller: _notesController,
      ),
    );
  }

  Widget _buildCatches() {
    return EntityPickerInput<Catch>.multi(
      manager: _catchManager,
      controller: _catchesController,
      emptyValue: Strings.of(context).saveTripPageNoCatches,
      isHidden: !_fields[_idCatches]!.isShowing,
      listPage: (pickerSettings) =>
          CatchListPage(pickerSettings: pickerSettings),
      onPicked: (ids) => setState(() {
        _catchesController.value = ids;

        if (ids.isNotEmpty) {
          var catches = _catchManager.catches(
            context,
            opt: CatchFilterOptions(
              order: CatchFilterOptions_Order.newest_to_oldest,
              catchIds: ids,
            ),
          );

          _updateTimestampControllersIfNeeded(catches);
          _updateCatchesPerEntityControllersIfNeeded(catches);
          _updateBodiesOfWaterController(catches);
          _updateCatchImages(catches);
        }
      }),
    );
  }

  Widget _buildBodiesOfWater() {
    return EntityPickerInput<BodyOfWater>.multi(
      manager: _bodyOfWaterManager,
      controller: _bodiesOfWaterController,
      emptyValue: Strings.of(context).saveTripPageNoBodiesOfWater,
      isHidden: !_fields[_idBodiesOfWater]!.isShowing,
      listPage: (pickerSettings) =>
          BodyOfWaterListPage(pickerSettings: pickerSettings),
      onPicked: (ids) => setState(() => _bodiesOfWaterController.value = ids),
    );
  }

  Widget _buildAtmosphere() {
    // Use the first location we know about.
    var latLng = _locationMonitor.currentLatLng;
    FishingSpot? fishingSpot;
    for (var id in _catchesController.value) {
      var cat = _catchManager.entity(id);
      if (cat == null || !cat.hasFishingSpotId()) {
        continue;
      }

      fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
      if (fishingSpot != null) {
        latLng = fishingSpot.latLng;
        break;
      }
    }

    // Use the timestamp in the middle of the start and end times.
    var startMs = _startTimestampController.timestamp;
    var endMs = _endTimestampController.timestamp;
    var time = ((endMs + startMs) / 2).round();

    return AtmosphereInput(
      fetcher: AtmosphereFetcher(
        _appManager,
        _timeManager.dateTime(time, _timeZoneController.value),
        latLng,
      ),
      controller: _atmosphereController,
      fishingSpot: fishingSpot,
    );
  }

  Widget _buildGpsTrails() {
    return EntityPickerInput<GpsTrail>.multi(
      manager: _gpsTrailManager,
      controller: _gpsTrailsController,
      emptyValue: Strings.of(context).saveTripPageNoGpsTrails,
      isHidden: !_fields[_idGpsTrails]!.isShowing,
      listPage: (pickerSettings) =>
          GpsTrailListPage(pickerSettings: pickerSettings),
      onPicked: (ids) => setState(() => _gpsTrailsController.value = ids),
    );
  }

  /// Update date and time values based on picked catches. This will not update
  /// the time if "All day" checkboxes are checked. This will _not_ overwrite any
  /// changes the user made to the time.
  void _updateTimestampControllersIfNeeded(List<Catch> catches) {
    if (!_userDidChangeStartTime) {
      var startDateTime = catches.last.dateTime(context);
      if (_startTimestampController.isMidnight) {
        _startTimestampController.date = startDateTime;
      } else {
        _startTimestampController.value = startDateTime;
      }
    }

    if (!_userDidChangeEndTime) {
      var endDateTime = catches.first.dateTime(context);
      if (_endTimestampController.isMidnight) {
        _endTimestampController.date = endDateTime;
      } else {
        _endTimestampController.value = endDateTime;
      }
    }
  }

  /// Updates "Catches Per Entity" values based on the given catches.
  /// This will _not_ overwrite any changes the user made to the catches per
  /// entity values.
  void _updateCatchesPerEntityControllersIfNeeded(List<Catch> catches) {
    var catchesPerAngler = <Trip_CatchesPerEntity>[];
    var catchesPerBait = <Trip_CatchesPerBait>[];
    var catchesPerFishingSpot = <Trip_CatchesPerEntity>[];
    var catchesPerSpecies = <Trip_CatchesPerEntity>[];

    for (var cat in catches) {
      if (_fields[_idCatchesPerAngler]!.isShowing) {
        Trips.incCatchesPerEntity(catchesPerAngler, cat.anglerId, cat);
      }

      if (_fields[_idCatchesPerFishingSpot]!.isShowing) {
        Trips.incCatchesPerEntity(
            catchesPerFishingSpot, cat.fishingSpotId, cat);
      }

      if (_fields[_idCatchesPerSpecies]!.isShowing) {
        Trips.incCatchesPerEntity(catchesPerSpecies, cat.speciesId, cat);
      }

      if (_fields[_idCatchesPerBait]!.isShowing) {
        Trips.incCatchesPerBait(catchesPerBait, cat);
      }
    }

    // Only update fields if the user hasn't already changed them.
    if (!_userDidChangeCatchesPerAngler) {
      _anglerCatchesController.value = catchesPerAngler.toSet();
    }

    if (!_userDidChangeCatchesPerBait) {
      _baitCatchesController.value = catchesPerBait.toSet();
    }

    if (!_userDidChangeCatchesPerFishingSpot) {
      _fishingSpotCatchesController.value = catchesPerFishingSpot.toSet();
    }

    if (!_userDidChangeCatchesPerSpecies) {
      _speciesCatchesController.value = catchesPerSpecies.toSet();
    }
  }

  /// Adds body of water values based on the given catches. This will add to
  /// the body of water values already selected by the user, if any.
  void _updateBodiesOfWaterController(List<Catch> catches) {
    if (!_fields[_idBodiesOfWater]!.isShowing) {
      return;
    }

    var bowIds = <Id>{};

    for (var cat in catches) {
      var bowId = _fishingSpotManager.entity(cat.fishingSpotId)?.bodyOfWaterId;
      if (Ids.isValid(bowId)) {
        bowIds.add(bowId!);
      }
    }

    _bodiesOfWaterController.addAll(bowIds);
  }

  /// Adds images based on the given catches. This will add photos to any
  /// existing photos already attached by the user.
  void _updateCatchImages(List<Catch> catches) {
    if (!_fields[_idImages]!.isShowing) {
      return;
    }

    _catchImages.addAll(catches.fold<List<String>>(
        <String>[], (prev, cat) => prev..addAll(cat.imageNames)));
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    // imageNames is set in _tripManager.addOrUpdate.
    var newTrip = Trip(
      id: _oldTrip?.id ?? randomId(),
      startTimestamp: Int64(_startTimestampController.timestamp),
      endTimestamp: Int64(_endTimestampController.timestamp),
      timeZone: _timeZoneController.value,
      catchIds: _catchesController.value,
      bodyOfWaterIds: _bodiesOfWaterController.value,
      catchesPerSpecies: _speciesCatchesController.value,
      catchesPerAngler: _anglerCatchesController.value,
      catchesPerFishingSpot: _fishingSpotCatchesController.value,
      catchesPerBait: _baitCatchesController.value,
      customEntityValues: entityValuesFromMap(customFieldValueMap),
      gpsTrailIds: _gpsTrailsController.value,
    );

    if (isNotEmpty(_nameController.value)) {
      newTrip.name = _nameController.value!;
    }

    if (_atmosphereController.hasValue) {
      newTrip.atmosphere = _atmosphereController.value!;
      newTrip.atmosphere.timeZone = newTrip.timeZone;
    }

    if (isNotEmpty(_notesController.value)) {
      newTrip.notes = _notesController.value!;
    }

    _tripManager.addOrUpdate(
      newTrip,
      imageFiles: _imagesController.originalFiles,
    );

    return true;
  }
}

class _DateTimeAllDayPicker extends StatefulWidget {
  final DateTimeInputController controller;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback? onChange;

  const _DateTimeAllDayPicker({
    required this.controller,
    required this.dateLabel,
    required this.timeLabel,
    this.onChange,
  });

  @override
  State<_DateTimeAllDayPicker> createState() => _DateTimeAllDayPickerState();
}

class _DateTimeAllDayPickerState extends State<_DateTimeAllDayPicker> {
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _isAllDay = widget.controller.isMidnight;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateTimePicker(
            datePicker: DatePicker(
              context,
              controller: widget.controller,
              label: widget.dateLabel,
              onChange: (_) => widget.onChange?.call(),
            ),
            timePicker: TimePicker(
              context,
              controller: widget.controller,
              label: widget.timeLabel,
              enabled: !_isAllDay,
              onChange: (_) => widget.onChange?.call(),
            ),
          ),
        ),
        Row(
          children: [
            Text(Strings.of(context).saveTripPageAllDay),
            const HorizontalSpace(paddingSmall),
            PaddedCheckbox(
              checked: _isAllDay,
              onChanged: (checked) => setState(() {
                _isAllDay = checked;
                widget.controller.time = const TimeOfDay(hour: 0, minute: 0);
              }),
            ),
            const HorizontalSpace(paddingDefault),
          ],
        ),
      ],
    );
  }
}
