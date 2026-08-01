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
                'Descripción',
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
                  title: 'Géneros',
                  subtitle: 'Categorías del videojuego',
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
                subtitle: 'Disponibilidad y tiendas',
              ),
              const SizedBox(height: 12),
              _PlatformPriceDesign(
                icon: Icons.computer_rounded,
                platform: 'PC',
                available: controller.hasPlatform('PC'),
                stores: _storesForPlatform('PC'),
                price: controller.simulatedPriceForPlatform('PC'),
              ),
              _PlatformPriceDesign(
                icon: Icons.sports_esports_rounded,
                platform: 'PlayStation',
                available: controller.hasPlatform('PlayStation'),
                stores: _storesForPlatform('PlayStation'),
                price: controller.simulatedPriceForPlatform('PlayStation'),
              ),
              _PlatformPriceDesign(
                icon: Icons.gamepad_rounded,
                platform: 'Xbox',
                available: controller.hasPlatform('Xbox'),
                stores: _storesForPlatform('Xbox'),
                price: controller.simulatedPriceForPlatform('Xbox'),
              ),
              _PlatformPriceDesign(
                icon: Icons.videogame_asset_rounded,
                platform: 'Nintendo',
                available: controller.hasPlatform('Nintendo'),
                stores: _storesForPlatform('Nintendo'),
                price: controller.simulatedPriceForPlatform('Nintendo'),
              ),
              if (controller.stores.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildStores(),
              ],
              const SizedBox(height: 26),
              SectionTitle(
                title: 'Calificaciones',
                subtitle: '${controller.ratingsCount} evaluaciones en RAWG',
              ),
              const SizedBox(height: 12),
              _RatingAspectDesign(
                label: 'RAWG',
                value: controller.rating,
                maximum: controller.ratingTop.toDouble(),
              ),
              _RatingAspectDesign(
                label: 'Metacritic',
                value: controller.metacritic.toDouble(),
                maximum: 100,
              ),
              const SizedBox(height: 12),
              _buildRatingSummary(),
              const SizedBox(height: 26),
              SectionTitle(
                title: 'Comentarios',
                subtitle: '${controller.comments.length} comentarios',
              ),
              const SizedBox(height: 12),
              _buildComments(),
              const SizedBox(height: 14),
              _buildCommentForm(),
              if (controller.minimumRequirements.isNotEmpty) ...[
                const SizedBox(height: 26),
                const SectionTitle(
                  title: 'Requisitos de PC',
                  subtitle: 'Requisitos recibidos desde RAWG',
                ),
                const SizedBox(height: 12),
                _buildRequirements(),
              ],
              if (controller.tags.isNotEmpty) ...[
                const SizedBox(height: 26),
                const SectionTitle(
                  title: 'Etiquetas',
                  subtitle: 'Características del juego',
                ),
                const SizedBox(height: 12),
                _buildChips(controller.tags.take(15).toList()),
              ],
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
                errorBuilder: (context, error, stackTrace) =>
                    _buildCoverPlaceholder(),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        children: [
          _InfoItem(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: controller.rating.toStringAsFixed(1),
          ),
          _InfoItem(
            icon: Icons.analytics_outlined,
            label: 'Metacritic',
            value: controller.metacritic > 0
                ? controller.metacritic.toString()
                : '--',
          ),
          _InfoItem(
            icon: Icons.schedule_rounded,
            label: 'Duración',
            value: controller.playtime > 0 ? '${controller.playtime} h' : '--',
          ),
          _InfoItem(
            icon: Icons.calendar_month_rounded,
            label: 'Lanzamiento',
            value: controller.released,
          ),
          _InfoItem(
            icon: Icons.people_alt_outlined,
            label: 'Agregado',
            value: controller.added > 0 ? controller.added.toString() : '--',
          ),
          _InfoItem(
            icon: Icons.warning_amber_rounded,
            label: 'Clasificación',
            value: controller.esrbRating,
          ),
        ],
      ),
    );
  }

  Widget _buildChips(List<String> values) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
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

  String _storesForPlatform(String platform) {
    final List<String> names = controller.stores
        .map((store) => store['name']?.toString() ?? '')
        .where((name) {
          final String lower = name.toLowerCase();
          switch (platform.toLowerCase()) {
            case 'pc':
              return lower.contains('steam') ||
                  lower.contains('epic') ||
                  lower.contains('gog');
            case 'playstation':
              return lower.contains('playstation');
            case 'xbox':
              return lower.contains('xbox') || lower.contains('microsoft');
            case 'nintendo':
              return lower.contains('nintendo');
            default:
              return false;
          }
        })
        .where((name) => name.isNotEmpty)
        .toList();

    return names.isEmpty ? 'Sin tienda registrada' : names.join(' - ');
  }

  Widget _buildStores() {
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
            'Tiendas disponibles',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.stores.map((store) {
            final String name = store['name']?.toString() ?? 'Tienda';
            final String domain = store['domain']?.toString() ?? '';

            final double? price = store['price'] is num
                ? (store['price'] as num).toDouble()
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (domain.isNotEmpty)
                          Text(
                            domain,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    price != null ? '\$${price.toStringAsFixed(2)}' : 'N/A',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
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
              controller.rating.toStringAsFixed(1),
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
                  'Calificación general',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${controller.ratingsCount} calificaciones',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${controller.reviewsCount} reseñas',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Obx(() {
      if (controller.comments.isEmpty) {
        return const DesignPlaceholder(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Los comentarios aparecerán aquí',
          message:
              'Esta sección mostrará las opiniones publicadas por usuarios.',
          compact: true,
        );
      }

      return Column(
        children: controller.comments.map((comment) {
          final String userName =
              comment.userName.isNotEmpty ? comment.userName : 'Usuario';

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
                    _buildMiniRatingTag('Gráficos', comment.graphicsRating),
                    _buildMiniRatingTag('Jugabilidad', comment.gameplayRating),
                    _buildMiniRatingTag('Historia', comment.storyRating),
                    _buildMiniRatingTag(
                        'Innovación', comment.innovationRating),
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
              hintText: 'Escribe tu opinión sobre el juego...',
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
              Obx(() => _buildAspectRatingSelector(
                    'Gráficos',
                    controller.graphicsRating.value,
                    (val) => controller.graphicsRating.value = val,
                  )),
              Obx(() => _buildAspectRatingSelector(
                    'Jugabilidad',
                    controller.gameplayRating.value,
                    (val) => controller.gameplayRating.value = val,
                  )),
              Obx(() => _buildAspectRatingSelector(
                    'Historia',
                    controller.storyRating.value,
                    (val) => controller.storyRating.value = val,
                  )),
              Obx(() => _buildAspectRatingSelector(
                    'Innovación',
                    controller.innovationRating.value,
                    (val) => controller.innovationRating.value = val,
                  )),
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
            children: List.generate(5, (index) {
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
                onPressed: () => onRatingChanged(starValue),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    final String minimum =
        controller.minimumRequirements['minimum'] ?? 'Sin requisitos mínimos.';

    final String recommended =
        controller.minimumRequirements['recommended'] ??
            'Sin requisitos recomendados.';

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
            'Mínimos',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            minimum,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Recomendados',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            recommended,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
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
      width: 130,
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
    required this.stores,
    required this.price,
  });

  final IconData icon;
  final String platform;
  final bool available;
  final String stores;
  final double? price;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  available ? stores : 'No disponible',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: available
                        ? AppColors.textSecondary
                        : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                available && price != null
                    ? '\$${price!.toStringAsFixed(2)}'
                    : 'N/A',
                style: TextStyle(
                  color: available
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Precio',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingAspectDesign extends StatelessWidget {
  const _RatingAspectDesign({
    required this.label,
    required this.value,
    required this.maximum,
  });

  final String label;
  final double value;
  final double maximum;

  @override
  Widget build(BuildContext context) {
    final double progress = maximum > 0 ? (value / maximum).clamp(0, 1) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceLight,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}