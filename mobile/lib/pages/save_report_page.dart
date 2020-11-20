import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../comparison_report_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../model/gen/google/protobuf/timestamp.pb.dart';
import '../pages/bait_list_page.dart';
import '../pages/fishing_spot_list_page.dart';
import '../pages/form_page.dart';
import '../pages/species_list_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../summary_report_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../widgets/date_range_picker_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';

class SaveReportPage extends StatefulWidget {
  final dynamic oldReport;

  SaveReportPage() : oldReport = null;
  SaveReportPage.edit(this.oldReport) : assert(oldReport != null);

  @override
  _SaveReportPageState createState() => _SaveReportPageState();
}

class _SaveReportPageState extends State<SaveReportPage> {
  static final _idName = randomId();
  static final _idDescription = randomId();
  static final _idType = randomId();
  static final _idStartDateRange = randomId();
  static final _idEndDateRange = randomId();
  static final _idSpecies = randomId();
  static final _idBaits = randomId();
  static final _idFishingSpots = randomId();

  static const _log = Log("SaveReportPage");

  final Key _keySummaryStart = ValueKey(0);
  final Key _keyComparisonStart = ValueKey(1);

  final Map<Id, InputData> _fields = {};

  BaitManager get _baitManager => BaitManager.of(context);
  ComparisonReportManager get _comparisonReportManager =>
      ComparisonReportManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);
  SummaryReportManager get _summaryReportManager =>
      SummaryReportManager.of(context);

  TextInputController get _nameController => _fields[_idName].controller;
  TextInputController get _descriptionController =>
      _fields[_idDescription].controller;
  InputController<_ReportType> get _typeController =>
      _fields[_idType].controller;
  InputController<DisplayDateRange> get _fromDateRangeController =>
      _fields[_idStartDateRange].controller;
  InputController<DisplayDateRange> get _toDateRangeController =>
      _fields[_idEndDateRange].controller;
  InputController<Set<Species>> get _speciesController =>
      _fields[_idSpecies].controller;
  InputController<Set<Bait>> get _baitsController =>
      _fields[_idBaits].controller;
  InputController<Set<FishingSpot>> get _fishingSpotsController =>
      _fields[_idFishingSpots].controller;

  dynamic get _oldReport => widget.oldReport;
  bool get _editing => _oldReport != null;
  bool get _summary => _typeController.value == _ReportType.summary;

  @override
  void initState() {
    super.initState();

    _fields[_idName] = InputData(
      id: _idName,
      controller: TextInputController(
        validator: NameValidator(
          nameExistsMessage: (context) =>
              Strings.of(context).saveCustomReportPageNameExists,
          nameExists: (newName) =>
              _comparisonReportManager.nameExists(newName) ||
              _summaryReportManager.nameExists(newName),
          oldName: _oldReport?.name,
        ),
      ),
    );

    _fields[_idDescription] = InputData(
      id: _idDescription,
      controller: TextInputController(),
    );

    _fields[_idType] = InputData(
      id: _idType,
      controller: InputController<_ReportType>(),
    );

    _fields[_idStartDateRange] = InputData(
      id: _idStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_idEndDateRange] = InputData(
      id: _idStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_idSpecies] = InputData(
      id: _idSpecies,
      controller: InputController<Set<Species>>(),
    );

    _fields[_idBaits] = InputData(
      id: _idBaits,
      controller: InputController<Set<Bait>>(),
    );

    _fields[_idFishingSpots] = InputData(
      id: _idFishingSpots,
      controller: InputController<Set<FishingSpot>>(),
    );

    if (_editing) {
      if (_oldReport is SummaryReport) {
        var report = _oldReport as SummaryReport;
        _nameController.value = report.name;
        _descriptionController.value = report.description;
        _typeController.value = _ReportType.summary;
        _fromDateRangeController.value = DisplayDateRange.of(
          report.displayDateRangeId,
          report.startTimestamp,
          report.endTimestamp,
        );
        _baitsController.value = _baitManager.list(report.baitIds).toSet();
        _fishingSpotsController.value =
            _fishingSpotManager.list(report.fishingSpotIds).toSet();
        _speciesController.value =
            _speciesManager.list(report.speciesIds).toSet();
      } else if (_oldReport is ComparisonReport) {
        var report = _oldReport as ComparisonReport;
        _nameController.value = report.name;
        _descriptionController.value = report.description;
        _typeController.value = _ReportType.comparison;
        _fromDateRangeController.value = DisplayDateRange.of(
          report.fromDisplayDateRangeId,
          report.fromStartTimestamp,
          report.fromEndTimestamp,
        );
        _toDateRangeController.value = DisplayDateRange.of(
          report.toDisplayDateRangeId,
          report.toStartTimestamp,
          report.toEndTimestamp,
        );
        _baitsController.value = _baitManager.list(report.baitIds).toSet();
        _fishingSpotsController.value =
            _fishingSpotManager.list(report.fishingSpotIds).toSet();
        _speciesController.value =
            _speciesManager.list(report.speciesIds).toSet();
      }
    } else {
      _typeController.value = _ReportType.summary;
      _fromDateRangeController.value = DisplayDateRange.allDates;
      _baitsController.value = {};
      _fishingSpotsController.value = {};
      _speciesController.value = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      runSpacing: 0,
      padding: insetsZero,
      title: Text(_editing
          ? Strings.of(context).saveCustomReportPageEditTitle
          : Strings.of(context).saveCustomReportPageNewTitle),
      isInputValid: _nameController.valid(context),
      fieldBuilder: (context) => {
        _idName: _buildName(),
        _idDescription: _buildDescription(),
        _idType: _buildType(),
        _idStartDateRange: _buildStartDateRange(),
        _idEndDateRange: _buildEndDateRange(),
        _idSpecies: _buildSpeciesPicker(),
        _idBaits: _buildBaitsPicker(),
        _idFishingSpots: _buildFishingSpotsPicker(),
      },
      onSave: _save,
    );
  }

  Widget _buildName() {
    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        // Trigger "Save" button state refresh.
        onChanged: () => setState(() {}),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.description(
        context,
        controller: _descriptionController,
      ),
    );
  }

  Widget _buildType() {
    return RadioInput(
      padding: insetsVerticalWidgetSmall,
      initialSelectedIndex: _typeController.value.index,
      optionCount: _ReportType.values.length,
      optionBuilder: (context, index) {
        var type = _ReportType.values[index];
        switch (type) {
          case _ReportType.comparison:
            return Strings.of(context).saveCustomReportPageComparison;
          case _ReportType.summary:
            return Strings.of(context).saveCustomReportPageSummary;
        }
        // Shouldn't ever happen.
        return null;
      },
      onSelect: (index) => setState(() {
        _typeController.value = _ReportType.values[index];
      }),
    );
  }

  Widget _buildStartDateRange() {
    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: _summary
          ? _startDateRangePicker(_keySummaryStart, null)
          : _startDateRangePicker(_keyComparisonStart,
              Strings.of(context).saveCustomReportPageStartDateRangeLabel),
    );
  }

  Widget _startDateRangePicker(Key key, String title) {
    return DateRangePickerInput(
      key: key,
      title: title,
      initialDateRange: _fromDateRangeController.value,
      onPicked: (dateRange) => setState(() {
        _fromDateRangeController.value = dateRange;
      }),
    );
  }

  Widget _buildEndDateRange() {
    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: _summary
          ? Empty()
          : DateRangePickerInput(
              title: Strings.of(context).saveCustomReportPageEndDateRangeLabel,
              initialDateRange: _toDateRangeController.value,
              onPicked: (dateRange) => setState(() {
                _toDateRangeController.value = dateRange;
              }),
            ),
    );
  }

  Widget _buildSpeciesPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _speciesController.value?.map((species) => species.name)?.toSet(),
      emptyValue: (context) =>
          Strings.of(context).saveCustomReportPageAllSpecies,
      onTap: () {
        push(
          context,
          SpeciesListPage.picker(
            multiPicker: true,
            initialValues: _speciesController.value,
            onPicked: (context, pickedSpecies) {
              setState(() {
                _speciesController.value = pickedSpecies;
              });
              return true;
            },
          ),
        );
      },
    );
  }

  Widget _buildBaitsPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _baitsController.value?.map((bait) => bait.name)?.toSet(),
      emptyValue: (context) => Strings.of(context).saveCustomReportPageAllBaits,
      onTap: () {
        push(
          context,
          BaitListPage.picker(
            multiPicker: true,
            initialValues: _baitsController.value,
            onPicked: (context, pickedBaits) {
              setState(() {
                _baitsController.value = pickedBaits;
              });
              return true;
            },
          ),
        );
      },
    );
  }

  Widget _buildFishingSpotsPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _fishingSpotsController.value
          ?.map((fishingSpot) => fishingSpot.name)
          ?.toSet(),
      emptyValue: (context) =>
          Strings.of(context).saveCustomReportPageAllFishingSpots,
      onTap: () {
        push(
          context,
          FishingSpotListPage.picker(
            multiPicker: true,
            initialValues: _fishingSpotsController.value,
            onPicked: (context, pickedFishingSpots) {
              setState(() {
                _fishingSpotsController.value = pickedFishingSpots;
              });
              return true;
            },
          ),
        );
      },
    );
  }

  FutureOr<bool> _save(BuildContext context) {
    dynamic report;
    switch (_typeController.value) {
      case _ReportType.summary:
        report = _createSummaryReport;
        break;
      case _ReportType.comparison:
        report = _createComparisonReport();
        break;
    }

    // Remove old report, in case an edit changed the type of report.
    if (_editing) {
      if (_oldReport is SummaryReport) {
        _summaryReportManager.delete(_oldReport.id);
      } else if (_oldReport is ComparisonReport) {
        _comparisonReportManager.delete(_oldReport.id);
      } else {
        _log.w("Unknown report type $_oldReport");
      }
    }

    _customReportManager.addOrUpdate(report);
    return true;
  }

  ReportManager get _customReportManager {
    switch (_typeController.value) {
      case _ReportType.summary:
        return _summaryReportManager;
      case _ReportType.comparison:
        return _comparisonReportManager;
    }

    // Can't happen. Silence compiler warning.
    return null;
  }

  SummaryReport get _createSummaryReport {
    var dateRange = _fromDateRangeController.value;
    var custom = dateRange == DisplayDateRange.custom;

    var report = SummaryReport()
      ..id = _oldReport?.id ?? randomId()
      ..name = _nameController.value
      ..displayDateRangeId = dateRange.id
      ..baitIds.addAll(_baitsController.value.map((e) => e.id))
      ..fishingSpotIds.addAll(_fishingSpotsController.value.map((e) => e.id))
      ..speciesIds.addAll(_speciesController.value.map((e) => e.id));

    if (isNotEmpty(_descriptionController.value)) {
      report.description = _descriptionController.value;
    }

    if (custom) {
      report.startTimestamp =
          Timestamp.fromDateTime(dateRange.value(context).startDate);
      report.endTimestamp =
          Timestamp.fromDateTime(dateRange.value(context).endDate);
    }

    return report;
  }

  ComparisonReport _createComparisonReport() {
    var fromDateRange = _fromDateRangeController.value;
    var toDateRange = _toDateRangeController.value;
    var customFrom = fromDateRange == DisplayDateRange.custom;
    var customTo = toDateRange == DisplayDateRange.custom;

    var report = ComparisonReport()
      ..id = _oldReport?.id ?? randomId()
      ..name = _nameController.value
      ..fromDisplayDateRangeId = fromDateRange.id
      ..toDisplayDateRangeId = toDateRange.id
      ..baitIds.addAll(_baitsController.value.map((e) => e.id))
      ..fishingSpotIds.addAll(_fishingSpotsController.value.map((e) => e.id))
      ..speciesIds.addAll(_speciesController.value.map((e) => e.id));

    if (isNotEmpty(_descriptionController.value)) {
      report.description = _descriptionController.value;
    }

    if (customFrom) {
      report.fromStartTimestamp =
          Timestamp.fromDateTime(fromDateRange.value(context).startDate);
      report.fromEndTimestamp =
          Timestamp.fromDateTime(fromDateRange.value(context).endDate);
    }

    if (customTo) {
      report.toStartTimestamp =
          Timestamp.fromDateTime(toDateRange.value(context).startDate);
      report.toEndTimestamp =
          Timestamp.fromDateTime(toDateRange.value(context).endDate);
    }

    return report;
  }
}

enum _ReportType { summary, comparison }
