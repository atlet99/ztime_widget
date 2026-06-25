import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_controller.g.dart';

@riverpod
class Clock extends _$Clock {
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
