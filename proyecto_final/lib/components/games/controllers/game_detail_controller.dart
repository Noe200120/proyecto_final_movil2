import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/firestore_service.dart';
import '../../shared/price_request_handler.dart';
import '../../shared/request_handler.dart';
import '../models/game_comment_model.dart';
import '../models/modelo.dart';
import 'favorites_controller.dart';

class GameDetailController extends GetxController {
  GameDetailController({required this.game});

  final GameModel game;

  final RequestHandler requestHandler = RequestHandler();

  final FirestoreService _firestoreService = Get.put(FirestoreService());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final PriceRequestHandler priceRequestHandler = PriceRequestHandler();

  final FavoritesController favoritesController =
      Get.find<FavoritesController>();

  final Rxn<double> pcRealPrice = Rxn<double>();

  final RxBool isLoading = false.obs;

  final RxBool isSubmittingComment = false.obs;

  final RxString errorMessage = ''.obs;

  final RxMap<String, dynamic> detail = <String, dynamic>{}.obs;

  final RxBool isFavorite = false.obs;

  final RxDouble userRating = 0.0.obs;

  final RxDouble graphicsRating = 5.0.obs;

  final RxDouble gameplayRating = 5.0.obs;

  final RxDouble storyRating = 5.0.obs;

  final RxDouble innovationRating = 5.0.obs;

  final RxList<GameCommentModel> comments = <GameCommentModel>[].obs;

  final TextEditingController commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    updateFavoriteStatus();

    loadGameDetail();

    _listenToComments();

