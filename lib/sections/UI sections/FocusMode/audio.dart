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

  /// Generates the filename dynamically instead of storing a massive map.
  /// Male:   "work_start_en.mp3"
  /// Female: "work_start_en_fm.mp3"
  static String _buildFileName(
      String soundType, String language, String voiceGender) {
    final suffix = voiceGender == 'female' ? '_fm' : '';
    return '${soundType}_$language$suffix.mp3';
  }

  static final Set<String> _languageSet = _languages.toSet();

  static String _detectLanguageCode(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toLowerCase() ?? '';

    // Try full locale (e.g. "zh-cn")
    if (country.isNotEmpty) {
      final full = '$lang-$country';
      if (_languageSet.contains(full)) return full;
    }

    // Try language-only (e.g. "en")
    if (_languageSet.contains(lang)) return lang;

    // Try partial match (e.g. "zh" → "zh-cn")
    for (final l in _languages) {
      if (l.startsWith(lang)) return l;
    }

    return 'en';
  }

  // Reuse a single player to avoid accumulating native handles
  static AudioPlayer? _player;

  static Future<void> playSound({
    required BuildContext context,
    required String soundType,
    required String voiceGender,
  }) async {
    try {
      // Stop any currently playing sound
      await stopAllSounds();

      final language = _detectLanguageCode(context);
      final soundFile = _buildFileName(soundType, language, voiceGender);

      debugPrint('Playing sound: sounds/$soundFile (language: $language)');

      final player = AudioPlayer();
      _player = player;

      player.onPlayerComplete.listen((_) {
        // Only dispose if this is still the current player
        if (_player == player) {
          _player = null;
          player.dispose();
        }
      });

      await player.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  static Future<void> stopAllSounds() async {
    final player = _player;
    if (player == null) return;
    _player = null;
    try {
      await player.stop();
      await player.dispose();
    } catch (e) {
      debugPrint('Error stopping player: $e');
    }
  }

  static Future<void> dispose() => stopAllSounds();
}
