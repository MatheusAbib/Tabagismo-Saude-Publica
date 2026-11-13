
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/sobre_screen.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/header/modals/logout_modal_widget.dart';

class HeaderActionsWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onEditData;
  final VoidCallback? onChangePassword;
  final bool isHome;

  const HeaderActionsWidget({
    super.key,
    required this.userData,
    this.onEditData,
    this.onChangePassword,
    this.isHome = false,
  });

  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _accent = Color(0xFF426E8C);
  static const Color _buttonBackground = Color(0xFFE1EDF6);
  static const Color _buttonBorder = Color(0xFFCADDEB);
  static const Color _surface = Color(0xFFFFFDF9);
  static const Color _divider = Color(0xFFE6E5DF);
  static const Color _danger = Color(0xFFC65D47);

  String _getUserFirstName() {
    final nomeCompleto = (userData['nomeCompleto'] ??
            userData['nome'] ??
            userData['name'] ??
            'Usuário')
        .toString()
        .trim();

    if (nomeCompleto.isEmpty) {
      return 'Usuário';
    }

    return nomeCompleto.split(RegExp(r'\s+')).first;
  }

  Future<void> _performLogout(BuildContext context) async {
    final authService = AuthService();

    await authService.logout();

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
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 500;

    return Container(
      decoration: BoxDecoration(
        color: _buttonBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _buttonBorder,
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 48),
        elevation: 0,
        color: _surface,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(
          minWidth: 205,
          maxWidth: 260,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: _divider,
            width: 1,
          ),
        ),
        tooltip: 'Opções da conta',
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 27,
                height: 27,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1E3F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: _accent,
                  size: 17,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 9),
                Text(
                  'Bem-vindo, ${_getUserFirstName()}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: _foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _accent,
                size: 19,
              ),
            ],
          ),
        ),
        onSelected: (String value) {
          switch (value) {
            case 'editar_dados':
              onEditData?.call();
              break;
            case 'alterar_senha':
              onChangePassword?.call();
              break;
            case 'sair':
              LogoutModal.show(
                context,
                onLogout: () => _performLogout(context),
              );
              break;
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            enabled: false,
            height: 43,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _buttonBackground,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.account_circle_outlined,
                    color: _accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getUserFirstName(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(
            height: 12,
          ),
          const PopupMenuItem<String>(
            value: 'editar_dados',
            height: 46,
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 19,
                  color: _accent,
                ),
                SizedBox(width: 12),
                Text(
                  'Meus Dados',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _foreground,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(
            height: 12,
          ),
          const PopupMenuItem<String>(
            value: 'sair',
            height: 46,
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 19,
                  color: _danger,
                ),
                SizedBox(width: 12),
                Text(
                  'Sair',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
