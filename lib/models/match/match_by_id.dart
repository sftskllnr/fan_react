// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:fan_react/models/away_team.dart/away_team.dart';
import 'package:fan_react/models/country/country.dart';
import 'package:fan_react/models/event/event.dart';
import 'package:fan_react/models/forecast/forecast.dart';
import 'package:fan_react/models/home_team.dart/home_team.dart';
import 'package:fan_react/models/league/league.dart';
import 'package:fan_react/models/news/news.dart';
import 'package:fan_react/models/predictions/predictions.dart';
import 'package:fan_react/models/referee/referee.dart';
import 'package:fan_react/models/state/match_state.dart';
import 'package:fan_react/models/statistic/response_statistic.dart';
import 'package:fan_react/models/venue/venue.dart';

class MatchById {
  final int id;
  final String round;
  final String date;
  final Country country;
  final AwayTeam awayTeam;
  final HomeTeam homeTeam;
  final League league;
  final MatchState state;
  final List<Event> events;
  final List<ResponseStatistic> statistics;
  final Referee referee;
  final Venue venue;
  final Forecast forecast;
  final Predictions? predictions;
  final List<News> news;

  MatchById(
      {required this.id,
      required this.round,
      required this.date,
      required this.country,
      required this.awayTeam,
      required this.homeTeam,
      required this.league,
      required this.state,
      required this.events,
      required this.statistics,
      required this.referee,
      required this.venue,
      required this.forecast,
      required this.predictions,
      required this.news});

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
      'events': events.map((x) => x.toMap()).toList(),
      'statistics': statistics.map((x) => x.toMap()).toList(),
      'referee': referee.toMap(),
      'venue': venue.toMap(),
      'forecast': forecast.toMap(),
      'predictions': predictions?.toMap(),
      'news': news.map((x) => x.toMap()).toList(),
    };
  }

  factory MatchById.fromMap(Map<String, dynamic> map) {
    return MatchById(
      id: map['id'] as int,
      round: map['round'] as String,
      date: map['date'] as String,
      country: Country.fromMap(map['country'] as Map<String, dynamic>),
      awayTeam: AwayTeam.fromMap(map['awayTeam'] as Map<String, dynamic>),
      homeTeam: HomeTeam.fromMap(map['homeTeam'] as Map<String, dynamic>),
      league: League.fromMap(map['league'] as Map<String, dynamic>),
      state: MatchState.fromMap(map['state'] as Map<String, dynamic>),
      events: List<Event>.from(
        (map['events'] as List<dynamic>).map<Event>(
          (x) => Event.fromMap(x as Map<String, dynamic>),
        ),
      ),
      statistics: List<ResponseStatistic>.from(
        (map['statistics'] as List<dynamic>).map<ResponseStatistic>(
          (x) => ResponseStatistic.fromMap(x as Map<String, dynamic>),
        ),
      ),
      referee: Referee.fromMap(map['referee'] as Map<String, dynamic>),
      venue: Venue.fromMap(map['venue'] as Map<String, dynamic>),
      forecast: Forecast.fromMap(map['forecast'] as Map<String, dynamic>),
      predictions: map['predictions'] != null
          ? Predictions.fromMap(map['predictions'] as Map<String, dynamic>)
          : null,
      news: List<News>.from(
        (map['news'] as List<dynamic>).map<News>(
          (x) => News.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchById.fromJson(String source) =>
      MatchById.fromMap(json.decode(source) as Map<String, dynamic>);
}

Future<MatchById> parseMatchById(String resp) async {
  return MatchById.fromMap(jsonDecode(resp));
}
