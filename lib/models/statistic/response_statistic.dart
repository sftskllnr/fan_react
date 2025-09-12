import 'dart:convert';
import 'package:fan_react/models/statistic/statistic_item.dart';
import 'package:fan_react/models/team/team.dart';

class ResponseStatistic {
  final List<StatisticItem> statistics;
  final Team team;

  ResponseStatistic({required this.statistics, required this.team});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'statistics': statistics.map((x) => x.toMap()).toList(),
      'team': team.toMap(),
    };
  }

  factory ResponseStatistic.fromMap(Map<String, dynamic> map) {
    return ResponseStatistic(
      statistics: List<StatisticItem>.from(
        (map['statistics'] as List<dynamic>).map<StatisticItem>(
          (x) => StatisticItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      team: Team.fromMap(map['team'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ResponseStatistic.fromJson(String source) =>
      ResponseStatistic.fromMap(json.decode(source) as Map<String, dynamic>);
}
