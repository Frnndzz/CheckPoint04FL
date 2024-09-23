import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/common/utils.dart';
import 'package:movie_app/models/movie_model.dart';

const baseUrl = 'https://api.themoviedb.org/3';
const key = '?api_key=$apiKey';

class ApiServices {
  Future<Result> _fetchMovies(String endpoint) async {
    final url = '$baseUrl$endpoint$key';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return Result.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load movies: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  Future<Result> getTopRatedMovies() async {
    return _fetchMovies('/movie/top_rated');
  }

  Future<Result> getNowPlayingMovies() async {
    return _fetchMovies('/movie/now_playing');
  }

  Future<Result> getUpcomingMovies() async {
    return _fetchMovies('/movie/upcoming');
  }

  Future<Result> getPopularMovies() async {
    return _fetchMovies('/movie/popular');
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId$key');
    print("Fetching movie details from URL: $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Movie.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load movie details: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<Result> getSimilarMovies(int movieId) async {
    return _fetchMovies('/movie/$movieId/similar');
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
        '$baseUrl/search/movie?query=${Uri.encodeQueryComponent(query)}');
    print("Searching movies from URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': accessTokenHeader,
          'accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final result = Result.fromJson(jsonDecode(response.body));
        return result.movies;
      } else {
        throw Exception(
            'Failed to search movies: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }
}
