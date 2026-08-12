import 'package:cloud_firestore/cloud_firestore.dart';

class GameCommentModel {
  final String? id;
  final int gameId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String text;
  final double graphicsRating;
  final double gameplayRating;
  final double storyRating;
  final double innovationRating;
  final DateTime createdAt;

  GameCommentModel({
    this.id,
    required this.gameId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl = '',
    required this.text,
    required this.graphicsRating,
    required this.gameplayRating,
    required this.storyRating,
    required this.innovationRating,
    required this.createdAt,
  });

  double get averageRating =>
      (graphicsRating + gameplayRating + storyRating + innovationRating) / 4.0;

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'graphicsRating': graphicsRating,
      'gameplayRating': gameplayRating,
      'storyRating': storyRating,
      'innovationRating': innovationRating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory GameCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameCommentModel(
      id: doc.id,
      gameId: data['gameId'] ?? 0,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuario',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      graphicsRating: (data['graphicsRating'] ?? 0.0).toDouble(),
      gameplayRating: (data['gameplayRating'] ?? 0.0).toDouble(),
      storyRating: (data['storyRating'] ?? 0.0).toDouble(),
      innovationRating: (data['innovationRating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
