import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/movie_model.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> trendingMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> actionMovies = [];
  List<Movie> sciFiMovies = [];

  bool isLoading = true;
  String errorMessage = '';

 
  Future<void> fetchAllHomeData() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
     
      await Future.wait([
        fetchTrending(),
        fetchTopRated(),
        fetchAction(),
        fetchSciFi(),
      ]);
    } catch (e) {
      errorMessage = 'Failed to load data. Please check your internet connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTrending() async {
    final response = await http.get(Uri.parse(ApiConstants.trendingMovies));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'] as List;
      trendingMovies = data.map((m) => Movie.fromJson(m)).toList();
    }
  }

  Future<void> fetchTopRated() async {
    final response = await http.get(Uri.parse(ApiConstants.topRatedMovies));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'] as List;
      topRatedMovies = data.map((m) => Movie.fromJson(m)).toList();
    }
  }

  Future<void> fetchAction() async {
    final response = await http.get(Uri.parse(ApiConstants.actionMovies));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'] as List;
      actionMovies = data.map((m) => Movie.fromJson(m)).toList();
    }
  }

  Future<void> fetchSciFi() async {
    final response = await http.get(Uri.parse(ApiConstants.sciFiMovies));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'] as List;
      sciFiMovies = data.map((m) => Movie.fromJson(m)).toList();
    }
  }
}
