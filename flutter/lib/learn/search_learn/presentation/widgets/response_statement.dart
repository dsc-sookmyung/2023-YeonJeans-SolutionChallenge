class Statement {
  final int id;
  final String content;
  final List<String> tags;
  bool bookmarked;
  final bool recommended;

  Statement(
      {required this.id,
        required this.content,
        required this.tags,
        required this.bookmarked,
        required this.recommended});

  factory Statement.fromJSON(Map<String, dynamic> json) {
    return Statement(
        id: json['statement_id'],
        content: json['content'],
        tags: json['tags'],
        bookmarked: json['bookmarked'],
        recommended: json['recommended']
    );
  }
}