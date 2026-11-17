import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// Wraps the native Android share sheet.
class ShareService {
  const ShareService();

  /// Returns true when the platform reports that a share action completed.
  /// Dismissing the sheet is a normal user choice, not an error.
  Future<bool> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final ShareResult result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          title: subject,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
      return result.status == ShareResultStatus.success;
    } catch (_) {
      return false;
    }
  }
}
