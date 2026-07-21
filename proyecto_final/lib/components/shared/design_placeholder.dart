import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class DesignPlaceholder extends StatelessWidget {
  const DesignPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 48 : 62,
            height: compact ? 48 : 62,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: compact ? 25 : 31,
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: compact ? 16 : 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
