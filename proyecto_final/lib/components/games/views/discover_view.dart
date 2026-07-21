import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../shared/design_placeholder.dart';
import '../../shared/platform_chip.dart';
import 'game_detail_view.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  int selectedPlatform = 0;

  static const platforms = [
    'Todos',
    'PC',
    'PlayStation',
    'Xbox',
    'Nintendo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                child: _buildFeaturedDesign(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 76,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: platforms.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return PlatformChip(
                      label: platforms[index],
                      selected: selectedPlatform == index,
                      onTap: () {
                        setState(() => selectedPlatform = index);
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: SectionTitle(
                  title: 'Catalogo de videojuegos',
                  subtitle: 'Sin datos conectados',
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 26),
              sliver: SliverToBoxAdapter(
                child: DesignPlaceholder(
                  icon: Icons.videogame_asset_off_outlined,
                  title: 'El catalogo aparecera aqui',
                  message:
                      'Esta pantalla contiene unicamente el diseño. Los juegos se mostraran cuando se conecte la API correspondiente.',
                ),
              ),
            ),
          ],
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
        const TextField(
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o género...',
            prefixIcon: Icon(Icons.search_rounded),
            suffixIcon: Icon(Icons.tune_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedDesign() {
    return Container(
      height: 206,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF211942),
          ],
        ),
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
          children: [
            Positioned(
              right: -22,
              top: -18,
              child: Icon(
                Icons.sports_esports_rounded,
                size: 190,
                color: Colors.white.withOpacity(0.09),
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
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ESPACIO DESTACADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Juego destacado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aqui se mostrara la informacion recibida desde la API.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 13),
                  InkWell(
                    onTap: () => Get.to(() => const GameDetailView()),
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver diseño del detalle',
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
}
