# 🎬 Cinéma — Application Flutter de lecture multimédia

Application Flutter pour lire les films et séries stockés sur ton téléphone Android,
avec récupération automatique des pochettes via TMDB.

## Fonctionnalités

- 📁 Scanner automatique des vidéos sur le téléphone (MP4, MKV, AVI, MOV…)
- 🎬 Pochettes et métadonnées via TheMovieDB (TMDB)
- ▶️ Lecteur vidéo complet (pause, seek, plein écran, paysage auto)
- 💾 Sauvegarde de la progression (reprendre où tu t'es arrêté)
- ❤️ Gestion des favoris
- 🔍 Recherche dans la bibliothèque
- 📺 Détection automatique films vs séries (S01E01)
- 🌙 Interface sombre cinéma

---

## Installation

### Prérequis

1. **Flutter SDK** : https://flutter.dev/docs/get-started/install
2. **Android Studio** ou **VS Code** avec l'extension Flutter
3. **Clé API TMDB gratuite** : https://www.themoviedb.org/settings/api

### Étapes

```bash
# 1. Cloner / décompresser le projet
cd cinema_app

# 2. Installer les dépendances
flutter pub get

# 3. Ajouter ta clé TMDB
# Ouvre lib/services/tmdb_service.dart
# Remplace 'TON_API_KEY_TMDB_ICI' par ta vraie clé

# 4. Connecter ton téléphone Android (mode développeur activé)
adb devices

# 5. Lancer en mode debug
flutter run

# 6. Générer l'APK de release
flutter build apk --release
# APK → build/app/outputs/flutter-apk/app-release.apk
```

---

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── theme/
│   └── cinema_theme.dart        # Couleurs et thème sombre
├── models/
│   └── movie.dart               # Modèle de données film/série
├── services/
│   ├── database_service.dart    # Base SQLite locale
│   ├── tmdb_service.dart        # API TMDB (pochettes)
│   └── media_scanner_service.dart # Scanner les vidéos du téléphone
├── providers/
│   └── media_provider.dart      # Gestion d'état (Provider)
├── screens/
│   ├── home_screen.dart         # Écran principal
│   ├── player_screen.dart       # Lecteur vidéo
│   ├── library_screen.dart      # Grille de la bibliothèque
│   └── search_screen.dart       # Recherche
└── widgets/
    ├── movie_card.dart           # Carte film (scroll horizontal)
    ├── movie_list_item.dart      # Élément liste avec progression
    ├── mini_player.dart          # Mini-lecteur en bas
    └── scan_overlay.dart         # Écran de scan initial
```

---

## Obtenir la clé TMDB (gratuite)

1. Va sur https://www.themoviedb.org/signup
2. Crée un compte gratuit
3. Va dans Paramètres → API → Créer une clé API
4. Copie la clé dans `lib/services/tmdb_service.dart`

L'application fonctionne sans clé TMDB (juste sans pochettes).

---

## Formats vidéo supportés

MP4, MKV, AVI, MOV, WMV, M4V, FLV, WebM, TS, M2TS, MPG, MPEG

## Dépendances principales

| Package | Rôle |
|---|---|
| `video_player` + `chewie` | Lecteur vidéo |
| `photo_manager` | Accès aux médias du téléphone |
| `cached_network_image` | Cache des pochettes |
| `sqflite` | Base de données locale |
| `provider` | Gestion d'état |
| `http` | Appels API TMDB |
| `permission_handler` | Permissions Android/iOS |
