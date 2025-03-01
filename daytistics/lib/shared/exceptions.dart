class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);
}

class InvalidInputException implements Exception {
  final String message;

  InvalidInputException(this.message);
}
