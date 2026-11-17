import 'package:flutter_tts/flutter_tts.dart';

/// Offline pronunciation through the device's built-in text-to-speech engine.
///
/// The service is defensive by design: TTS is optional on Android (the engine
/// may be missing, the language pack may be unavailable) and no TTS failure may
/// ever crash or block the learning flow.
class TtsService {
  FlutterTts? _tts;
  bool _initializationAttempted = false;
  bool _available = false;
  bool _disposed = false;
  String? _language;

  String? get language => _language;

  bool get isAvailable => _available;

  Future<bool> _ensureInitialized() async {
    if (_disposed) return false;
    if (_initializationAttempted) return _available;
    _initializationAttempted = true;

    try {
      final FlutterTts tts = FlutterTts();
      await tts.awaitSpeakCompletion(true);
      await tts.setSpeechRate(0.42);
      await tts.setPitch(1.0);
      await tts.setVolume(1.0);

      String? chosen;
      for (final String candidate in const <String>['en-US', 'en-GB', 'en']) {
        try {
          final dynamic available = await tts.isLanguageAvailable(candidate);
          if (available == true || available == 1) {
            await tts.setLanguage(candidate);
            chosen = candidate;
            break;
          }
        } catch (_) {
          // Try the next candidate.
        }
      }
      // Fall back to the plugin default English voice.
      if (chosen == null) {
        try {
          await tts.setLanguage('en-US');
          chosen = 'en-US';
        } catch (_) {
          // Leave the device default voice in place.
        }
      }

      _tts = tts;
      _language = chosen;
      _available = true;
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  /// Speaks [text]. Returns false when speech could not be started.
  Future<bool> speak(String text) async {
    if (_disposed || text.trim().isEmpty) return false;
    try {
      final bool ready = await _ensureInitialized();
      final FlutterTts? tts = _tts;
      if (!ready || tts == null) return false;
      await tts.stop();
      final dynamic result = await tts.speak(text);
      return result != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {
      // Ignore: nothing is playing or the engine is unavailable.
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
    _tts = null;
    _available = false;
  }
}
