import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../shared/design_placeholder.dart';
import '../../shared/platform_chip.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
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
      appBar: AppBar(
        title: const Text('Buscar videojuegos'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Limpiar'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          children: [
            const TextField(
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Nombre del videojuego...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Filtrar por plataforma',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                platforms.length,
                (index) => PlatformChip(
                  label: platforms[index],
                  selected: selectedPlatform == index,
                  onTap: () => setState(() => selectedPlatform = index),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ordenar resultados',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Precio, calificacion o descuento',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: 'Resultados',
              subtitle: 'Sin busqueda conectada',
            ),
            const SizedBox(height: 14),
            const DesignPlaceholder(
              icon: Icons.search_off_rounded,
              title: 'No hay resultados todavia',
              message:
                  'Los resultados apareceran aquí cuando el buscador se conecte con la fuente de videojuegos.',
            ),
          ],
        ),
      ),
    );
  }
}
