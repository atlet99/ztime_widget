import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_controller.g.dart';

@riverpod
Stream<DateTime> currentTime(Ref ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}
