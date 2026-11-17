/// One local calendar day of learning activity.
class StudyDay {
  const StudyDay({
    required this.localDate,
    required this.completedExercises,
    required this.correctAnswers,
    required this.newWordsStudied,
    required this.sessionCompleted,
  });

  final String localDate;
  final int completedExercises;
  final int correctAnswers;
  final int newWordsStudied;
  final bool sessionCompleted;

  bool get hasActivity => completedExercises > 0;

  StudyDay copyWith({
    int? completedExercises,
    int? correctAnswers,
    int? newWordsStudied,
    bool? sessionCompleted,
  }) {
    return StudyDay(
      localDate: localDate,
      completedExercises: completedExercises ?? this.completedExercises,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      newWordsStudied: newWordsStudied ?? this.newWordsStudied,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
    );
  }

  factory StudyDay.empty(String localDate) => StudyDay(
    localDate: localDate,
    completedExercises: 0,
    correctAnswers: 0,
    newWordsStudied: 0,
    sessionCompleted: false,
  );

  factory StudyDay.fromMap(Map<String, Object?> map) {
    return StudyDay(
      localDate: map['local_date'] as String,
      completedExercises: map['completed_exercises'] as int,
      correctAnswers: map['correct_answers'] as int,
      newWordsStudied: map['new_words_studied'] as int,
      sessionCompleted: (map['session_completed'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'local_date': localDate,
    'completed_exercises': completedExercises,
    'correct_answers': correctAnswers,
    'new_words_studied': newWordsStudied,
    'session_completed': sessionCompleted ? 1 : 0,
  };
}
