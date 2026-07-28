import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/design_placeholder.dart';
import '../../utils/app_colors.dart';
import '../controllers/favorites_controller.dart';
import '../models/modelo.dart';
import 'game_detail_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  FavoritesController get controller {
    return Get.find<FavoritesController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis favoritos'),
        actions: [
          Obx(() {
            if (controller.favoriteGames.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: () {
                _showClearDialog(context);
              },
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Eliminar todos',
            );
          }),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final List<GameModel> favorites = controller.favoriteGames.toList();

          if (favorites.isEmpty) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Center(
                child: DesignPlaceholder(
                  icon: Icons.favorite_border_rounded,
                  title: 'Aun no hay favoritos',
                  message:
                      'Los videojuegos que marques como favoritos apareceran aqui.',
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            itemCount: favorites.length,
            itemBuilder: (BuildContext context, int index) {
              final GameModel game = favorites[index];

              return _buildFavoriteCard(game);
            },
          );
        }),
      ),
    );
  }

  Widget _buildFavoriteCard(GameModel game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
          Get.to(() => GameDetailView(game: game));
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
                  height: 160,
                  child: game.backgroundImage.isNotEmpty
                      ? Image.network(
                          game.backgroundImage,
                          width: 105,
                          height: 160,
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
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            game.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game.released.isNotEmpty ? game.released : 'Sin fecha',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 190),
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
                      Row(
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Ver detalles',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                controller.removeFavorite(game.id);
                              },
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                              tooltip: 'Eliminar de favoritos',
                            ),
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
      height: 160,
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_esports_rounded,
        color: AppColors.primary,
        size: 42,
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar favoritos'),
          content: const Text(
            'Deseas eliminar todos los videojuegos favoritos?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                controller.clearFavorites();

                Navigator.pop(dialogContext);
              },
              child: const Text('Eliminar todos'),
            ),
          ],
        );
      },
    );
  }
}
