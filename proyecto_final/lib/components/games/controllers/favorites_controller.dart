import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/modelo.dart';

class FavoritesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<GameModel> favoriteGames = <GameModel>[].obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  @override
  void onInit() {
    super.onInit();

    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToFavorites(user.uid);
      } else {
        _favoritesSubscription?.cancel();
        favoriteGames.clear();
      }
    });
  }

  void _listenToFavorites(String userId) {
    _favoritesSubscription?.cancel();

    _favoritesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            final List<GameModel> loaded = snapshot.docs.map((doc) {
              final data = doc.data();
              return GameModel.fromJson(data);
            }).toList();

            favoriteGames.assignAll(loaded);
          },
          onError: (error) {
            Get.snackbar(
              'Error',
              'No se pudieron cargar los favoritos: $error',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
  }

  bool isFavorite(int gameId) {
    return favoriteGames.any((GameModel game) => game.id == gameId);
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

    favoriteGames.removeWhere((GameModel game) => game.id == gameId);

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

  void clearFavorites() async {
    final User? user = _auth.currentUser;

    favoriteGames.clear();

    Get.snackbar(
      'Favoritos eliminados',
      'Se eliminaron todos los videojuegos favoritos.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    if (user != null) {
      try {
        final collection = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites');

        final snapshots = await collection.get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'No se pudieron borrar todos los favoritos de Firebase.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> saveFavoriteToFirebase(GameModel game) async {
    final User? user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(game.id.toString())
          .set(game.toJson());
    } catch (e) {
      Get.snackbar(
        'Error de sincronización',
        'No se pudo guardar en la nube: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFavoriteFromFirebase(int gameId) async {
    final User? user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(gameId.toString())
          .delete();
    } catch (e) {
      Get.snackbar(
        'Error de sincronización',
        'No se pudo eliminar de la nube: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.onClose();
  }
}
