import 'dart:convert';

class HomeTeam {
  final int id;
  final String? logo;
  final String name;

  HomeTeam({required this.id, required this.logo, required this.name});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'logo': logo,
      'name': name,
    };
  }

  factory HomeTeam.fromMap(Map<String, dynamic> map) {
    return HomeTeam(
      id: map['id'] as int,
      logo: map['logo'] != null ? map['logo'] as String : null,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeTeam.fromJson(String source) =>
      HomeTeam.fromMap(json.decode(source) as Map<String, dynamic>);
}
