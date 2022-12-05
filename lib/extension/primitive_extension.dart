import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

extension StringExtension on String {
  String get removeExceptionTextIfContains {
    if (this.contains('Exception:')) return replaceFirst('Exception:', '');
    return this;
  }

  Future<Uint8List> bytesFromAsset(int size) async {
    ByteData data = await rootBundle.load(this);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: size);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<ui.Image> imageFromAsset(int size, [int? height]) async {
    ByteData data = await rootBundle.load(this);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: size, targetHeight: height ?? size);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  CreditCardBrand get cardBrand {
    switch (this.toLowerCase()) {
      case 'mastercard':
        return CreditCardBrand(CardType.mastercard);
      case 'visa':
        return CreditCardBrand(CardType.visa);
      case 'amex':
        return CreditCardBrand(CardType.americanExpress);
      case 'discover':
        return CreditCardBrand(CardType.discover);
      default:
        return CreditCardBrand(CardType.otherBrand);
    }
  }

  DateTime get parsedDatetime {
    final tSplitDatetime = split('T');
    final dateSplit = tSplitDatetime[0];
    final timeSplit = tSplitDatetime[1];

    final dateMultiSplit = dateSplit.split('-');
    final year = int.parse(dateMultiSplit[0]);
    final month = int.parse(dateMultiSplit[1]);
    final date = int.parse(dateMultiSplit[2]);

    final timeMultiSplit = timeSplit.split(':');
    final hour = int.parse(timeMultiSplit[0]);
    final minutes = int.parse(timeMultiSplit[1]);

    return DateTime(year, month, date, hour, minutes);
  }
}

extension IntExtension on int {
  String get monthName {
    switch (this) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'Jan';
    }
  }
}
