import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../theme/cinema_theme.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: movie.posterUrl != null
                    ? CachedNetworkImage(
                        imageUrl: movie.posterUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: CinemaTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (movie.posterUrl != null)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: CinemaTheme.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'HD',
                            style: TextStyle(fontSize: 9, color: CinemaTheme.accent, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (movie.year != null) movie.year.toString(),
                      movie.durationFormatted,
                      if (movie.genre != null) movie.genre!,
                    ].join(' · '),
                    style: const TextStyle(fontSize: 11, color: CinemaTheme.textMuted),
                  ),
                  // Barre de progression
                  if (movie.isInProgress) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: movie.progressPercent,
                              backgroundColor: CinemaTheme.bg3,
                              valueColor: const AlwaysStoppedAnimation(CinemaTheme.accent),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          movie.remainingFormatted,
                          style: const TextStyle(fontSize: 10, color: CinemaTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Bouton favori
            IconButton(
              icon: Icon(
                movie.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 20,
                color: movie.isFavorite ? CinemaTheme.accent : CinemaTheme.textMuted,
              ),
              onPressed: onFavorite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: CinemaTheme.bg3,
      child: const Icon(Icons.movie_rounded, color: CinemaTheme.textMuted, size: 24),
    );
  }
}
