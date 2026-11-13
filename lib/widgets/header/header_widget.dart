import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/header/header_actions_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/logout_modal_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/meus_dados_modal.dart';
import 'package:tabagismo_app/widgets/header/modals/fagerstrom_modal_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/notificacoes_modal.dart';
import 'package:tabagismo_app/widgets/header/modals/sintomas_modal_widget.dart';
import 'package:tabagismo_app/screens/upa_screen.dart';
import 'package:tabagismo_app/screens/matriculas_screen.dart';

class HeaderWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic> userData;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool isHome;
  final Function(String)? onNameUpdated;

  const HeaderWidget({
    Key? key,
    required this.title,
    this.subtitle = '',
    required this.icon,
    this.iconColor = Colors.white,
    required this.userData,
    this.showBackButton = false,
    this.onBackPressed,
    this.isHome = false,
    this.onNameUpdated,
  }) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFDEDCD5);
  static const Color _divider = Color(0xFFE6E5DF);

  int _naoLidas = 0;

  String get _firstName {
    final name = widget.userData['nomeCompleto']?.toString().trim() ?? '';
    if (name.isEmpty) return 'Usuário';
    return name.split(RegExp(r'\s+')).first;
  }

  void _showNotificationsDialog() {
    NotificacoesModal.show(context);
  }

  void _openUPAScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UPAScreen(
          userData: widget.userData,
          onNameUpdated: widget.onNameUpdated,
        ),
      ),
    );
  }

  void _openMyEnrollments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEnrollmentsScreen(
          userData: widget.userData,
          onNameUpdated: widget.onNameUpdated,
        ),
      ),
    );
  }

  void _openFagerstromTest() {
    FagerstromTestModal.show(
      context,
      onScoreUpdated: (score) {
        ToastService.showSuccess(
          context,
          'Teste de Fagerström finalizado! Score: $score',
        );
      },
    );
  }

  void _showSintomasModal() {
    SintomasModalWidget.show(context);
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'turmas_apoio':
        _openUPAScreen();
        break;
      case 'sintomas':
        _showSintomasModal();
        break;
      case 'teste_fagerstrom':
        _openFagerstromTest();
        break;
      case 'minhas_matriculas':
        _openMyEnrollments();
        break;
      case 'editar_dados':
        MeusDadosModal.show(context);
        break;
      case 'sair':
        LogoutModal.show(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 50.0);

    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        _naoLidas = pollingService.notificacoesNaoLidas;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 12,
          ),
          decoration: const BoxDecoration(
            color: _background,
            border: Border(
              bottom: BorderSide(
                color: _border,
                width: 1,
              ),
            ),
          ),
          child: widget.isHome
              ? _buildHomeHeader(isMobile)
              : _buildAdminEnfermeiraHeader(isMobile),
        );
      },
    );
  }

  Widget _buildHomeHeader(bool isMobile) {
    return Row(
      children: [
        if (widget.showBackButton) ...[
          _buildBackButton(),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildLogo(),
          ),
        ),
        const SizedBox(width: 12),
        if (isMobile)
          _buildHomeMobileMenu()
        else
          _buildHomeDesktopMenu(),
      ],
    );
  }

  Widget _buildLogo() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isHome
            ? () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _softBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: _primary,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESFUMO',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                        color: _foreground,
                        height: 0.95,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Apoio ao Tabagismo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onBackPressed ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: _foreground,
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showNotificationsDialog,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                color: _primary,
                size: 21,
              ),
            ),
          ),
        ),
        if (_naoLidas > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFC76D60),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _background,
                  width: 2,
                ),
              ),
              child: Text(
                _naoLidas > 9 ? '9+' : '$_naoLidas',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHomeMobileMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNotificationBell(),
        const SizedBox(width: 10),
        _buildPopupMenu(
          isMobile: true,
          includeSupportGroups: true,
        ),
      ],
    );
  }

  Widget _buildHomeDesktopMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSupportGroupsButton(),
        const SizedBox(width: 10),
        _buildPopupMenu(
          isMobile: false,
          includeSupportGroups: false,
        ),
        const SizedBox(width: 10),
        _buildNotificationBell(),
      ],
    );
  }

  Widget _buildSupportGroupsButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openUPAScreen,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: _primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Turmas de Apoio',
                style: TextStyle(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu({
    required bool isMobile,
    required bool includeSupportGroups,
  }) {
    return PopupMenuButton<String>(
      tooltip: isMobile ? 'Abrir menu' : 'Minha conta',
      offset: const Offset(0, 50),
      elevation: 0,
      color: _background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _border),
      ),
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => _buildMenuItems(
        includeSupportGroups: includeSupportGroups,
      ),
      child: Container(
        height: 42,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: isMobile ? _softBlue : _background,
          border: Border.all(
            color: isMobile ? _softBlue : _border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: isMobile
            ? const Icon(
                Icons.menu,
                color: _primary,
                size: 22,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: _primary,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Olá, $_firstName',
                    style: const TextStyle(
                      color: _foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: _secondary,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems({
    required bool includeSupportGroups,
  }) {
    return [
      if (includeSupportGroups) ...[
        _buildMenuItem(
          value: 'turmas_apoio',
          icon: Icons.location_on_outlined,
          label: 'Turmas de Apoio',
        ),
        const PopupMenuDivider(height: 8),
      ],
      _buildMenuItem(
        value: 'sintomas',
        icon: Icons.monitor_heart_outlined,
        label: 'Sintomas Diários',
      ),
      _buildMenuItem(
        value: 'teste_fagerstrom',
        icon: Icons.assessment_outlined,
        label: 'Teste de Fagerström',
      ),
      _buildMenuItem(
        value: 'minhas_matriculas',
        icon: Icons.list_alt_outlined,
        label: 'Minhas Matrículas',
      ),
      const PopupMenuDivider(height: 8),
      _buildMenuItem(
        value: 'editar_dados',
        icon: Icons.person_outline,
        label: 'Meus Dados',
      ),
      _buildMenuItem(
        value: 'sair',
        icon: Icons.logout_outlined,
        label: 'Sair',
        isDestructive: true,
      ),
    ];
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    final itemColor =
        isDestructive ? const Color(0xFFB85F55) : _primary;

    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: itemColor,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? itemColor : _foreground,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminEnfermeiraHeader(bool isMobile) {
    return Row(
      children: [
        if (widget.showBackButton) ...[
          _buildBackButton(),
          const SizedBox(width: 10),
        ],
        Container(
          width: isMobile ? 40 : 46,
          height: isMobile ? 40 : 46,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: _softBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: _primary,
            size: isMobile ? 23 : 27,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isMobile
                    ? widget.title.split(' • ').first
                    : widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _foreground,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  fontFamily: 'Inter',
                ),
              ),
              if (!isMobile && widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        HeaderActionsWidget(
          userData: widget.userData,
          onEditData: () => MeusDadosModal.show(context),
          onChangePassword: () => MeusDadosModal.show(context),
        ),
      ],
    );
  }
}