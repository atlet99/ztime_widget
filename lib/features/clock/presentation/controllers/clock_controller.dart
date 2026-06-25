import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_controller.g.dart';

/// Ticks every 16ms for smooth second hand and digital display.
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
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
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
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
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
