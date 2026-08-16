import 'dart:async';
import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';

class AutoUpdater {
  AutoUpdater._();

  static final AutoUpdater instance = AutoUpdater._();

  AutoUpdaterPlatform get _platform => AutoUpdaterPlatform.instance;

  Future<void> setFeedURL(String feedUrl) {
    try {
      return _platform.setFeedURL(feedUrl);
    } catch (_) {
      return Future.value();
    }
  }

  Future<void> checkForUpdates({bool? inBackground}) {
    try {
      return _platform.checkForUpdates(inBackground: inBackground);
    } catch (_) {
      return Future.value();
    }
  }

  Future<void> setScheduledCheckInterval(int interval) {
    try {
      return _platform.setScheduledCheckInterval(interval);
    } catch (_) {
      return Future.value();
    }
  }
}

final autoUpdater = AutoUpdater.instance;
