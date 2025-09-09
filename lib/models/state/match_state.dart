// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fan_react/models/state/score.dart';

class MatchState {
  final int? clock;
  final Score score;
  MatchState({required this.clock, required this.score});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'clock': clock,
      'score': score.toMap(),
    };
  }

  factory MatchState.fromMap(Map<String, dynamic> map) {
    return MatchState(
      clock: map['clock'] != null ? map['clock'] as int : null,
      score: Score.fromMap(map['score'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchState.fromJson(String source) =>
      MatchState.fromMap(json.decode(source) as Map<String, dynamic>);
}
