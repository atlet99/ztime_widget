// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glass_style.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GlassStyleNotifier)
final glassStyleProvider = GlassStyleNotifierProvider._();

final class GlassStyleNotifierProvider
    extends $NotifierProvider<GlassStyleNotifier, GlassStyle> {
  GlassStyleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'glassStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$glassStyleNotifierHash();

  @$internal
  @override
  GlassStyleNotifier create() => GlassStyleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlassStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlassStyle>(value),
    );
  }
}

String _$glassStyleNotifierHash() =>
    r'338d1af52a344129a8a1dbdf208bcc87af879974';

abstract class _$GlassStyleNotifier extends $Notifier<GlassStyle> {
  GlassStyle build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GlassStyle, GlassStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GlassStyle, GlassStyle>,
              GlassStyle,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
