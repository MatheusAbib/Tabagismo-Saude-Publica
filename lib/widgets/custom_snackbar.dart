
import 'package:flutter/material.dart';

class CustomSnackBar {
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      title: 'Sucesso',
      icon: Icons.check_circle_outline_rounded,
      accent: const Color(0xFF397C69),
      background: const Color(0xFFF3FAF6),
      iconBackground: const Color(0xFFE1F0E8),
      border: const Color(0xFFBFDFCE),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      title: 'Não foi possível concluir',
      icon: Icons.error_outline_rounded,
      accent: const Color(0xFFC65D47),
      background: const Color(0xFFFEF7F5),
      iconBackground: const Color(0xFFF9EBE7),
      border: const Color(0xFFEBC9C0),
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      title: 'Atenção',
      icon: Icons.warning_amber_rounded,
      accent: const Color(0xFF9B7136),
      background: const Color(0xFFFFFBF3),
      iconBackground: const Color(0xFFF8EED8),
      border: const Color(0xFFEAD9B7),
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      title: 'Informação',
      icon: Icons.info_outline_rounded,
      accent: const Color(0xFF426E8C),
      background: const Color(0xFFF4F9FC),
      iconBackground: const Color(0xFFE1EDF6),
      border: const Color(0xFFCADDEB),
      duration: const Duration(seconds: 3),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required String title,
    required IconData icon,
    required Color accent,
    required Color background,
    required Color iconBackground,
    required Color border,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(16),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Container(
          constraints: const BoxConstraints(
            maxWidth: 440,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: messenger.hideCurrentSnackBar,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: _textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
