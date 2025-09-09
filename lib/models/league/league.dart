import 'dart:convert';

class League {
  final int id;
  final String? logo;
  final String name;
  final int season;

  League(
      {required this.id,
      required this.logo,
      required this.name,
      required this.season});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'logo': logo,
      'name': name,
      'season': season,
    };
  }

  factory League.fromMap(Map<String, dynamic> map) {
    return League(
      id: map['id'] as int,
      logo: map['logo'] != null ? map['logo'] as String : null,
      name: map['name'] as String,
      season: map['season'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory League.fromJson(String source) =>
      League.fromMap(json.decode(source) as Map<String, dynamic>);
}
