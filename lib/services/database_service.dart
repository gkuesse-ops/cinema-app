import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseService {
  static Database? _db;
  static const String _tableName = 'movies';

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cinema.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            filePath TEXT NOT NULL,
            posterUrl TEXT,
            backdropUrl TEXT,
            overview TEXT,
            rating REAL,
            year INTEGER,
            duration INTEGER,
            genre TEXT,
            isSeries INTEGER DEFAULT 0,
            seriesName TEXT,
            season INTEGER,
            episode INTEGER,
            watchProgress INTEGER DEFAULT 0,
            isFavorite INTEGER DEFAULT 0,
            dateAdded TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insérer ou mettre à jour un film
  static Future<void> upsertMovie(Movie movie) async {
    final database = await db;
    await database.insert(
      _tableName,
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer tous les films
  static Future<List<Movie>> getAllMovies() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      _tableName,
      orderBy: 'dateAdded DESC',
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  // Récupérer les films en cours
  static Future<List<Movie>> getInProgressMovies() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      _tableName,
      where: 'watchProgress > 0',
      orderBy: 'dateAdded DESC',
      limit: 10,
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  // Récupérer les favoris
  static Future<List<Movie>> getFavorites() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      _tableName,
      where: 'isFavorite = 1',
      orderBy: 'title ASC',
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  // Mettre à jour la progression
  static Future<void> updateProgress(String id, int seconds) async {
    final database = await db;
    await database.update(
      _tableName,
      {'watchProgress': seconds},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Basculer favori
  static Future<void> toggleFavorite(String id, bool value) async {
    final database = await db;
    await database.update(
      _tableName,
      {'isFavorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mettre à jour les infos TMDB
  static Future<void> updateTmdbInfo(String id, Map<String, dynamic> info) async {
    final database = await db;
    await database.update(
      _tableName,
      info,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Recherche
  static Future<List<Movie>> searchMovies(String query) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      _tableName,
      where: 'title LIKE ? OR seriesName LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  // Supprimer un film de la base
  static Future<void> deleteMovie(String id) async {
    final database = await db;
    await database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
