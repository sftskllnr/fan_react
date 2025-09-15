// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:fan_react/models/statistic/statistic_item.dart';
import 'package:fan_react/models/team/team.dart';

class MatchStatistic {
  final Team team;
  final List<StatisticItem> statistics;

  MatchStatistic({required this.team, required this.statistics});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'team': team.toMap(),
      'statistics': statistics.map((x) => x.toMap()).toList(),
    };
  }

  factory MatchStatistic.fromMap(Map<String, dynamic> map) {
    return MatchStatistic(
      team: Team.fromMap(map['team'] as Map<String, dynamic>),
      statistics: List<StatisticItem>.from(
        (map['statistics'] as List<dynamic>).map<StatisticItem>(
          (x) => StatisticItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchStatistic.fromJson(String source) =>
      MatchStatistic.fromMap(json.decode(source) as Map<String, dynamic>);
}

Future<List<MatchStatistic>> parseMatcStatistic(String resp) async {
  final parsed = (jsonDecode(resp) as List).cast<Map<String, dynamic>>();
  return parsed
      .map<MatchStatistic>((json) => MatchStatistic.fromMap(json))
      .toList();
}
