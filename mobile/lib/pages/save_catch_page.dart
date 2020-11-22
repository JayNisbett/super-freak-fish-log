import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart' as photo_manager;

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../image_manager.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_list_page.dart';
import '../pages/editable_form_page.dart';
import '../pages/fishing_spot_picker_page.dart';
import '../pages/image_picker_page.dart';
import '../pages/species_list_page.dart';
import '../preferences_manager.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../time_manager.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/static_fishing_spot.dart';
import '../widgets/widget.dart';

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback popOverride;

  final List<PickedImage> images;
  final Species species;
  final FishingSpot fishingSpot;

  final Catch oldCatch;

  /// A [Catch] cannot be created without first selecting a [Species] and
  /// [FishingSpot], normally from an [AddCatchJourney] widget.
  SaveCatchPage({
    this.images = const [],
    @required this.species,
    @required this.fishingSpot,
    this.popOverride,
  })  : assert(images != null),
        assert(species != null),
        assert(fishingSpot != null),
        oldCatch = null;

  SaveCatchPage.edit(this.oldCatch)
      : assert(oldCatch != null),
        popOverride = null,
        images = const [],
        species = null,
        fishingSpot = null;

  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static final _idTimestamp = randomId();
  static final _idImages = randomId();
  static final _idSpecies = randomId();
  static final _idFishingSpot = randomId();
  static final _idBait = randomId();

  final Log _log = Log("SaveCatchPage");

  final Map<Id, InputData> _fields = {};

  Future<List<PickedImage>> _imagesFuture = Future.value([]);
  List<CustomEntityValue> _customEntityValues = [];

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);
  CatchManager get _catchManager => CatchManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  ImageManager get _imageManager => ImageManager.of(context);
  PreferencesManager get _preferencesManager => PreferencesManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);
  TimeManager get _timeManager => TimeManager.of(context);
  Catch get _oldCatch => widget.oldCatch;

  TimestampInputController get _timestampController =>
      _fields[_idTimestamp].controller;
  InputController<Species> get _speciesController =>
      _fields[_idSpecies].controller;
  InputController<List<PickedImage>> get _imagesController =>
      _fields[_idImages].controller;
  InputController<FishingSpot> get _fishingSpotController =>
      _fields[_idFishingSpot].controller;
  InputController<Bait> get _baitController => _fields[_idBait].controller;

  bool get _editing => _oldCatch != null;

  @override
  void initState() {
    super.initState();

    _fields[_idTimestamp] = InputData(
      id: _idTimestamp,
      controller: TimestampInputController(),
      label: (context) => Strings.of(context).saveCatchPageDateTimeLabel,
      removable: false,
      showing: true,
    );

    _fields[_idSpecies] = InputData(
      id: _idSpecies,
      controller: InputController<Species>(),
      label: (context) => Strings.of(context).saveCatchPageSpeciesLabel,
      removable: false,
      showing: true,
    );

    _fields[_idBait] = InputData(
      id: _idBait,
      controller: InputController<Bait>(),
      label: (context) => Strings.of(context).saveCatchPageBaitLabel,
      showing: true,
    );

    _fields[_idImages] = InputData(
      id: _idImages,
      controller: InputController<List<PickedImage>>(),
      label: (context) => Strings.of(context).saveCatchPageImagesLabel,
      showing: true,
    );

    _fields[_idFishingSpot] = InputData(
      id: _idFishingSpot,
      controller: InputController<FishingSpot>(),
      label: (context) => Strings.of(context).saveCatchPageFishingSpotLabel,
      showing: true,
    );

    if (_editing) {
      _timestampController.value = _oldCatch.timestamp;
      _speciesController.value = _speciesManager.entity(_oldCatch.speciesId);
      _baitController.value = _baitManager.entity(_oldCatch.baitId);
      _fishingSpotController.value =
          _fishingSpotManager.entity(_oldCatch.fishingSpotId);
      _customEntityValues = _oldCatch.customEntityValues;
      _imagesFuture = _pickedImagesForOldCatch;
    } else {
      if (widget.images.isNotEmpty) {
        var image = widget.images.first;
        if (image.dateTime != null) {
          _timestampController.date = image.dateTime;
          _timestampController.time = TimeOfDay.fromDateTime(image.dateTime);
        }
      }
      _speciesController.value = widget.species;
      _imagesController.value = widget.images;
      _fishingSpotController.value = widget.fishingSpot;
    }
  }

  @override
  Widget build(BuildContext context) {
    _timestampController.date =
        _timestampController.date ?? _timeManager.currentDateTime;
    _timestampController.time =
        _timestampController.time ?? _timeManager.currentTime;

    return EditableFormPage(
      title: Text(_editing
          ? Strings.of(context).saveCatchPageEditTitle
          : Strings.of(context).saveCatchPageNewTitle),
      runSpacing: 0,
      padding: insetsZero,
      fields: _fields,
      customEntityIds: _preferencesManager.catchCustomEntityIds,
      customEntityValues: _customEntityValues,
      onBuildField: _buildField,
      onSave: _save,
    );
  }

  Widget _buildField(Id id) {
    if (id == _idTimestamp) {
      return _buildTimestamp();
    } else if (id == _idImages) {
      return _buildImages();
    } else if (id == _idSpecies) {
      return _buildSpecies();
    } else if (id == _idFishingSpot) {
      return _buildFishingSpot();
    } else if (id == _idBait) {
      return _buildBait();
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: paddingWidgetSmall,
      ),
      child: DateTimePicker(
        datePicker: DatePicker(
          context,
          initialDate: _timestampController.date,
          label: Strings.of(context).saveCatchPageDateLabel,
          onChange: (newDate) => _timestampController.date = newDate,
        ),
        timePicker: TimePicker(
          context,
          initialTime: _timestampController.time,
          label: Strings.of(context).saveCatchPageTimeLabel,
          onChange: (newTime) => _timestampController.time = newTime,
        ),
      ),
    );
  }

  Widget _buildBait() {
    return EntityListenerBuilder(
      managers: [
        _baitCategoryManager,
        _baitManager,
      ],
      builder: (context) {
        String value;
        if (_baitController.value != null) {
          value = _baitManager.formatNameWithCategory(_baitController.value);
        }

        return ListPickerInput(
          title: Strings.of(context).saveCatchPageBaitLabel,
          value: value,
          onTap: () {
            push(
              context,
              BaitListPage.picker(
                initialValues: {_baitController.value},
                onPicked: (context, pickedBaits) {
                  setState(() {
                    _baitController.value = pickedBaits.first;
                  });
                  return true;
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFishingSpot() {
    var fishingSpot = _fishingSpotController.value;

    if (fishingSpot == null) {
      return ListItem(
        title: Text(Strings.of(context).saveCatchPageFishingSpotLabel),
        trailing: RightChevronIcon(),
        onTap: _pushFishingSpotPicker,
      );
    }

    return StaticFishingSpot(
      fishingSpot,
      padding: insetsHorizontalDefaultVerticalSmall,
      onTap: _pushFishingSpotPicker,
    );
  }

  Widget _buildSpecies() {
    return EntityListenerBuilder(
      managers: [_speciesManager],
      builder: (context) {
        return ListPickerInput(
          title: Strings.of(context).saveCatchPageSpeciesLabel,
          value: _speciesController.value?.name,
          onTap: () {
            push(
              context,
              SpeciesListPage.picker(
                initialValues: {_speciesController.value},
                onPicked: (context, pickedSpecies) {
                  setState(() {
                    _speciesController.value = pickedSpecies.first;
                  });
                  return true;
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImages() {
    return EmptyFutureBuilder<List<PickedImage>>(
      future: _imagesFuture,
      builder: (context, images) {
        return ImageInput(
          requestPhotoPermission: photo_manager.PhotoManager.requestPermission,
          initialImages: _imagesController.value ?? [],
          onImagesPicked: (pickedImages) {
            setState(() {
              _imagesController.value = pickedImages;
              _imagesFuture = Future.value(_imagesController.value);
            });
          },
        );
      },
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _preferencesManager.catchCustomEntityIds =
        customFieldValueMap.keys.toList();

    // imageNames is set in _catchManager.addOrUpdate
    var cat = Catch()
      ..id = _oldCatch?.id ?? randomId()
      ..timestamp = _timestampController.value
      ..speciesId = _speciesController.value.id
      ..fishingSpotId = _fishingSpotController.value.id
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (_baitController.value != null) {
      cat.baitId = _baitController.value.id;
    }

    _catchManager.addOrUpdate(
      cat,
      fishingSpot: _fields[_idFishingSpot].controller.value,
      imageFiles:
          _imagesController.value.map((img) => img.originalFile).toList(),
    );

    if (widget.popOverride != null) {
      widget.popOverride();
      return false;
    }

    return true;
  }

  void _pushFishingSpotPicker() {
    push(
      context,
      FishingSpotPickerPage(
        fishingSpot: _fishingSpotController.value,
        onPicked: (context, pickedFishingSpot) {
          if (pickedFishingSpot != _fishingSpotController.value) {
            setState(() {
              _fishingSpotController.value = pickedFishingSpot;
            });
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Converts [oldCatch] images into a list of [PickedImage] objects to be
  /// managed by the [ImageInput].
  Future<List<PickedImage>> get _pickedImagesForOldCatch async {
    if (!_editing || _oldCatch.imageNames.isEmpty) {
      return Future.value([]);
    }

    var bytesList = await _imageManager.images(
      context,
      imageNames: _oldCatch.imageNames,
      size: galleryMaxThumbSize,
    );

    _imagesController.value =
        bytesList.map((bytes) => PickedImage(thumbData: bytes)).toList();
    return _imagesController.value;
  }
}
