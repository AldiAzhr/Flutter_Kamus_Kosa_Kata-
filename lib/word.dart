class Word {
  int? id;
  String originalWord;
  String translatedWord;

  Word({this.id, required this.originalWord, required this.translatedWord});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalWord': originalWord,
      'translatedWord': translatedWord,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      originalWord: map['originalWord'],
      translatedWord: map['translatedWord'],
    );
  }
}
