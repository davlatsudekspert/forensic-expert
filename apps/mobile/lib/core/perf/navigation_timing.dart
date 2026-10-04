import 'dart:developer' as developer;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Har bir navigatsiyadan keyingi birinchi kadr vaqtini o‘lchaydi
/// (`didPush` → keyingi kadr tugashi). Natijalar Timeline’ga yoziladi.
class NavigationTimingObserver extends NavigatorObserver {
  NavigationTimingObserver({this.onMeasured});

  final void Function(String route, Duration duration)? onMeasured;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _measure(route.settings.name ?? route.runtimeType.toString());
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _measure(newRoute.settings.name ?? newRoute.runtimeType.toString());
    }
  }

  void _measure(String name) {
    final sw = Stopwatch()..start();
    final task = developer.TimelineTask()..start('fe.nav.$name');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      task.finish();
      onMeasured?.call(name, sw.elapsed);
    });
  }
}
