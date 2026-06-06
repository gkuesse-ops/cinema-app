class Movie {
  final String id;
  final String title;
  final String filePath;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final double? rating;
  final int? year;
  final int? duration; // en secondes
  final String? genre;
  final bool isSeries;
  final String? seriesName;
  final int? season;
  final int? episode;
  final int watchProgress; // secondes regardées
  final bool isFavorite;
  final DateTime dateAdded;

  Movie({
    required this.id,
    required this.title,
    required this.filePath,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.rating,
    this.year,
    this.duration,
    this.genre,
    this.isSeries = false,
    this.seriesName,
    this.season,
    this.episode,
    this.watchProgress = 0,
    this.isFavorite = false,
    required this.dateAdded,
  });

  double get progressPercent =>
      (duration != null && duration! > 0)
          ? (watchProgress / duration!).clamp(0.0, 1.0)
          : 0.0;

  bool get isInProgress => watchProgress > 0 && progressPercent < 0.95;

  String get durationFormatted {
    if (duration == null) return '--:--';
    final h = duration! ~/ 3600;
    final m = (duration! % 3600) ~/ 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }

  String get remainingFormatted {
    final remaining = (duration ?? 0) - watchProgress;
    if (remaining <= 0) return 'Terminé';
    final h = remaining ~/ 3600;
    final m = (remaining % 3600) ~/ 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')} restant';
    return '$m min restant';
  }

  Movie copyWith({
    String? posterUrl,
    String? backdropUrl,
    String? overview,
    double? rating,
    int? year,
    int? duration,
    String? genre,
    bool? isFavorite,
    int? watchProgress,
  }) {
    return Movie(
      id: id,
      title: title,
      filePath: filePath,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      overview: overview ?? this.overview,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      isSeries: isSeries,
      seriesName: seriesName,
      season: season,
      episode: episode,
      watchProgress: watchProgress ?? this.watchProgress,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'overview': overview,
      'rating': rating,
      'year': year,
      'duration': duration,
      'genre': genre,
      'isSeries': isSeries ? 1 : 0,
      'seriesName': seriesName,
      'season': season,
      'episode': episode,
      'watchProgress': watchProgress,
      'isFavorite': isFavorite ? 1 : 0,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      filePath: map['filePath'],
      posterUrl: map['posterUrl'],
      backdropUrl: map['backdropUrl'],
      overview: map['overview'],
      rating: map['rating'],
      year: map['year'],
      duration: map['duration'],
      genre: map['genre'],
      isSeries: map['isSeries'] == 1,
      seriesName: map['seriesName'],
      season: map['season'],
      episode: map['episode'],
      watchProgress: map['watchProgress'] ?? 0,
      isFavorite: map['isFavorite'] == 1,
      dateAdded: DateTime.parse(map['dateAdded']),
    );
  }
}
