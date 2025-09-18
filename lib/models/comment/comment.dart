import 'dart:convert';

class Comment {
  final String userId;
  final String userName;
  final String commentText;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'commentText': commentText,
      'timestamp': timestamp.millisecondsSinceEpoch
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        commentText: map['commentText'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']));
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source) as Map<String, dynamic>);
}
