
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message = 'Carregando...',
  });

  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accent = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFE1EDF6);
  static const Color _textPrimary = Color(0xFF30383E);
  static const Color _textSecondary = Color(0xFF758087);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: _background.withValues(alpha: 0.88),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _border,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _accentSoft,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                strokeCap: StrokeCap.round,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  _accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'DESFUMO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: _accent,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            message ?? 'Carregando...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Aguarde um momento',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: _textSecondary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
