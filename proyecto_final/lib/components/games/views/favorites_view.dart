import 'package:flutter/material.dart';

import '../../shared/design_placeholder.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis favoritos'),
      ),
      body: const SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Center(
            child: DesignPlaceholder(
              icon: Icons.favorite_border_rounded,
              title: 'Aún no hay favoritos',
              message:
                  'Los videojuegos marcados por el usuario se mostraran en esta seccion cuando se conecte el almacenamiento.',
            ),
          ),
        ),
      ),
    );
  }
}
