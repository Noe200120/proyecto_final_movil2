import 'package:get/get.dart';
import '../models/modelo.dart';

class FavoritesController extends GetxController {
  final RxList<GameModel> favoriteGames =
      <GameModel>[].obs;

  bool isFavorite(int gameId) {
    return favoriteGames.any(
      (GameModel game) => game.id == gameId,
    );
  }

  void toggleFavorite(GameModel game) {
    if (isFavorite(game.id)) {
      removeFavorite(game.id);
    } else {
      addFavorite(game);
    }
  }

  void addFavorite(GameModel game) {
    if (isFavorite(game.id)) {
      return;
    }

    favoriteGames.add(game);
    favoriteGames.refresh();

    Get.snackbar(
      'Agregado a favoritos',
      '${game.name} fue agregado a tus favoritos.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    saveFavoriteToFirebase(game);
  }

  void removeFavorite(int gameId) {
    GameModel? removedGame;

    for (final GameModel game in favoriteGames) {
      if (game.id == gameId) {
        removedGame = game;
        break;
      }
    }

    favoriteGames.removeWhere(
      (GameModel game) => game.id == gameId,
    );

    favoriteGames.refresh();

    if (removedGame != null) {
      Get.snackbar(
        'Eliminado de favoritos',
        '${removedGame.name} fue eliminado de tus favoritos.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }

    removeFavoriteFromFirebase(gameId);
  }

  void clearFavorites() {
    favoriteGames.clear();
    favoriteGames.refresh();

    Get.snackbar(
      'Favoritos eliminados',
      'Se eliminaron todos los videojuegos favoritos.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> loadFavoritesFromFirebase() async {
    // Se conectara con Firebase posteriormente.
  }

  Future<void> saveFavoriteToFirebase(
    GameModel game,
  ) async {
    // Se conectara con Firebase posteriormente.
  }

  Future<void> removeFavoriteFromFirebase(
    int gameId,
  ) async {
    // Se conectara con Firebase posteriormente.
  }
}