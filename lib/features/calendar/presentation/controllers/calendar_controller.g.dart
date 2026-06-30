// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Currently selected date in the calendar (for month view).

@ProviderFor(SelectedCalendarDate)
final selectedCalendarDateProvider = SelectedCalendarDateProvider._();

/// Currently selected date in the calendar (for month view).
final class SelectedCalendarDateProvider
    extends $NotifierProvider<SelectedCalendarDate, DateTime> {
  /// Currently selected date in the calendar (for month view).
  SelectedCalendarDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCalendarDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCalendarDateHash();

  @$internal
  @override
  SelectedCalendarDate create() => SelectedCalendarDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedCalendarDateHash() =>
    r'21697a352a0833681b436cfef0bffc2725837510';

/// Currently selected date in the calendar (for month view).

abstract class _$SelectedCalendarDate extends $Notifier<DateTime> {
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

/// Which month the calendar is focused on (controls visible page).

@ProviderFor(FocusedCalendarDate)
final focusedCalendarDateProvider = FocusedCalendarDateProvider._();

/// Which month the calendar is focused on (controls visible page).
final class FocusedCalendarDateProvider
    extends $NotifierProvider<FocusedCalendarDate, DateTime> {
  /// Which month the calendar is focused on (controls visible page).
  FocusedCalendarDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusedCalendarDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusedCalendarDateHash();

  @$internal
  @override
  FocusedCalendarDate create() => FocusedCalendarDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$focusedCalendarDateHash() =>
    r'0f008c9cf1dfd38263e2439cc8209d6d5ae23913';

/// Which month the calendar is focused on (controls visible page).

abstract class _$FocusedCalendarDate extends $Notifier<DateTime> {
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
