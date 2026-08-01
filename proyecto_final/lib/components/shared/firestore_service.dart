import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../games/models/game_comment_model.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 
  /// Agrega un nuevo comentario con sus evaluaciones de 1 a 5 estrellas
  Future<void> addComment(GameCommentModel comment) async {
    await _db.collection('comments').add(comment.toMap());
  }

  /// comentarios en tiempo real
  Stream<List<GameCommentModel>> getCommentsStream(int gameId) {
    return _db
        .collection('comments')
        .where('gameId', isEqualTo: gameId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameCommentModel.fromFirestore(doc))
            .toList());
  }

  
  /// Agrega o quita un juego de la lista de favoritos de un usuario
  Future<void> toggleFavorite({
    required String userId,
    required int gameId,
    required Map<String, dynamic> gameData,
  }) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(gameId.toString());

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        ...gameData,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Verifica si un juego está marcado como favorito por el usuario
  Stream<bool> isFavoriteStream(String userId, int gameId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(gameId.toString())
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  /// Obtiene los favoritos del usuario en tiempo real
  Stream<List<Map<String, dynamic>>> getFavoritesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}