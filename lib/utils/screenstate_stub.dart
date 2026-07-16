// lib/utils/screenstate_stub.dart

import 'package:flutter/foundation.dart';

enum ScreenStateEvent {
  active,
  sleep,
  lock,
  unlock,
}

class DesktopScreenState {
  static final DesktopScreenState instance = DesktopScreenState._();
  DesktopScreenState._();

  final ValueNotifier<ScreenStateEvent> isActive = ValueNotifier<ScreenStateEvent>(ScreenStateEvent.active);
}
