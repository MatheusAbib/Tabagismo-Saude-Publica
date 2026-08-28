import 'dart:async';

import 'package:flutter/material.dart';

class ToastService {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;
  static double _progress = 1.0;
  static bool _isHovered = false;

 static void showToast(BuildContext context, String message, {Color backgroundColor = const Color(0xFFC65D47), IconData icon = Icons.error_outline}) {
  _hideToast();

  final isSuccess = backgroundColor == const Color(0xFF2E8B6A);
  final isWarning = backgroundColor == const Color(0xFFD97706);
  final isError = backgroundColor == const Color(0xFFC65D47);
  
  Color borderColor = backgroundColor;
  Color iconColor = Colors.white;
  
  if (isSuccess) {
    icon = Icons.check_circle_outline;
    iconColor = const Color(0xFF2E8B6A);
    backgroundColor = Colors.white;
    borderColor = const Color(0xFF2E8B6A);
  } else if (isWarning) {
    icon = Icons.warning_amber_outlined;
    iconColor = const Color(0xFFD97706);
    backgroundColor = Colors.white;
    borderColor = const Color(0xFFD97706);
  } else if (isError) {
    icon = Icons.error_outline;
    iconColor = const Color(0xFFC65D47);
    backgroundColor = Colors.white;
    borderColor = const Color(0xFFC65D47);
  }

  _progress = 1.0;
  _isHovered = false;

  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;
  final isSmallMobile = screenWidth < 400;

  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + (isSmallMobile ? 10 : 20),
      left: isMobile ? 10 : null,
      right: isMobile ? 10 : 20,
      child: Material(
        color: Colors.transparent,
        child: MouseRegion(
          onEnter: (_) {
            _isHovered = true;
            _updateOverlay();
          },
          onExit: (_) {
            _isHovered = false;
            _updateOverlay();
            _startProgressTimer(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Container(
              width: isSmallMobile ? double.infinity : (isMobile ? 340 : 380),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: isSmallMobile ? 16 : 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSuccess ? 'Sucesso' : (isWarning ? 'Aviso' : 'Erro'),
                                style: TextStyle(
                                  color: borderColor,
                                  fontSize: isSmallMobile ? 11 : 13,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message,
                                style: TextStyle(
                                  color: const Color(0xFF1E293B),
                                  fontSize: isSmallMobile ? 11 : 13,
                                  fontFamily: 'Inter',
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _hideToast,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade400,
                              size: isSmallMobile ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: AlwaysStoppedAnimation(_progress),
                    builder: (context, child) {
                      final barWidth = isSmallMobile 
                          ? MediaQuery.of(context).size.width - 20
                          : (isMobile ? 340 : 380);
                      return Container(
                        height: 3,
                        width: barWidth * _progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              borderColor,
                              borderColor.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  final overlay = Overlay.of(context);
  overlay.insert(_overlayEntry!);

  _startProgressTimer(context);
}
  static void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  static void _startProgressTimer(BuildContext context) {
    _timer?.cancel();
    const duration = Duration(seconds: 5);
    const interval = Duration(milliseconds: 30);
    final steps = duration.inMilliseconds ~/ interval.inMilliseconds;
    int currentStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      if (_isHovered) {
        return;
      }
      currentStep++;
      _progress = 1.0 - (currentStep / steps);
      _updateOverlay();

      if (_progress <= 0) {
        _hideToast();
      }
    });
  }

  static void _hideToast() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _progress = 1.0;
  }

  static void showSuccess(BuildContext context, String message) {
    showToast(context, message, backgroundColor: const Color(0xFF2E8B6A));
  }

  static void showError(BuildContext context, String message) {
    showToast(context, message, backgroundColor: const Color(0xFFC65D47));
  }

  static void showWarning(BuildContext context, String message) {
    showToast(context, message, backgroundColor: const Color(0xFFD97706));
  }
}