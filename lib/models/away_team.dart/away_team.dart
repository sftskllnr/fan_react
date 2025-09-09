import 'dart:convert';

class AwayTeam {
  final int id;
  final String? logo;
  final String name;

  AwayTeam({required this.id, required this.logo, required this.name});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'logo': logo,
      'name': name,
    };
  }

  factory AwayTeam.fromMap(Map<String, dynamic> map) {
    return AwayTeam(
      id: map['id'] as int,
      logo: map['logo'] != null ? map['logo'] as String : null,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AwayTeam.fromJson(String source) =>
      AwayTeam.fromMap(json.decode(source) as Map<String, dynamic>);
}
