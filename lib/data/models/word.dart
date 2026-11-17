import '../../core/constants/part_of_speech.dart';

/// A vocabulary item together with every piece of learning content shown to the
/// user. Instances are immutable and come straight from the seeded SQLite
/// vocabulary table.
class Word {
  const Word({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.cefrLevel,
    required this.translation,
    required this.definition,
    required this.example,
    required this.exampleTranslation,
  });

  final int id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String cefrLevel;
  final String translation;
  final String definition;
  final String example;
  final String exampleTranslation;

  String get posLabelUz => PartOfSpeech.uzLabel(partOfSpeech);

  String get normalizedWord => word.trim().toLowerCase();

  String get normalizedTranslation => translation.trim().toLowerCase();

  factory Word.fromMap(Map<String, Object?> map) {
    return Word(
      id: map['id'] as int,
      word: map['word'] as String,
      phonetic: map['phonetic'] as String,
      partOfSpeech: map['part_of_speech'] as String,
      cefrLevel: map['cefr_level'] as String,
      translation: map['translation'] as String,
      definition: map['definition'] as String,
      example: map['example'] as String,
      exampleTranslation: map['example_translation'] as String,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'word': word,
    'phonetic': phonetic,
    'part_of_speech': partOfSpeech,
    'cefr_level': cefrLevel,
    'translation': translation,
    'definition': definition,
    'example': example,
    'example_translation': exampleTranslation,
  };
}
