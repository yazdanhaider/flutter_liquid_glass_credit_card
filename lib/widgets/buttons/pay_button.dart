import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class PayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const PayButton({super.key, this.onPressed, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient:
              isEnabled
                  ? AppColors.primaryGradient
                  : LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.3),
                    ],
                  ),
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isEnabled
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            'Pay Now',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color:
                  isEnabled
                      ? AppColors.textLight
                      : AppColors.textLight.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
