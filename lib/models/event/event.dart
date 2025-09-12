import 'dart:convert';
import 'package:fan_react/models/team/team.dart';

class Event {
  final Team team;
  final String time;
  final String type;
  final String? assist;
  final String? player;
  final int? playerId;
  final String? substituted;
  final int? assistingPlayerId;

  Event(
      {required this.team,
      required this.time,
      required this.type,
      required this.assist,
      required this.player,
      required this.playerId,
      required this.substituted,
      required this.assistingPlayerId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'team': team.toMap(),
      'time': time,
      'type': type,
      'assist': assist,
      'player': player,
      'playerId': playerId,
      'substituted': substituted,
      'assistingPlayerId': assistingPlayerId,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      team: Team.fromMap(map['team'] as Map<String, dynamic>),
      time: map['time'] as String,
      type: map['type'] as String,
      assist: map['assist'] != null ? map['assist'] as String : null,
      player: map['player'] != null ? map['player'] as String : null,
      playerId: map['playerId'] != null ? map['playerId'] as int : null,
      substituted:
          map['substituted'] != null ? map['substituted'] as String : null,
      assistingPlayerId: map['assistingPlayerId'] != null
          ? map['assistingPlayerId'] as int
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) =>
      Event.fromMap(json.decode(source) as Map<String, dynamic>);
}
