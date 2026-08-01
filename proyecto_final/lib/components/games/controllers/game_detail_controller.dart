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

  /// Precio real de PC obtenido de CheapShark. Null mientras carga o si
  final Rxn<double> pcRealPrice = Rxn<double>();

  final RxBool isLoading = false.obs;
  final RxBool isSubmittingComment = false.obs; // Prevención de doble clic
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

  /// juego. No bloquea la UI: si falla o no encuentra nada, los precios
  /// de PC y consolas simplemente usan el precio de mercado simulado.
  Future<void> fetchRealPcPrice() async {
    final double? price = await priceRequestHandler.cheapestPcPrice(
      game.name,
    );

    pcRealPrice.value = price;
  }

  /// comentarios en tiempo real desde firestore
  void _listenToComments() {
    comments.bindStream(_firestoreService.getCommentsStream(game.id));
  }

  /// Total de evaluaciones realizadas por la comunidad para este juego
  int get communityReviewsCount => comments.length;

  /// Promedio de Gráficos
  double get averageGraphicsRating {
    if (comments.isEmpty) return 0.0;
    final double total =
        comments.fold<double>(0.0, (sum, c) => sum + c.graphicsRating);
    return total / comments.length;
  }

  /// Promedio de Jugabilidad 
  double get averageGameplayRating {
    if (comments.isEmpty) return 0.0;
    final double total =
        comments.fold<double>(0.0, (sum, c) => sum + c.gameplayRating);
    return total / comments.length;
  }

  /// Promedio de Historia
  double get averageStoryRating {
    if (comments.isEmpty) return 0.0;
    final double total =
        comments.fold<double>(0.0, (sum, c) => sum + c.storyRating);
    return total / comments.length;
  }

  /// Promedio de Innovación 
  double get averageInnovationRating {
    if (comments.isEmpty) return 0.0;
    final double total =
        comments.fold<double>(0.0, (sum, c) => sum + c.innovationRating);
    return total / comments.length;
  }

  /// Promedio General Global de la Comunidad 
  double get averageOverallRating {
    if (comments.isEmpty) return rating; // 
    final double overall = averageGraphicsRating +
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
    await loadGameDetail();
  }


  int get id {
    final dynamic value = detail['id'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return game.id;
  }

  String get name => _stringValue(detail['name'], game.name);
  String get slug => _stringValue(detail['slug'], '');

  String get description {
    final String descriptionRaw = _stringValue(detail['description_raw'], '');
    if (descriptionRaw.isNotEmpty) return descriptionRaw;

    final String descriptionHtml = _stringValue(detail['description'], '');
    if (descriptionHtml.isNotEmpty) return _removeHtml(descriptionHtml);

    return 'Sin descripción disponible.';
  }

  String get backgroundImage =>
      _stringValue(detail['background_image'], game.backgroundImage);

  String get backgroundImageAdditional =>
      _stringValue(detail['background_image_additional'], '');

  String get released => _stringValue(
        detail['released'],
        game.released.isNotEmpty ? game.released : 'Sin fecha',
      );

  bool get tba => detail['tba'] is bool ? detail['tba'] : false;

  double get rating => _doubleValue(detail['rating'], game.rating);
  int get ratingTop => _intValue(detail['rating_top'], 5);
  int get ratingsCount => _intValue(detail['ratings_count'], 0);
  int get reviewsCount => _intValue(detail['reviews_count'], 0);
  int get reviewsTextCount => _intValue(detail['reviews_text_count'], 0);
  int get metacritic => _intValue(detail['metacritic'], 0);
  int get playtime => _intValue(detail['playtime'], 0);
  int get added => _intValue(detail['added'], 0);
  int get suggestionsCount => _intValue(detail['suggestions_count'], 0);
  String get website => _stringValue(detail['website'], '');
  String get redditUrl => _stringValue(detail['reddit_url'], '');
  String get redditName => _stringValue(detail['reddit_name'], '');
  String get redditDescription => _stringValue(detail['reddit_description'], '');
  String get metacriticUrl => _stringValue(detail['metacritic_url'], '');

  String get esrbRating {
    final dynamic value = detail['esrb_rating'];
    if (value is Map) {
      return _stringValue(value['name'], 'Sin clasificación');
    }
    return 'Sin clasificación';
  }

  List<String> get genres {
    final List<String> apiGenres = _extractNames(detail['genres']);
    return apiGenres.isNotEmpty ? apiGenres : game.genres;
  }

  List<String> get platforms {
    final dynamic value = detail['platforms'];
    if (value is List) {
      final List<String> result = [];
      for (final dynamic item in value) {
        if (item is! Map) continue;
        final dynamic platform = item['platform'];
        if (platform is! Map) continue;
        final String platformName = _stringValue(platform['name'], '');
        if (platformName.isNotEmpty) result.add(platformName);
      }
      if (result.isNotEmpty) return result;
    }
    return game.platforms;
  }

  List<String> get parentPlatforms {
    final dynamic value = detail['parent_platforms'];
    if (value is! List) return [];

    final List<String> result = [];
    for (final dynamic item in value) {
      if (item is! Map) continue;
      final dynamic platform = item['platform'];
      if (platform is! Map) continue;
      final String platformName = _stringValue(platform['name'], '');
      if (platformName.isNotEmpty) result.add(platformName);
    }
    return result;
  }

  List<String> get developers => _extractNames(detail['developers']);
  List<String> get publishers => _extractNames(detail['publishers']);
  List<String> get tags => _extractNames(detail['tags']);
  List<Map<String, dynamic>> get ratings => _extractMaps(detail['ratings']);

  List<Map<String, dynamic>> get stores {
    final dynamic value = detail['stores'];
    if (value is! List) return [];

    final List<Map<String, dynamic>> result = [];
    for (final dynamic item in value) {
      if (item is! Map) continue;
      final dynamic storeData = item['store'];
      if (storeData is! Map) continue;

      final int storeId = _intValue(storeData['id'], 0);
      final String storeName = _stringValue(storeData['name'], 'Tienda');

      result.add({
        'id': storeData['id'],
        'name': storeName,
        'domain': _stringValue(storeData['domain'], ''),
        'slug': _stringValue(storeData['slug'], ''),
        'price': _priceForStore(storeName: storeName, storeId: storeId),
      });
    }
    return result;
  }

  /// Precios de mercado "normales" (tiers tipicos con los que se suele
  /// vender un juego digital: 19.99, 29.99, 39.99, 49.99, 59.99, 69.99).
  static const List<double> _marketTiers = [
    19.99,
    29.99,
    39.99,
    49.99,
    59.99,
    69.99,
  ];

  /// Redondea [price] hacia arriba al tier de mercado normal mas cercano.
  double _nearestMarketTier(double price) {
    for (final double tier in _marketTiers) {
      if (tier >= price) return tier;
    }
    return _marketTiers.last;
  }

  /// Elige un tier de mercado normal de forma determinista segun [seed],
  /// para cuando no hay un precio real de referencia.
  double _marketTierForSeed(int seed) {
    final int index = seed.abs() % _marketTiers.length;
    return _marketTiers[index];
  }

  /// Precio para una tienda individual de la lista "Tiendas disponibles".
  /// Steam usa el precio real de CheapShark si ya se cargo; el resto usa
  /// un precio de mercado normal (anclado al real de PC si existe).
  double _priceForStore({required String storeName, required int storeId}) {
    final bool isSteam = storeName.toLowerCase().contains('steam');

    if (isSteam && pcRealPrice.value != null) {
      return pcRealPrice.value!;
    }

    if (pcRealPrice.value != null) {
      return _nearestMarketTier(pcRealPrice.value!);
    }

    return _marketTierForSeed(id * 17 + storeId);
  }

  /// Precio para una plataforma (PC, PlayStation, Xbox, Nintendo).
  /// PC usa el precio real de CheapShark cuando esta disponible; las
  /// consolas siempre usan un precio de mercado normal (CheapShark no
  /// cubre PlayStation Store, Xbox Store ni Nintendo eShop), anclado al
  /// precio real de PC cuando se conoce. Retorna null si el juego no
  /// esta disponible en esa plataforma.
  double? simulatedPriceForPlatform(String platformName) {
    if (!hasPlatform(platformName)) return null;

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

  Map<String, String> get minimumRequirements {
    final dynamic value = detail['platforms'];
    if (value is! List) return {};

    for (final dynamic item in value) {
      if (item is! Map) continue;
      final dynamic platform = item['platform'];
      if (platform is! Map) continue;

      final String platformName = _stringValue(platform['name'], '');
      if (platformName.toLowerCase() != 'pc') continue;

      final dynamic requirements = item['requirements_en'];
      if (requirements is Map) {
        return {
          'minimum': _stringValue(
            requirements['minimum'],
            'Sin requisitos mínimos.',
          ),
          'recommended': _stringValue(
            requirements['recommended'],
            'Sin requisitos recomendados.',
          ),
        };
      }
    }
    return {};
  }

  String get mainGenre => genres.isEmpty ? 'Sin género' : genres.first;
  String get mainDeveloper => developers.isEmpty ? 'Sin desarrollador' : developers.first;
  String get informationLine => [mainGenre, mainDeveloper, released].join(' - ');

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
          return false;
      }
    });
  }

  // --- SELECCIÓN DE EVALUACIONES ---

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
        'Calificación',
        'Selecciona una calificación.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Calificación guardada',
      'Tu calificación fue registrada exitosamente.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Publica el comentario junto a las 4 calificaciones multicriterio en Cloud Firestore
  Future<void> publishCommentToFirebase() async {
    if (isSubmittingComment.value) return;

    final String text = commentController.text.trim();

    if (text.isEmpty) {
      Get.snackbar(
        'Comentario vacío',
        'Por favor escribe una opinión sobre el juego.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmittingComment.value = true;
      final User? user = _auth.currentUser;

      final newComment = GameCommentModel(
        gameId: game.id,
        userId: user?.uid ?? 'anonymous',
        userName: user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuario Gamer',
        userPhotoUrl: user?.photoURL ?? '',
        text: text,
        graphicsRating: graphicsRating.value,
        gameplayRating: gameplayRating.value,
        storyRating: storyRating.value,
        innovationRating: innovationRating.value,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addComment(newComment);

      // Limpieza
      commentController.clear();
      graphicsRating.value = 5.0;
      gameplayRating.value = 5.0;
      storyRating.value = 5.0;
      innovationRating.value = 5.0;

      Get.snackbar(
        'Comentario publicado',
        'Tu evaluación ha sido registrada correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo publicar el comentario: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmittingComment.value = false;
    }
  }


  List<String> _extractNames(dynamic value) {
    if (value is! List) return [];
    final List<String> result = [];
    for (final dynamic item in value) {
      if (item is! Map) continue;
      final String itemName = _stringValue(item['name'], '');
      if (itemName.isNotEmpty) result.add(itemName);
    }
    return result;
  }

  List<Map<String, dynamic>> _extractMaps(dynamic value) {
    if (value is! List) return [];
    final List<Map<String, dynamic>> result = [];
    for (final dynamic item in value) {
      if (item is Map<String, dynamic>) {
        result.add(item);
      } else if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      }
    }
    return result;
  }

  int _intValue(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _doubleValue(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _stringValue(dynamic value, String fallback) {
    final String text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
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