import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/time.dart';

import '../app_manager.dart';
import '../i18n/strings.dart';
import '../utils/string_utils.dart';

const monthFormat = "MMMM";
const monthDayFormat = "MMM d";
const monthDayYearFormat = "MMM d, yyyy";
const monthDayYearFormatFull = "MMMM d, yyyy";

/// Units of duration, ordered smallest to largest.
enum DurationUnit {
  minutes,
  hours,
  days,
  years,
}

/// A representation of a [Duration] object meant to be shown to the user. Units
/// are split by largest possible. For example, the hours property is the
/// number of hours in the duration, minus the number of days.
class DisplayDuration {
  final Duration _duration;
  final bool _includesYears;
  final bool _includesDays;
  final bool _includesHours;
  final bool _includesMinutes;

  DisplayDuration(
    this._duration, {
    bool includesYears = true,
    bool includesDays = true,
    bool includesHours = true,
    bool includesMinutes = true,
  })  : _includesYears = includesYears,
        _includesDays = includesDays,
        _includesHours = includesHours,
        _includesMinutes = includesMinutes;

  int get years => _duration.inYears;

  int get days {
    if (_includesYears) {
      return _duration.inDays.remainder(Durations.daysPerYear);
    } else {
      return _duration.inDays;
    }
  }

  int get hours {
    if (_includesDays) {
      return _duration.inHours.remainder(Duration.hoursPerDay);
    } else {
      return _duration.inHours;
    }
  }

  int get minutes {
    if (_includesHours) {
      return _duration.inMinutes.remainder(Duration.minutesPerHour);
    } else {
      return _duration.inMinutes;
    }
  }

  int get seconds {
    if (_includesMinutes) {
      return _duration.inSeconds.remainder(Duration.secondsPerMinute);
    } else {
      return _duration.inSeconds;
    }
  }
}

bool isSameYear(DateTime a, DateTime b) {
  return a.year == b.year;
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.month == b.month;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.day == b.day;
}

bool isSameTimeOfDay(DateTime a, DateTime b) {
  return TimeOfDay.fromDateTime(a) == TimeOfDay.fromDateTime(b);
}

/// Returns `true` if `a` is later in the day than `b`.
bool isLater(TimeOfDay a, TimeOfDay b) {
  return a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute);
}

/// Returns `true` if the given [DateTime] comes after `now`, to minute
/// accuracy.
bool isInFutureWithMinuteAccuracy(DateTime dateTime, DateTime now) {
  var newDateTime = dateTimeToMinuteAccuracy(dateTime);
  var newNow = dateTimeToMinuteAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns `true` if the given [DateTime] comes after `now`, to day
/// accuracy.
bool isInFutureWithDayAccuracy(DateTime dateTime, DateTime now) {
  var newDateTime = dateTimeToDayAccuracy(dateTime);
  var newNow = dateTimeToDayAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns true if the given DateTime objects are equal. Compares
/// only year, month, and day.
bool isSameDate(DateTime a, DateTime b) {
  return isSameYear(a, b) && isSameMonth(a, b) && isSameDay(a, b);
}

bool isYesterday(DateTime today, DateTime yesterday) {
  return isSameDate(yesterday, today.subtract(aDay));
}

/// Returns true of the  given DateTime objects are within one week of one
/// another.
bool isWithinOneWeek(DateTime a, DateTime b) {
  return a.difference(b).inMilliseconds.abs() <= aWeek.inMilliseconds;
}

/// Returns a [DateTime] object with the given [DateTime] and [TimeOfDay]
/// combined.  Accurate to the millisecond.
///
/// Due to the lack of granularity in [TimeOfDay], the seconds and milliseconds
/// value of the result are that of the given [DateTime].
DateTime combine(DateTime dateTime, TimeOfDay timeOfDay) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, timeOfDay.hour,
      timeOfDay.minute, dateTime.second, dateTime.millisecond);
}

/// Returns a new [DateTime] object, with time properties more granular than
/// minutes set to 0.
DateTime dateTimeToMinuteAccuracy(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      dateTime.minute);
}

