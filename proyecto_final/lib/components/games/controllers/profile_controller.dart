import 'dart:async';
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

  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString photoUrl = ''.obs;

  final RxInt favoritesCount = 0.obs;
  final RxInt reviewsCount = 0.obs;

  final RxList<String> selectedPlatforms = <String>[].obs;

  final List<String> availablePlatforms = [
    'pc',
    'playstation',
    'xbox',
    'nintendo',
  ];

  final RxBool isLoading = true.obs;
  final RxBool isLoadingImage = false.obs;

  StreamSubscription<User?>? _authSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _favoritesSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reviewsSubscription;

  @override
  void onInit() {
    super.onInit();

    // Escucha cuando el usuario vuelve a iniciar sesión para recargar sus datos y contadores
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadUserProfile();
      }
    });

    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        return;
      }

      userEmail.value = currentUser.email ?? '';

      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> data = userDoc.data()!;

        userName.value = data['name'] ?? currentUser.displayName ?? 'Usuario';

        photoUrl.value = data['photoUrl'] ?? '';

        if (data['favorite_platforms'] != null) {
          selectedPlatforms.assignAll(
            List<String>.from(data['favorite_platforms']),
          );
        }
      } else {
        userName.value = currentUser.displayName ?? 'Usuario';

        photoUrl.value = '';

        selectedPlatforms.clear();
      }

      _listenCounts(currentUser.uid);
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

  void _listenCounts(String userId) {
    _favoritesSubscription?.cancel();
    _reviewsSubscription?.cancel();

    _favoritesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            favoritesCount.value = snapshot.docs.length;
          },
          onError: (Object error) {
            favoritesCount.value = 0;
          },
        );

    _reviewsSubscription = _firestore
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            reviewsCount.value = snapshot.docs.length;
          },
          onError: (Object error) {
            reviewsCount.value = 0;
          },
        );
  }

  Future<void> pickAndUploadImage() async {
    if (isLoadingImage.value) {
      return;
    }

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
        return;
      }

      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        return;
      }

      final List<int> bytes = await image.readAsBytes();

      final String base64Image =
          'data:image/jpeg;base64,${base64Encode(bytes)}';

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
        builder: (BuildContext context, StateSetter setStateModal) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF181824),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

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
                  itemBuilder: (BuildContext context, int index) {
                    final String platformKey = availablePlatformsMap.keys
                        .elementAt(index);

                    final IconData icon = availablePlatformsMap.values
                        .elementAt(index);

                    final bool isSelected = tempSelected.contains(platformKey);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setStateModal(() {
                            if (tempSelected.contains(platformKey)) {
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
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
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

                            final User? currentUser = _auth.currentUser;

                            if (currentUser != null) {
                              await _firestore
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .set({
                                    'favorite_platforms': selectedPlatforms
                                        .toList(),
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

  void showAccountConfigDialog() {
    final TextEditingController nameController = TextEditingController(
      text: userName.value,
    );

    final TextEditingController currentPasswordController =
        TextEditingController();

    final TextEditingController newPasswordController = TextEditingController();

    final TextEditingController confirmPasswordController =
        TextEditingController();

    final RxBool hideCurrentPass = true.obs;

    final RxBool hideNewPass = true.obs;

    final RxBool hideConfirmPass = true.obs;

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
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222232),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C4DFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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

                Obx(
                  () => TextField(
                    controller: currentPasswordController,
                    obscureText: hideCurrentPass.value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideCurrentPass.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => hideCurrentPass.toggle(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Obx(
                  () => TextField(
                    controller: newPasswordController,
                    obscureText: hideNewPass.value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideNewPass.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => hideNewPass.toggle(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Obx(
                  () => TextField(
                    controller: confirmPasswordController,
                    obscureText: hideConfirmPass.value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirmar Nueva Contraseña',
                      prefixIcon: const Icon(
                        Icons.check_circle_outline_rounded,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideConfirmPass.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => hideConfirmPass.toggle(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancelar'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final String newName = nameController.text.trim();

                          final String currentPass = currentPasswordController
                              .text
                              .trim();

                          final String newPass = newPasswordController.text
                              .trim();

                          final String confirmPass = confirmPasswordController
                              .text
                              .trim();

                          final User? currentUser = _auth.currentUser;

                          if (currentUser == null) {
                            return;
                          }

                          try {
                            if (newName.isNotEmpty &&
                                newName != userName.value) {
                              await currentUser.updateDisplayName(newName);

                              await _firestore
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .set({
                                    'name': newName,
                                  }, SetOptions(merge: true));

                              userName.value = newName;
                            }

                            final bool wantsPasswordChange =
                                currentPass.isNotEmpty ||
                                newPass.isNotEmpty ||
                                confirmPass.isNotEmpty;

                            if (wantsPasswordChange) {
                              if (currentPass.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Ingresa tu contraseña actual',
                                );
                                return;
                              }

                              if (newPass != confirmPass) {
                                Get.snackbar(
                                  'Error',
                                  'Las nuevas contraseñas no coinciden',
                                );
                                return;
                              }

                              if (newPass.length < 6) {
                                Get.snackbar(
                                  'Error',
                                  'La nueva contraseña debe tener al menos 6 caracteres',
                                );
                                return;
                              }

                              if (currentUser.email == null) {
                                Get.snackbar(
                                  'Error',
                                  'Esta cuenta no tiene correo disponible',
                                );
                                return;
                              }

                              final AuthCredential credential =
                                  EmailAuthProvider.credential(
                                    email: currentUser.email!,
                                    password: currentPass,
                                  );

                              await currentUser.reauthenticateWithCredential(
                                credential,
                              );

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
                        child: const Text('Guardar'),
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

  Future<void> logout() async {
    try {
      await _favoritesSubscription?.cancel();

      await _reviewsSubscription?.cancel();

      _favoritesSubscription = null;

      _reviewsSubscription = null;

      favoritesCount.value = 0;
      reviewsCount.value = 0;

      await _auth.signOut();

      Get.offAll(() => const LoginView());
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();

    _favoritesSubscription?.cancel();

    _reviewsSubscription?.cancel();

    super.onClose();
  }
}