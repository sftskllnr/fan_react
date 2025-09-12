import 'dart:convert';
import 'package:fan_react/models/probabilities/probabilities.dart';

class Live {
  final String type;
  final String modelType;
  final String description;
  final String generatedAt;
  final Probabilities probabilities;

  Live({
    required this.type,
    required this.modelType,
    required this.description,
    required this.generatedAt,
    required this.probabilities,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'modelType': modelType,
      'description': description,
      'generatedAt': generatedAt,
      'probabilities': probabilities.toMap(),
    };
  }

  factory Live.fromMap(Map<String, dynamic> map) {
    return Live(
      type: map['type'] as String,
      modelType: map['modelType'] as String,
      description: map['description'] as String,
      generatedAt: map['generatedAt'] as String,
      probabilities:
          Probabilities.fromMap(map['probabilities'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Live.fromJson(String source) =>
      Live.fromMap(json.decode(source) as Map<String, dynamic>);
}
