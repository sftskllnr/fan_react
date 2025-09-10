import 'dart:convert';

class Score {
  final String? current;
  final String? penalties;

  Score({required this.current, required this.penalties});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'current': current,
      'penalties': penalties,
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      current: map['current'] != null ? map['current'] as String : null,
      penalties: map['penalties'] != null ? map['penalties'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Score.fromJson(String source) =>
      Score.fromMap(json.decode(source) as Map<String, dynamic>);
}
