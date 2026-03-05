import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SoundManager {
  SoundManager._();

  static const List<String> _languages = [
    'en',
    'zh-cn',
    'hi-in',
    'es-es',
    'fr-fr',
    'ar-sa',
    'bn-bd',
    'pt-br',
    'ru-ru',
    'ur-pk',
    'id-id',
    'ja-jp',
  ];

  static final Set<String> _languageSet = _languages.toSet();

  static String _buildFileName(
      String soundType, String language, String voiceGender) {
    final suffix = voiceGender == 'female' ? '_fm' : '';
    return '${soundType}_$language$suffix.mp3';
  }

  static String _detectLanguageCode(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toLowerCase() ?? '';

    if (country.isNotEmpty) {
      final full = '$lang-$country';
      if (_languageSet.contains(full)) return full;
    }
    if (_languageSet.contains(lang)) return lang;
    for (final l in _languages) {
      if (l.startsWith(lang)) return l;
    }
    return 'en';
  }

  static AudioPlayer? _current;

  static Future<void> playSound({
    required BuildContext context,
    required String soundType,
    required String voiceGender,
  }) async {
    // Stop and discard the previous player without listening to its events
    final old = _current;
    _current = null;
    if (old != null) {
      try {
        await old.stop();
      } catch (_) {}
      // Dispose on a slight delay so iOS can finish its native teardown
      // before we create the next player — prevents the duplicate-response error
      Future.delayed(const Duration(milliseconds: 50), () {
        try {
          old.dispose();
        } catch (_) {}
      });
    }

    final language = _detectLanguageCode(context);
    final soundFile = _buildFileName(soundType, language, voiceGender);
    debugPrint('Playing sound: sounds/$soundFile');

    final player = AudioPlayer();
    // Tell audioplayers not to emit a platform completion event on iOS
    await player.setReleaseMode(ReleaseMode.release);
    _current = player;

    try {
      await player.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }

    // Self-cleanup: once done, dispose without a completion listener
    // Use a one-shot timer based on an estimated max sound duration
    Future.delayed(const Duration(seconds: 10), () {
      if (_current == player) {
        _current = null;
        try {
          player.dispose();
        } catch (_) {}
      }
    });
  }

  static Future<void> stopAllSounds() async {
    final player = _current;
    _current = null;
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {}
    Future.delayed(const Duration(milliseconds: 50), () {
      try {
        player.dispose();
      } catch (_) {}
    });
  }

  static Future<void> dispose() => stopAllSounds();
}
