class JournalEntry {
  final int id;
  final String originalThought;
  final String reframedText;
  final String category;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.originalThought,
    required this.reframedText,
    required this.category,
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      originalThought: json['original_thought'],
      reframedText: json['reframed_text'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 