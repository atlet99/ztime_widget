// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ticks once per second for clock hands and digital display.

@ProviderFor(ClockSeconds)
final clockSecondsProvider = ClockSecondsProvider._();

/// Ticks once per second for clock hands and digital display.
final class ClockSecondsProvider
    extends $NotifierProvider<ClockSeconds, DateTime> {
  /// Ticks once per second for clock hands and digital display.
  ClockSecondsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockSecondsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockSecondsHash();

  @$internal
  @override
  ClockSeconds create() => ClockSeconds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$clockSecondsHash() => r'818f4fdf65d87b298f95e8e99aa975823fe929b1';

/// Ticks once per second for clock hands and digital display.

abstract class _$ClockSeconds extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ticks once per minute for date and weekday row (saves battery).

@ProviderFor(ClockMinutes)
final clockMinutesProvider = ClockMinutesProvider._();

/// Ticks once per minute for date and weekday row (saves battery).
final class ClockMinutesProvider
    extends $NotifierProvider<ClockMinutes, DateTime> {
  /// Ticks once per minute for date and weekday row (saves battery).
  ClockMinutesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockMinutesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockMinutesHash();

  @$internal
  @override
  ClockMinutes create() => ClockMinutes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$clockMinutesHash() => r'229874a5dd958f677dc4e8b7c1542a7fad1f2779';

/// Ticks once per minute for date and weekday row (saves battery).

abstract class _$ClockMinutes extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
