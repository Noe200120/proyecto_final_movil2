import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/utils/app_colors.dart';
import 'components/games/views/login_view.dart';

void main() {
  runApp(const ClubGamingApp());
}

class ClubGamingApp extends StatelessWidget {
  const ClubGamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Club Gaming',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.20),
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(MaterialState.selected)
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: states.contains(MaterialState.selected)
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(MaterialState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIconColor: AppColors.textSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: const LoginView(),
    );
  }
}
