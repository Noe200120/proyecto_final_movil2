import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/design_placeholder.dart';
import '../../utils/app_colors.dart';
import '../controllers/game_detail_controller.dart';
import '../models/modelo.dart';

class GameDetailView extends StatelessWidget {
  final GameModel game;
  final GameDetailController controller;

  GameDetailView({super.key, required this.game})
    : controller = Get.put(
        GameDetailController(game: game),
        tag: game.id.toString(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del videojuego'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.toggleFavorite,
              icon: Icon(
                controller.isFavorite.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: controller.isFavorite.value
                    ? Colors.red
                    : AppColors.textPrimary,
              ),
              tooltip: 'Favorito',
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DesignPlaceholder(
                    icon: Icons.error_outline_rounded,
                    title: 'Error al cargar el detalle',
                    message: controller.errorMessage.value,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _buildCover(),

              const SizedBox(height: 22),

              Text(
                controller.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                controller.informationLine,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              _buildGeneralInformation(),

              const SizedBox(height: 24),

              const Text(
                'Descripcion',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                controller.description,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),

              if (controller.genres.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Generos',
                  subtitle: 'Categorias del videojuego',
                ),
                const SizedBox(height: 12),
                _buildChips(controller.genres),
              ],

              if (controller.platforms.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Plataformas',
                  subtitle: 'Disponibilidad del videojuego',
                ),
                const SizedBox(height: 12),
                _buildChips(controller.platforms),
              ],

              if (controller.developers.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Desarrolladores',
                  subtitle: 'Creadores del videojuego',
                ),
                const SizedBox(height: 12),
                _buildChips(controller.developers),
              ],

              if (controller.publishers.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Distribuidores',
                  subtitle: 'Empresas responsables',
                ),
                const SizedBox(height: 12),
                _buildChips(controller.publishers),
              ],

              const SizedBox(height: 26),

              const SectionTitle(
                title: 'Precios por plataforma',
                subtitle: 'Ofertas disponibles',
              ),

              const SizedBox(height: 12),

              _PlatformPriceDesign(
                icon: Icons.computer_rounded,
                platform: 'PC',
                available: controller.hasPlatform('PC'),
                price: controller.simulatedPriceForPlatform('PC'),
              ),

              _PlatformPriceDesign(
                icon: Icons.sports_esports_rounded,
                platform: 'PlayStation',
                available: controller.hasPlatform('PlayStation'),
                price: controller.simulatedPriceForPlatform('PlayStation'),
              ),

              _PlatformPriceDesign(
                icon: Icons.gamepad_rounded,
                platform: 'Xbox',
                available: controller.hasPlatform('Xbox'),
                price: controller.simulatedPriceForPlatform('Xbox'),
              ),

              _PlatformPriceDesign(
                icon: Icons.videogame_asset_rounded,
                platform: 'Nintendo',
                available: controller.hasPlatform('Nintendo'),
                price: controller.simulatedPriceForPlatform('Nintendo'),
              ),

              const SizedBox(height: 26),

              SectionTitle(
                title: 'Opiniones de la comunidad',
                subtitle: '${controller.comments.length} comentarios',
              ),

              const SizedBox(height: 12),

              _buildCommunitySummary(),

              const SizedBox(height: 16),

              _buildComments(),

              const SizedBox(height: 14),

