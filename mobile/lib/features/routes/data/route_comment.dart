class RouteComment {
  const RouteComment({
    required this.id,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String text;
  final DateTime createdAt;

  factory RouteComment.fromJson(Map<String, dynamic> json) {
    return RouteComment(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
