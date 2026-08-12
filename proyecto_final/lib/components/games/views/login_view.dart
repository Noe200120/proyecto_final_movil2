import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../utils/app_colors.dart';
import 'home_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Get.offAll(() => const HomeView());
    } on FirebaseAuthException catch (e) {
      String message = 'No se pudo iniciar sesion';

      if (e.code == 'user-not-found') {
        message = 'No existe un usuario con ese correo';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Correo o contrasena incorrectos';
      } else if (e.code == 'invalid-email') {
        message = 'El correo no es valido';
      } else if (e.code == 'user-disabled') {
        message = 'Este usuario fue deshabilitado';
      } else if (e.code == 'too-many-requests') {
        message = 'Demasiados intentos. Intenta mas tarde';
      } else if (e.code == 'network-request-failed') {
        message = 'Error de red. Revisa tu conexion';
      }

      _showError('Error de acceso', message);
    } catch (_) {
      _showError('Error', 'No se pudo completar el inicio de sesion');
    } finally {
      _stopLoading();
    }
  }

  Future<void> _resetPassword() async {
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      _showError(
        'Correo requerido',
        'Ingresa tu correo para recuperar la contrasena',
      );

      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Correo no valido', 'Ingresa un correo electronico valido');

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      Get.snackbar(
        'Correo enviado',
        'Revisa tu correo para restablecer tu contrasena',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'No se pudo enviar el correo';

      if (e.code == 'user-not-found') {
        message = 'No existe un usuario con ese correo';
      } else if (e.code == 'invalid-email') {
        message = 'El correo no es valido';
      } else if (e.code == 'network-request-failed') {
        message = 'Error de red. Revisa tu conexion';
      }

      _showError('Error', message);
    } catch (_) {
      _showError('Error', 'No se pudo enviar el correo de recuperacion');
    } finally {
      _stopLoading();
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      await GoogleSignIn.instance.initialize();

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Get.offAll(() => const HomeView());
    } on FirebaseAuthException catch (e) {
      String message = 'No se pudo iniciar sesion con Google';

      if (e.code == 'account-exists-with-different-credential') {
        message = 'Ya existe una cuenta con ese correo y otro metodo de acceso';
      } else if (e.code == 'invalid-credential') {
        message = 'La credencial de Google no es valida';
      } else if (e.code == 'network-request-failed') {
        message = 'Error de red. Revisa tu conexion';
      }

      _showError('Error con Google', message);
    } catch (_) {
      _showError('Error', 'No se pudo completar el acceso con Google');
    } finally {
      _stopLoading();
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _stopLoading() {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF151024),
              AppColors.background,
              Color(0xFF0A1820),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    _buildLogo(),

                    const SizedBox(height: 22),

                    const Text(
                      'Club Gaming',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Inicia sesion para descubrir videojuegos, guardar favoritos y compartir tus opiniones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildLoginCard(),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No tienes una cuenta?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Get.to(() => const RegisterView());
                                },
                          child: const Text(
                            'Registrate',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
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
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.sports_esports_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Iniciar sesion',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Ingresa tus datos para continuar.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration(
                label: 'Correo electronico',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu correo';
                }

                if (!GetUtils.isEmail(value.trim())) {
                  return 'Ingresa un correo valido';
                }

                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: passwordController,
              obscureText: hidePassword,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration:
                  _inputDecoration(
                    label: 'Contrasena',
                    icon: Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contrasena';
                }

                if (value.length < 6) {
                  return 'La contrasena debe tener al menos 6 caracteres';
                }

                return null;
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading ? null : _resetPassword,
                child: const Text(
                  'Olvidaste tu contrasena?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Iniciar sesion',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.10))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continua con',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.10))),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Continuar con Google',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
  }
}
