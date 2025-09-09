import 'dart:convert';

class Country {
  final String code;
  final String name;
  final String logo;

  Country({required this.code, required this.name, required this.logo});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'logo': logo,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      code: map['code'] as String,
      name: map['name'] as String,
      logo: map['logo'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Country.fromJson(String source) =>
      Country.fromMap(json.decode(source) as Map<String, dynamic>);
}
