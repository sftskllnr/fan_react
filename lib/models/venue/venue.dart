import 'dart:convert';

class Venue {
  final String? city;
  final String? name;
  final String? country;
  final String? capacity;

  Venue(
      {required this.city,
      required this.name,
      required this.country,
      required this.capacity});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'city': city,
      'name': name,
      'country': country,
      'capacity': capacity,
    };
  }

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      city: map['city'] != null ? map['city'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      country: map['country'] != null ? map['country'] as String : null,
      capacity: map['capacity'] != null ? map['capacity'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Venue.fromJson(String source) =>
      Venue.fromMap(json.decode(source) as Map<String, dynamic>);
}
