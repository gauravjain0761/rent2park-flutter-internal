

import '../util/app_strings.dart';

class MaterialDialogContent {
  final String title;
  final String message;
  final String positiveText;
  final String negativeText;

  MaterialDialogContent(
      {required this.title,
      required this.message,
      this.positiveText = AppText.TRY_AGAIN,
      this.negativeText = AppText.CANCEL});

  MaterialDialogContent.networkError()
      : this(
            title: AppText.LIMITED_NETWORK_CONNECTION,
            message: AppText.LIMITED_NETWORK_CONNECTION_CONTENT);

  @override
  String toString() {
    return 'MaterialDialogContent{title: $title, message: $message, positiveText: $positiveText, negativeText: $negativeText}';
  }
}
