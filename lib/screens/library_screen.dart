import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/media_provider.dart';
import '../theme/cinema_theme.dart';
import 'player_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemaTheme.bg,
      appBar: AppBar(
        title: const Text(
          'MÉDIATHÈQUE',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 22,
            letterSpacing: 3,
            color: CinemaTheme.accent,
          ),
        ),
        backgroundColor: CinemaTheme.bg,
      ),
      body: Consumer<MediaProvider>(
        builder: (ctx, provider, _) {
          final movies = provider.filteredMovies;
          if (movies.isEmpty) {
            return const Center(
              child: Text('Aucun film dans la bibliothèque',
                style: TextStyle(color: CinemaTheme.textMuted)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.62,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: movies.length,
            itemBuilder: (ctx, i) {
              final movie = movies[i];
              return GestureDetector(
                onTap: () {
                  provider.setNowPlaying(movie);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: movie.posterUrl != null
                            ? CachedNetworkImage(
                                imageUrl: movie.posterUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (_, __) => Container(
                                  color: CinemaTheme.bg2,
                                  child: const Center(
                                    child: Icon(Icons.movie_rounded, color: CinemaTheme.textMuted),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => _PlaceholderPoster(title: movie.title),
                              )
                            : _PlaceholderPoster(title: movie.title),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      movie.isSeries ? (movie.seriesName ?? movie.title) : movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: CinemaTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (movie.year != null)
                      Text(
                        movie.year.toString(),
                        style: const TextStyle(fontSize: 10, color: CinemaTheme.textMuted),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlaceholderPoster extends StatelessWidget {
  final String title;
  const _PlaceholderPoster({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CinemaTheme.bg3,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_rounded, color: CinemaTheme.textMuted, size: 32),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: CinemaTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
