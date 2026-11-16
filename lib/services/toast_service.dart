
import 'dart:async';

import 'package:flutter/material.dart';

class ToastService {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;
  static GlobalKey<_ToastContentState>? _toastKey;

  static const Color _success = Color(0xFF2E8B6A);
  static const Color _error = Color(0xFFC65D47);
  static const Color _warning = Color(0xFFD97706);
  static const Color _info = Color(0xFF426E8C);

  static void showToast(
    BuildContext context,
    String message, {
    Color backgroundColor = _error,
    IconData icon = Icons.error_outline,
  }) {
    _removeToast();

    final isSuccess = backgroundColor == _success;
    final isWarning = backgroundColor == _warning;
    final isError = backgroundColor == _error;

    final Color accentColor;
    final String title;
    final IconData toastIcon;
    final Duration duration;

    if (isSuccess) {
      accentColor = _success;
      title = 'Sucesso';
      toastIcon = Icons.check_circle_outline_rounded;
      duration = const Duration(seconds: 3);
    } else if (isWarning) {
      accentColor = _warning;
      title = 'Atenção';
      toastIcon = Icons.warning_amber_rounded;
      duration = const Duration(seconds: 3);
    } else if (isError) {
      accentColor = _error;
      title = 'Erro';
      toastIcon = Icons.error_outline_rounded;
      duration = const Duration(seconds: 4);
    } else {
      accentColor = backgroundColor;
      title = 'Informação';
      toastIcon = icon;
      duration = const Duration(seconds: 3);
    }

    final key = GlobalKey<_ToastContentState>();
    _toastKey = key;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;
        final isMobile = screenWidth < 768;
        final horizontalPadding = isMobile ? 12.0 : 24.0;

        return Positioned(
          top: MediaQuery.paddingOf(overlayContext).top +
              (isMobile ? 12 : 20),
          left: isMobile ? horizontalPadding : null,
          right: horizontalPadding,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: isMobile ? null : 360,
              child: _ToastContent(
                key: key,
                title: title,
                message: message,
                color: accentColor,
                icon: toastIcon,
                onClose: _hideToast,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(duration, _hideToast);
  }
static void _hideToast() {
  _timer?.cancel();
  _timer = null;

  final key = _toastKey;

  if (key?.currentState != null) {
    key!.currentState!._dismiss();
  } else {
    _removeToast();
  }
}
  static void _removeToast() {
    _timer?.cancel();
    _timer = null;

    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _toastKey = null;
  }

  static void showSuccess(BuildContext context, String message) {
    showToast(
      context,
      message,
      backgroundColor: _success,
    );
  }

  static void showError(BuildContext context, String message) {
    showToast(
      context,
      message,
      backgroundColor: _error,
    );
  }

  static void showWarning(BuildContext context, String message) {
    showToast(
      context,
      message,
      backgroundColor: _warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    showToast(
      context,
      message,
      backgroundColor: _info,
      icon: Icons.info_outline_rounded,
    );
  }
}

class _ToastContent extends StatefulWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;

  const _ToastContent({
    super.key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.onClose,
  });

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.12, -0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

Future<void> _dismiss() async {
  if (_isDismissing) return;

  _isDismissing = true;

  await _controller.reverse();

  if (mounted) {
    ToastService._removeToast();
  }
}
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE6E5DF),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: widget.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _dismiss,
                  borderRadius: BorderRadius.circular(7),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: Color(0xFF667078),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
