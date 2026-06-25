import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:home_widget/home_widget.dart';

class WidgetRenderer {
  WidgetRenderer._();

  static Future<void> renderFrom(RenderRepaintBoundary? boundary) async {
    if (boundary == null) return;

    // Canvas is already 1200×600 physical pixels — no need for device pixelRatio.
    // Using device ratio (2x–4x) would produce a 4800×2400 image and risk OOM.
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // saveFile writes PNG to disk and stores the file path in SharedPreferences.
    // saveWidgetData does NOT accept Uint8List — it would throw error code -10.
    await HomeWidget.saveFile('widget_png', pngBytes, extension: 'png');
    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'com.gosayram.ztime_widget.CustomClockWidgetProvider',
    );

    image.dispose();
  }
}
