// ─── Web Location Helper (Web Platform) ────────────────────────────────────────

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

StreamSubscription? subscribeHashChange(void Function() callback) {
  late final StreamController<void> controller;
  JSFunction? jsListener;
  controller = StreamController<void>.broadcast(
    onListen: () {
      jsListener = ((web.Event _) => controller.add(null)).toJS;
      web.window.addEventListener('hashchange', jsListener);
    },
    onCancel: () {
      if (jsListener != null) {
        web.window.removeEventListener('hashchange', jsListener);
      }
      controller.close();
    },
  );
  return controller.stream.listen((_) => callback());
}

bool isSettingsUrl() {
  final href = web.window.location.href.toLowerCase();
  final hash = web.window.location.hash.toLowerCase();
  final search = web.window.location.search.toLowerCase();
  return hash.contains('settings') || href.contains('settings') || search.contains('tab=settings');
}

void openDownloadUrl() {
  final userAgent = web.window.navigator.userAgent.toLowerCase();
  final platform = userAgent.contains('mac')
      ? 'mac'
      : userAgent.contains('win')
          ? 'windows'
          : 'linux';
  final browser = userAgent.contains('edg')
      ? 'edge'
      : userAgent.contains('firefox')
          ? 'firefox'
          : 'chrome';
  final url = 'https://www.scolect.com/download?source=extension&platform=$platform&browser=$browser';
  web.window.open(url, '_blank');
}
