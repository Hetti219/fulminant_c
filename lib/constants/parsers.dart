class Parsers {
  static int parseIntSafely(dynamic value) {
    if (value == null || value == '') return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
