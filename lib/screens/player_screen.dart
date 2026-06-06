import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/movie.dart';
import '../providers/media_provider.dart';
import '../theme/cinema_theme.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Mode paysage automatique pour la lecture
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.file(
        File(widget.movie.filePath),
      );

      await _videoController!.initialize();

      // Reprendre à la progression sauvegardée
      if (widget.movie.watchProgress > 0) {
        await _videoController!.seekTo(
          Duration(seconds: widget.movie.watchProgress),
        );
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: CinemaTheme.accent,
          handleColor: CinemaTheme.accent,
          backgroundColor: CinemaTheme.bg3,
          bufferedColor: CinemaTheme.textMuted,
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (ctx, msg) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(msg, style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );

      // Sauvegarder la progression toutes les 5 secondes
      _videoController!.addListener(_onVideoProgress);

      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _error = 'Impossible de lire ce fichier.\n${e.toString()}');
    }
  }

  DateTime _lastSave = DateTime.now();

  void _onVideoProgress() {
    final now = DateTime.now();
    if (now.difference(_lastSave).inSeconds >= 5) {
      _lastSave = now;
      final pos = _videoController!.value.position.inSeconds;
      context.read<MediaProvider>().updateProgress(widget.movie.id, pos);
    }
  }

  @override
  void dispose() {
    // Sauvegarder la position finale
    if (_videoController != null) {
      final pos = _videoController!.value.position.inSeconds;
      context.read<MediaProvider>().updateProgress(widget.movie.id, pos);
    }
    _chewieController?.dispose();
    _videoController?.dispose();

    // Retour en mode portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Lecteur vidéo
            if (_isInitialized && _chewieController != null)
              Chewie(controller: _chewieController!)
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image_rounded, color: CinemaTheme.textMuted, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: CinemaTheme.textMuted),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: CinemaTheme.accent),
                        child: const Text('Retour', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: CinemaTheme.accent),
              ),

            // Bouton retour
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Titre en haut
            if (_isInitialized)
              Positioned(
                top: 12,
                left: 52,
                right: 52,
                child: Text(
                  widget.movie.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Bouton favori
            Positioned(
              top: 12,
              right: 12,
              child: Consumer<MediaProvider>(
                builder: (_, provider, __) {
                  final movie = provider.filteredMovies
                      .where((m) => m.id == widget.movie.id)
                      .firstOrNull ?? widget.movie;
                  return IconButton(
                    icon: Icon(
                      movie.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: movie.isFavorite ? CinemaTheme.accent : Colors.white,
                    ),
                    onPressed: () => provider.toggleFavorite(widget.movie.id),
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
