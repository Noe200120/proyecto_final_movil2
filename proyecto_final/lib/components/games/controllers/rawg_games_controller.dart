import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/request_handler.dart';
import '../models/modelo.dart';

class RawgGamesController extends GetxController {
  final RequestHandler requestHandler = RequestHandler();

  final TextEditingController searchController = TextEditingController();

  final RxList<GameModel> games = <GameModel>[].obs;
  final RxList<GameModel> filteredGames = <GameModel>[].obs;

  final Rxn<GameModel> featuredGame = Rxn<GameModel>();

  final RxBool isLoading = false.obs;
  final RxBool isFeaturedLoading = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString searchText = ''.obs;

  final RxInt selectedPlatform = 0.obs;
  final RxInt currentPage = 1.obs;

  static const int totalPages = 5;
  static const int gamesPerPage = 20;

  static const List<String> platforms = [
    'Todos',
    'PC',
    'PlayStation',
    'Xbox',
    'Nintendo',
  ];

  @override
  void onInit() {
    super.onInit();

    loadFeaturedGame();
    loadGames();
  }

  Future<void> loadGames() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (selectedPlatform.value == 0) {
        await _loadAllPlatforms();
      } else {
        final int? platformId = _getSelectedPlatformId();

        if (platformId == null) {
          throw Exception('No se pudo identificar la plataforma.');
        }

        final RequestGamesModel response = await requestHandler.requestGetGames(
          page: currentPage.value,
          pageSize: gamesPerPage,
          parentPlatformId: platformId,
        );

        games.assignAll(response.results);
      }

      applyFilters();
    } catch (error) {
      games.clear();
      filteredGames.clear();

      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllPlatforms() async {
    final List<int> platformIds = [1, 2, 3, 7];

    const int gamesPerPlatform = 5;

    final List<Future<RequestGamesModel>> requests = [];

    for (final int platformId in platformIds) {
      requests.add(
        requestHandler.requestGetGames(
          page: currentPage.value,
          pageSize: gamesPerPlatform,
          parentPlatformId: platformId,
        ),
      );
    }

    final List<RequestGamesModel> responses = await Future.wait(requests);

    final List<GameModel> allGames = [];

    for (final RequestGamesModel response in responses) {
      allGames.addAll(response.results);
    }

    final Map<int, GameModel> uniqueGames = {};

    for (final GameModel game in allGames) {
      uniqueGames[game.id] = game;
    }

    final List<GameModel> finalGames = uniqueGames.values.toList();

    finalGames.shuffle();

    games.assignAll(finalGames);
  }

  Future<void> loadFeaturedGame() async {
    try {
      isFeaturedLoading.value = true;

      if (selectedPlatform.value == 0) {
        final RequestGamesModel response = await requestHandler.requestGetGames(
          page: 1,
          pageSize: 1,
          parentPlatformId: 1,
        );

        if (response.results.isNotEmpty) {
          featuredGame.value = response.results.first;
        } else {
          featuredGame.value = null;
        }

        return;
      }

      final int? platformId = _getSelectedPlatformId();

      if (platformId == null) {
        featuredGame.value = null;
        return;
      }

      final RequestGamesModel response = await requestHandler.requestGetGames(
        page: 1,
        pageSize: 1,
        parentPlatformId: platformId,
      );

      if (response.results.isNotEmpty) {
        featuredGame.value = response.results.first;
      } else {
        featuredGame.value = null;
      }
    } catch (_) {
      featuredGame.value = null;
    } finally {
      isFeaturedLoading.value = false;
    }
  }

  Future<void> reloadGames() async {
    await Future.wait([loadGames(), loadFeaturedGame()]);
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > totalPages) {
      return;
    }

    if (page == currentPage.value) {
      return;
    }

    currentPage.value = page;

    await loadGames();
  }

  Future<void> previousPage() async {
    if (currentPage.value > 1) {
      await changePage(currentPage.value - 1);
    }
  }

  Future<void> nextPage() async {
    if (currentPage.value < totalPages) {
      await changePage(currentPage.value + 1);
    }
  }

  Future<void> selectPlatform(int index) async {
    if (index < 0 || index >= platforms.length) {
      return;
    }

    if (selectedPlatform.value == index) {
      return;
    }

    selectedPlatform.value = index;

    currentPage.value = 1;

    searchController.clear();
    searchText.value = '';

    games.clear();
    filteredGames.clear();

    await Future.wait([loadGames(), loadFeaturedGame()]);
  }

  void searchGames(String value) {
    searchText.value = value.trim().toLowerCase();

    applyFilters();
  }

  void clearSearch() {
    searchController.clear();

    searchText.value = '';

    applyFilters();
  }

  void applyFilters() {
    List<GameModel> result = List<GameModel>.from(games);

    if (searchText.value.isNotEmpty) {
      result = result.where((GameModel game) {
        final String name = game.name.toLowerCase();

        final bool matchesName = name.contains(searchText.value);

        final bool matchesGenre = game.genres.any((String genre) {
          return genre.toLowerCase().contains(searchText.value);
        });

        return matchesName || matchesGenre;
      }).toList();
    }

    filteredGames.assignAll(result);
  }

  int? _getSelectedPlatformId() {
    switch (selectedPlatform.value) {
      // TODOS
      case 0:
        return null;

      // PC
      case 1:
        return 1;

      // PLAYSTATION
      case 2:
        return 2;

      // XBOX
      case 3:
        return 3;

      // NINTENDO
      case 4:
        return 7;

      default:
        return null;
    }
  }

  @override
  void onClose() {
    searchController.dispose();

    super.onClose();
  }
}
