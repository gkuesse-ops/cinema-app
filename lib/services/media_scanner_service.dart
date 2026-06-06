import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../services/database_service.dart';

class MediaScannerService {
  // Extensions vidéo supportées
  static const List<String> _videoExtensions = [
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'm4v',
    'flv', 'webm', 'ts', 'm2ts', 'mpg', 'mpeg',
  ];

  /// Demander les permissions de stockage
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ utilise READ_MEDIA_VIDEO
      final videoPermission = await Permission.videos.request();
      if (videoPermission.isGranted) return true;

      // Android < 13
      final storagePermission = await Permission.storage.request();
      return storagePermission.isGranted;
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      return photos.isGranted || photos.isLimited;
    }
    return false;
  }

  /// Scanner tous les fichiers vidéo du téléphone
  static Future<List<Movie>> scanLocalVideos({
    void Function(int found, int total)? onProgress,
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return [];

    final List<Movie> movies = [];

    try {
      // Utiliser photo_manager pour accéder aux médias
      final result = await PhotoManager.requestPermissionExtend();
      if (!result.isAuth) return [];

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: false,
      );

      int total = 0;
      for (final album in albums) {
        total += await album.assetCountAsync;
      }

      int found = 0;
      for (final album in albums) {
        final count = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: count);

        for (final asset in assets) {
          final file = await asset.file;
          if (file == null) continue;

          final ext = p.extension(file.path).replaceAll('.', '').toLowerCase();
          if (!_videoExtensions.contains(ext)) continue;

          final filename = p.basenameWithoutExtension(file.path);
          final seriesInfo = TmdbService.detectSeriesInfo(filename);

          final movie = Movie(
            id: asset.id,
            title: _buildTitle(filename, seriesInfo),
            filePath: file.path,
            isSeries: seriesInfo['isSeries'] ?? false,
            seriesName: seriesInfo['seriesName'],
            season: seriesInfo['season'],
            episode: seriesInfo['episode'],
            duration: asset.duration,
            dateAdded: asset.createDateTime,
          );

          movies.add(movie);
          found++;
          onProgress?.call(found, total);
        }
      }
    } catch (e) {
      // Fallback : scanner manuellement les dossiers courants
      movies.addAll(await _fallbackScan(onProgress: onProgress));
    }

    return movies;
  }

  /// Fallback : scanner les dossiers classiques Android
  static Future<List<Movie>> _fallbackScan({
    void Function(int found, int total)? onProgress,
  }) async {
    final List<Movie> movies = [];
    final commonPaths = [
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Videos',
      '/sdcard/Movies',
      '/sdcard/Download',
    ];

    for (final dirPath in commonPaths) {
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;

      await for (final entity in dir.list(recursive: true)) {
        if (entity is! File) continue;
        final ext = p.extension(entity.path).replaceAll('.', '').toLowerCase();
        if (!_videoExtensions.contains(ext)) continue;

        final filename = p.basenameWithoutExtension(entity.path);
        final seriesInfo = TmdbService.detectSeriesInfo(filename);
        final stat = await entity.stat();

        final movie = Movie(
          id: entity.path.hashCode.toString(),
          title: _buildTitle(filename, seriesInfo),
          filePath: entity.path,
          isSeries: seriesInfo['isSeries'] ?? false,
          seriesName: seriesInfo['seriesName'],
          season: seriesInfo['season'],
          episode: seriesInfo['episode'],
          dateAdded: stat.modified,
        );

        movies.add(movie);
        onProgress?.call(movies.length, 0);
      }
    }

    return movies;
  }

  /// Enrichir un film avec les données TMDB
  static Future<Movie> enrichWithTmdb(Movie movie) async {
    try {
      final query = movie.isSeries
          ? (movie.seriesName ?? movie.title)
          : movie.title;

      final tmdbData = movie.isSeries
          ? await TmdbService.searchTv(query)
          : await TmdbService.searchMovie(query);

      if (tmdbData != null) {
        final enriched = movie.copyWith(
          posterUrl: tmdbData['posterUrl'],
          backdropUrl: tmdbData['backdropUrl'],
          overview: tmdbData['overview'],
          rating: tmdbData['rating'],
          year: tmdbData['year'],
        );
        // Sauvegarder en base
        await DatabaseService.upsertMovie(enriched);
        return enriched;
      }
    } catch (_) {}

    await DatabaseService.upsertMovie(movie);
    return movie;
  }

  static String _buildTitle(String filename, Map seriesInfo) {
    if (seriesInfo['isSeries'] == true) {
      final s = seriesInfo['season'].toString().padLeft(2, '0');
      final e = seriesInfo['episode'].toString().padLeft(2, '0');
      final name = seriesInfo['seriesName'] ?? filename;
      return '$name — S${s}E$e';
    }
    return _cleanFilename(filename);
  }

  static String _cleanFilename(String name) {
    return name
        .replaceAll(RegExp(r'\b(19|20)\d{2}\b.*$'), '')
        .replaceAll(RegExp(r'\b(1080p|720p|4K|BluRay|WEB|HDRip)\b.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'[._]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
