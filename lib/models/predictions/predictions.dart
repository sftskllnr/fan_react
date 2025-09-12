import 'dart:convert';
import 'package:fan_react/models/live/live.dart';

class Predictions {
  final List<Live> live;
  final List<Live> prematch;

  Predictions({
    required this.live,
    required this.prematch,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'live': live.map((x) => x.toMap()).toList(),
      'prematch': prematch.map((x) => x.toMap()).toList(),
    };
  }

  factory Predictions.fromMap(Map<String, dynamic> map) {
    return Predictions(
      live: List<Live>.from(
        (map['live'] as List<dynamic>).map<Live>(
          (x) => Live.fromMap(x as Map<String, dynamic>),
        ),
      ),
      prematch: List<Live>.from(
        (map['prematch'] as List<dynamic>).map<Live>(
          (x) => Live.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Predictions.fromJson(String source) =>
      Predictions.fromMap(json.decode(source) as Map<String, dynamic>);
}
