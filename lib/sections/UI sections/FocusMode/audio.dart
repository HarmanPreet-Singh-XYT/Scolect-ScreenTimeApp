import 'dart:async';
import 'package:just_audio/just_audio.dart';
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

  static AudioPlayer? _player;
  static String? _lastSoundFile;
  
  static AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  static Future<void> playSound({
    required BuildContext context,
    required String soundType,
    required String voiceGender,
  }) async {
    final language = _detectLanguageCode(context);
    final soundFile = _buildFileName(soundType, language, voiceGender);
    debugPrint('Playing sound: sounds/$soundFile');

    try {
      // Unconditionally stop any previous playback
      if (_player != null) {
        await _player!.stop();
      }
      
      if (_lastSoundFile != soundFile) {
        // If it's a new file, load it.
        await player.setAsset('assets/sounds/$soundFile');
        _lastSoundFile = soundFile;
      }
      
      // Unconditionally seek to zero to avoid any glitchy internal states
      // where the player remembers the end of a previous playback.
      await player.seek(Duration.zero);
      
      // Do not await play() so rapid clicks don't throw an interrupted exception here
      player.play();
    } catch (e) {
      // Ignore benign interruption exceptions from rapid clicking
      if (e.toString().toLowerCase().contains('interrupted')) return;
      debugPrint('Error playing sound: $e');
    }
  }

  static Future<void> stopAllSounds() async {
    if (_player != null && _player!.playing) {
      try {
        await _player!.stop();
      } catch (_) {}
    }
  }

  static Future<void> dispose() async {
    if (_player != null) {
      try {
        await _player!.dispose();
        _player = null;
      } catch (_) {}
    }
  }
}
