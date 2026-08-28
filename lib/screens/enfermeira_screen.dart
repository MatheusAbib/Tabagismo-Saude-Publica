import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/enfermeira/enfermeira_cronograma_widget.dart';
import 'package:tabagismo_app/widgets/enfermeira/enfermeira_dashboard_widget.dart';
import 'package:tabagismo_app/widgets/enfermeira/enfermeira_turmas_widget.dart';
import 'package:tabagismo_app/widgets/enfermeira/enfermeira_usuarios_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/widgets/loading_overlay.dart';

class EnfermeiraScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const EnfermeiraScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EnfermeiraScreenState createState() => _EnfermeiraScreenState();
}

class _EnfermeiraScreenState extends State<EnfermeiraScreen> with SingleTickerProviderStateMixin {
  final Color _accentColor = const Color(0xFF1F4E6E);
  
  late TabController _tabController;
  final List<String> _tabTitles = ['Dashboard', 'Usuários', 'Cronogramas', 'Turmas'];
  String _upaNome = '';
  bool _isLoading = true;
  int _ultimaVersao = 0;

  @override
  void initState() {
    super.initState();
    final nome = widget.userData['upa_nome'];
    _upaNome = (nome != null && nome.toString().isNotEmpty) ? nome : 'Carregando...';
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recarregarSilenciosamente() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading) {
            _recarregarSilenciosamente();
          }
        }
        
        return LoadingOverlay(
          isLoading: _isLoading,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Column(
              children: [
                HeaderWidget(
                  title: 'Painel Enfermeira • $_upaNome',
                  icon: Icons.medical_services,
                  userData: widget.userData,
                ),
                Container(
                  color: const Color(0xFFF1F5F9),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: isMobile,
                    indicatorColor: _accentColor,
                    labelColor: _accentColor,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontFamily: 'Inter',
                    ),
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                    tabs: _tabTitles.map((title) => Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 12),
                        child: Text(title),
                      ),
                    )).toList(),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    DashboardWidget(
                      key: ValueKey('dashboard_$_ultimaVersao'),
                      upaId: widget.userData['upa_id'] ?? 0,
                    ),
                    UsuariosWidget(
                      key: ValueKey('usuarios_$_ultimaVersao'),
                      upaId: widget.userData['upa_id'] ?? 0,
                    ),
                    CronogramaWidget(
                      key: ValueKey('cronograma_$_ultimaVersao'),
                      upaId: widget.userData['upa_id'] ?? 0,
                    ),
                    ListaPresencaWidget(
                      key: ValueKey('presenca_$_ultimaVersao'),
                      upaId: widget.userData['upa_id'] ?? 0,
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}