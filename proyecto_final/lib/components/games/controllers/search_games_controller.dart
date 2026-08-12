import 'package:get/get.dart';

import '../../shared/request_handler.dart';
import '../models/modelo.dart';
import 'rawg_games_controller.dart';

class SearchGamesController extends RawgGamesController {
  static const List<String> sortOptions = [
    'Relevancia',
    'Nombre A-Z',
    'Mas recientes',
    'Mas antiguos',
  ];

  final RequestHandler _requestHandler = RequestHandler();

  final RxInt selectedSort = 0.obs;
  final RxBool hasSearched = false.obs;

  final RxString selectedGenreName = ''.obs;

  List<GameModel> get sortedResults {
    final List<GameModel> games = List<GameModel>.from(filteredGames);

    switch (selectedSort.value) {
      case 1:
        games.sort((GameModel a, GameModel b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;

      case 2:
        games.sort((GameModel a, GameModel b) {
          return _dateValue(b.released).compareTo(_dateValue(a.released));
        });
        break;

      case 3:
        games.sort((GameModel a, GameModel b) {
          return _dateValue(a.released).compareTo(_dateValue(b.released));
        });
        break;

      default:
        break;
    }

    return games;
  }

  void search(String value) {
    final String text = value.trim();

    searchText.value = text;

    selectedGenreName.value = '';

    if (text.isEmpty) {
      hasSearched.value = false;
      filteredGames.clear();
      return;
    }

    hasSearched.value = true;
    currentPage.value = 1;

    loadSearchResults();
  }

  void submitSearch(String value) {
    search(value);
  }

  Future<void> searchByGenre({
    required String name,
    required String slug,
    bool useTag = false,
  }) async {
    searchController.clear();

    searchText.value = '';

    selectedGenreName.value = name;

    hasSearched.value = true;

    currentPage.value = 1;

    await loadSearchResults();
  }

  void selectSearchPlatform(int index) {
    if (index < 0 || index >= RawgGamesController.platforms.length) {
      return;
    }

    selectedPlatform.value = index;

    currentPage.value = 1;

    if (hasSearched.value) {
      loadSearchResults();
    }
  }

  void selectSort(int index) {
    if (index < 0 || index >= sortOptions.length) {
      return;
    }

    selectedSort.value = index;
  }

  Future<void> retrySearch() async {
    if (!hasSearched.value) {
      return;
    }

    await loadSearchResults();
  }

  Future<void> loadSearchResults() async {
    final String text = searchController.text.trim();

    final bool hasText = text.isNotEmpty;

    final bool hasGenre = selectedGenreName.value.isNotEmpty;

    if (!hasText && !hasGenre) {
      filteredGames.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      RequestGamesModel response;

      if (hasText) {
        response = await _requestHandler.requestGetGames(
          page: currentPage.value,
          pageSize: 40,
          search: text,
          parentPlatformId: _getParentPlatformId(),
        );
      } else {
        response = await _requestHandler.requestGetGames(
          page: currentPage.value,
          pageSize: 40,
          parentPlatformId: _getParentPlatformId(),
        );
      }

      List<GameModel> result = List<GameModel>.from(response.results);

      if (hasGenre) {
        result = _filterByGenre(result, selectedGenreName.value);
      }

      filteredGames.assignAll(result);
    } catch (error) {
      filteredGames.clear();

      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  List<GameModel> _filterByGenre(List<GameModel> games, String genreName) {
    final String selected = _normalizeGenre(genreName);

    return games.where((GameModel game) {
      return game.genres.any((String genre) {
        final String current = _normalizeGenre(genre);

        return _genreMatches(selected, current);
      });
    }).toList();
  }

  bool _genreMatches(String selected, String current) {
    switch (selected) {
      case 'accion':
        return current == 'action';

      case 'aventura':
        return current == 'adventure';

      case 'carreras':
        return current == 'racing';

      case 'terror':
        return current == 'horror';

      case 'estrategia':
        return current == 'strategy';

      case 'deportes':
        return current == 'sports';

      default:
        return current == selected;
    }
  }

  String _normalizeGenre(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  Future<void> applyFilters() async {
    if (!hasSearched.value) {
      return;
    }

    currentPage.value = 1;

    await loadSearchResults();
  }

  Future<void> clearAll() async {
    searchController.clear();

    searchText.value = '';

    selectedGenreName.value = '';

    selectedPlatform.value = 0;

    selectedSort.value = 0;

    currentPage.value = 1;

    hasSearched.value = false;

    errorMessage.value = '';

    filteredGames.clear();
  }

  int? _getParentPlatformId() {
    switch (selectedPlatform.value) {
      case 1:
        return 1;

      case 2:
        return 2;

      case 3:
        return 3;

      case 4:
        return 7;

      default:
        return null;
    }
  }

  int _dateValue(String date) {
    if (date.trim().isEmpty) {
      return 0;
    }

    return DateTime.tryParse(date)?.millisecondsSinceEpoch ?? 0;
  }
}
