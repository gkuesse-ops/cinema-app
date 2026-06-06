import 'package:flutter/material.dart';
import '../providers/media_provider.dart';
import '../theme/cinema_theme.dart';

class ScanOverlay extends StatelessWidget {
  final ScanState state;
  final int progress;
  final int total;

  const ScanOverlay({
    super.key,
    required this.state,
    required this.progress,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isEnriching = state == ScanState.enriching;
    final percent = total > 0 ? progress / total : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter_rounded,
              size: 64,
              color: CinemaTheme.accent,
            ),
            const SizedBox(height: 24),
            Text(
              isEnriching ? 'Récupération des pochettes…' : 'Scan des vidéos…',
              style: const TextStyle(
                color: CinemaTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEnriching
                  ? 'Recherche sur TMDB ($progress / $total)'
                  : '$progress fichier${progress > 1 ? 's' : ''} trouvé${progress > 1 ? 's' : ''}',
              style: const TextStyle(color: CinemaTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: CinemaTheme.bg2,
                valueColor: const AlwaysStoppedAnimation(CinemaTheme.accent),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Première utilisation uniquement',
              style: TextStyle(color: CinemaTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
