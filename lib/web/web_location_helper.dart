// ─── Web Location Helper (Web Platform) ────────────────────────────────────────

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

StreamSubscription? subscribeHashChange(void Function() callback) {
  return html.window.onHashChange.listen((_) => callback());
}

bool isSettingsUrl() {
  final href = html.window.location.href.toLowerCase();
  final hash = html.window.location.hash.toLowerCase();
  final search = (html.window.location.search ?? '').toLowerCase();
  return hash.contains('settings') || href.contains('settings') || search.contains('tab=settings');
}

void openDownloadUrl() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
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
  html.window.open(url, '_blank');
}
