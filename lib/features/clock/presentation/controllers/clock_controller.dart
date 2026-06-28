import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ztime_widget/core/constants/durations.dart';

part 'clock_controller.g.dart';

/// Ticks once per second for clock hands and digital display.
@riverpod
class ClockSeconds extends _$ClockSeconds {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return DateTime.now();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppDurations.clockTick, (_) {
      state = DateTime.now();
    });
  }

  void pause() => _timer?.cancel();

  void resume() {
    if (_timer == null || !_timer!.isActive) {
      state = DateTime.now();
      _startTimer();
    }
  }
}

/// Ticks once per minute for date and weekday row (saves battery).
@riverpod
class ClockMinutes extends _$ClockMinutes {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return DateTime.now();
  }

  void _startTimer() {
    _timer?.cancel();
    final now = DateTime.now();
    final initialDelay = Duration(seconds: 60 - now.second);
    _timer = Timer(initialDelay, () {
      state = DateTime.now();
      _timer = Timer.periodic(AppDurations.minuteTick, (_) {
        state = DateTime.now();
      });
    });
  }

  void pause() => _timer?.cancel();

  void resume() {
    if (_timer == null || !_timer!.isActive) {
      state = DateTime.now();
      _startTimer();
    }
  }
}
