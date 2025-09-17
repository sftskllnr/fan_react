import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      commentText: json['commentText'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'commentText': commentText,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
