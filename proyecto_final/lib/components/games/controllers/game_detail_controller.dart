import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/request_handler.dart';
import '../models/modelo.dart';
import 'favorites_controller.dart';

class GameDetailController extends GetxController {
  GameDetailController({required this.game});

  final GameModel game;

  final RequestHandler requestHandler = RequestHandler();

  final FavoritesController favoritesController =
      Get.find<FavoritesController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxMap<String, dynamic> detail = <String, dynamic>{}.obs;

  final RxBool isFavorite = false.obs;

  final RxDouble userRating = 0.0.obs;
  final RxDouble graphicsRating = 0.0.obs;
  final RxDouble gameplayRating = 0.0.obs;
  final RxDouble storyRating = 0.0.obs;
  final RxDouble innovationRating = 0.0.obs;

  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;

  final TextEditingController commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    updateFavoriteStatus();
    loadGameDetail();
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

  String get slug {
    return _stringValue(detail['slug'], '');
  }

  String get description {
    final String descriptionRaw = _stringValue(detail['description_raw'], '');

    if (descriptionRaw.isNotEmpty) {
      return descriptionRaw;
    }

    final String descriptionHtml = _stringValue(detail['description'], '');

    if (descriptionHtml.isNotEmpty) {
      return _removeHtml(descriptionHtml);
    }

    return 'Sin descripcion disponible.';
  }

  String get backgroundImage {
    return _stringValue(detail['background_image'], game.backgroundImage);
  }

  String get backgroundImageAdditional {
    return _stringValue(detail['background_image_additional'], '');
  }

  String get released {
    return _stringValue(
      detail['released'],
      game.released.isNotEmpty ? game.released : 'Sin fecha',
    );
  }

  bool get tba {
    final dynamic value = detail['tba'];

    if (value is bool) {
      return value;
    }

    return false;
  }

  double get rating {
    return _doubleValue(detail['rating'], game.rating);
  }

  int get ratingTop {
    return _intValue(detail['rating_top'], 5);
  }

  int get ratingsCount {
    return _intValue(detail['ratings_count'], 0);
  }

  int get reviewsCount {
    return _intValue(detail['reviews_count'], 0);
  }

  int get reviewsTextCount {
    return _intValue(detail['reviews_text_count'], 0);
  }

  int get metacritic {
    return _intValue(detail['metacritic'], 0);
  }

  int get playtime {
    return _intValue(detail['playtime'], 0);
  }

  int get added {
    return _intValue(detail['added'], 0);
  }

  int get suggestionsCount {
    return _intValue(detail['suggestions_count'], 0);
  }

  String get website {
    return _stringValue(detail['website'], '');
  }

  String get redditUrl {
    return _stringValue(detail['reddit_url'], '');
  }

  String get redditName {
    return _stringValue(detail['reddit_name'], '');
  }

  String get redditDescription {
    return _stringValue(detail['reddit_description'], '');
  }

  String get metacriticUrl {
    return _stringValue(detail['metacritic_url'], '');
  }

  String get esrbRating {
    final dynamic value = detail['esrb_rating'];

    if (value is Map) {
      return _stringValue(value['name'], 'Sin clasificacion');
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

  List<String> get parentPlatforms {
    final dynamic value = detail['parent_platforms'];

    if (value is! List) {
      return [];
    }

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

    return result;
  }

  List<String> get developers {
    return _extractNames(detail['developers']);
  }

  List<String> get publishers {
    return _extractNames(detail['publishers']);
  }

  List<String> get tags {
    return _extractNames(detail['tags']);
  }

  List<Map<String, dynamic>> get ratings {
    return _extractMaps(detail['ratings']);
  }

  List<Map<String, dynamic>> get stores {
    final dynamic value = detail['stores'];

    if (value is! List) {
      return [];
    }

    final List<Map<String, dynamic>> result = [];

    for (final dynamic item in value) {
      if (item is! Map) {
        continue;
      }

      final dynamic storeData = item['store'];

      if (storeData is! Map) {
        continue;
      }

      result.add({
        'id': storeData['id'],
        'name': _stringValue(storeData['name'], 'Tienda'),
        'domain': _stringValue(storeData['domain'], ''),
        'slug': _stringValue(storeData['slug'], ''),
        'price': null,
      });
    }

    return result;
  }

  Map<String, String> get minimumRequirements {
    final dynamic value = detail['platforms'];

    if (value is! List) {
      return {};
    }

    for (final dynamic item in value) {
      if (item is! Map) {
        continue;
      }

      final dynamic platform = item['platform'];

      if (platform is! Map) {
        continue;
      }

      final String platformName = _stringValue(platform['name'], '');

      if (platformName.toLowerCase() != 'pc') {
        continue;
      }

      final dynamic requirements = item['requirements_en'];

      if (requirements is Map) {
        return {
          'minimum': _stringValue(
            requirements['minimum'],
            'Sin requisitos minimos.',
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

  String get mainGenre {
    if (genres.isEmpty) {
      return 'Sin genero';
    }

    return genres.first;
  }

  String get mainDeveloper {
    if (developers.isEmpty) {
      return 'Sin desarrollador';
    }

    return developers.first;
  }

  String get informationLine {
    return [mainGenre, mainDeveloper, released].join(' - ');
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
          return false;
      }
    });
  }

  void selectUserRating(double value) {
    if (value < 0 || value > 5) {
      return;
    }

    userRating.value = value;
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
      'Tu calificacion fue guardada.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> publishCommentToFirebase() async {
    final String text = commentController.text.trim();

    if (text.isEmpty) {
      Get.snackbar(
        'Comentario vacio',
        'Escribe un comentario.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    comments.insert(0, {
      'text': text,
      'createdAt': DateTime.now(),
      'userName': 'Usuario',
    });

    commentController.clear();

    Get.snackbar(
      'Comentario publicado',
      'Tu comentario fue agregado.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  List<String> _extractNames(dynamic value) {
    if (value is! List) {
      return [];
    }

    final List<String> result = [];

    for (final dynamic item in value) {
      if (item is! Map) {
        continue;
      }

      final String itemName = _stringValue(item['name'], '');

      if (itemName.isNotEmpty) {
        result.add(itemName);
      }
    }

    return result;
  }

  List<Map<String, dynamic>> _extractMaps(dynamic value) {
    if (value is! List) {
      return [];
    }

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