              _buildCommentForm(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCover() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: controller.backgroundImage.isNotEmpty
            ? Image.network(
                controller.backgroundImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCoverPlaceholder();
                },
              )
            : _buildCoverPlaceholder(),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceLight, Color(0xFF17132C)],
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: AppColors.primary, size: 62),
          SizedBox(height: 11),
          Text(
            'Sin imagen disponible',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInformation() {
    final List<Widget> items = [];

    if (controller.platforms.isNotEmpty) {
      items.add(
        _InfoItem(
          icon: Icons.sports_esports_rounded,
          label: 'Plataforma',
          value: controller.platforms.first,
        ),
      );
    }

    if (controller.released.isNotEmpty && controller.released != 'Sin fecha') {
      items.add(
        _InfoItem(
          icon: Icons.calendar_month_rounded,
          label: 'Lanzamiento',
          value: controller.released,
        ),
      );
    }

    if (controller.esrbRating.isNotEmpty &&
        controller.esrbRating != 'Sin clasificacion') {
      items.add(
        _InfoItem(
          icon: Icons.warning_amber_rounded,
          label: 'Clasificacion',
          value: controller.esrbRating,
        ),
      );
    }

    if (controller.players > 0) {
      items.add(
        _InfoItem(
          icon: Icons.people_alt_outlined,
          label: 'Jugadores',
          value: controller.players.toString(),
        ),
      );
    }

    if (controller.hasCoop) {
      items.add(
        const _InfoItem(
          icon: Icons.groups_rounded,
          label: 'Cooperativo',
          value: 'Disponible',
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Wrap(spacing: 18, runSpacing: 14, children: items),
    );
  }

  Widget _buildChips(List<String> values) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((String value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.13),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommunitySummary() {
    return Obx(() {
      final int total = controller.communityReviewsCount;

      final double overall = controller.averageOverallRating;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                total > 0 ? overall.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calificacion de usuarios',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    total > 0
                        ? '$total evaluaciones realizadas'
                        : 'Aun no hay evaluaciones',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),

                  if (total > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 17,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${overall.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildComments() {
    return Obx(() {
      if (controller.comments.isEmpty) {
        return const DesignPlaceholder(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Los comentarios apareceran aqui',
          message:
              'Esta seccion mostrara las opiniones publicadas por usuarios.',
          compact: true,
        );
      }

      return Column(
        children: controller.comments.map((comment) {
          final String userName = comment.userName.isNotEmpty
              ? comment.userName
              : 'Usuario';

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.surfaceLight,
                      backgroundImage: comment.userPhotoUrl.isNotEmpty
                          ? NetworkImage(comment.userPhotoUrl)
                          : null,
                      child: comment.userPhotoUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  comment.text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildMiniRatingTag('Graficos', comment.graphicsRating),
                    _buildMiniRatingTag('Jugabilidad', comment.gameplayRating),
                    _buildMiniRatingTag('Historia', comment.storyRating),
                    _buildMiniRatingTag('Innovacion', comment.innovationRating),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildMiniRatingTag(String label, double rating) {
    return Text(
      '$label: ${rating.toStringAsFixed(1)} ★',
      style: TextStyle(
        fontSize: 11,
        color: AppColors.textSecondary.withOpacity(0.8),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCommentForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escribir un comentario',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 13),

          TextField(
            controller: controller.commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe tu opinion sobre el juego...',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Califica los aspectos del juego:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          Column(
            children: [
              Obx(
                () => _buildAspectRatingSelector(
                  'Graficos',
                  controller.graphicsRating.value,
                  controller.setGraphicsRating,
                ),
              ),

              Obx(
                () => _buildAspectRatingSelector(
                  'Jugabilidad',
                  controller.gameplayRating.value,
                  controller.setGameplayRating,
                ),
              ),

              Obx(
                () => _buildAspectRatingSelector(
                  'Historia',
                  controller.storyRating.value,
                  controller.setStoryRating,
                ),
              ),

              Obx(
                () => _buildAspectRatingSelector(
                  'Innovacion',
                  controller.innovationRating.value,
                  controller.setInnovationRating,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: controller.publishCommentToFirebase,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Publicar comentario'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectRatingSelector(
    String label,
    double currentValue,
    Function(double) onRatingChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          Row(
            children: List.generate(5, (int index) {
              final double starValue = (index + 1).toDouble();

              final bool isSelected = starValue <= currentValue;

              return IconButton(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
                onPressed: () {
                  onRatingChanged(starValue);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 21),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformPriceDesign extends StatelessWidget {
  const _PlatformPriceDesign({
    required this.icon,
    required this.platform,
    required this.available,
    required this.price,
  });

  final IconData icon;
  final String platform;
  final bool available;
  final double? price;

  @override
  Widget build(BuildContext context) {
    final bool hasPrice = available && price != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: available
              ? AppColors.primary.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: available
                  ? AppColors.primary.withOpacity(0.14)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: available
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.55),
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: TextStyle(
                    color: available
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  available
                      ? hasPrice
                            ? 'Oferta disponible'
                            : 'Sin ofertas registradas'
                      : 'No disponible para este juego',
                  style: TextStyle(
                    color: available
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          if (hasPrice)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${price!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Mejor precio',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.remove_rounded,
                    color: AppColors.textSecondary,
                    size: 15,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Sin oferta',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
