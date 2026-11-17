import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/routes.dart';
import '../../providers/session_provider.dart';
import '../../providers/session_state.dart';
import '../../shared/utils/dialogs.dart';

/// Starts a fresh learning session and navigates to the Learn screen.
///
/// Used by Home ("Boshlash") and by the completion screen ("Yana o‘rganish").
Future<void> launchLearnSession(
  BuildContext context,
  WidgetRef ref, {
  bool replaceCurrentRoute = false,
}) async {
  final SessionController controller = ref.read(sessionProvider.notifier);
  final bool created = (await controller.startSession()) != null;
  if (!context.mounted) return;

  if (!created) {
    final String message =
        ref.read(sessionProvider).errorMessage ??
        'Mashqni boshlashda xatolik yuz berdi.';
    showAppSnack(context, message, isError: true);
    return;
  }

  if (replaceCurrentRoute) {
    await Navigator.of(context).pushReplacementNamed(AppRoutes.learn);
  } else {
    await Navigator.of(context).pushNamed(AppRoutes.learn);
  }
}

/// Leaves the current session and returns to Home, resetting in-memory state.
Future<void> exitSessionToHome(BuildContext context, WidgetRef ref) async {
  final bool confirmed = await showExitSessionDialog(context);
  if (!confirmed) return;
  ref.read(sessionProvider.notifier).reset();
  if (!context.mounted) return;
  Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
}

/// Whether the session provider is currently building a session.
bool isSessionStarting(SessionState state) =>
    state.phase == SessionPhase.loading;
