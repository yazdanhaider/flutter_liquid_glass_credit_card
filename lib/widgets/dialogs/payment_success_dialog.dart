import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final VoidCallback onClose;

  const PaymentSuccessDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.textLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuccessIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildMessage(),
            const SizedBox(height: 24),
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 40),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Payment Successful!',
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      'Your payment has been processed successfully.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textLightSecondary,
      ),
    );
  }

  Widget _buildDoneButton() {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Text(
            'Done',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, VoidCallback onClose) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PaymentSuccessDialog(onClose: onClose);
      },
    );
  }
}
