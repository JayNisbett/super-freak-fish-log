///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class MeasurementSystem extends $pb.ProtobufEnum {
  static const MeasurementSystem imperial_whole = MeasurementSystem._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'imperial_whole');
  static const MeasurementSystem imperial_decimal = MeasurementSystem._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'imperial_decimal');
  static const MeasurementSystem metric = MeasurementSystem._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'metric');

  static const $core.List<MeasurementSystem> values = <MeasurementSystem>[
    imperial_whole,
    imperial_decimal,
    metric,
  ];

  static final $core.Map<$core.int, MeasurementSystem> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static MeasurementSystem? valueOf($core.int value) => _byValue[value];

  const MeasurementSystem._($core.int v, $core.String n) : super(v, n);
}

class NumberBoundary extends $pb.ProtobufEnum {
  static const NumberBoundary number_boundary_any = NumberBoundary._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'number_boundary_any');
  static const NumberBoundary less_than = NumberBoundary._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'less_than');
  static const NumberBoundary less_than_or_equal_to = NumberBoundary._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'less_than_or_equal_to');
  static const NumberBoundary equal_to = NumberBoundary._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'equal_to');
  static const NumberBoundary greater_than = NumberBoundary._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'greater_than');
  static const NumberBoundary greater_than_or_equal_to = NumberBoundary._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'greater_than_or_equal_to');
  static const NumberBoundary range = NumberBoundary._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'range');

  static const $core.List<NumberBoundary> values = <NumberBoundary>[
    number_boundary_any,
    less_than,
    less_than_or_equal_to,
    equal_to,
    greater_than,
    greater_than_or_equal_to,
    range,
  ];

  static final $core.Map<$core.int, NumberBoundary> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static NumberBoundary? valueOf($core.int value) => _byValue[value];

  const NumberBoundary._($core.int v, $core.String n) : super(v, n);
}

class Period extends $pb.ProtobufEnum {
  static const Period period_all = Period._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'period_all');
  static const Period period_none = Period._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'period_none');
  static const Period dawn = Period._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'dawn');
  static const Period morning = Period._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'morning');
  static const Period midday = Period._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'midday');
  static const Period afternoon = Period._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'afternoon');
  static const Period dusk = Period._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'dusk');
  static const Period night = Period._(
      7,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'night');

  static const $core.List<Period> values = <Period>[
    period_all,
    period_none,
    dawn,
    morning,
    midday,
    afternoon,
    dusk,
    night,
  ];

  static final $core.Map<$core.int, Period> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Period? valueOf($core.int value) => _byValue[value];

  const Period._($core.int v, $core.String n) : super(v, n);
}

class Season extends $pb.ProtobufEnum {
  static const Season season_all = Season._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'season_all');
  static const Season season_none = Season._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'season_none');
  static const Season winter = Season._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'winter');
  static const Season spring = Season._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'spring');
  static const Season summer = Season._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'summer');
  static const Season autumn = Season._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'autumn');

  static const $core.List<Season> values = <Season>[
    season_all,
    season_none,
    winter,
    spring,
    summer,
    autumn,
  ];

  static final $core.Map<$core.int, Season> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Season? valueOf($core.int value) => _byValue[value];

  const Season._($core.int v, $core.String n) : super(v, n);
}

class Unit extends $pb.ProtobufEnum {
  static const Unit feet = Unit._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'feet');
  static const Unit inches = Unit._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'inches');
  static const Unit pounds = Unit._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'pounds');
  static const Unit ounces = Unit._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ounces');
  static const Unit fahrenheit = Unit._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'fahrenheit');
  static const Unit meters = Unit._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'meters');
  static const Unit centimeters = Unit._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'centimeters');
  static const Unit kilograms = Unit._(
      7,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'kilograms');
  static const Unit celsius = Unit._(
      8,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'celsius');

  static const $core.List<Unit> values = <Unit>[
    feet,
    inches,
    pounds,
    ounces,
    fahrenheit,
    meters,
    centimeters,
    kilograms,
    celsius,
  ];

  static final $core.Map<$core.int, Unit> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Unit? valueOf($core.int value) => _byValue[value];

  const Unit._($core.int v, $core.String n) : super(v, n);
}

class CustomEntity_Type extends $pb.ProtobufEnum {
  static const CustomEntity_Type boolean = CustomEntity_Type._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'boolean');
  static const CustomEntity_Type number = CustomEntity_Type._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'number');
  static const CustomEntity_Type text = CustomEntity_Type._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'text');

  static const $core.List<CustomEntity_Type> values = <CustomEntity_Type>[
    boolean,
    number,
    text,
  ];

  static final $core.Map<$core.int, CustomEntity_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static CustomEntity_Type? valueOf($core.int value) => _byValue[value];

  const CustomEntity_Type._($core.int v, $core.String n) : super(v, n);
}

class DateRange_Period extends $pb.ProtobufEnum {
  static const DateRange_Period allDates = DateRange_Period._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'allDates');
  static const DateRange_Period today = DateRange_Period._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'today');
  static const DateRange_Period yesterday = DateRange_Period._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'yesterday');
  static const DateRange_Period thisWeek = DateRange_Period._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'thisWeek');
  static const DateRange_Period thisMonth = DateRange_Period._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'thisMonth');
  static const DateRange_Period thisYear = DateRange_Period._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'thisYear');
  static const DateRange_Period lastWeek = DateRange_Period._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'lastWeek');
  static const DateRange_Period lastMonth = DateRange_Period._(
      7,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'lastMonth');
  static const DateRange_Period lastYear = DateRange_Period._(
      8,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'lastYear');
  static const DateRange_Period last7Days = DateRange_Period._(
      9,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'last7Days');
  static const DateRange_Period last14Days = DateRange_Period._(
      10,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'last14Days');
  static const DateRange_Period last30Days = DateRange_Period._(
      11,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'last30Days');
  static const DateRange_Period last60Days = DateRange_Period._(
      12,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'last60Days');
  static const DateRange_Period last12Months = DateRange_Period._(
      13,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'last12Months');
  static const DateRange_Period custom = DateRange_Period._(
      14,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'custom');

  static const $core.List<DateRange_Period> values = <DateRange_Period>[
    allDates,
    today,
    yesterday,
    thisWeek,
    thisMonth,
    thisYear,
    lastWeek,
    lastMonth,
    lastYear,
    last7Days,
    last14Days,
    last30Days,
    last60Days,
    last12Months,
    custom,
  ];

  static final $core.Map<$core.int, DateRange_Period> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static DateRange_Period? valueOf($core.int value) => _byValue[value];

  const DateRange_Period._($core.int v, $core.String n) : super(v, n);
}

class Report_Type extends $pb.ProtobufEnum {
  static const Report_Type summary = Report_Type._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'summary');
  static const Report_Type comparison = Report_Type._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'comparison');

  static const $core.List<Report_Type> values = <Report_Type>[
    summary,
    comparison,
  ];

  static final $core.Map<$core.int, Report_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Report_Type? valueOf($core.int value) => _byValue[value];

  const Report_Type._($core.int v, $core.String n) : super(v, n);
}

// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports
