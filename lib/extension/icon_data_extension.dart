import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

extension IconDataExtension on IconData {
  Future<Uint8List> bytesFromIconData(int size, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(codePoint);
    textPainter.text = TextSpan(
        text: iconStr,
        style: TextStyle(
            letterSpacing: 0.0,
            fontSize: size.toDouble(),
            fontFamily: fontFamily,
            color: color));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0.0, 0.0));
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
