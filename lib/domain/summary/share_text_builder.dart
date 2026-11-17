import '../../domain/models/session_models.dart';

/// Builds the share message shown in the native Android share sheet.
///
/// Only real progress from the completed session is used — never placeholder
/// achievements. Built as a pure function so it can be unit tested.
String buildSessionShareText(SessionSummary summary) {
  final List<String> lines = <String>[
    'So‘z Atlas bilan ingliz so‘zlarini o‘rganyapman!',
    '',
    'Bugun: ${summary.totalExercises} ta mashq, '
        '${summary.correctAnswers} ta to‘g‘ri javob, '
        '${summary.newWordsStudied} ta yangi so‘z.',
  ];

  if (summary.currentStreak > 0) {
    lines.add('Joriy seriya: ${summary.currentStreak} kun.');
  }
  if (summary.goalCompleted) {
    lines.add('Bugungi maqsad bajarildi.');
  }
  lines
    ..add('')
    ..add('Har kuni oz-ozdan — katta natijalarga.');

  return lines.join('\n');
}
