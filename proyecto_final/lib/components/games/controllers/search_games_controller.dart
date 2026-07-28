import 'package:get/get.dart';

import '../../shared/request_handler.dart';
import '../models/modelo.dart';
import 'rawg_games_controller.dart';

class SearchGamesController extends RawgGamesController {
  static const List<String> sortOptions = [
    'Relevancia',
    'Mejor calificacion',
    'Nombre A-Z',
    'Mas recientes',
    'Mas antiguos',
  ];

  static const Map<String, String> genreSlugs = {
    'Accion': 'action',
    'Aventura': 'adventure',
    'Carreras': 'racing',
    'Estrategia': 'strategy',
    'Deportes': 'sports',
  };

  final RequestHandler _requestHandler =
      RequestHandler();

  final RxInt selectedSort = 0.obs;
  final RxBool hasSearched = false.obs;

  final RxString selectedGenreName = ''.obs;
  final RxString selectedGenreSlug = ''.obs;
  final RxString selectedTagSlug = ''.obs;

  List<GameModel> get sortedResults {
    final List<GameModel> games =
        List<GameModel>.from(
      filteredGames,
    );

    switch (selectedSort.value) {
      case 1:
        games.sort(
          (
            GameModel a,
            GameModel b,
          ) {
            return b.rating.compareTo(
              a.rating,
            );
          },
        );
        break;

      case 2:
        games.sort(
          (
            GameModel a,
            GameModel b,
          ) {
            return a.name
                .toLowerCase()
                .compareTo(
                  b.name.toLowerCase(),
                );
          },
        );
        break;

      case 3:
        games.sort(
          (
            GameModel a,
            GameModel b,
          ) {
            return _dateValue(
              b.released,
            ).compareTo(
              _dateValue(
                a.released,
              ),
            );
          },
        );
        break;

      case 4:
        games.sort(
          (
            GameModel a,
            GameModel b,
          ) {
            return _dateValue(
              a.released,
            ).compareTo(
              _dateValue(
                b.released,
              ),
            );
          },
        );
        break;

      default:
        break;
    }

    return games;
  }

  void search(
    String value,
  ) {
    final String text =
        value.trim();

    searchText.value = text;
    hasSearched.value =
        text.isNotEmpty;

    selectedGenreName.value = '';
    selectedGenreSlug.value = '';
    selectedTagSlug.value = '';

    if (text.isEmpty) {
      filteredGames.clear();
      return;
    }

    currentPage.value = 1;

    loadSearchResults();
  }

  void submitSearch(
    String value,
  ) {
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

    if (useTag) {
      selectedGenreSlug.value = '';
      selectedTagSlug.value = slug;
    } else {
      selectedGenreSlug.value = slug;
      selectedTagSlug.value = '';
    }

    hasSearched.value = true;
    currentPage.value = 1;

    await loadSearchResults();
  }

  void selectSearchPlatform(
    int index,
  ) {
    selectedPlatform.value =
        index;

    currentPage.value = 1;

    final bool hasText =
        searchController.text
            .trim()
            .isNotEmpty;

    final bool hasGenre =
        selectedGenreSlug
            .value
            .isNotEmpty ||
        selectedTagSlug
            .value
            .isNotEmpty;

    if (hasText || hasGenre) {
      hasSearched.value = true;
      loadSearchResults();
    }
  }

  void selectSort(
    int index,
  ) {
    if (index < 0 ||
        index >= sortOptions.length) {
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
    final String text =
        searchController.text.trim();

    final bool hasGenre =
        selectedGenreSlug.value.isNotEmpty;

    final bool hasTag =
        selectedTagSlug.value.isNotEmpty;

    if (text.isEmpty &&
        !hasGenre &&
        !hasTag) {
      filteredGames.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final RequestGamesModel response =
          await _requestHandler.requestGetGames(
        page: currentPage.value,
        pageSize: 30,
        search: text,
        parentPlatformId:
            _getParentPlatformId(),
        genre:
            selectedGenreSlug.value,
        tag:
            selectedTagSlug.value,
        ordering:
            _getApiOrdering(),
      );

      filteredGames.assignAll(
        response.results,
      );
    } catch (error) {
      filteredGames.clear();

      errorMessage.value = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );
    } finally {
      isLoading.value = false;
    }
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
    selectedGenreSlug.value = '';
    selectedTagSlug.value = '';

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

  String _getApiOrdering() {
    switch (selectedSort.value) {
      case 1:
        return '-rating';

      case 2:
        return 'name';

      case 3:
        return '-released';

      case 4:
        return 'released';

      default:
        return '-added';
    }
  }

  int _dateValue(
    String date,
  ) {
    if (date.trim().isEmpty) {
      return 0;
    }

    return DateTime.tryParse(
          date,
        )?.millisecondsSinceEpoch ??
        0;
  }
}