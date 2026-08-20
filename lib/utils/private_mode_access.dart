import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';

/// Sync snapshot of private-mode unlock state, safe to call from any Dart
/// class (controllers, widgets) without BuildContext. Note: on web this
/// reflects `WebPrivateModeService.isUnlocked`'s sync getter — it does NOT
/// await `isSetUp`, matching the existing sync-only call sites.
bool isPrivateModeUnlocked() =>
    kIsWeb ? WebPrivateModeService().isUnlocked : PrivateModeController().isUnlocked;

/// Sync snapshot of whether existing pages should show private-only data in
/// place of public data — driven by the titlebar toggle. Same platform
/// branching and sync-only caveats as [isPrivateModeUnlocked].
bool shouldShowPrivateOnly() => kIsWeb
    ? WebPrivateModeService().showPrivateOnly
    : PrivateModeController().showPrivateOnly;