/// Returns a new [DateTime] object, with time properties more granular than
/// day set to 0.
DateTime dateTimeToDayAccuracy(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

/// Returns a [DateTime] representing the start of the week to which `now`
/// belongs.
DateTime startOfWeek(DateTime now) {
  return dateTimeToDayAccuracy(now).subtract(Duration(days: now.weekday - 1));
}

/// Returns a [DateTime] representing the start of the month to which `now`
/// belongs.
DateTime startOfMonth(DateTime now) {
  return DateTime(now.year, now.month);
}

/// Returns a [DateTime] representing the start of the year to which `now`
/// belongs.
DateTime startOfYear(DateTime now) {
  return DateTime(now.year);
}

/// Calculates week number from a date as per
/// https://en.wikipedia.org/wiki/ISO_week_date#Calculation.
int weekOfYear(DateTime date) {
  return ((dayOfYear(date) - date.weekday + 10) / DateTime.daysPerWeek).floor();
}

/// Returns the day of the year for the given [DateTime]. For example, 185.
int dayOfYear(DateTime date) {
  return int.parse(DateFormat("D").format(date));
}

/// Returns a formatted [String] for a time of day. The format depends on a
/// combination of the current locale and the user's system time format setting.
///
/// Example:
///   21:35, or
///   9:35 PM
String formatTimeOfDay(BuildContext context, TimeOfDay time) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    time,
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
}

/// Returns a formatted hour range for the give [startHour] and [endHour].
///
/// Example:
///   8:00 AM to 9:00 AM, or
///   15:00 to 16:00
String formatHourRange(BuildContext context, int startHour, int endHour) {
  if (endHour == Duration.hoursPerDay) {
    endHour = 0;
  }

  var start = TimeOfDay(hour: startHour, minute: 0);
  var end = TimeOfDay(hour: endHour, minute: 0);

  return format(Strings.of(context).dateRangeFormat,
      [formatTimeOfDay(context, start), formatTimeOfDay(context, end)]);
}

String formatTimeMillis(BuildContext context, Int64 millis) {
  return formatTimeOfDay(
      context,
      TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(millis.toInt())));
}

/// Returns a formatted [DateTime] to be displayed to the user. Includes date
/// and time.
///
/// Examples:
///   - Today at 2:35 PM
///   - Yesterday at 2:35 PM
///   - Monday at 2:35 PM
///   - Jan 8 at 2:35 PM
///   - Dec 8, 2018 at 2:35 PM
String formatDateTime(
  BuildContext context,
  DateTime dateTime, {
  bool abbreviated = false,
  bool excludeMidnight = false,
}) {
  var recentDate = formatDateAsRecent(
    context,
    dateTime,
    abbreviated: abbreviated,
  );

  var time = TimeOfDay.fromDateTime(dateTime);
  if (excludeMidnight && time.hour == 0 && time.minute == 0) {
    return recentDate;
  }

  return format(Strings.of(context).dateTimeFormat, [
    recentDate,
    formatTimeOfDay(context, time),
  ]);
}

String formatTimestamp(BuildContext context, int timestamp) {
  return formatDateTime(
      context, DateTime.fromMillisecondsSinceEpoch(timestamp));
}

/// Returns a [Timestamp] as a searchable [String]. This value should not be
/// shown to users, but to be used for searching through list items that include
/// timestamps.
///
/// The value returned is just a concatenation of different ways of representing
/// a date and time.
String timestampToSearchString(BuildContext context, int timestamp) {
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${formatDateTime(context, dateTime)} "
      "${DateFormat(monthDayYearFormatFull).format(dateTime)}";
}

/// Returns a formatted [DateTime] to be displayed to the user. Includes
/// date only.
///
/// Examples:
///   - Today
///   - Yesterday
///   - Monday
///   - Jan. 8
///   - Dec. 8, 2018
String formatDateAsRecent(
  BuildContext context,
  DateTime dateTime, {
  bool abbreviated = false,
}) {
  final now = AppManager.of(context).timeManager.currentDateTime;

  if (isSameDate(dateTime, now)) {
    // Today.
    return Strings.of(context).today;
  } else if (isYesterday(now, dateTime)) {
    // Yesterday.
    return Strings.of(context).yesterday;
  } else if (isWithinOneWeek(dateTime, now)) {
    // 2 days ago to 6 days ago.
    return DateFormat(abbreviated ? "E" : "EEEE").format(dateTime);
  } else if (isSameYear(dateTime, now)) {
    // Same year.
    return DateFormat(monthDayFormat).format(dateTime);
  } else {
    // Different year.
    return DateFormat(monthDayYearFormat).format(dateTime);
  }
}

