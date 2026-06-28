import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:home_widget/home_widget.dart';
import 'package:ztime_widget/core/constants/android_constants.dart';
import 'package:ztime_widget/core/constants/home_widget_keys.dart';

class WidgetRenderer {
  WidgetRenderer._();

  static Future<void> renderFrom(RenderRepaintBoundary? boundary) async {
    if (boundary == null) return;

    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    await HomeWidget.saveFile(
      HomeWidgetKeys.widgetPng,
      pngBytes,
      extension: 'png',
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: AndroidConstants.widgetProvider,
    );

    image.dispose();
  }
}
