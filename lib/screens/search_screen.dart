import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../theme/cinema_theme.dart';
import '../widgets/movie_list_item.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemaTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: TextField(
                controller: _controller,
                autofocus: false,
                style: const TextStyle(color: CinemaTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher un film, une série…',
                  hintStyle: const TextStyle(color: CinemaTheme.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: CinemaTheme.textMuted),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: CinemaTheme.textMuted),
                          onPressed: () {
                            _controller.clear();
                            context.read<MediaProvider>().setSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: CinemaTheme.bg2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => context.read<MediaProvider>().setSearch(val),
              ),
            ),
            Expanded(
              child: Consumer<MediaProvider>(
                builder: (ctx, provider, _) {
                  final results = provider.filteredMovies;
                  if (provider.searchQuery.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, size: 64, color: CinemaTheme.textMuted),
                          SizedBox(height: 12),
                          Text('Tapez pour rechercher', style: TextStyle(color: CinemaTheme.textMuted)),
                        ],
                      ),
                    );
                  }
                  if (results.isEmpty) {
                    return const Center(
                      child: Text('Aucun résultat', style: TextStyle(color: CinemaTheme.textMuted)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: results.length,
                    itemBuilder: (ctx, i) => MovieListItem(
                      movie: results[i],
                      onTap: () {
                        provider.setNowPlaying(results[i]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerScreen(movie: results[i])),
                        );
                      },
                      onFavorite: () => provider.toggleFavorite(results[i].id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
