import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/loader_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/screens/sobre_screen.dart';

class LogoutModal {
  static void show(BuildContext context, {VoidCallback? onLogout}) {
    const Color background = Color(0xFFFFFDF9);
    const Color foreground = Color(0xFF333333);
    const Color secondary = Color(0xFF667078);
    const Color border = Color(0xFFE6E5DF);
    const Color danger = Color(0xFFC65D47);
    const Color dangerSoft = Color(0xFFF9EBE7);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final isMobile = size.width < 600;
        final isSmallMobile = size.width < 400;

        return Dialog(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 12 : (isMobile ? 16 : 24),
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: size.height - 48,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallMobile ? 20 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 32,
                      color: danger,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Sair da conta?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 21 : 24,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                      fontFamily: 'DMSerifDisplay',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Você tem certeza de que deseja encerrar sua sessão? Será necessário entrar novamente para acessar sua conta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondary,
                      height: 1.6,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compactButtons = constraints.maxWidth < 260;

                      final cancelButton = OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: secondary,
                          side: const BorderSide(color: border),
                          elevation: 0,
                          minimumSize: const Size(0, 46),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        child: const Text('Cancelar'),
                      );

                      final logoutButton = ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(dialogContext);

                          if (onLogout != null) {
                            onLogout();
                            return;
                          }

                          final authService = AuthService();

                          LoaderService.show(
                            context,
                            message: 'Saindo da conta...',
                          );

                          try {
                            await authService.logout();

                            LoaderService.hide();

                            if (!context.mounted) return;

                            ToastService.showSuccess(
                              context,
                              'Você saiu da sua conta com sucesso',
                            );

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SobreScreen(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            LoaderService.hide();

                            if (!context.mounted) return;

                            ToastService.showError(
                              context,
                              'Não foi possível sair da conta. Tente novamente.',
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 17,
                        ),
                        label: const Text('Sair'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 46),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );

                      if (compactButtons) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            logoutButton,
                            const SizedBox(height: 10),
                            cancelButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: cancelButton),
                          const SizedBox(width: 10),
                          Expanded(child: logoutButton),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}