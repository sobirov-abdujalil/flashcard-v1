import 'package:flutter/services.dart';

/// Thin, failure-tolerant wrappers around platform haptics.
///
/// Haptic feedback is purely decorative: platform errors, missing channels or a
/// slow implementation can never interrupt the learning flow.
abstract final class AppHaptics {
  static const Duration _timeout = Duration(milliseconds: 300);

  static Future<void> _safe(Future<dynamic> Function() action) async {
    try {
      await action().timeout(_timeout);
    } catch (_) {
      // Ignore: haptics are optional.
    }
  }

  static Future<void> selection() => _safe(HapticFeedback.selectionClick);

  static Future<void> light() => _safe(HapticFeedback.lightImpact);

  static Future<void> success() => _safe(HapticFeedback.mediumImpact);

  static Future<void> error() => _safe(HapticFeedback.heavyImpact);
}
