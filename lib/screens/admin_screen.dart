import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/admin/admin_dashboard_widget.dart';
import 'package:tabagismo_app/widgets/admin/admin_enfermeiras_widget.dart';
import 'package:tabagismo_app/widgets/admin/admin_unidades_widget.dart';
import 'package:tabagismo_app/widgets/admin/admin_usuarios_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/widgets/loading_overlay.dart';

class AdminScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const AdminScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  int _ultimaVersao = 0;
  
  final List<String> _tabTitles = ['Dashboard', 'Usuários', 'Unidades', 'Enfermeiras'];
  
  final Color _accentColor = const Color(0xFF1F4E6E);

  @override
  void initState() {
    super.initState();
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
          child: DefaultTabController(
            length: _tabTitles.length,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: Column(
                children: [
                  HeaderWidget(
                    title: 'Painel Administrativo',
                    subtitle: '',
                    icon: Icons.admin_panel_settings,
                    userData: widget.userData,
                  ),
                  Container(
                    color: const Color(0xFFF1F5F9),
                    child: TabBar(
                      isScrollable: isMobile,
                      indicatorColor: _accentColor,
                      labelColor: _accentColor,
                      unselectedLabelColor: const Color(0xFF64748B),
                      labelStyle: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0),
                      tabs: _tabTitles.map((title) => Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8),
                          child: Text(title),
                        ),
                      )).toList(),
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        const AdminDashboardWidget(),
                        const AdminUsuariosWidget(),
                        const AdminUPAsWidget(),
                        const AdminEnfermeirasWidget(),
                      ],
                    ),
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