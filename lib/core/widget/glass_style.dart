import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztime_widget/core/constants/pref_keys.dart';

part 'glass_style.g.dart';

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

@Riverpod(keepAlive: true)
class GlassStyleNotifier extends _$GlassStyleNotifier {
  @override
  GlassStyle build() {
    _loadFromPrefs();
    return GlassStyle.coldGlass;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(PrefKeys.glassStyle) ?? 0;
    if (index < GlassStyle.values.length) {
      state = GlassStyle.values[index];
    }
  }

  Future<void> setStyle(GlassStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKeys.glassStyle, style.index);
  }
}
