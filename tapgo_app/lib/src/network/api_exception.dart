/// Typed API / network failure for repositories and controllers.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.errors,
    this.isOffline = false,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? errors;
  final bool isOffline;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 422;
  bool get isNotFound => statusCode == 404;

  String get displayMessage {
    if (isOffline) return 'No internet connection. Please try again.';
    if (errors != null && errors!.isNotEmpty) {
      final first = errors!.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return message;
  }

  @override
  String toString() => displayMessage;
}
