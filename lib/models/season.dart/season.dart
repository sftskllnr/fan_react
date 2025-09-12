import 'dart:convert';

class Season {
  final int season;

  Season({required this.season});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'season': season,
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      season: map['season'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Season.fromJson(String source) =>
      Season.fromMap(json.decode(source) as Map<String, dynamic>);
}
