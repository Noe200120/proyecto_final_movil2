import 'package:get/get.dart';

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

  final RxInt selectedSort = 0.obs;
  final RxBool hasSearched = false.obs;

  List<GameModel> get sortedResults {
    final List<GameModel> games =
        List<GameModel>.from(filteredGames);

    switch (selectedSort.value) {
      case 1:
        games.sort(
          (GameModel a, GameModel b) {
            return b.rating.compareTo(a.rating);
          },
        );
        break;

      case 2:
        games.sort(
          (GameModel a, GameModel b) {
            return a.name.toLowerCase().compareTo(
                  b.name.toLowerCase(),
                );
          },
        );
        break;

      case 3:
        games.sort(
          (GameModel a, GameModel b) {
            return _dateValue(b.released).compareTo(
              _dateValue(a.released),
            );
          },
        );
        break;

      case 4:
        games.sort(
          (GameModel a, GameModel b) {
            return _dateValue(a.released).compareTo(
              _dateValue(b.released),
            );
          },
        );
        break;

      default:
        break;
    }

    return games;
  }

  void search(String value) {
    final String text = value.trim();

    searchText.value = text;
    hasSearched.value = text.isNotEmpty;

    searchGames(text);
  }

  void submitSearch(String value) {
    search(value);
  }

  void selectSearchPlatform(int index) {
    selectedPlatform.value = index;
    currentPage.value = 1;

    if (searchController.text.trim().isNotEmpty) {
      hasSearched.value = true;
    }

    loadGames();
  }

  void selectSort(int index) {
    if (index < 0 || index >= sortOptions.length) {
      return;
    }

    selectedSort.value = index;
  }

  Future<void> retrySearch() async {
    await loadGames();
  }

  Future<void> clearAll() async {
    searchController.clear();

    searchText.value = '';
    selectedPlatform.value = 0;
    selectedSort.value = 0;
    currentPage.value = 1;
    hasSearched.value = false;

    filteredGames.clear();
  }

  int _dateValue(String date) {
    if (date.trim().isEmpty) {
      return 0;
    }

    return DateTime.tryParse(date)?.millisecondsSinceEpoch ?? 0;
  }
}