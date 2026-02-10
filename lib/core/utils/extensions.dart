/// Dart extensions for common types.
extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
