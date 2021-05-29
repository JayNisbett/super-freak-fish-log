import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../image_manager.dart';
import '../log.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_list_page.dart';
import '../pages/editable_form_page.dart';
import '../pages/fishing_spot_picker_page.dart';
import '../pages/image_picker_page.dart';
import '../pages/species_list_page.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/catch_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../water_clarity_manager.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/static_fishing_spot.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'manageable_list_page.dart';
import 'method_list_page.dart';
import 'picker_page.dart';
import 'water_clarity_list_page.dart';

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback? popOverride;

  final List<PickedImage> images;
  final Id? speciesId;
  final Id? fishingSpotId;

  final Catch? oldCatch;

  /// See [EditableFormPage.popupMenuKey].
  final GlobalKey<PopupMenuButtonState>? popupMenuKey;

  SaveCatchPage({
    required this.speciesId,
    this.popupMenuKey,
    this.images = const [],
    this.fishingSpotId,
    this.popOverride,
  }) : oldCatch = null;

  SaveCatchPage.edit(this.oldCatch)
      : popupMenuKey = null,
        popOverride = null,
        images = const [],
        speciesId = null,
        fishingSpotId = null;

  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static final _idAngler = catchFieldIdAngler();
  static final _idBait = catchFieldIdBait();
  static final _idCatchAndRelease = catchFieldIdCatchAndRelease();
  static final _idFavorite = catchFieldIdFavorite();
  static final _idFishingSpot = catchFieldIdFishingSpot();
  static final _idImages = catchFieldIdImages();
  static final _idLength = catchFieldIdLength();
  static final _idMethods = catchFieldIdMethods();
  static final _idNotes = catchFieldIdNotes();
  static final _idPeriod = catchFieldIdPeriod();
  static final _idQuantity = catchFieldIdQuantity();
  static final _idSeason = catchFieldIdSeason();
  static final _idSpecies = catchFieldIdSpecies();
  static final _idTimestamp = catchFieldIdTimestamp();
  static final _idWaterClarity = catchFieldIdWaterClarity();
  static final _idWaterDepth = catchFieldIdWaterDepth();
  static final _idWaterTemperature = catchFieldIdWaterTemperature();
  static final _idWeight = catchFieldIdWeight();

  final _log = Log("SaveCatchPage");

  final Map<Id, Field> _fields = {};

  Future<List<PickedImage>> _imagesFuture = Future.value([]);
  List<CustomEntityValue> _customEntityValues = [];

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  ImageManager get _imageManager => ImageManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  Catch? get _oldCatch => widget.oldCatch;

  TimestampInputController get _timestampController =>
      _fields[_idTimestamp]!.controller as TimestampInputController;

  InputController<Period> get _periodController =>
      _fields[_idPeriod]!.controller as InputController<Period>;

  InputController<Season> get _seasonController =>
      _fields[_idSeason]!.controller as InputController<Season>;

  IdInputController get _speciesController =>
      _fields[_idSpecies]!.controller as IdInputController;

  ListInputController<PickedImage> get _imagesController =>
      _fields[_idImages]!.controller as ListInputController<PickedImage>;

  IdInputController get _fishingSpotController =>
      _fields[_idFishingSpot]!.controller as IdInputController;

  IdInputController get _baitController =>
      _fields[_idBait]!.controller as IdInputController;

  IdInputController get _anglerController =>
      _fields[_idAngler]!.controller as IdInputController;

  BoolInputController get _catchAndReleaseController =>
      _fields[_idCatchAndRelease]!.controller as BoolInputController;

  BoolInputController get _favoriteController =>
      _fields[_idFavorite]!.controller as BoolInputController;

  SetInputController<Id> get _methodsController =>
      _fields[_idMethods]!.controller as SetInputController<Id>;

  IdInputController get _waterClarityController =>
      _fields[_idWaterClarity]!.controller as IdInputController;

  MultiMeasurementInputController get _waterDepthController =>
      _fields[_idWaterDepth]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _waterTemperatureController =>
      _fields[_idWaterTemperature]!.controller
          as MultiMeasurementInputController;

  MultiMeasurementInputController get _lengthController =>
      _fields[_idLength]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _weightController =>
      _fields[_idWeight]!.controller as MultiMeasurementInputController;

  NumberInputController get _quantityController =>
      _fields[_idQuantity]!.controller as NumberInputController;

  TextInputController get _notesController =>
      _fields[_idNotes]!.controller as TextInputController;

  bool get _editing => _oldCatch != null;

  @override
  void initState() {
    super.initState();

    var showingFieldIds = _userPreferencesManager.catchFieldIds;
    for (var field in allCatchFields(_timeManager)) {
      _fields[field.id] = field;
      // By default, show all fields.
      _fields[field.id]!.showing =
          showingFieldIds.isEmpty || showingFieldIds.contains(field.id);
    }

    if (_editing) {
      _timestampController.value = _oldCatch!.timestamp.toInt();
      _periodController.value =
          _oldCatch!.hasPeriod() ? _oldCatch!.period : null;
      _seasonController.value =
          _oldCatch!.hasSeason() ? _oldCatch!.season : null;
      _speciesController.value = _oldCatch!.speciesId;
      _baitController.value = _oldCatch!.baitId;
      _fishingSpotController.value = _oldCatch!.fishingSpotId;
      _anglerController.value = _oldCatch!.anglerId;
      _catchAndReleaseController.value = _oldCatch!.wasCatchAndRelease;
      _favoriteController.value = _oldCatch!.isFavorite;
      _methodsController.value = _oldCatch!.methodIds.toSet();
      _waterClarityController.value = _oldCatch!.waterClarityId;
      _waterDepthController.value =
          _oldCatch!.hasWaterDepth() ? _oldCatch!.waterDepth : null;
      _waterTemperatureController.value =
          _oldCatch!.hasWaterTemperature() ? _oldCatch!.waterTemperature : null;
      _lengthController.value =
          _oldCatch!.hasLength() ? _oldCatch!.length : null;
      _weightController.value =
          _oldCatch!.hasWeight() ? _oldCatch!.weight : null;
      _quantityController.intValue =
          _oldCatch!.hasQuantity() ? _oldCatch!.quantity : null;
      _notesController.value =
          isEmpty(_oldCatch!.notes) ? null : _oldCatch!.notes;
      _customEntityValues = _oldCatch!.customEntityValues;
      _imagesFuture = _pickedImagesForOldCatch;
    } else {
      if (widget.images.isNotEmpty) {
        var image = widget.images.first;
        if (image.dateTime != null) {
          _timestampController.date = image.dateTime;
          _timestampController.time = TimeOfDay.fromDateTime(image.dateTime!);
        }
      }
      _speciesController.value = widget.speciesId;
      _imagesController.value = widget.images;
      _fishingSpotController.value = widget.fishingSpotId;
      _methodsController.value = {};

      _calculateSeason();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      popupMenuKey: widget.popupMenuKey,
      title: Text(_editing
          ? Strings.of(context).saveCatchPageEditTitle
          : Strings.of(context).saveCatchPageNewTitle),
      runSpacing: 0,
      padding: insetsZero,
      fields: _fields,
      customEntityIds: _userPreferencesManager.catchCustomEntityIds,
      customEntityValues: _customEntityValues,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferencesManager.setCatchFieldIds(ids.toList()),
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
    } else if (id == _idAngler) {
      return _buildAngler();
    } else if (id == _idMethods) {
      return _buildMethods();
    } else if (id == _idPeriod) {
      return _buildPeriod();
    } else if (id == _idFavorite) {
      return _buildFavorite();
    } else if (id == _idCatchAndRelease) {
      return _buildCatchAndRelease();
    } else if (id == _idSeason) {
      return _buildSeason();
    } else if (id == _idWaterClarity) {
      return _buildWaterClarity();
    } else if (id == _idWaterDepth) {
      return _buildWaterDepth();
    } else if (id == _idWaterTemperature) {
      return _buildWaterTemperature();
    } else if (id == _idLength) {
      return _buildLength();
    } else if (id == _idWeight) {
      return _buildWeight();
    } else if (id == _idQuantity) {
      return _buildQuantity();
    } else if (id == _idNotes) {
      return _buildNotes();
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
          label: Strings.of(context).catchFieldDate,
          onChange: (newDate) {
            _timestampController.date = newDate;
            setState(_calculateSeason);
          },
        ),
        timePicker: TimePicker(
          context,
          initialTime: _timestampController.time,
          label: Strings.of(context).catchFieldTime,
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
        String? value;
        if (_baitController.value != null) {
          value = _baitManager.formatNameWithCategory(_baitController.value);
        }

        return ListPickerInput(
          title: Strings.of(context).catchFieldBaitLabel,
          value: value,
          onTap: () {
            push(
              context,
              BaitListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<dynamic>.single(
                  onPicked: (context, bait) {
                    setState(() => _baitController.value = bait?.id);
                    return true;
                  },
                  initialValue: _baitManager.entity(_baitController.value),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAngler() {
    return EntityListenerBuilder(
      managers: [
        _anglerManager,
      ],
      builder: (context) {
        var angler = _anglerManager.entity(_anglerController.value);
        return ListPickerInput(
          title: Strings.of(context).catchFieldAnglerLabel,
          value: angler?.name,
          onTap: () {
            push(
              context,
              AnglerListPage(
                pickerSettings: ManageableListPagePickerSettings<Angler>.single(
                  onPicked: (context, angler) {
                    setState(() => _anglerController.value = angler?.id);
                    return true;
                  },
                  initialValue: angler,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaterClarity() {
    return EntityListenerBuilder(
      managers: [
        _waterClarityManager,
      ],
      builder: (context) {
        var clarity =
            _waterClarityManager.entity(_waterClarityController.value);
        return ListPickerInput(
          title: Strings.of(context).catchFieldWaterClarityLabel,
          value: clarity?.name,
          onTap: () {
            push(
              context,
              WaterClarityListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<WaterClarity>.single(
                  onPicked: (context, clarity) {
                    setState(() => _waterClarityController.value = clarity?.id);
                    return true;
                  },
                  initialValue: clarity,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaterDepth() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.waterDepth(context),
        controller: _waterDepthController,
        onChanged: () => _userPreferenceManager
            .setWaterDepthSystem(_waterDepthController.value?.system),
      ),
    );
  }

  Widget _buildWaterTemperature() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.waterTemperature(context),
        controller: _waterTemperatureController,
        onChanged: () => _userPreferenceManager.setWaterTemperatureSystem(
            _waterTemperatureController.value?.system),
      ),
    );
  }

  Widget _buildLength() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.length(context),
        controller: _lengthController,
        onChanged: () => _userPreferenceManager
            .setCatchLengthSystem(_lengthController.value?.system),
      ),
    );
  }

  Widget _buildWeight() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.weight(context),
        controller: _weightController,
        onChanged: () => _userPreferenceManager
            .setCatchWeightSystem(_weightController.value?.system),
      ),
    );
  }

  Widget _buildQuantity() {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: TextInput.number(
        context,
        controller: _quantityController,
        label: Strings.of(context).catchFieldQuantityLabel,
        signed: false,
        decimal: false,
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: TextInput.description(
        context,
        title: Strings.of(context).catchFieldNotesLabel,
        controller: _notesController,
      ),
    );
  }

  Widget _buildMethods() {
    return EntityListenerBuilder(
      managers: [
        _methodManager,
      ],
      builder: (context) {
        var values = _methodsController.value.isNotEmpty
            ? _methodManager.list(_methodsController.value.toList())
            : <Method>[];

        return MultiListPickerInput(
          padding: insetsHorizontalDefaultVerticalWidget,
          values: values.map((method) => method.name).toSet(),
          emptyValue: (context) => Strings.of(context).catchFieldNoMethods,
          onTap: () {
            push(
              context,
              MethodListPage(
                pickerSettings: ManageableListPagePickerSettings<Method>(
                  onPicked: (context, methods) {
                    setState(() {
                      _methodsController.value =
                          methods.map((m) => m.id).toSet();
                    });
                    return true;
                  },
                  initialValues: values.toSet(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPeriod() {
    return ListPickerInput(
      title: Strings.of(context).catchFieldPeriod,
      value: _periodController.value?.displayName(context),
      onTap: () {
        push(
          context,
          PickerPage<Period>.single(
            title: Text(Strings.of(context).periodPickerTitle),
            initialValue: _periodController.value ?? Period.period_none,
            itemBuilder: () => pickerItemsForPeriod(context),
            allItem: PickerPageItem<Period>(
              title: Strings.of(context).none,
              value: Period.period_none,
              onTap: () {
                setState(() => _periodController.value = null);
                Navigator.of(context).pop();
              },
            ),
            onFinishedPicking: (context, period) {
              setState(() => _periodController.value = period);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildSeason() {
    return ListPickerInput(
      title: Strings.of(context).catchFieldSeason,
      value: _seasonController.value?.displayName(context),
      onTap: () {
        push(
          context,
          PickerPage<Season>.single(
            title: Text(Strings.of(context).seasonPickerTitle),
            initialValue: _seasonController.value ?? Season.season_none,
            itemBuilder: () => pickerItemsForSeason(context),
            allItem: PickerPageItem<Season>(
              title: Strings.of(context).none,
              value: Season.season_none,
              onTap: () {
                setState(() => _seasonController.value = null);
                Navigator.of(context).pop();
              },
            ),
            onFinishedPicking: (context, period) {
              setState(() => _seasonController.value = period);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildFavorite() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: CheckboxInput(
        label: Strings.of(context).catchFieldFavorite,
        value: _favoriteController.value,
        onChanged: (checked) => _favoriteController.value = checked,
      ),
    );
  }

  Widget _buildCatchAndRelease() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: CheckboxInput(
        label: Strings.of(context).catchFieldCatchAndRelease,
        value: _catchAndReleaseController.value,
        onChanged: (checked) => _catchAndReleaseController.value = checked,
      ),
    );
  }

  Widget _buildFishingSpot() {
    return EntityListenerBuilder(
      managers: [
        _fishingSpotManager,
      ],
      builder: (context) {
        var fishingSpot =
            _fishingSpotManager.entity(_fishingSpotController.value);

        if (fishingSpot == null) {
          return ListItem(
            title: Text(Strings.of(context).catchFieldFishingSpot),
            trailing: RightChevronIcon(),
            onTap: _pushFishingSpotPicker,
          );
        }

        return StaticFishingSpot(
          fishingSpot,
          padding: insetsHorizontalDefaultVerticalSmall,
          onTap: _pushFishingSpotPicker,
        );
      },
    );
  }

  Widget _buildSpecies() {
    return EntityListenerBuilder(
      managers: [
        _speciesManager,
      ],
      builder: (context) {
        var species = _speciesManager.entity(_speciesController.value);
        return ListPickerInput(
          title: Strings.of(context).catchFieldSpecies,
          value: species?.name,
          onTap: () {
            push(
              context,
              SpeciesListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<Species>.single(
                  onPicked: (context, species) {
                    setState(() => _speciesController.value = species?.id);
                    return true;
                  },
                  initialValue: species,
                  isRequired: true,
                ),
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
          initialImages: _imagesController.value,
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
    _userPreferencesManager
        .setCatchCustomEntityIds(customFieldValueMap.keys.toList());

    // imageNames is set in _catchManager.addOrUpdate
    var cat = Catch()
      ..id = _oldCatch?.id ?? randomId()
      ..timestamp = Int64(_timestampController.value)
      ..speciesId = _speciesController.value!
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (_fishingSpotController.value != null) {
      cat.fishingSpotId = _fishingSpotController.value!;
    }

    if (_baitController.value != null) {
      cat.baitId = _baitController.value!;
    }

    if (_anglerController.value != null) {
      cat.anglerId = _anglerController.value!;
    }

    if (_waterClarityController.value != null) {
      cat.waterClarityId = _waterClarityController.value!;
    }

    if (_waterDepthController.isSet) {
      cat.waterDepth = _waterDepthController.value!;
    }

    if (_waterTemperatureController.isSet) {
      cat.waterTemperature = _waterTemperatureController.value!;
    }

    if (_lengthController.isSet) {
      cat.length = _lengthController.value!;
    }

    if (_weightController.isSet) {
      cat.weight = _weightController.value!;
    }

    if (_methodsController.value.isNotEmpty) {
      cat.methodIds.addAll(_methodsController.value);
    } else {
      cat.methodIds.clear();
    }

    if (_periodController.value != null) {
      cat.period = _periodController.value!;
    }

    if (_seasonController.value != null) {
      cat.season = _seasonController.value!;
    }

    // If the user cares about (i.e. the field is showing) catch and release
    // data, always set it.
    if (_fields[_idCatchAndRelease] != null &&
        _fields[_idCatchAndRelease]!.showing) {
      cat.wasCatchAndRelease = _catchAndReleaseController.value;
    }

    if (_favoriteController.value) {
      cat.isFavorite = true;
    }

    if (_quantityController.intValue != null) {
      cat.quantity = _quantityController.intValue!;
    }

    if (isNotEmpty(_notesController.value)) {
      cat.notes = _notesController.value!;
    }

    _catchManager.addOrUpdate(
      cat,
      imageFiles: _imagesController.value
          .where((img) => img.originalFile != null)
          .map((img) => img.originalFile!)
          .toList(),
    );

    if (widget.popOverride != null) {
      widget.popOverride!();
      return false;
    }

    return true;
  }

  void _pushFishingSpotPicker() {
    push(
      context,
      FishingSpotPickerPage(
        fishingSpotId: _fishingSpotController.value,
        onPicked: (context, pickedFishingSpot) {
          if (pickedFishingSpot == null ||
              pickedFishingSpot.id != _fishingSpotController.value) {
            setState(() {
              _fishingSpotController.value = pickedFishingSpot?.id;
              _calculateSeason(fishingSpot: pickedFishingSpot);
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
    if (!_editing || _oldCatch!.imageNames.isEmpty) {
      return Future.value([]);
    }

    var imageMap = await _imageManager.images(
      context,
      imageNames: _oldCatch!.imageNames,
      size: galleryMaxThumbSize,
    );

    var result = <PickedImage>[];
    imageMap.forEach((file, bytes) => result.add(PickedImage(
          originalFile: file,
          thumbData: bytes,
        )));

    _imagesController.value = result;
    return result;
  }

  void _calculateSeason({FishingSpot? fishingSpot}) {
    var spot =
        fishingSpot ?? _fishingSpotManager.entity(_fishingSpotController.value);
    _seasonController.value =
        Seasons.from(_timestampController.dateTime, spot?.lat);
  }
}
