/// Primary button widget

import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.color = AppColors.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? [
              color,
              AppColors.seaGreen,
            ]
                : [
              Colors.grey.shade500,
              Colors.grey.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: color.withOpacity(.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}