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
    Key? key,
    required this.userData,
    this.onEditData,
    this.onChangePassword,
    this.isHome = false,
  }) : super(key: key);

  String _getUserFirstName() {
    String nomeCompleto = userData['nomeCompleto'] ??
        userData['nome'] ??
        userData['name'] ??
        'Usuário';
    if (nomeCompleto.isNotEmpty && nomeCompleto.contains(' ')) {
      return nomeCompleto.split(' ').first;
    }
    return nomeCompleto;
  }

  void _performLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      ToastService.showSuccess(context, 'Você saiu da sua conta com sucesso');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SobreScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 52),
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
              ),
              if (!isMobile) const SizedBox(width: 8),
              if (!isMobile)
                Text(
                  'Bem-vindo, ${_getUserFirstName()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
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
              LogoutModal.show(context, onLogout: () => _performLogout(context));
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'editar_dados',
            child: Row(
              children: [
                Icon(Icons.person, size: 20, color: Color(0xFF0F2B3D)),
                SizedBox(width: 12),
                Text('Meus Dados', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'sair',
            child: Row(
              children: [
                Icon(Icons.logout_outlined, size: 20, color: const Color(0xFFC65D47)),
                const SizedBox(width: 12),
                Text('Sair', style: TextStyle(fontSize: 14, color: Color(0xFFC65D47))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}