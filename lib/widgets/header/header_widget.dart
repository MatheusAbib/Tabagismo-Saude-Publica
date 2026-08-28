import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/notification_service.dart';
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
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  int _naoLidas = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildNotificationBell() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showNotificationsDialog,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none, color: Colors.white, size: 18),
                if (_naoLidas > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Transform.translate(
                      offset: const Offset(8, -8),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _naoLidas > 9 ? '9+' : '$_naoLidas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  void _showNotificationsDialog() async {
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
    FagerstromTestModal.show(context, onScoreUpdated: (score) {
      ToastService.showSuccess(context, 'Teste de Fagerström finalizado! Score: $score');
    });
  }

  void _showSintomasModal() {
    SintomasModalWidget.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 50.0);

    if (widget.isHome) {
      return Consumer<PollingService>(
        builder: (context, pollingService, child) {
          _naoLidas = pollingService.notificacoesNaoLidas;
          return _buildHomeHeader(isMobile, horizontalPadding);
        },
      );
    }

    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        _naoLidas = pollingService.notificacoesNaoLidas;
        return _buildAdminEnfermeiraHeader(isMobile, horizontalPadding);
      },
    );
  }

  Widget _buildHomeHeader(bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                Container(
                  margin: EdgeInsets.only(right: 5),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 32),
              ),
              const SizedBox(width: 12),
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESFUMO',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'Apoio ao Tabagismo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 0.9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isMobile ? _buildHomeMobileMenu() : _buildHomeDesktopMenu(),
        ],
      ),
    );
  }

  Widget _buildHomeMobileMenu() {
    return Row(
      children: [
        _buildNotificationBell(),
        const SizedBox(width: 8),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 24),
            onSelected: (String value) {
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
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'turmas_apoio',
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF1F4E6E)),
                    SizedBox(width: 12),
                    Text('Turmas de Apoio', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'sintomas',
                child: Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined, size: 20, color: Color(0xFF1F4E6E)),
                    SizedBox(width: 12),
                    Text('Sintomas Diários', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'teste_fagerstrom',
                child: Row(
                  children: [
                    Icon(Icons.assessment_outlined, size: 20, color: Color(0xFFD97706)),
                    SizedBox(width: 12),
                    Text('Teste de Fagerström', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'minhas_matriculas',
                child: Row(
                  children: [
                    Icon(Icons.list_alt_outlined, size: 20, color: Color(0xFF6B21A8)),
                    SizedBox(width: 12),
                    Text('Minhas Matrículas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'editar_dados',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Color(0xFF64748B)),
                    SizedBox(width: 12),
                    Text('Meus Dados', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'sair',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined, size: 20, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeDesktopMenu() {
    return Row(
      children: [
        Container(
          height: 42,
          margin: const EdgeInsets.only(right: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openUPAScreen,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Turmas de Apoio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Bem-vindo, ${widget.userData['nomeCompleto']?.split(' ').first ?? 'Usuário'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                ],
              ),
            ),
            onSelected: (String value) {
              switch (value) {
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
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'sintomas',
                child: Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined, size: 20, color: Color(0xFF1F4E6E)),
                    SizedBox(width: 12),
                    Text('Sintomas Diários', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'teste_fagerstrom',
                child: Row(
                  children: [
                    Icon(Icons.assessment_outlined, size: 20, color: Color(0xFFD97706)),
                    SizedBox(width: 12),
                    Text('Teste de Fagerström', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'minhas_matriculas',
                child: Row(
                  children: [
                    Icon(Icons.list_alt_outlined, size: 20, color: Color(0xFF6B21A8)),
                    SizedBox(width: 12),
                    Text('Minhas Matrículas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'editar_dados',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Color(0xFF64748B)),
                    SizedBox(width: 12),
                    Text('Meus Dados', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'sair',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined, size: 20, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildNotificationBell(),
      ],
    );
  }

  Widget _buildAdminEnfermeiraHeader(bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                Container(
                  margin: EdgeInsets.only(right: 5),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 29),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMobile ? widget.title.split(' • ')[0] : widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (widget.subtitle.isNotEmpty && !isMobile)
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                ],
              ),
            ],
          ),
          HeaderActionsWidget(
            userData: widget.userData,
            onEditData: () => MeusDadosModal.show(context),
            onChangePassword: () => MeusDadosModal.show(context),
          ),
        ],
      ),
    );
  }
}