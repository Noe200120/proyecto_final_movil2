import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/design_placeholder.dart';
import '../../shared/platform_chip.dart';
import '../../utils/app_colors.dart';
import '../controllers/rawg_games_controller.dart';
import '../controllers/search_games_controller.dart';
import '../models/modelo.dart';
import 'game_detail_view.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final SearchGamesController controller =
      Get.put<SearchGamesController>(
    SearchGamesController(),
    tag: 'search-games-controller',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar videojuegos'),
        actions: [
          Obx(
            () {
              final bool canClear =
                  controller.searchText.value.isNotEmpty ||
                      controller.selectedPlatform.value != 0 ||
                      controller.selectedSort.value != 0;

              return TextButton(
                onPressed: canClear
                    ? () {
                        controller.clearAll();
                      }
                    : null,
                child: const Text('Limpiar'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.retrySearch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),
            children: [
              _buildSearchField(),
              const SizedBox(height: 18),
              _buildPlatformFilters(),
              const SizedBox(height: 24),
              _buildSortSelector(context),
              const SizedBox(height: 28),
              _buildResultsTitle(),
              const SizedBox(height: 14),
              _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Obx(
      () {
        final bool hasText =
            controller.searchText.value.isNotEmpty;

        return TextField(
          controller: controller.searchController,
          onChanged: controller.search,
          onSubmitted: controller.submitSearch,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Nombre del videojuego...',
            prefixIcon: const Icon(
              Icons.search_rounded,
            ),
            suffixIcon: hasText
                ? IconButton(
                    onPressed: () {
                      controller.clearAll();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    tooltip: 'Limpiar busqueda',
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPlatformFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por plataforma',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () {
            final int selectedIndex =
                controller.selectedPlatform.value;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                RawgGamesController.platforms.length,
                (int index) {
                  return PlatformChip(
                    label:
                        RawgGamesController.platforms[index],
                    selected: selectedIndex == index,
                    onTap: () {
                      controller.selectSearchPlatform(
                        index,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSortSelector(
    BuildContext context,
  ) {
    return Obx(
      () {
        final int selectedIndex =
            controller.selectedSort.value;

        return InkWell(
          onTap: () {
            _showSortOptions(context);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white10,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sort_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ordenar resultados',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SearchGamesController
                            .sortOptions[selectedIndex],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsTitle() {
    return Obx(
      () {
        final bool loading =
            controller.isLoading.value;

        final int total =
            controller.sortedResults.length;

        String subtitle;

        if (loading) {
          subtitle = 'Buscando...';
        } else if (!controller.hasSearched.value) {
          subtitle = 'Escribe el nombre de un juego';
        } else {
          subtitle = '$total resultados';
        }

        return SectionTitle(
          title: 'Resultados',
          subtitle: subtitle,
        );
      },
    );
  }

  Widget _buildResults() {
    return Obx(
      () {
        final bool loading =
            controller.isLoading.value;

        final String error =
            controller.errorMessage.value;

        final bool hasSearched =
            controller.hasSearched.value;

        final List<GameModel> games =
            controller.sortedResults;

        if (loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 65,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
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
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Reintentar',
                ),
              ),
            ],
          );
        }

        if (!hasSearched) {
          return const DesignPlaceholder(
            icon: Icons.search_rounded,
            title: 'Busca un videojuego',
            message:
                'Escribe el nombre del videojuego que deseas encontrar.',
          );
        }

        if (games.isEmpty) {
          return const DesignPlaceholder(
            icon: Icons.search_off_rounded,
            title: 'Sin resultados',
            message:
                'No se encontraron videojuegos con ese nombre y plataforma.',
          );
        }

        return Column(
          children: games.map(
            (GameModel game) {
              return _buildGameCard(game);
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildGameCard(GameModel game) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(
            () => GameDetailView(
              game: game,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 105,
                  height: 140,
                  child: game.backgroundImage.isNotEmpty
                      ? Image.network(
                          game.backgroundImage,
                          width: 105,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 19,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            game.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        game.released.isNotEmpty
                            ? game.released
                            : 'Sin fecha',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        game.platforms.isNotEmpty
                            ? game.platforms
                                .take(2)
                                .join(' - ')
                            : 'Sin plataforma',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.textSecondary,
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              color:
                                  AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 19,
                          ),
                        ],
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
      width: 105,
      height: 140,
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_esports_rounded,
        color: AppColors.primary,
        size: 42,
      ),
    );
  }

  void _showSortOptions(
    BuildContext context,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (
        BuildContext bottomSheetContext,
      ) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ordenar resultados',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  SearchGamesController
                      .sortOptions.length,
                  (int index) {
                    return Obx(
                      () {
                        final bool selected =
                            controller.selectedSort
                                    .value ==
                                index;

                        return RadioListTile<int>(
                          value: index,
                          groupValue:
                              controller.selectedSort.value,
                          onChanged: (
                            int? selectedIndex,
                          ) {
                            if (selectedIndex == null) {
                              return;
                            }

                            controller.selectSort(
                              selectedIndex,
                            );

                            Navigator.pop(
                              bottomSheetContext,
                            );
                          },
                          activeColor: AppColors.primary,
                          title: Text(
                            SearchGamesController
                                .sortOptions[index],
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}