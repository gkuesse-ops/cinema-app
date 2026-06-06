import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../theme/cinema_theme.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_list_item.dart';
import '../widgets/mini_player.dart';
import '../widgets/scan_overlay.dart';
import 'player_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemaTheme.bg,
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _HomeTab(),
          SearchScreen(),
          LibraryScreen(),
        ],
      ),
      bottomNavigationBar: Consumer<MediaProvider>(
        builder: (_, provider, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.nowPlaying != null)
              MiniPlayer(
                movie: provider.nowPlaying!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(movie: provider.nowPlaying!),
                  ),
                ),
              ),
            BottomNavigationBar(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
              backgroundColor: CinemaTheme.bg,
              selectedItemColor: CinemaTheme.accent,
              unselectedItemColor: CinemaTheme.textMuted,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Chercher'),
                BottomNavigationBarItem(icon: Icon(Icons.video_library_rounded), label: 'Médiathèque'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, provider, _) {
        if (provider.scanState == ScanState.scanning ||
            provider.scanState == ScanState.enriching) {
          return ScanOverlay(
            state: provider.scanState,
            progress: provider.scanProgress,
            total: provider.scanTotal,
          );
        }

        return CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: CinemaTheme.bg,
              title: const Text(
                'CINÉMA',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 24,
                  letterSpacing: 3,
                  color: CinemaTheme.accent,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: CinemaTheme.textMuted),
                  onPressed: () => provider.scanLibrary(),
                  tooltip: 'Rescanner',
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Onglets de filtre
            SliverToBoxAdapter(
              child: _FilterTabs(provider: provider),
            ),

            // Section "En vedette"
            if (provider.filteredMovies.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Text(
                    '— EN VEDETTE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 3,
                      color: CinemaTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: provider.filteredMovies.take(10).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) {
                      final movie = provider.filteredMovies[i];
                      return MovieCard(
                        movie: movie,
                        onTap: () => _openPlayer(context, movie, provider),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Section "Continuer à regarder"
            if (provider.inProgress.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 24, 18, 12),
                  child: Text(
                    '— CONTINUER À REGARDER',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 3,
                      color: CinemaTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final movie = provider.inProgress[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: MovieListItem(
                        movie: movie,
                        onTap: () => _openPlayer(context, movie, provider),
                        onFavorite: () => provider.toggleFavorite(movie.id),
                      ),
                    );
                  },
                  childCount: provider.inProgress.length,
                ),
              ),
            ],

            // État vide
            if (provider.filteredMovies.isEmpty && provider.scanState == ScanState.done)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.movie_filter_rounded, size: 64, color: CinemaTheme.textMuted),
                      const SizedBox(height: 16),
                      const Text('Aucun film trouvé', style: TextStyle(color: CinemaTheme.textMuted, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => provider.scanLibrary(),
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Scanner le téléphone'),
                        style: TextButton.styleFrom(foregroundColor: CinemaTheme.accent),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  void _openPlayer(BuildContext context, movie, MediaProvider provider) {
    provider.setNowPlaying(movie);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final MediaProvider provider;
  const _FilterTabs({required this.provider});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (FilterTab.all, 'Tous'),
      (FilterTab.movies, 'Films'),
      (FilterTab.series, 'Séries'),
      (FilterTab.recent, 'Récents'),
      (FilterTab.favorites, 'Favoris'),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: tabs.map((tab) {
          final isActive = provider.currentTab == tab.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => provider.setTab(tab.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? CinemaTheme.accent : CinemaTheme.bg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? CinemaTheme.accent : CinemaTheme.border,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  tab.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? CinemaTheme.bg : CinemaTheme.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
