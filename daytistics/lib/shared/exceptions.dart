class SupabaseException implements Exception {
  final String message;

  SupabaseException(this.message);
}

class SembastException implements Exception {
  final String message;
  SembastException(this.message);
}
