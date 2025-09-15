import 'dart:convert';
import 'package:fan_react/models/state/score.dart';

class MatchState {
  final int? clock;
  final Score score;
  final String? description;
  MatchState({required this.clock, required this.score, this.description});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'clock': clock,
      'score': score.toMap(),
      'description': description,
    };
  }

  factory MatchState.fromMap(Map<String, dynamic> map) {
    return MatchState(
      clock: map['clock'] != null ? map['clock'] as int : null,
      score: Score.fromMap(map['score'] as Map<String, dynamic>),
      description:
          map['description'] != null ? map['description'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchState.fromJson(String source) =>
      MatchState.fromMap(json.decode(source) as Map<String, dynamic>);
}