/// Returns formatted text to display the duration, in the format Dd Hh Mm Ss.
///
/// Example:
///   - 1y 50d 5h 30m 0s
String formatDuration({
  required BuildContext context,
  required int millisecondsDuration,
  bool includesYears = true,
  bool includesDays = true,
  bool includesHours = true,
  bool includesMinutes = true,
  bool includesSeconds = true,

  /// If `true`, values equal to 0 will not be included.
  bool condensed = false,

  /// When set, only the largest value quantities will be shown. Null (default)
  /// will show all quantities.
  ///
  /// Examples:
  ///   - Value of 2 will show 1d 12h
  ///   - Value of 1 will show 12h
  ///   - Value of null will show 1d 12h 30m 45s
  int? numberOfQuantities,

  /// The largest [DurationUnit] to use. For example, if equal to
  /// [DurationUnit.hours], 2 days and 3 hours will be formatted as `51h`
  /// rather than `2d 3h`. The same effect can be done by setting `includesDays`
  /// to `false`.
  ///
  /// This is primarily meant for use with a user-preference where the
  /// [DurationUnit] is read from [SharedPreferences].
  DurationUnit largestDurationUnit = DurationUnit.years,
}) {
  includesYears = includesYears && largestDurationUnit == DurationUnit.years;
  includesDays =
      includesDays && largestDurationUnit.index >= DurationUnit.days.index;
  includesHours =
      includesHours && largestDurationUnit.index >= DurationUnit.hours.index;

  var duration = DisplayDuration(
    Duration(milliseconds: millisecondsDuration),
    includesYears: includesYears,
    includesDays: includesDays,
    includesHours: includesHours,
    includesMinutes: includesMinutes,
  );

  var result = "";

  maybeAddSpace() {
    if (result.isNotEmpty) {
      result += " ";
    }
  }

  var numberIncluded = 0;

  bool shouldAdd(int value, {required bool include}) {
    return include &&
        (!condensed || value > 0) &&
        (numberOfQuantities == null || numberIncluded < numberOfQuantities);
  }

  if (shouldAdd(duration.years, include: includesYears)) {
    result += format(Strings.of(context).yearsFormat, [duration.years]);
    numberIncluded++;
  }

  if (shouldAdd(duration.days, include: includesDays)) {
    maybeAddSpace();
    result += format(Strings.of(context).daysFormat, [duration.days]);
    numberIncluded++;
  }

  if (shouldAdd(duration.hours, include: includesHours)) {
    maybeAddSpace();
    result += format(Strings.of(context).hoursFormat, [duration.hours]);
    numberIncluded++;
  }

  if (shouldAdd(duration.minutes, include: includesMinutes)) {
    maybeAddSpace();
    result += format(Strings.of(context).minutesFormat, [duration.minutes]);
    numberIncluded++;
  }

  if (shouldAdd(duration.seconds, include: includesSeconds)) {
    maybeAddSpace();
    result += format(Strings.of(context).secondsFormat, [duration.seconds]);
  }

  // If there is no result and not everything is excluded, default to 0m.
  if (result.isEmpty &&
      (includesSeconds || includesMinutes || includesHours || includesDays)) {
    result += format(Strings.of(context).minutesFormat, [0]);
  }

  return result;
}

extension DateTimes on DateTime {
  bool get isMidnight => hour == 0 && minute == 0;
}

extension TimeOfDays on TimeOfDay {
  bool get isMidnight => hour == 0 && minute == 0;
}

extension Durations on Duration {
  static const int monthsPerYear = 12;
  static const int daysPerYear = 365;
  static const int microsecondsPerYear =
      Duration.microsecondsPerDay * Durations.daysPerYear;

  /// The number of years spanned by this duration.
  int get inYears => inMicroseconds ~/ microsecondsPerYear;
}
