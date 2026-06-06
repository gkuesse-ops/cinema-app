import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/database_service.dart';
import '../services/media_scanner_service.dart';

enum ScanState { idle, scanning, enriching, done, error }
enum FilterTab { all, movies, series, recent, favorites }

class MediaProvider extends ChangeNotifier {
  List<Movie> _allMovies = [];
  List<Movie> _inProgress = [];
  ScanState _scanState = ScanState.idle;
  FilterTab _currentTab = FilterTab.all;
  String _searchQuery = '';
  Movie? _nowPlaying;
  int _scanProgress = 0;
  int _scanTotal = 0;
  String? _errorMessage;

  // Getters
  ScanState get scanState => _scanState;
  FilterTab get currentTab => _currentTab;
  String get searchQuery => _searchQuery;
  Movie? get nowPlaying => _nowPlaying;
  int get scanProgress => _scanProgress;
  int get scanTotal => _scanTotal;
  String? get errorMessage => _errorMessage;
  List<Movie> get inProgress => _inProgress;

  List<Movie> get filteredMovies {
    List<Movie> list = List.from(_allMovies);

    // Filtre par onglet
    switch (_currentTab) {
      case FilterTab.movies:
        list = list.where((m) => !m.isSeries).toList();
        break;
      case FilterTab.series:
        list = list.where((m) => m.isSeries).toList();
        break;
      case FilterTab.recent:
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        list = list.take(30).toList();
        break;
      case FilterTab.favorites:
        list = list.where((m) => m.isFavorite).toList();
        break;
      case FilterTab.all:
        break;
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((m) =>
        m.title.toLowerCase().contains(q) ||
        (m.seriesName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return list;
  }

  // Initialisation : charger depuis la base de données
  Future<void> init() async {
    _allMovies = await DatabaseService.getAllMovies();
    _inProgress = await DatabaseService.getInProgressMovies();
    notifyListeners();

    // Scanner si la bibliothèque est vide
    if (_allMovies.isEmpty) {
      await scanLibrary();
    }
  }

  // Scanner les vidéos du téléphone
  Future<void> scanLibrary() async {
    _scanState = ScanState.scanning;
    _scanProgress = 0;
    _errorMessage = null;
    notifyListeners();

    try {
      final videos = await MediaScannerService.scanLocalVideos(
        onProgress: (found, total) {
          _scanProgress = found;
          _scanTotal = total;
          notifyListeners();
        },
      );

      if (videos.isEmpty) {
        _scanState = ScanState.done;
        notifyListeners();
        return;
      }

      // Enrichir avec TMDB en arrière-plan
      _scanState = ScanState.enriching;
      notifyListeners();

      final enriched = <Movie>[];
      for (int i = 0; i < videos.length; i++) {
        final movie = await MediaScannerService.enrichWithTmdb(videos[i]);
        enriched.add(movie);
        _scanProgress = i + 1;
        _scanTotal = videos.length;
        notifyListeners();
      }

      _allMovies = enriched;
      _inProgress = enriched.where((m) => m.isInProgress).toList();
      _scanState = ScanState.done;
    } catch (e) {
      _scanState = ScanState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void setTab(FilterTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setNowPlaying(Movie? movie) {
    _nowPlaying = movie;
    notifyListeners();
  }

  Future<void> updateProgress(String id, int seconds) async {
    await DatabaseService.updateProgress(id, seconds);
    final idx = _allMovies.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _allMovies[idx] = _allMovies[idx].copyWith(watchProgress: seconds);
      _inProgress = _allMovies.where((m) => m.isInProgress).toList();
      if (_nowPlaying?.id == id) {
        _nowPlaying = _allMovies[idx];
      }
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _allMovies.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final newVal = !_allMovies[idx].isFavorite;
    await DatabaseService.toggleFavorite(id, newVal);
    _allMovies[idx] = _allMovies[idx].copyWith(isFavorite: newVal);
    notifyListeners();
  }
}
