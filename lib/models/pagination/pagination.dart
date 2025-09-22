import 'dart:convert';

class Pagination {
  int totalCount;
  int offset;
  int limit;
  Pagination({
    required this.totalCount,
    required this.offset,
    required this.limit,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalCount': totalCount,
      'offset': offset,
      'limit': limit,
    };
  }

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      totalCount: map['totalCount'] as int,
      offset: map['offset'] as int,
      limit: map['limit'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Pagination.fromJson(String source) =>
      Pagination.fromMap(json.decode(source) as Map<String, dynamic>);
}
