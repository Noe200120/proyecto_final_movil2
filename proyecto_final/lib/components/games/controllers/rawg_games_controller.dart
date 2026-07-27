import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/request_handler.dart';
import '../models/modelo.dart';

class RawgGamesController extends GetxController {
  final RequestHandler requestHandler = RequestHandler();

  final TextEditingController searchController =
      TextEditingController();

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

      final RequestGamesModel response =
          await requestHandler.requestGetGames(
        page: currentPage.value,
        pageSize: gamesPerPage,
      );

      games.assignAll(response.results);

      applyFilters();
    } catch (error) {
      games.clear();
      filteredGames.clear();

      errorMessage.value = error
          .toString()
          .replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFeaturedGame() async {
    try {
      isFeaturedLoading.value = true;

      final RequestGamesModel response =
          await requestHandler.requestGetGames(
        page: 1,
        pageSize: 1,
      );

      if (response.results.isNotEmpty) {
        featuredGame.value = response.results.first;
      }
    } catch (_) {
      featuredGame.value = null;
    } finally {
      isFeaturedLoading.value = false;
    }
  }

  Future<void> reloadGames() async {
    await Future.wait([
      loadGames(),
      loadFeaturedGame(),
    ]);
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > totalPages) {
      return;
    }

    if (page == currentPage.value) {
      return;
    }

    currentPage.value = page;
    selectedPlatform.value = 0;

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

  void selectPlatform(int index) {
    if (index < 0 || index >= platforms.length) {
      return;
    }

    selectedPlatform.value = index;

    applyFilters();
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
      result = result.where((game) {
        final String name = game.name.toLowerCase();

        final bool matchesName =
            name.contains(searchText.value);

        final bool matchesGenre =
            game.genres.any((genre) {
          return genre
              .toLowerCase()
              .contains(searchText.value);
        });

        return matchesName || matchesGenre;
      }).toList();
    }

    if (selectedPlatform.value != 0) {
      final String selected =
          platforms[selectedPlatform.value]
              .toLowerCase();

      result = result.where((game) {
        return game.platforms.any((platform) {
          final String platformName =
              platform.toLowerCase();

          switch (selected) {
            case 'pc':
              return platformName == 'pc' ||
                  platformName.contains('windows');

            case 'playstation':
              return platformName
                  .contains('playstation');

            case 'xbox':
              return platformName.contains('xbox');

            case 'nintendo':
              return platformName
                  .contains('nintendo') ||
                  platformName.contains('switch');

            default:
              return true;
          }
        });
      }).toList();
    }

    filteredGames.assignAll(result);
  }

  @override
  void onClose() {
    searchController.dispose();

    super.onClose();
  }
}