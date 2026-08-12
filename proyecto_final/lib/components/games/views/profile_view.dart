import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  ProfileController get controller {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }

    return Get.put(ProfileController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoCard(context, controller),

              const SizedBox(height: 16),

              _buildStatsCard(controller),

              const SizedBox(height: 24),

              const Text(
                'Preferencias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildMenuOption(
                icon: Icons.gamepad_rounded,
                title: 'Plataformas favoritas',
                subtitle: Obx(
                  () => Text(
                    controller.selectedPlatforms.isEmpty
                        ? 'Seleccionar plataformas'
                        : controller.selectedPlatforms.join(', ').toUpperCase(),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () {
                  controller.showPlatformsDialog();
                },
              ),

              const SizedBox(height: 12),

              _buildMenuOption(
                icon: Icons.settings_rounded,
                title: 'Configuración de cuenta',
                subtitle: const Text(
                  'Datos personales y seguridad',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  controller.showAccountConfigDialog();
                },
              ),

              const SizedBox(height: 28),

              _buildLogoutButton(controller),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    ProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF181824),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Obx(() {
                final String photo = controller.photoUrl.value;

                ImageProvider? imageProvider;

                if (photo.isNotEmpty) {
                  if (photo.startsWith('data:image')) {
                    try {
                      final String base64String = photo.split(',').last;

                      imageProvider = MemoryImage(base64Decode(base64String));
                    } catch (_) {
                      imageProvider = null;
                    }
                  } else {
                    imageProvider = NetworkImage(photo);
                  }
                }

                return CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFF2A2A3D),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          controller.userName.value.isNotEmpty
                              ? controller.userName.value[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                );
              }),

              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    controller.pickAndUploadImage();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF181824),
                        width: 2,
                      ),
                    ),
                    child: Obx(
                      () => controller.isLoadingImage.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.userName.value.isEmpty
                        ? 'Cargando...'
                        : controller.userName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 4),

                Obx(
                  () => Text(
                    controller.userEmail.value,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ProfileController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF181824),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Obx(
                      () => Text(
                        controller.favoritesCount.value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Favoritos',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),

          Container(height: 28, width: 1, color: Colors.white10),

          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.rate_review_rounded,
                      color: Color(0xFF7C4DFF),
                      size: 20,
                    ),

                    const SizedBox(width: 8),

                    Obx(
                      () => Text(
                        controller.reviewsCount.value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Reseñas',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Widget subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF181824),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF7C4DFF), size: 22),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    subtitle,
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          controller.logout();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF2E2E42)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
