import 'package:device_info_plus/device_info_plus.dart';

/// How well the device's launcher supports widget transparency.
enum TransparencySupport {
  /// Full blur + transparency (MIUI, HyperOS)
  full,

  /// Semi-transparent without blur (One UI, ColorOS)
  partial,

  /// Solid background fallback (Stock Android, Pixel)
  none,
}

/// Detected launcher capabilities for adaptive glass rendering.
class LauncherCapabilities {
  const LauncherCapabilities({
    required this.manufacturer,
    required this.brand,
    required this.transparencySupport,
  });

  final String manufacturer;
  final String brand;
  final TransparencySupport transparencySupport;

  static LauncherCapabilities? _cached;

  /// Detect device capabilities. Cached after first call.
  static Future<LauncherCapabilities> detect() async {
    if (_cached != null) return _cached!;

    final info = await DeviceInfoPlugin().androidInfo;
    final manufacturer = info.manufacturer.toLowerCase();
    final brand = info.brand.toLowerCase();
    final sdk = info.version.sdkInt;

    TransparencySupport support;

    if (manufacturer == 'xiaomi' ||
        brand == 'xiaomi' ||
        brand == 'redmi' ||
        brand == 'poco') {
      // MIUI / HyperOS — full blur + transparency
      support = TransparencySupport.full;
    } else if (manufacturer == 'samsung' && sdk >= 31) {
      // One UI 4+ — partial support
      support = TransparencySupport.partial;
    } else if (manufacturer == 'oppo' ||
        brand == 'oneplus' ||
        brand == 'realme') {
      // ColorOS — partial support
      support = TransparencySupport.partial;
    } else if (manufacturer == 'huawei' || brand == 'huawei') {
      // HarmonyOS — partial support
      support = TransparencySupport.partial;
    } else {
      support = TransparencySupport.none;
    }

    _cached = LauncherCapabilities(
      manufacturer: manufacturer,
      brand: brand,
      transparencySupport: support,
    );
    return _cached!;
  }

  /// Synchronous access after detect() has been called.
  static LauncherCapabilities get current =>
      _cached ??
      const LauncherCapabilities(
        manufacturer: 'unknown',
        brand: 'unknown',
        transparencySupport: TransparencySupport.none,
      );
}
