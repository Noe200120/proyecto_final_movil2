import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/design_placeholder.dart';
import '../../shared/platform_chip.dart';
import '../../utils/app_colors.dart';
import '../controllers/rawg_games_controller.dart';
import '../models/modelo.dart';
import 'game_detail_view.dart';

class DiscoverView extends StatelessWidget {
  DiscoverView({super.key});

  final RawgGamesController controller = Get.put(RawgGamesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.reloadGames,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildHeader(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Obx(() {
                    final bool loading = controller.isFeaturedLoading.value;

                    final GameModel? game = controller.featuredGame.value;

                    return _buildFeaturedSection(loading: loading, game: game);
                  }),
                ),
              ),
              SliverToBoxAdapter(child: _buildPlatformFilters()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: Obx(() {
                    final bool loading = controller.isLoading.value;

                    final int total = controller.filteredGames.length;

                    return SectionTitle(
                      title: 'Catalogo de videojuegos',
                      subtitle: loading ? 'Cargando...' : '$total juegos',
                    );
                  }),
                ),
              ),
              Obx(() {
                final bool loading = controller.isLoading.value;

                final String error = controller.errorMessage.value;

                final List<GameModel> games = controller.filteredGames.toList();

                return _buildCatalog(
                  loading: loading,
                  error: error,
                  games: games,
                );
              }),
              SliverToBoxAdapter(
                child: Obx(() {
                  final bool loading = controller.isLoading.value;

                  final String error = controller.errorMessage.value;

                  final bool hasGames = controller.filteredGames.isNotEmpty;

                  final int currentPage = controller.currentPage.value;

                  if (loading || error.isNotEmpty || !hasGames) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    child: _buildPagination(currentPage: currentPage),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLUB GAMING',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Encuentra tu proximo juego',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          controller: controller.searchController,
          onChanged: controller.searchGames,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o genero...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: Obx(() {
              final bool hasText = controller.searchText.value.isNotEmpty;

              if (!hasText) {
                return const Icon(Icons.tune_rounded);
              }

              return IconButton(
                onPressed: controller.clearSearch,
                icon: const Icon(Icons.close_rounded),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformFilters() {
    return SizedBox(
      height: 76,
      child: Obx(() {
        final int selectedIndex = controller.selectedPlatform.value;

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          scrollDirection: Axis.horizontal,
          itemCount: RawgGamesController.platforms.length,
          separatorBuilder: (_, __) {
            return const SizedBox(width: 10);
          },
          itemBuilder: (context, index) {
            return PlatformChip(
              label: RawgGamesController.platforms[index],
              selected: selectedIndex == index,
              onTap: () {
                controller.selectPlatform(index);
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildCatalog({
    required bool loading,
    required String error,
    required List<GameModel> games,
  }) {
    if (loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 65),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (error.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              DesignPlaceholder(
                icon: Icons.error_outline_rounded,
                title: 'Error al cargar juegos',
                message: error,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: controller.loadGames,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (games.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 26),
        sliver: SliverToBoxAdapter(
          child: DesignPlaceholder(
            icon: Icons.search_off_rounded,
            title: 'Sin resultados',
            message: 'No hay juegos disponibles.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildGameCard(games[index]);
        }, childCount: games.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.67,
        ),
      ),
    );
  }

  Widget _buildPagination({required int currentPage}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: controller.previousPage,
        ),
        const SizedBox(width: 4),
        ...List.generate(RawgGamesController.totalPages, (index) {
          final int page = index + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildPageButton(page: page, currentPage: currentPage),
          );
        }),
        const SizedBox(width: 4),
        _buildArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < RawgGamesController.totalPages,
          onTap: controller.nextPage,
        ),
      ],
    );
  }

  Widget _buildPageButton({required int page, required int currentPage}) {
    final bool selected = currentPage == page;

    return InkWell(
      onTap: () {
        controller.changePage(page);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(
          icon,
          color: enabled
              ? AppColors.textPrimary
              : AppColors.textSecondary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildGameCard(GameModel game) {
    return InkWell(
      onTap: () {
        Get.to(() => GameDetailView(game: game));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: game.backgroundImage.isNotEmpty
                    ? Image.network(
                        game.backgroundImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                game.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    game.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      game.released,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 12),
              child: Text(
                game.platforms.isNotEmpty
                    ? game.platforms.take(2).join(' - ')
                    : 'Sin plataforma',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection({
    required bool loading,
    required GameModel? game,
  }) {
    if (loading) {
      return Container(
        height: 206,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (game == null) {
      return Container(
        height: 206,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Sin juego destacado',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return _buildFeaturedGame(game);
  }

  Widget _buildFeaturedGame(GameModel game) {
    return Container(
      height: 206,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (game.backgroundImage.isNotEmpty)
              Image.network(
                game.backgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.primary);
                },
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.transparent, Color(0xE6101118)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'JUEGO DESTACADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 19,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        game.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          game.genres.isNotEmpty
                              ? game.genres.take(2).join(' - ')
                              : 'Videojuego',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Get.to(() => GameDetailView(game: game));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_esports_rounded,
        size: 48,
        color: AppColors.textSecondary,
      ),
    );
  }
}
