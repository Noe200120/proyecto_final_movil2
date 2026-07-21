import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../shared/design_placeholder.dart';

class GameDetailView extends StatelessWidget {
  const GameDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del videojuego'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded),
            tooltip: 'Favorito',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _buildCoverPlaceholder(),
          const SizedBox(height: 22),
          const Text(
            'Nombre del videojuego',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Genero • Desarrollador • Año',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Descripcion',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'La descripcion recibida desde la API se mostrara en este espacio. No se ha agregado informacion simulada.',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          const SectionTitle(
            title: 'Precios por plataforma',
            subtitle: 'Diseño de comparacion',
          ),
          const SizedBox(height: 12),
          const _PlatformPriceDesign(
            icon: Icons.computer_rounded,
            platform: 'PC',
          ),
          const _PlatformPriceDesign(
            icon: Icons.sports_esports_rounded,
            platform: 'PlayStation',
          ),
          const _PlatformPriceDesign(
            icon: Icons.gamepad_rounded,
            platform: 'Xbox',
          ),
          const _PlatformPriceDesign(
            icon: Icons.videogame_asset_rounded,
            platform: 'Nintendo',
          ),
          const SizedBox(height: 26),
          const SectionTitle(
            title: 'Calificaciones',
            subtitle: 'Sin evaluaciones',
          ),
          const SizedBox(height: 12),
          const _RatingAspectDesign(label: 'Graficos'),
          const _RatingAspectDesign(label: 'Jugabilidad'),
          const _RatingAspectDesign(label: 'Historia'),
          const _RatingAspectDesign(label: 'Innovacion'),
          const SizedBox(height: 16),
          Container(
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
                  'Evaluacion del usuario',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Los controles de calificacion se conectaran posteriormente con el almacenamiento de usuarios.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(
                    5,
                    (_) => const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.star_border_rounded,
                        color: AppColors.warning,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: null,
                    child: const Text('Guardar calificacion'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionTitle(
            title: 'Comentarios',
            subtitle: 'Sin comentarios',
          ),
          const SizedBox(height: 12),
          const DesignPlaceholder(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Los comentarios apareceran aqui',
            message:
                'Esta seccion mostrara las opiniones publicadas por usuarios cuando se conecte la base de datos.',
            compact: true,
          ),
          const SizedBox(height: 14),
          Container(
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
                const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu opinion sobre el juego...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Publicar comentario'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceLight,
              Color(0xFF17132C),
            ],
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.primary,
              size: 62,
            ),
            SizedBox(height: 11),
            Text(
              'Imagen recibida desde la API',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformPriceDesign extends StatelessWidget {
  const _PlatformPriceDesign({
    required this.icon,
    required this.platform,
  });

  final IconData icon;
  final String platform;

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
                const Text(
                  'Tienda y disponibilidad',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '--',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Precio',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingAspectDesign extends StatelessWidget {
  const _RatingAspectDesign({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
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
              child: const LinearProgressIndicator(
                value: 0,
                minHeight: 9,
                backgroundColor: AppColors.surfaceLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '--',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
