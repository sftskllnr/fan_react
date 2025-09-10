import 'dart:convert';
import 'package:fan_react/models/away_team.dart/away_team.dart';
import 'package:fan_react/models/country/country.dart';
import 'package:fan_react/models/home_team.dart/home_team.dart';
import 'package:fan_react/models/league/league.dart';
import 'package:fan_react/models/state/match_state.dart';

class Match {
  final int id;
  final String round;
  final String date;
  final Country country;
  final AwayTeam awayTeam;
  final HomeTeam homeTeam;
  final League league;
  final MatchState state;

  Match(
      {required this.id,
      required this.round,
      required this.date,
      required this.country,
      required this.awayTeam,
      required this.homeTeam,
      required this.league,
      required this.state});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'round': round,
      'date': date,
      'country': country.toMap(),
      'awayTeam': awayTeam.toMap(),
      'homeTeam': homeTeam.toMap(),
      'league': league.toMap(),
      'state': state.toMap(),
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] as int,
      round: map['round'] as String,
      date: map['date'] as String,
      country: Country.fromMap(map['country'] as Map<String, dynamic>),
      awayTeam: AwayTeam.fromMap(map['awayTeam'] as Map<String, dynamic>),
      homeTeam: HomeTeam.fromMap(map['homeTeam'] as Map<String, dynamic>),
      league: League.fromMap(map['league'] as Map<String, dynamic>),
      state: MatchState.fromMap(map['state'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Match.fromJson(String source) =>
      Match.fromMap(json.decode(source) as Map<String, dynamic>);
}

Future<List<Match>> parseMatches(String resp) async {
  final parsed = (jsonDecode(resp) as List).cast<Map<String, dynamic>>();
  return parsed.map<Match>((json) => Match.fromMap(json)).toList();
}
