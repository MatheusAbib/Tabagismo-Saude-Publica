
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

  const EnfermeiraScreen({
    super.key,
    required this.userData,
  });

  @override
  State<EnfermeiraScreen> createState() => _EnfermeiraScreenState();
}

class _EnfermeiraScreenState extends State<EnfermeiraScreen>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _surfaceSoft = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accentColor = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFE1EDF6);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);

  late TabController _tabController;

  final List<String> _tabTitles = [
    'Dashboard',
    'Usuários',
    'Cronogramas',
    'Turmas',
  ];

  final List<IconData> _tabIcons = [
    Icons.dashboard_outlined,
    Icons.people_outline_rounded,
    Icons.calendar_month_outlined,
    Icons.groups_outlined,
  ];

  final List<IconData> _tabActiveIcons = [
    Icons.dashboard_rounded,
    Icons.people_rounded,
    Icons.calendar_month_rounded,
    Icons.groups_rounded,
  ];

  String _upaNome = '';
  bool _isLoading = true;
  int _ultimaVersao = 0;
  int _abaAtual = 0;

  @override
  void initState() {
    super.initState();

    final nome = widget.userData['upa_nome'];

    _upaNome = nome != null && nome.toString().trim().isNotEmpty
        ? nome.toString()
        : 'Unidade de atendimento';

    _tabController = TabController(
      length: _tabTitles.length,
      vsync: this,
    );

    _tabController.addListener(_onTabChanged);

    _carregarDados();
  }

  void _onTabChanged() {
    if (!mounted) return;

    if (_abaAtual != _tabController.index) {
      setState(() {
        _abaAtual = _tabController.index;
      });
    }
  }

  Future<void> _carregarDados() async {
    if (!_isLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  void _selecionarAba(int index) {
    if (index == _tabController.index) return;

    _tabController.animateTo(index);
  }

  int get _upaId {
    final value = widget.userData['upa_id'];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
        }

        return LoadingOverlay(
          isLoading: _isLoading,
          child: Scaffold(
            backgroundColor: _background,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  HeaderWidget(
                    title: 'Painel Enfermeira • $_upaNome',
                    icon: Icons.medical_services_outlined,
                    userData: widget.userData,
                  ),
                  _buildNavigation(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        DashboardWidget(
                          key: ValueKey(
                            'dashboard_$_ultimaVersao',
                          ),
                          upaId: _upaId,
                        ),
                        UsuariosWidget(
                          key: ValueKey(
                            'usuarios_$_ultimaVersao',
                          ),
                          upaId: _upaId,
                        ),
                        CronogramaWidget(
                          key: ValueKey(
                            'cronograma_$_ultimaVersao',
                          ),
                          upaId: _upaId,
                        ),
                        ListaPresencaWidget(
                          key: ValueKey(
                            'presenca_$_ultimaVersao',
                          ),
                          upaId: _upaId,
                        ),
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

  Widget _buildNavigation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 650) {
          return _buildMobileNavigation();
        }

        return _buildDesktopNavigation(
          compact: width < 950,
        );
      },
    );
  }

  Widget _buildDesktopNavigation({
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1440,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 20 : 28,
              vertical: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: List.generate(
                      _tabTitles.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == _tabTitles.length - 1
                                  ? 0
                                  : 8,
                            ),
                            child: _buildNavigationItem(
                              index,
                              compact: compact,
                            ),
                          ),
                        );
                      },
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



  Widget _buildNavigationItem(
    int index, {
    bool compact = false,
  }) {
    final selected = _abaAtual == index;

    return Material(
      color: selected ? _accentSoft : _surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _selecionarAba(index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _accentColor : _border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? _tabActiveIcons[index]
                    : _tabIcons[index],
                size: compact ? 18 : 19,
                color: selected
                    ? _accentColor
                    : _textSecondary,
              ),
              SizedBox(width: compact ? 7 : 10),
              Flexible(
                child: Text(
                  _tabTitles[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: compact ? 11 : 12,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? _accentColor
                        : _textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavigation() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              12,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.medical_information_outlined,
                    size: 19,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÁREA DE GESTÃO',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: _accentColor,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Enfermagem',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  child: const Text(
                    'DESFUMO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              0,
              12,
              12,
            ),
            child: Row(
              children: List.generate(
                _tabTitles.length,
                (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _tabTitles.length - 1
                            ? 0
                            : 6,
                      ),
                      child: _buildMobileNavigationItem(index),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigationItem(int index) {
    final selected = _abaAtual == index;

    return Material(
      color: selected ? _accentSoft : _surfaceSoft,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: () => _selecionarAba(index),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? _accentColor : _border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? _tabActiveIcons[index]
                    : _tabIcons[index],
                size: 20,
                color: selected
                    ? _accentColor
                    : _textSecondary,
              ),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _tabTitles[index],
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? _accentColor
                        : _textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
