import 'dart:convert';
import 'package:fan_react/models/country/country.dart';
import 'package:fan_react/models/season.dart/season.dart';

class LeagueSeason {
  final int id;
  final String logo;
  final String name;
  final List<Season> seasons;
  final Country country;

  LeagueSeason(
      {required this.id,
      required this.logo,
      required this.name,
      required this.seasons,
      required this.country});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'logo': logo,
      'name': name,
      'seasons': seasons.map((x) => x.toMap()).toList(),
      'country': country.toMap(),
    };
  }

  factory LeagueSeason.fromMap(Map<String, dynamic> map) {
    return LeagueSeason(
      id: map['id'] as int,
      logo: map['logo'] as String,
      name: map['name'] as String,
      seasons: List<Season>.from(
        (map['seasons'] as List<dynamic>).map<Season>(
          (x) => Season.fromMap(x as Map<String, dynamic>),
        ),
      ),
      country: Country.fromMap(map['country'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory LeagueSeason.fromJson(String source) =>
      LeagueSeason.fromMap(json.decode(source) as Map<String, dynamic>);
}

Future<List<LeagueSeason>> parseLeaguesSeason(String resp) async {
  final parsed = (jsonDecode(resp) as List).cast<Map<String, dynamic>>();
  return parsed
      .map<LeagueSeason>((json) => LeagueSeason.fromMap(json))
      .toList();
}
