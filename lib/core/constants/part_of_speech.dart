/// Uzbek labels for the parts of speech stored in the database.
abstract final class PartOfSpeech {
  static const String noun = 'noun';
  static const String verb = 'verb';
  static const String adjective = 'adjective';
  static const String adverb = 'adverb';
  static const String preposition = 'preposition';
  static const String conjunction = 'conjunction';
  static const String pronoun = 'pronoun';
  static const String interjection = 'interjection';

  static const Map<String, String> _uzLabels = <String, String>{
    noun: 'ot',
    verb: 'fe’l',
    adjective: 'sifat',
    adverb: 'ravish',
    preposition: 'predlog',
    conjunction: 'bog‘lovchi',
    pronoun: 'olmoshlar',
    interjection: 'undov',
  };

  static String uzLabel(String value) => _uzLabels[value] ?? value;
}
