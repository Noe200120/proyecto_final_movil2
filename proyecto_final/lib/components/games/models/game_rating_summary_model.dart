import 'game_comment_model.dart';

class GameRatingSummary {
  final double avgGraphics;
  final double avgGameplay;
  final double avgStory;
  final double avgInnovation;
  final int totalReviews;

  GameRatingSummary({
    this.avgGraphics = 0.0,
    this.avgGameplay = 0.0,
    this.avgStory = 0.0,
    this.avgInnovation = 0.0,
    this.totalReviews = 0,
  });

  double get overallAverage => totalReviews == 0
      ? 0.0
      : (avgGraphics + avgGameplay + avgStory + avgInnovation) / 4.0;

  factory GameRatingSummary.fromComments(List<GameCommentModel> comments) {
    if (comments.isEmpty) return GameRatingSummary();

    double gAcc = 0, gpAcc = 0, sAcc = 0, iAcc = 0;
    for (var c in comments) {
      gAcc += c.graphicsRating;
      gpAcc += c.gameplayRating;
      sAcc += c.storyRating;
      iAcc += c.innovationRating;
    }

final count = comments.length;
return GameRatingSummary(
  avgGraphics: count == 0 ? 0.0 : gAcc / count,
  avgGameplay: count == 0 ? 0.0 : gpAcc / count,
  avgStory: count == 0 ? 0.0 : sAcc / count,
  avgInnovation: count == 0 ? 0.0 : iAcc / count,
  totalReviews: count,
);
  }
}