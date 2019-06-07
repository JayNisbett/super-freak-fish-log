bool isNotEmpty(String str) {
  return str != null && str.isNotEmpty;
}

bool isEmpty(String str) {
  return str == null || str.isEmpty;
}

/// Supported formats:
///   - %s
/// For each argument, toString() is called to replace %s.
String format(String s, List<dynamic> args) {
  int index = 0;
  return s.replaceAllMapped(RegExp(r'%s'), (Match match) {
    return args[index++].toString();
  });
}