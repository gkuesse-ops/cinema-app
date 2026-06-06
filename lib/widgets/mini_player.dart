import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../theme/cinema_theme.dart';

class MiniPlayer extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: CinemaTheme.bg2,
          border: Border(top: BorderSide(color: CinemaTheme.border, width: 0.5)),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(0)),
              child: SizedBox(
                width: 48,
                height: 64,
                child: movie.posterUrl != null
                    ? Image.network(movie.posterUrl!, fit: BoxFit.cover)
                    : Container(
                        color: CinemaTheme.bg3,
                        child: const Icon(Icons.movie_rounded, color: CinemaTheme.textMuted, size: 20),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Titre + progression
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CinemaTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (movie.isInProgress)
                    LinearProgressIndicator(
                      value: movie.progressPercent,
                      backgroundColor: CinemaTheme.bg3,
                      valueColor: const AlwaysStoppedAnimation(CinemaTheme.accent),
                      minHeight: 2,
                    ),
                ],
              ),
            ),
            // Contrôles
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: CinemaTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: CinemaTheme.textMuted, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
