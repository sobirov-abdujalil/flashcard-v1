import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Installs a no-op handler for `SystemChannels.platform`.
///
/// Haptic feedback and system-chrome calls go through this channel. Without a
/// mock, platform calls can leave pending timers behind (our haptics wrapper has
/// a safety timeout) which makes widget tests fail at teardown.
void installPlatformChannelMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async => null,
  );
}
