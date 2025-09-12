import 'dart:convert';

class StatisticItem {
  final String displayName;
  final num value;

  StatisticItem({required this.displayName, required this.value});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'value': value,
    };
  }

  factory StatisticItem.fromMap(Map<String, dynamic> map) {
    return StatisticItem(
      displayName: map['displayName'] as String,
      value: map['value'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticItem.fromJson(String source) =>
      StatisticItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
