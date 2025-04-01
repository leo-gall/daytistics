@Deprecated('Validate the input in the UI instead')
class NotFoundException implements Exception {
  @Deprecated('Validate the input in the UI instead')
  final String message;

  @Deprecated('Validate the input in the UI instead')
  NotFoundException(
    @Deprecated('Validate the input in the UI instead') this.message,
  );
}

@Deprecated('Validate the input in the UI instead')
class InvalidInputException implements Exception {
  @Deprecated('Validate the input in the UI instead')
  final String message;

  @Deprecated('Validate the input in the UI instead')
  InvalidInputException(
    @Deprecated('Validate the input in the UI instead') this.message,
  );
}

@Deprecated('Use SupabaseException instead')
class ServerException implements Exception {
  @Deprecated('Use SupabaseException instead')
  final String message;

  @Deprecated('Use SupabaseException instead')
  ServerException(@Deprecated('Use SupabaseException instead') this.message);
}

class SupabaseException implements Exception {
  final String message;

  SupabaseException(this.message);
}
