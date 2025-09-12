import 'dart:convert';

class News {
  final String url;
  final String image;
  final String title;
  final String datePublished;

  News(
      {required this.url,
      required this.image,
      required this.title,
      required this.datePublished});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'image': image,
      'title': title,
      'datePublished': datePublished,
    };
  }

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      url: map['url'] as String,
      image: map['image'] as String,
      title: map['title'] as String,
      datePublished: map['datePublished'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory News.fromJson(String source) =>
      News.fromMap(json.decode(source) as Map<String, dynamic>);
}
