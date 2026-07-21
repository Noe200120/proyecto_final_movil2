import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perfil del usuario',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'La informacion real se cargara al conectar el inicio de sesion.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferencias',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _ProfileOption(
              icon: Icons.sports_esports_outlined,
              title: 'Plataformas favoritas',
              subtitle: 'PC, PlayStation, Xbox o Nintendo',
            ),
            const _ProfileOption(
              icon: Icons.notifications_none_rounded,
              title: 'Notificaciones',
              subtitle: 'Ofertas y nuevos comentarios',
            ),
            const _ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Configuración de cuenta',
              subtitle: 'Datos personales y seguridad',
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Get.offAll(() => const LoginView()),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
            width: 46,
            height: 46,
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
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
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
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
