import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApiClient {
  final Dio _dio = Dio();

  final String _baseUrl = 'https://soccer.highlightly.net/matches';
  var header = {
    'x-rapidapi-host': 'sport-highlights-api.p.rapidapi.com',
    'x-rapidapi-key': 'b5d85490-eb3a-4f4c-9645-8784e32a8b24'
  };

  Future<void> getAllMatches() async {
    DateFormat dateFormatBack = DateFormat('yyyy-MM-dd');
    var now = DateTime.now();
    debugPrint(dateFormatBack.format(now));
    DateFormat.yMMMd().format(DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1)));

    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    // ?date=2025-08-06&timezone=Europe%2FLondon&season=2025
    // https://soccer.highlightly.net/matches?date=2025-09-08&timezone=Europe%2FLondon&season=2025&offset=0
    Response response;

    try {
      response = await _dio.request('$_baseUrl?',
          options: Options(method: 'GET', headers: header));

      if (response.statusCode == 200) {
        //
      } else {
        //
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle error response
      } else {
        // Handle no response
      }
    }
  }
}
