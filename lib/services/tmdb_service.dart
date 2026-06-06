import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service pour récupérer les métadonnées depuis The Movie Database (TMDB)
/// Obtenir une clé API gratuite sur : https://www.themoviedb.org/settings/api
class TmdbService {
  // ⚠️  Remplace par ta clé API TMDB (gratuite)
  static const String _apiKey = 'a5b5462014f493857c50ea0ebba5e665';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p';

  // Qualités d'image disponibles : w92, w154, w185, w342, w500, w780, original
  static const String posterSize = 'w342';
  static const String backdropSize = 'w780';

  /// Rechercher un film par titre
  static Future<Map<String, dynamic>?> searchMovie(String title) async {
    try {
      final cleanTitle = _cleanTitle(title);
      final uri = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(cleanTitle)}&language=fr-FR',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return _formatMovieResult(results.first);
        }
      }
    } catch (e) {
      // TMDB indisponible - on continue sans pochette
    }
    return null;
  }

  /// Rechercher une série TV
  static Future<Map<String, dynamic>?> searchTv(String title) async {
    try {
      final cleanTitle = _cleanTitle(title);
      final uri = Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(cleanTitle)}&language=fr-FR',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return _formatTvResult(results.first);
        }
      }
    } catch (e) {
      // Pas de réseau ou erreur API
    }
    return null;
  }

  /// Formater le résultat film
  static Map<String, dynamic> _formatMovieResult(Map result) {
    return {
      'posterUrl': result['poster_path'] != null
          ? '$_imageBase/$posterSize${result['poster_path']}'
          : null,
      'backdropUrl': result['backdrop_path'] != null
          ? '$_imageBase/$backdropSize${result['backdrop_path']}'
          : null,
      'overview': result['overview'],
      'rating': (result['vote_average'] as num?)?.toDouble(),
      'year': result['release_date'] != null
          ? int.tryParse(result['release_date'].toString().substring(0, 4))
          : null,
      'genre': null, // nécessite un appel détaillé
    };
  }

  /// Formater le résultat série
  static Map<String, dynamic> _formatTvResult(Map result) {
    return {
      'posterUrl': result['poster_path'] != null
          ? '$_imageBase/$posterSize${result['poster_path']}'
          : null,
      'backdropUrl': result['backdrop_path'] != null
          ? '$_imageBase/$backdropSize${result['backdrop_path']}'
          : null,
      'overview': result['overview'],
      'rating': (result['vote_average'] as num?)?.toDouble(),
      'year': result['first_air_date'] != null
          ? int.tryParse(result['first_air_date'].toString().substring(0, 4))
          : null,
      'genre': null,
    };
  }

  /// Nettoyer le nom de fichier pour en extraire un titre propre
  /// Ex : "The.Dark.Knight.2008.1080p.BluRay" → "The Dark Knight"
  static String _cleanTitle(String filename) {
    // Enlever l'extension
    String name = filename.replaceAll(RegExp(r'\.\w{2,4}$'), '');

    // Patterns courants dans les noms de fichiers de films
    final patterns = [
      RegExp(r'\b(19|20)\d{2}\b.*$'),          // année et tout ce qui suit
      RegExp(r'\b(1080p|720p|480p|4K|2160p)\b.*$', caseSensitive: false),
      RegExp(r'\b(BluRay|BDRip|WEB|HDRip|DVDRip|HDTV)\b.*$', caseSensitive: false),
      RegExp(r'\b(x264|x265|H264|HEVC|AAC|AC3)\b.*$', caseSensitive: false),
      RegExp(r'\[.*?\]|\(.*?\)'),               // crochets et parenthèses
      RegExp(r'S\d{2}E\d{2}.*$'),              // S01E01 et la suite
    ];

    for (final pattern in patterns) {
      name = name.replaceAll(pattern, '');
    }

    // Remplacer les points et underscores par des espaces
    name = name.replaceAll(RegExp(r'[._]'), ' ').trim();

    // Nettoyer les espaces multiples
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    return name;
  }

  /// Détecter si c'est une série et extraire saison/épisode
  /// Ex : "Breaking.Bad.S03E07" → {isSeries: true, season: 3, episode: 7}
  static Map<String, dynamic> detectSeriesInfo(String filename) {
    final match = RegExp(r'S(\d{2})E(\d{2})', caseSensitive: false).firstMatch(filename);
    if (match != null) {
      return {
        'isSeries': true,
        'season': int.parse(match.group(1)!),
        'episode': int.parse(match.group(2)!),
        'seriesName': _cleanTitle(filename.substring(0, match.start)),
      };
    }
    return {'isSeries': false};
  }
}
