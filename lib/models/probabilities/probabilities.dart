import 'dart:convert';

class Probabilities {
  final String away;
  final String draw;
  final String home;

  Probabilities({
    required this.away,
    required this.draw,
    required this.home,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'away': away,
      'draw': draw,
      'home': home,
    };
  }

  factory Probabilities.fromMap(Map<String, dynamic> map) {
    return Probabilities(
      away: map['away'] as String,
      draw: map['draw'] as String,
      home: map['home'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Probabilities.fromJson(String source) =>
      Probabilities.fromMap(json.decode(source) as Map<String, dynamic>);
}
