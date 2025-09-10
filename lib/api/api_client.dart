import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ApiClient {
  final Dio _dio = Dio();

  final String _baseUrl = 'https://soccer.highlightly.net/matches';
  var header = {
    'x-rapidapi-host': 'sport-highlights-api.p.rapidapi.com',
    'x-rapidapi-key': 'b5d85490-eb3a-4f4c-9645-8784e32a8b24'
  };

  Future<List<Match>> getAllMatches() async {
    DateFormat dateFormatBack = DateFormat('yyyy-MM-dd');
    var yesterday = DateTime.now().subtract(const Duration(days: 1));
    String date = dateFormatBack.format(yesterday);

    Response response;

    try {
      response = await _dio.request(
          '$_baseUrl?date=$date&timezone=Europe%2FLondon&season=2025',
          options: Options(method: 'GET', headers: header));

      if (response.statusCode == 200) {
        return compute(parseMatches, jsonEncode(response.data['data']));
      } else {
        return List<Match>.empty();
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle error response
      } else {
        // Handle no response
      }
    }
    return List<Match>.empty();
  }
}
