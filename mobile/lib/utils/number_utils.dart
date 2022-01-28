import '../log.dart';

const _log = Log("NumberUtils");

/// Converts [value] to a [double], if possible. This function will work if
/// [value] is one of the following data types:
///   - String
///   - int
///   - double
double? doubleFromDynamic(dynamic value) {
  if (value == null) {
    // ignore: avoid_returning_null
    return null;
  } else if (value is String) {
    return double.tryParse(value);
  } else if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  }
  _log.w("Can't convert type to double: ${value.runtimeType}");
  // ignore: avoid_returning_null
  return null;
}

/// Converts [value] to an [int], if possible. This function will work if
/// [value] is one of the following data types:
///   - String
///   - int
///   - double
int? intFromDynamic(dynamic value) {
  if (value == null) {
    // ignore: avoid_returning_null
    return null;
  } else if (value is String) {
    return int.tryParse(value);
  } else if (value is double) {
    return value.round();
  } else if (value is int) {
    return value;
  }
  _log.w("Can't convert type to int: ${value.runtimeType}");
  // ignore: avoid_returning_null
  return null;
}

int percent(int numerator, int denominator) {
  assert(denominator > 0);
  return (numerator / denominator * 100).round();
}

extension Doubles on double {
  bool get isWhole => this % 1 == 0;

  int? roundIfWhole() => isWhole ? round() : null;

  /// Returns a display value for the double. [decimalPlaces] defaults to 2.
  String displayValue([int? decimalPlaces]) {
    if (isWhole || (decimalPlaces != null && decimalPlaces <= 0)) {
      return round().toString();
    }

    var fixed = toStringAsFixed(decimalPlaces ?? 2);
    if (fixed[fixed.length - 1] == "0") {
      fixed = fixed.substring(0, fixed.length - 1);
    }

    return fixed;
  }
}
