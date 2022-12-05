class NoInternetConnectException implements Exception {
  static const String _MESSAGE = 'Device not connected to the Internet';

  @override
  String toString() => _MESSAGE;
}

class ErrorGettingData implements Exception {
  final String message;
  ErrorGettingData({required this.message});

  @override
  String toString() => message;
}

class OnCatchException implements Exception {
  static const String _MESSAGE = 'Sigining cancelled by the user';

  @override
  String toString() => _MESSAGE;
}

class InCorrectCardNumberException implements Exception {
  final String message;

  InCorrectCardNumberException({required this.message});
}

class InvalidBankAccountNumber implements Exception {}

class NoBankAccountException implements Exception {}
