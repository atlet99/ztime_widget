import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:home_widget/home_widget.dart';

class WidgetRenderer {
  WidgetRenderer._();

  static Future<void> renderFrom(
    RenderRepaintBoundary? boundary,
  ) async {
    if (boundary == null) return;

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    await HomeWidget.saveWidgetData('widget_png', pngBytes);
    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'com.gosayram.ztime_widget.CustomClockWidgetProvider',
    );

    image.dispose();
  }
}
