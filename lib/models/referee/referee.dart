import 'dart:convert';

class Referee {
  final String? name;
  final String? nationality;

  Referee({required this.name, required this.nationality});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'nationality': nationality,
    };
  }

  factory Referee.fromMap(Map<String, dynamic> map) {
    return Referee(
      name: map['name'] != null ? map['name'] as String : null,
      nationality:
          map['nationality'] != null ? map['nationality'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Referee.fromJson(String source) =>
      Referee.fromMap(json.decode(source) as Map<String, dynamic>);
}
