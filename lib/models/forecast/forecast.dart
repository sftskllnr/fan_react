import 'dart:convert';

class Forecast {
  final String? status;
  final String? temperature;

  Forecast({required this.status, required this.temperature});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'temperature': temperature,
    };
  }

  factory Forecast.fromMap(Map<String, dynamic> map) {
    return Forecast(
      status: map['status'] != null ? map['status'] as String : null,
      temperature:
          map['temperature'] != null ? map['temperature'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Forecast.fromJson(String source) =>
      Forecast.fromMap(json.decode(source) as Map<String, dynamic>);
}
