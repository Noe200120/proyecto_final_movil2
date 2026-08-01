import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/login_view.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userName = ''.obs;
  var userEmail = ''.obs;
  var favoritesCount = 0.obs;
  var reviewsCount = 0.obs;
  var photoUrl = ''.obs;

  // Preferencias de Plataformas
  var selectedPlatforms = <String>[].obs;
  final availablePlatforms = ['pc', 'playstation', 'xbox', 'nintendo'];

  var isLoading = true.obs;
  var isLoadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  /// Carga los datos del perfil desde Auth y Firestore
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        userEmail.value = currentUser.email ?? '';

        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          userName.value = data['name'] ?? currentUser.displayName ?? 'Usuario';
          photoUrl.value = data['photoUrl'] ?? '';

          if (data['favorite_platforms'] != null) {
            selectedPlatforms.assignAll(List<String>.from(data['favorite_platforms']));
          }
        } else {
          userName.value = currentUser.displayName ?? 'Usuario';
        }

        await _loadCounts(currentUser.uid);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la información del perfil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga los contadores de Favoritos y Reseñas
  Future<void> _loadCounts(String userId) async {
    try {
      // Favoritos
      final favsSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      favoritesCount.value = favsSnap.docs.length;

      // Comentarios / Reseñas del usuario
      final reviewsSnap = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .get();
      reviewsCount.value = reviewsSnap.docs.length;
    } catch (_) {
      favoritesCount.value = 0;
      reviewsCount.value = 0;
    }
  }

  /// Selecciona una foto de la galería, la comprime y la guarda en Base64 en Firestore
  Future<void> pickAndUploadImage() async {
    if (isLoadingImage.value) return;

    try {
      isLoadingImage.value = true;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 300,
        maxHeight: 300,
      );

      if (image == null) {
        isLoadingImage.value = false;
        return;
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        isLoadingImage.value = false;
        return;
      }

      final bytes = await image.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      await _firestore.collection('users').doc(currentUser.uid).set({
        'photoUrl': base64Image,
      }, SetOptions(merge: true));

      photoUrl.value = base64Image;

      Get.snackbar(
        'Éxito',
        'Foto de perfil actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la foto de perfil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingImage.value = false;
    }
  }

  /// Selector de plataformas favoritas
  void showPlatformsDialog() {
    final Map<String, IconData> availablePlatformsMap = {
      'pc': Icons.computer_rounded,
      'playstation': Icons.sports_esports_rounded,
      'xbox': Icons.gamepad_rounded,
      'nintendo': Icons.videogame_asset_rounded,
    };

    final List<String> tempSelected = List<String>.from(selectedPlatforms);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF181824),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador superior 
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                // Título y Subtítulo
                const Text(
                  'Plataformas Favoritas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecciona las plataformas donde sueles jugar',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Tarjetas de Plataformas
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: availablePlatformsMap.length,
                  itemBuilder: (context, index) {
                    final platformKey = availablePlatformsMap.keys.elementAt(index);
                    final icon = availablePlatformsMap.values.elementAt(index);
                    final isSelected = tempSelected.contains(platformKey);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setStateModal(() {
                            if (isSelected) {
                              tempSelected.remove(platformKey);
                            } else {
                              tempSelected.add(platformKey);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7C4DFF).withOpacity(0.18)
                                : const Color(0xFF222232),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7C4DFF)
                                  : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                color: isSelected
                                    ? const Color(0xFF7C4DFF)
                                    : Colors.grey[400],
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  platformKey.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[300],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7C4DFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey[400], fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            selectedPlatforms.assignAll(tempSelected);
                            Get.back();

                            final currentUser = _auth.currentUser;
                            if (currentUser != null) {
                              await _firestore
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .set({
                                'favorite_platforms': selectedPlatforms.toList(),
                              }, SetOptions(merge: true));
                            }

                            Get.snackbar(
                              'Éxito',
                              'Plataformas actualizadas',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  /// Cambio de nombre y Contraseña
  void showAccountConfigDialog() {
    final nameController = TextEditingController(text: userName.value);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // ocultar/mostrar contraseña
    final hideCurrentPass = true.obs;
    final hideNewPass = true.obs;
    final hideConfirmPass = true.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF181824),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Título e Icono
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.manage_accounts_rounded,
                        color: Color(0xFF7C4DFF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuración de Cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Actualiza tu información personal',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Seccion 1: Nombre de Usuario
                const Text(
                  'DATOS GENERALES',
                  style: TextStyle(
                    color: Color(0xFF7C4DFF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.grey, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF222232),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Seccion 2: Seguridad (Contraseñas)
                const Text(
                  'CAMBIAR CONTRASEÑA',
                  style: TextStyle(
                    color: Color(0xFF7C4DFF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),

                // Contraseña actual
                Obx(() => TextField(
                  controller: currentPasswordController,
                  obscureText: hideCurrentPass.value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideCurrentPass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => hideCurrentPass.toggle(),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222232),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5),
                    ),
                  ),
                )),
                const SizedBox(height: 12),

                // Nueva Contraseña
                Obx(() => TextField(
                  controller: newPasswordController,
                  obscureText: hideNewPass.value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.key_rounded, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideNewPass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => hideNewPass.toggle(),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222232),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5),
                    ),
                  ),
                )),
                const SizedBox(height: 12),

                // Confirmar Nueva Contraseña
                Obx(() => TextField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPass.value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirmPass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => hideConfirmPass.toggle(),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222232),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5),
                    ),
                  ),
                )),
                const SizedBox(height: 28),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            final currentPass = currentPasswordController.text.trim();
                            final newPass = newPasswordController.text.trim();
                            final confirmPass = confirmPasswordController.text.trim();

                            final currentUser = _auth.currentUser;
                            if (currentUser == null) return;

                            try {
                              // Actualizar Nombre de Usuario
                              if (newName.isNotEmpty && newName != userName.value) {
                                await currentUser.updateDisplayName(newName);
                                await _firestore.collection('users').doc(currentUser.uid).set({
                                  'name': newName,
                                }, SetOptions(merge: true));
                                userName.value = newName;
                              }

                              // Procesar Cambio de Contraseña
                              if (currentPass.isNotEmpty || newPass.isNotEmpty || confirmPass.isNotEmpty) {
                                if (newPass != confirmPass) {
                                  Get.snackbar(
                                    'Error',
                                    'Las nuevas contraseñas no coinciden',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                if (newPass.length < 6) {
                                  Get.snackbar(
                                    'Error',
                                    'La nueva contraseña debe tener al menos 6 caracteres',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                // Reautenticar al usuario
                                AuthCredential credential = EmailAuthProvider.credential(
                                  email: currentUser.email!,
                                  password: currentPass,
                                );

                                await currentUser.reauthenticateWithCredential(credential);
                                await currentUser.updatePassword(newPass);
                              }

                              Get.back();
                              Get.snackbar(
                                'Éxito',
                                'Perfil actualizado correctamente',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Error al actualizar: Contraseña actual incorrecta o credencial inválida',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cierra la sesión
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const LoginView());
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}