class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '6ddeb84d8cd1ab794a8b6a272fceff82';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String originalImageBaseUrl = 'https://image.tmdb.org/t/p/original';

  static const String trendingMovies = '$baseUrl/trending/movie/day?api_key=$apiKey';
  static const String topRatedMovies = '$baseUrl/movie/top_rated?api_key=$apiKey';
  static const String actionMovies = '$baseUrl/discover/movie?api_key=$apiKey&with_genres=28';
  static const String sciFiMovies = '$baseUrl/discover/movie?api_key=$apiKey&with_genres=878';
}

class ServerConstants {
  static List<Map<String, String>> getServers(String tmdbId) {
    return [
      {
        "name": "Server 1",
        "url": "https://vidlink.pro/movie/$tmdbId"
      },
      {
        "name": "Server 2",
        "url": "https://vidsrc.mov/embed/movie/$tmdbId"
      },
    ];
  }
}