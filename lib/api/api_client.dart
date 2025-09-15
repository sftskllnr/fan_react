import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fan_react/models/league/league_season.dart';
import 'package:fan_react/models/match/match.dart';
import 'package:fan_react/models/match/match_by_id.dart';
import 'package:fan_react/models/statistic/match_statistic.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ApiClient {
  final Dio _dio = Dio();

  final String _matchesBaseUrl = 'https://soccer.highlightly.net/matches';
  final String _leaguesBaseUrl = 'https://soccer.highlightly.net/leagues';
  final String _statisticsBaseUrl = 'https://soccer.highlightly.net/statistics';

  var header = {
    'x-rapidapi-host': 'sport-highlights-api.p.rapidapi.com',
    'x-rapidapi-key': 'b5d85490-eb3a-4f4c-9645-8784e32a8b24'
    // 'x-rapidapi-key': 'dd9f256b-4d13-49d2-b927-9d6bbf49dcf6'
  };

  Future<List<Match>> getAllMatches({int offset = 0}) async {
    DateFormat dateFormatBack = DateFormat('yyyy-MM-dd');
    var yesterday = DateTime.now().subtract(const Duration(days: 1));
    String date = dateFormatBack.format(yesterday);

    Response response;

    try {
      response = await _dio.request(
          '$_matchesBaseUrl?date=$date&timezone=Europe%2FLondon&season=2025&limit=100&offset=$offset',
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

  Future<MatchById?> getMatchById(int id) async {
    Response response;

    try {
      response = await _dio.request('$_matchesBaseUrl/$id',
          options: Options(method: 'GET', headers: header));

      if (response.statusCode == 200) {
        return compute(parseMatchById, jsonEncode(response.data[0]));
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle error response
      } else {
        // Handle no response
      }
    }
    return null;
  }

  Future<List<LeagueSeason>> getAllLeagues() async {
    Response response;
    try {
      response = await _dio.request(
          '$_leaguesBaseUrl?limit=100&offset=0&season=2025',
          options: Options(method: 'GET', headers: header));

      if (response.statusCode == 200) {
        return compute(parseLeaguesSeason, jsonEncode(response.data['data']));
      } else {
        return List<LeagueSeason>.empty();
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle error response
      } else {
        // Handle no response
      }
    }
    return List<LeagueSeason>.empty();
  }

  Future<List<Match>> getLeagueMatches(int leagueId) async {
    Response response;
    try {
      response = await _dio.request(
          '$_matchesBaseUrl?leagueId=$leagueId&timezone=Europe%2FLondon&season=2025&limit=100&offset=0',
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

  Future<List<Match>> getLastFiveMatches(int teamId) async {
    Response response;

    try {
      response = await _dio.request(
          'https://soccer.highlightly.net/last-five-games?teamId=$teamId',
          options: Options(method: 'GET', headers: header));

      if (response.statusCode == 200) {
        return compute(parseMatches, jsonEncode(response.data));
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

  Future<List<MatchStatistic>> getMatchStatistic(int matchId) async {
    Response response;

    try {
      response = await _dio.request('$_statisticsBaseUrl/$matchId',
          options: Options(method: 'GET', headers: header));

      if (response.statusCode == 200) {
        return compute(parseMatcStatistic, jsonEncode(response.data));
      } else {
        return List<MatchStatistic>.empty();
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle error response
      } else {
        // Handle no response
      }
    }
    return List<MatchStatistic>.empty();
  }
}
