import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SoundManager {
  // Removed unused static _audioPlayer that was causing native resource leak

  static const Map<String, Map<String, Map<String, String>>> soundFiles = {
    "male": {
      "work_start": {
        "en": "work_start_en.mp3",
        "zh-cn": "work_start_zh-cn.mp3",
        "hi-in": "work_start_hi-in.mp3",
        "es-es": "work_start_es-es.mp3",
        "fr-fr": "work_start_fr-fr.mp3",
        "ar-sa": "work_start_ar-sa.mp3",
        "bn-bd": "work_start_bn-bd.mp3",
        "pt-br": "work_start_pt-br.mp3",
        "ru-ru": "work_start_ru-ru.mp3",
        "ur-pk": "work_start_ur-pk.mp3",
        "id-id": "work_start_id-id.mp3",
        "ja-jp": "work_start_ja-jp.mp3",
      },
      "break_start": {
        "en": "break_start_en.mp3",
        "zh-cn": "break_start_zh-cn.mp3",
        "hi-in": "break_start_hi-in.mp3",
        "es-es": "break_start_es-es.mp3",
        "fr-fr": "break_start_fr-fr.mp3",
        "ar-sa": "break_start_ar-sa.mp3",
        "bn-bd": "break_start_bn-bd.mp3",
        "pt-br": "break_start_pt-br.mp3",
        "ru-ru": "break_start_ru-ru.mp3",
        "ur-pk": "break_start_ur-pk.mp3",
        "id-id": "break_start_id-id.mp3",
        "ja-jp": "break_start_ja-jp.mp3",
      },
      "long_break_start": {
        "en": "long_break_start_en.mp3",
        "zh-cn": "long_break_start_zh-cn.mp3",
        "hi-in": "long_break_start_hi-in.mp3",
        "es-es": "long_break_start_es-es.mp3",
        "fr-fr": "long_break_start_fr-fr.mp3",
        "ar-sa": "long_break_start_ar-sa.mp3",
        "bn-bd": "long_break_start_bn-bd.mp3",
        "pt-br": "long_break_start_pt-br.mp3",
        "ru-ru": "long_break_start_ru-ru.mp3",
        "ur-pk": "long_break_start_ur-pk.mp3",
        "id-id": "long_break_start_id-id.mp3",
        "ja-jp": "long_break_start_ja-jp.mp3",
      },
      "timer_complete": {
        "en": "timer_complete_en.mp3",
        "zh-cn": "timer_complete_zh-cn.mp3",
        "hi-in": "timer_complete_hi-in.mp3",
        "es-es": "timer_complete_es-es.mp3",
        "fr-fr": "timer_complete_fr-fr.mp3",
        "ar-sa": "timer_complete_ar-sa.mp3",
        "bn-bd": "timer_complete_bn-bd.mp3",
        "pt-br": "timer_complete_pt-br.mp3",
        "ru-ru": "timer_complete_ru-ru.mp3",
        "ur-pk": "timer_complete_ur-pk.mp3",
        "id-id": "timer_complete_id-id.mp3",
        "ja-jp": "timer_complete_ja-jp.mp3",
      },
    },
    "female": {
      "work_start": {
        "en": "work_start_en_fm.mp3",
        "zh-cn": "work_start_zh-cn_fm.mp3",
        "hi-in": "work_start_hi-in_fm.mp3",
        "es-es": "work_start_es-es_fm.mp3",
        "fr-fr": "work_start_fr-fr_fm.mp3",
        "ar-sa": "work_start_ar-sa_fm.mp3",
        "bn-bd": "work_start_bn-bd_fm.mp3",
        "pt-br": "work_start_pt-br_fm.mp3",
        "ru-ru": "work_start_ru-ru_fm.mp3",
        "ur-pk": "work_start_ur-pk_fm.mp3",
        "id-id": "work_start_id-id_fm.mp3",
        "ja-jp": "work_start_ja-jp_fm.mp3",
      },
      "break_start": {
        "en": "break_start_en_fm.mp3",
        "zh-cn": "break_start_zh-cn_fm.mp3",
        "hi-in": "break_start_hi-in_fm.mp3",
        "es-es": "break_start_es-es_fm.mp3",
        "fr-fr": "break_start_fr-fr_fm.mp3",
        "ar-sa": "break_start_ar-sa_fm.mp3",
        "bn-bd": "break_start_bn-bd_fm.mp3",
        "pt-br": "break_start_pt-br_fm.mp3",
        "ru-ru": "break_start_ru-ru_fm.mp3",
        "ur-pk": "break_start_ur-pk_fm.mp3",
        "id-id": "break_start_id-id_fm.mp3",
        "ja-jp": "break_start_ja-jp_fm.mp3",
      },
      "long_break_start": {
        "en": "long_break_start_en_fm.mp3",
        "zh-cn": "long_break_start_zh-cn_fm.mp3",
        "hi-in": "long_break_start_hi-in_fm.mp3",
        "es-es": "long_break_start_es-es_fm.mp3",
        "fr-fr": "long_break_start_fr-fr_fm.mp3",
        "ar-sa": "long_break_start_ar-sa_fm.mp3",
        "bn-bd": "long_break_start_bn-bd_fm.mp3",
        "pt-br": "long_break_start_pt-br_fm.mp3",
        "ru-ru": "long_break_start_ru-ru_fm.mp3",
        "ur-pk": "long_break_start_ur-pk_fm.mp3",
        "id-id": "long_break_start_id-id_fm.mp3",
        "ja-jp": "long_break_start_ja-jp_fm.mp3",
      },
      "timer_complete": {
        "en": "timer_complete_en_fm.mp3",
        "zh-cn": "timer_complete_zh-cn_fm.mp3",
        "hi-in": "timer_complete_hi-in_fm.mp3",
        "es-es": "timer_complete_es-es_fm.mp3",
        "fr-fr": "timer_complete_fr-fr_fm.mp3",
        "ar-sa": "timer_complete_ar-sa_fm.mp3",
        "bn-bd": "timer_complete_bn-bd_fm.mp3",
        "pt-br": "timer_complete_pt-br_fm.mp3",
        "ru-ru": "timer_complete_ru-ru_fm.mp3",
        "ur-pk": "timer_complete_ur-pk_fm.mp3",
        "id-id": "timer_complete_id-id_fm.mp3",
        "ja-jp": "timer_complete_ja-jp_fm.mp3",
      },
    },
  };

  static String _detectLanguageCode(
      BuildContext context, String soundType, String voiceGender) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode.toLowerCase();
    final countryCode = locale.countryCode?.toLowerCase() ?? '';

    final availableLanguages =
        soundFiles[voiceGender]?[soundType]?.keys.toSet() ?? {};

    if (availableLanguages.isEmpty) {
      debugPrint('No sound files available for $voiceGender/$soundType');
      return 'en';
    }

    if (countryCode.isNotEmpty) {
      final fullCode = '$languageCode-$countryCode';
      if (availableLanguages.contains(fullCode)) {
        return fullCode;
      }
    }

    if (availableLanguages.contains(languageCode)) {
      return languageCode;
    }

    final partialMatch = availableLanguages.firstWhere(
      (lang) => lang.startsWith(languageCode),
      orElse: () => '',
    );

    if (partialMatch.isNotEmpty) {
      return partialMatch;
    }

    if (availableLanguages.contains('en')) {
      return 'en';
    }

    return availableLanguages.first;
  }

  // FIX: Use a Set to avoid duplicate entries and simplify membership checks
  static final Set<AudioPlayer> _activePlayers = {};

  static Future<void> playSound({
    required BuildContext context,
    required String soundType,
    required String voiceGender,
  }) async {
    try {
      // FIX: Stop all current sounds before playing a new one to prevent
      // multiple overlapping native audio handles accumulating
      await stopAllSounds();

      final language = _detectLanguageCode(context, soundType, voiceGender);
      final soundFile = soundFiles[voiceGender]?[soundType]?[language];

      if (soundFile == null) {
        debugPrint(
            'Sound file not found for: $voiceGender/$soundType/$language');
        return;
      }

      debugPrint(
          'Playing sound: sounds/$soundFile (detected language: $language)');

      final player = AudioPlayer();
      _activePlayers.add(player);

      // FIX: Remove from set before disposing to avoid use-after-free;
      // copy the reference so the closure doesn't risk a dangling lookup
      player.onPlayerComplete.listen((_) {
        _activePlayers.remove(player);
        player.dispose();
      });

      await player.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  /// Stop all currently playing sounds
  static Future<void> stopAllSounds() async {
    // FIX: Copy the set before iterating so removals during async ops
    // don't cause concurrent modification / access violations
    final players = Set<AudioPlayer>.from(_activePlayers);
    _activePlayers.clear();

    for (final player in players) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        debugPrint('Error stopping player: $e');
      }
    }
  }

  /// Dispose all audio players (call when app is closing)
  static Future<void> dispose() async {
    await stopAllSounds();
  }
}