    fetchRealPcPrice();
  }

  Future<void> fetchRealPcPrice() async {
    try {
      final double? price = await priceRequestHandler.cheapestPcPrice(
        game.name,
      );

      pcRealPrice.value = price;
    } catch (_) {
      pcRealPrice.value = null;
    }
  }

  void _listenToComments() {
    comments.bindStream(_firestoreService.getCommentsStream(game.id));
  }

  int get communityReviewsCount => comments.length;

  double get averageGraphicsRating {
    if (comments.isEmpty) {
      return 0.0;
    }

    final double total = comments.fold<double>(0.0, (
      double sum,
      GameCommentModel comment,
    ) {
      return sum + comment.graphicsRating;
    });

    return total / comments.length;
  }

  double get averageGameplayRating {
    if (comments.isEmpty) {
      return 0.0;
    }

    final double total = comments.fold<double>(0.0, (
      double sum,
      GameCommentModel comment,
    ) {
      return sum + comment.gameplayRating;
    });

    return total / comments.length;
  }

  double get averageStoryRating {
    if (comments.isEmpty) {
      return 0.0;
    }

    final double total = comments.fold<double>(0.0, (
      double sum,
      GameCommentModel comment,
    ) {
      return sum + comment.storyRating;
    });

    return total / comments.length;
  }

  double get averageInnovationRating {
    if (comments.isEmpty) {
      return 0.0;
    }

    final double total = comments.fold<double>(0.0, (
      double sum,
      GameCommentModel comment,
    ) {
      return sum + comment.innovationRating;
    });

    return total / comments.length;
  }

  double get averageOverallRating {
    if (comments.isEmpty) {
      return rating;
    }

    final double overall =
        averageGraphicsRating +
        averageGameplayRating +
        averageStoryRating +
        averageInnovationRating;

    return overall / 4.0;
  }

  void updateFavoriteStatus() {
    isFavorite.value = favoritesController.isFavorite(game.id);
  }

  void toggleFavorite() {
    favoritesController.toggleFavorite(game);

    updateFavoriteStatus();
  }

  Future<void> loadGameDetail() async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      final Map<String, dynamic> response = await requestHandler
          .requestGetGameDetail(game.id);

      detail.assignAll(response);
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() async {
    await Future.wait([loadGameDetail(), fetchRealPcPrice()]);
  }

  int get id {
    final dynamic value = detail['id'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return game.id;
  }

  String get name {
    return _stringValue(detail['name'], game.name);
  }

  String get description {
    final String raw = _stringValue(detail['description_raw'], '');

    if (raw.isNotEmpty) {
      return raw;
    }

    final String normal = _stringValue(detail['description'], '');

    if (normal.isNotEmpty) {
      return _removeHtml(normal);
    }

    return 'Sin descripcion disponible.';
  }

  String get backgroundImage {
    return _stringValue(detail['background_image'], game.backgroundImage);
  }

  String get released {
    return _stringValue(
      detail['released'],
      game.released.isNotEmpty ? game.released : 'Sin fecha',
    );
  }

  double get rating {
    return _doubleValue(detail['rating'], game.rating);
  }

  int get ratingTop {
    return _intValue(detail['rating_top'], 5);
  }

  int get ratingsCount => 0;

  int get reviewsCount => comments.length;

  int get reviewsTextCount => comments.length;

  int get metacritic => 0;

  int get playtime {
    return _intValue(detail['playtime'], 0);
  }

  int get added => 0;

  int get suggestionsCount => 0;

  String get esrbRating {
    final dynamic value = detail['esrb_rating'];

    if (value is Map) {
      return _stringValue(value['name'], 'Sin clasificacion');
    }

    final String direct = _stringValue(value, '');

    if (direct.isNotEmpty) {
      return direct;
    }

    return 'Sin clasificacion';
  }

  List<String> get genres {
    final List<String> apiGenres = _extractNames(detail['genres']);

    if (apiGenres.isNotEmpty) {
      return apiGenres;
    }

    return game.genres;
  }

  String get mainGenre {
    if (genres.isEmpty) {
      return 'Sin genero';
    }

    return genres.first;
  }

  List<String> get platforms {
    final dynamic value = detail['platforms'];

    if (value is List) {
      final List<String> result = [];

      for (final dynamic item in value) {
        if (item is! Map) {
          continue;
        }

        final dynamic platform = item['platform'];

        if (platform is! Map) {
          continue;
        }

        final String platformName = _stringValue(platform['name'], '');

        if (platformName.isNotEmpty) {
          result.add(platformName);
        }
      }

      if (result.isNotEmpty) {
        return result;
      }
    }

    return game.platforms;
  }

  bool hasPlatform(String platformName) {
    final String selected = platformName.toLowerCase();

    return platforms.any((String platform) {
      final String current = platform.toLowerCase();

      switch (selected) {
        case 'pc':
          return current == 'pc' || current.contains('windows');

        case 'playstation':
          return current.contains('playstation');

        case 'xbox':
          return current.contains('xbox');

        case 'nintendo':
          return current.contains('nintendo') || current.contains('switch');

        default:
          return current.contains(selected);
      }
    });
  }

  List<String> get developers {
    return _extractNames(detail['developers']);
  }

  List<String> get publishers {
    return _extractNames(detail['publishers']);
  }

  String get mainDeveloper {
    if (developers.isEmpty) {
      return 'Sin desarrollador';
    }

    return developers.first;
  }

  String get youtube {
    return _stringValue(detail['youtube'], '');
  }

  bool get hasYoutube => youtube.isNotEmpty;

  int get players {
    return _intValue(detail['players'], 0);
  }

  String get coop {
    return _stringValue(detail['coop'], '');
  }

  bool get hasCoop {
    final String value = coop.trim().toLowerCase();

    return value == 'yes' || value == 'true' || value == '1';
  }

  String get informationLine {
    final List<String> values = [];

    if (mainGenre != 'Sin genero') {
      values.add(mainGenre);
    }

    if (mainDeveloper != 'Sin desarrollador') {
      values.add(mainDeveloper);
    }

    if (released.isNotEmpty && released != 'Sin fecha') {
      values.add(released);
    }

    if (values.isEmpty) {
      return 'Informacion no disponible';
    }

    return values.join(' - ');
  }

  String get slug => '';

  String get backgroundImageAdditional => '';

  bool get tba => false;

  String get website => '';

  String get redditUrl => '';

  String get redditName => '';

  String get redditDescription => '';

  String get metacriticUrl => '';

  List<String> get parentPlatforms => [];

  List<String> get tags => [];

  List<Map<String, dynamic>> get ratings => [];

  List<Map<String, dynamic>> get stores => [];

  Map<String, String> get minimumRequirements => {};

  static const List<double> _marketTiers = [
    19.99,
    29.99,
    39.99,
    49.99,
    59.99,
    69.99,
  ];

  double _nearestMarketTier(double price) {
    for (final double tier in _marketTiers) {
      if (tier >= price) {
        return tier;
      }
    }

    return _marketTiers.last;
  }

  double _marketTierForSeed(int seed) {
    final int index = seed.abs() % _marketTiers.length;

    return _marketTiers[index];
  }

  double? simulatedPriceForPlatform(String platformName) {
    if (!hasPlatform(platformName)) {
      return null;
    }

    final bool isPc = platformName.toLowerCase() == 'pc';

    if (isPc && pcRealPrice.value != null) {
      return pcRealPrice.value;
    }

    if (pcRealPrice.value != null) {
      return _nearestMarketTier(pcRealPrice.value!);
    }

    final int seed = id * 31 + platformName.toLowerCase().hashCode;

    return _marketTierForSeed(seed);
  }

  void selectUserRating(double value) {
    if (value >= 0 && value <= 5) {
      userRating.value = value;
    }
  }

  void setGraphicsRating(double value) {
    graphicsRating.value = value.clamp(0, 5).toDouble();
  }

  void setGameplayRating(double value) {
    gameplayRating.value = value.clamp(0, 5).toDouble();
  }

  void setStoryRating(double value) {
    storyRating.value = value.clamp(0, 5).toDouble();
  }

  void setInnovationRating(double value) {
    innovationRating.value = value.clamp(0, 5).toDouble();
  }

  Future<void> saveRatingToFirebase() async {
    if (userRating.value <= 0) {
      Get.snackbar(
        'Calificacion',
        'Selecciona una calificacion.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    Get.snackbar(
      'Calificacion guardada',
      'Tu calificacion fue registrada exitosamente.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> publishCommentToFirebase() async {
    if (isSubmittingComment.value) {
      return;
    }

    final String text = commentController.text.trim();

    if (text.isEmpty) {
      Get.snackbar(
        'Comentario vacio',
        'Por favor escribe una opinion sobre el juego.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isSubmittingComment.value = true;

      final User? user = _auth.currentUser;

      final GameCommentModel newComment = GameCommentModel(
        gameId: game.id,

        userId: user?.uid ?? 'anonymous',

        userName:
            user?.displayName ??
            user?.email?.split('@').first ??
            'Usuario Gamer',

        userPhotoUrl: user?.photoURL ?? '',

        text: text,

        graphicsRating: graphicsRating.value,

        gameplayRating: gameplayRating.value,

        storyRating: storyRating.value,

        innovationRating: innovationRating.value,

        createdAt: DateTime.now(),
      );

      await _firestoreService.addComment(newComment);

      commentController.clear();

      graphicsRating.value = 5.0;

      gameplayRating.value = 5.0;

      storyRating.value = 5.0;

      innovationRating.value = 5.0;

      Get.snackbar(
        'Comentario publicado',
        'Tu evaluacion ha sido registrada correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se pudo publicar el comentario: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingComment.value = false;
    }
  }

  List<String> _extractNames(dynamic value) {
    if (value is! List) {
      return [];
    }

    final List<String> result = [];

    for (final dynamic item in value) {
      if (item is Map) {
        final String itemName = _stringValue(item['name'], '');

        if (itemName.isNotEmpty) {
          result.add(itemName);
        }

        continue;
      }

      final String text = _stringValue(item, '');

      if (text.isNotEmpty) {
        result.add(text);
      }
    }

    return result;
  }

  int _intValue(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _doubleValue(dynamic value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _stringValue(dynamic value, String fallback) {
    final String text = value?.toString().trim() ?? '';

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  String _removeHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  @override
  void onClose() {
    commentController.dispose();

    super.onClose();
  }
}
