import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GlassStyle {
  coldGlass('cold_glass', 'hol_stek'),
  icyBlue('icy_blue', 'led_gol'),
  warmMilk('warm_milk', 'tepl_mol');

  const GlassStyle(this.labelKey, this.assetKey);
  final String labelKey;
  final String assetKey;

  String get widgetPath => 'assets/glass/${assetKey}_widget.png';
  String get appPath => 'assets/glass/${assetKey}_app.png';
}

class GlassStyleNotifier extends Notifier<GlassStyle> {
  @override
  GlassStyle build() => GlassStyle.coldGlass;

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('glass_style') ?? 0;
    if (index < GlassStyle.values.length) {
      state = GlassStyle.values[index];
    }
  }

  void setStyle(GlassStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('glass_style', style.index);
  }
}

final glassStyleProvider = NotifierProvider<GlassStyleNotifier, GlassStyle>(
  GlassStyleNotifier.new,
);
