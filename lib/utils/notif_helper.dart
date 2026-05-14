import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

void showCenterNotification(BuildContext context, String message, {bool isError = false}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2),
    barrierDismissible: false,
    builder: (dialogContext) {
      // Auto dismiss
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (Navigator.canPop(dialogContext)) {
          Navigator.pop(dialogContext);
        }
      });

      return Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9F5),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (isError ? const Color(0xFFBA1A1A) : const Color(0xFF775A19)).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: isError ? const Color(0xFFBA1A1A) : const Color(0xFF775A19),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1B1C1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
