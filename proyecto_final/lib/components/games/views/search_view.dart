import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/design_placeholder.dart';
import '../../utils/app_colors.dart';
import '../controllers/rawg_games_controller.dart';
import '../controllers/search_games_controller.dart';
import '../models/modelo.dart';
import 'game_detail_view.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final SearchGamesController controller = Get.put<SearchGamesController>(
    SearchGamesController(),
    tag: 'search-games-controller',
  );

  static const List<Map<String, dynamic>> popularGenres = [
    {
      'name': 'Accion',
      'slug': 'action',
      'useTag': false,
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'name': 'Aventura',
      'slug': 'adventure',
      'useTag': false,
      'icon': Icons.explore_rounded,
    },
    {
      'name': 'Carreras',
      'slug': 'racing',
      'useTag': false,
      'icon': Icons.sports_motorsports_rounded,
    },
    {
      'name': 'Terror',
      'slug': 'horror',
      'useTag': true,
      'icon': Icons.nightlight_round,
    },
    {
      'name': 'Estrategia',
      'slug': 'strategy',
      'useTag': false,
      'icon': Icons.psychology_rounded,
    },
    {
      'name': 'Deportes',
      'slug': 'sports',
      'useTag': false,
      'icon': Icons.sports_soccer_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar videojuegos'),
        actions: [
          Obx(() {
            final bool canClear =
                controller.searchText.value.isNotEmpty ||
                controller.selectedGenreName.value.isNotEmpty ||
                controller.selectedPlatform.value != 0 ||
                controller.selectedSort.value != 0;

            if (!canClear) {
              return const SizedBox.shrink();
            }

            return TextButton(
              onPressed: controller.clearAll,
              child: const Text('Limpiar'),
            );
          }),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.retrySearch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              _buildSearchArea(context),
              const SizedBox(height: 24),
              Obx(() {
                final bool hasSearched = controller.hasSearched.value;

                final bool hasText = controller.searchText.value
                    .trim()
                    .isNotEmpty;

                final bool hasGenre =
                    controller.selectedGenreName.value.isNotEmpty;

                if (!hasSearched && !hasText && !hasGenre) {
                  return _buildInitialContent();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultsTitle(),
                    const SizedBox(height: 14),
                    _buildResults(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchArea(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Obx(() {
            final bool hasText = controller.searchText.value.isNotEmpty;

            return TextField(
              controller: controller.searchController,
              onChanged: controller.search,
              onSubmitted: controller.submitSearch,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Nombre del videojuego...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: hasText
                    ? IconButton(
                        onPressed: controller.clearAll,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Limpiar busqueda',
                      )
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(width: 10),
        _buildFilterButton(context),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Obx(() {
      final int activeFilters = _activeFiltersCount();

      return InkWell(
        onTap: () {
          _showFilterOptions(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: activeFilters > 0 ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activeFilters > 0
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.tune_rounded,
                  color: activeFilters > 0
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              if (activeFilters > 0)
                Positioned(
                  right: -4,
                  top: -5,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: Text(
                      activeFilters.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  int _activeFiltersCount() {
    int count = 0;

    if (controller.selectedPlatform.value != 0) {
      count++;
    }

    if (controller.selectedSort.value != 0) {
      count++;
    }

    return count;
  }

  Widget _buildInitialContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explorar por genero',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Selecciona una categoria para ver juegos de ese genero.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 15),
        _buildGenreGrid(),
      ],
    );
  }

  Widget _buildGenreGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: popularGenres.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.25,
      ),
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> genre = popularGenres[index];

        final String genreName = genre['name'] as String;

        final String genreSlug = genre['slug'] as String;

        final bool useTag = genre['useTag'] as bool;

        final IconData genreIcon = genre['icon'] as IconData;

        return InkWell(
          onTap: () {
            controller.searchByGenre(
              name: genreName,
              slug: genreSlug,
              useTag: useTag,
            );
          },
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(genreIcon, color: AppColors.primary, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    genreName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsTitle() {
    return Obx(() {
      final bool loading = controller.isLoading.value;

      final int total = controller.sortedResults.length;

      final String searchText = controller.searchText.value.trim();

      final String genreName = controller.selectedGenreName.value;

      final String title;

      if (genreName.isNotEmpty) {
        title = 'Juegos de $genreName';
      } else if (searchText.isNotEmpty) {
        title = 'Resultados para "$searchText"';
      } else {
        title = 'Resultados';
      }

      final String subtitle = loading ? 'Buscando...' : '$total encontrados';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final int activeFilters = _activeFiltersCount();

            if (activeFilters == 0) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$activeFilters filtros',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildResults() {
    return Obx(() {
      final bool loading = controller.isLoading.value;

      final String error = controller.errorMessage.value;

      final bool hasSearched = controller.hasSearched.value;

      final List<GameModel> games = controller.sortedResults.toList();

      if (loading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 65),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (error.isNotEmpty) {
        return Column(
          children: [
            DesignPlaceholder(
              icon: Icons.error_outline_rounded,
              title: 'Error en la busqueda',
              message: error,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.retrySearch,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        );
      }

      if (!hasSearched) {
        return const DesignPlaceholder(
          icon: Icons.search_rounded,
          title: 'Busca un videojuego',
          message: 'Escribe el nombre del videojuego que deseas encontrar.',
        );
      }

      if (games.isEmpty) {
        return const DesignPlaceholder(
          icon: Icons.search_off_rounded,
          title: 'Sin resultados',
          message:
              'No se encontraron videojuegos con la busqueda y los filtros seleccionados.',
        );
      }

      return Column(
        children: games.map((GameModel game) {
          return _buildGameCard(game);
        }).toList(),
      );
    });
  }

  Widget _buildGameCard(GameModel game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => GameDetailView(game: game));
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 98,
                  height: 130,
                  child: game.backgroundImage.isNotEmpty
                      ? Image.network(
                          game.backgroundImage,
                          width: 98,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return _buildImagePlaceholder();
                              },
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            game.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              game.released.isNotEmpty
                                  ? game.released
                                  : 'Sin fecha',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            game.platforms.isNotEmpty
                                ? game.platforms.take(2).join(' - ')
                                : 'Sin plataforma',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 98,
      height: 130,
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_esports_rounded,
        color: AppColors.primary,
        size: 34,
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filtros de busqueda',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearAll();

                        Navigator.pop(bottomSheetContext);
                      },
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Selecciona una plataforma y el orden de los resultados.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Plataforma',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final int selectedIndex = controller.selectedPlatform.value;

                  return Wrap(
                    spacing: 9,
                    runSpacing: 10,
                    children: List.generate(
                      RawgGamesController.platforms.length,
                      (int index) {
                        final String platform =
                            RawgGamesController.platforms[index];

                        final bool selected = selectedIndex == index;

                        return InkWell(
                          onTap: () {
                            controller.selectSearchPlatform(index);
                          },
                          borderRadius: BorderRadius.circular(13),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white10,
                              ),
                            ),
                            child: Text(
                              platform,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 26),
                const Text(
                  'Ordenar por',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 11),
                Obx(() {
                  return Column(
                    children: List.generate(
                      SearchGamesController.sortOptions.length,
                      (int index) {
                        final bool selected =
                            controller.selectedSort.value == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacity(0.13)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.5)
                                  : Colors.white10,
                            ),
                          ),
                          child: RadioListTile<int>(
                            value: index,
                            groupValue: controller.selectedSort.value,
                            activeColor: AppColors.primary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            title: Text(
                              SearchGamesController.sortOptions[index],
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                            onChanged: (int? selectedIndex) {
                              if (selectedIndex == null) {
                                return;
                              }

                              controller.selectSort(selectedIndex);
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);

                      controller.applyFilters();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aplicar filtros'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
