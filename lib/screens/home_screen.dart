import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/loading_overlay.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/fagerstrom_modal_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/sintomas_modal_widget.dart';
import 'package:tabagismo_app/widgets/user/home_materiais_widget.dart';
import 'package:tabagismo_app/widgets/user/home_metas_widget.dart';
import 'package:tabagismo_app/widgets/user/home_sobre_widget.dart';
import 'package:tabagismo_app/screens/sobre_screen.dart';
import 'package:tabagismo_app/screens/upa_screen.dart';
import 'package:tabagismo_app/screens/matriculas_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  static const Color _bgBase = Color(0xFFFAF8F3);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF4E4E4E);
  static const Color _textMuted = Color(0xFF8A8A85);
  static const Color _menta50 = Color(0xFFD9F0E6);
  static const Color _menta100 = Color(0xFFB8E4D2);
  static const Color _menta300 = Color(0xFF8CD4B9);
  static const Color _menta900 = Color(0xFF2F7A63);
  static const Color _terra50 = Color(0xFFF2D9CC);
  static const Color _terra700 = Color(0xFF8F4A2C);
  static const Color _border = Color(0xFFE4E0D6);
  static const Color _heroBackground = Color(0xFFEAF3F9);
  static const Color _heroBlue = Color(0xFF426E8C);
  static const Color _heroBlueLight = Color(0xFFE1EDF6);
  static const Color _quickBackground = Color(0xFFFAF8F3);
  static const Color _goalsBackground = Color(0xFFFFFFFF);
  static const Color _materialsBackground = Color(0xFFF2EFE7);
  static const Color _aboutBackground = Color(0xFFFCFBF8);
  late Map<String, dynamic> _userData;
  int? _hoveredHeroCard;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  int _ultimaVersao = 0;
  Timer? _updateTimer;
  final GlobalKey _metasKey = GlobalKey();
  final GlobalKey _materiaisKey = GlobalKey();
  final GlobalKey _sobreKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.userData);
    final userId = _userData['id'];
    final token = _userData['token'];
    _isLoggedIn =
        (userId is num && userId > 0) ||
        (token != null && token.toString().isNotEmpty);
    _carregarDados();
    if (_isLoggedIn) {
      _loadGoalData();
      _loadFagerstromScore();
    }
    _startRealtimeUpdate();
  }
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  Future<void> _carregarDados() async {
    if (!_isLoading && mounted) {
      setState(() => _isLoading = true);
    }
    await Future.delayed(
      const Duration(milliseconds: 800),
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _recarregarSilenciosamente() async {
    if (!_isLoggedIn) return;
    await Future.wait([
      _loadGoalData(),
      _loadFagerstromScore(),
    ]);
  }
  void _startRealtimeUpdate() {
    _updateTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
  Future<void> _loadGoalData() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      if (!mounted || userData == null) return;
      setState(() {
        if (userData['stop_date'] != null &&
            userData['stop_date'].toString().isNotEmpty &&
            userData['stop_date'].toString() != 'null') {
          _userData['stopDate'] =
              userData['stop_date'].toString();
        }
        final targetDays = int.tryParse(
          userData['target_days']?.toString() ?? '',
        );
        if (targetDays != null && targetDays > 0) {
          _userData['targetDays'] = targetDays;
        }
        final cigarrosPorDia = int.tryParse(
          userData['cigarros_por_dia']?.toString() ?? '',
        );
        if (cigarrosPorDia != null && cigarrosPorDia > 0) {
          _userData['cigarrosPorDia'] = cigarrosPorDia;
        }
        final valorCarteira = double.tryParse(
          userData['valor_carteira']?.toString() ?? '',
        );
        if (valorCarteira != null && valorCarteira > 0) {
          _userData['valorCarteira'] = valorCarteira;
        }
      });
    } catch (e) {
      debugPrint('Erro ao carregar meta: $e');
    }
  }
  Future<void> _loadFagerstromScore() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      if (!mounted || userData == null) return;
      final score = int.tryParse(
        userData['scoreFagestrom']?.toString() ?? '',
      );
      if (score != null && score > 0) {
        setState(() {
          _userData['scoreFagestrom'] = score;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar score: $e');
    }
  }
  void _updateUserName(String newName) {
    if (!mounted) return;
    setState(() {
      _userData['nomeCompleto'] = newName;
    });
  }
  String _getFirstName() {
    final nome = (_userData['nomeCompleto'] ??
            _userData['nome'] ??
            _userData['name'] ??
            '')
        .toString()
        .trim();
    if (nome.isEmpty) return '';
    return nome.split(' ').first;
  }
  void _openUPAScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UPAScreen(
          userData: _userData,
          onNameUpdated: _updateUserName,
        ),
      ),
    );
  }
  void _openMyEnrollments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEnrollmentsScreen(
          userData: _userData,
          onNameUpdated: _updateUserName,
        ),
      ),
    );
  }
  void _openSintomas() {
    SintomasModalWidget.show(context);
  }
  void _openFagerstrom() {
    FagerstromTestModal.show(
      context,
      onScoreUpdated: (score) {
        if (!mounted) return;
        setState(() {
          _userData['scoreFagestrom'] = score;
        });
      },
    );
  }
  void _openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SobreScreen(),
      ),
    );
  }
  void _scrollTo(GlobalKey key) {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }
  double _horizontalPadding(double width) {
    if (width < 768) return 20;
    if (width < 1200) return 36;
    return 56;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading && _isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _recarregarSilenciosamente();
              }
            });
          }
        }
        return LoadingOverlay(
          isLoading: _isLoading,
          child: Scaffold(
            backgroundColor: _bgBase,
            resizeToAvoidBottomInset: false,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    _isLoggedIn
                        ? HeaderWidget(
                            title: 'DESFUMO',
                            subtitle: 'Apoio ao Tabagismo',
                            icon: Icons.smoke_free_outlined,
                            userData: _userData,
                            isHome: true,
                            onNameUpdated: _updateUserName,
                          )
                        : _buildGuestHeader(constraints),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildIntroduction(constraints),
                            _buildQuickAccess(constraints),
                            if (_isLoggedIn)
                              _buildGoalsSection(constraints),
                            _buildMaterialsSection(constraints),
                            _buildAboutSection(constraints),
                            const FooterWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
  Widget _buildIntroduction(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isMobile = width < 768;
    final isTablet = width < 1200;
    final padding = _horizontalPadding(width);
    final firstName = _getFirstName();
return Container(
  width: double.infinity,
  clipBehavior: Clip.hardEdge,
  decoration: const BoxDecoration(
    color: _heroBackground,
  ),
  child: Stack(
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 4,
              sigmaY: 4,
            ),
            child: Image.asset(
              'assets/images/Viva-Mais.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.75),
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: Container(
           color: const Color(0xFFEAF3F9).withValues(alpha: 0.55),
          ),
        ),
      ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding,
              isMobile ? 58 : 92,
              padding,
              isMobile ? 66 : 100,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1320,
                ),
child: isMobile
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            child: _buildIntroContent(
              true,
              firstName,
            ),
          ),
          const SizedBox(height: 64),
          _buildIntroVisual(true),
        ],
      )
    : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 24 : 30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.93),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              child: _buildIntroContent(
                false,
                firstName,
              ),
            ),
          ),
            SizedBox(
              width: isTablet ? 40 : 80,
            ),
            Expanded(
              flex: 5,
              child: _buildIntroVisual(false),
            ),
        ],
      ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 1,
              color: const Color(0xFFCADDEB),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIntroContent(
    bool isMobile,
    String firstName,
  ) {
    final title = _isLoggedIn
        ? firstName.isNotEmpty
            ? 'Olá, $firstName.'
            : 'Seu acompanhamento começa aqui.'
        : 'Apoio para parar de fumar.';
    final description = _isLoggedIn
        ? 'Acompanhe suas metas, encontre turmas de apoio e acesse ferramentas para cuidar da sua saúde.'
        : 'Conheça os recursos do Desfumo, encontre informações sobre o programa e descubra como receber acompanhamento.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFCADDEB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: _heroBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  _isLoggedIn
                      ? 'SEU ESPAÇO DE ACOMPANHAMENTO'
                      : 'PROGRAMA DE APOIO AO TABAGISMO',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: _heroBlue,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Icon(Icons.health_and_safety_outlined, size: 15, color: _heroBlue),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 25 : 33),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'DMSerifDisplay',
              fontSize: isMobile ? 44 : 69,
              fontWeight: FontWeight.w400,
              letterSpacing: -1.6,
              height: 1.08,
              color: _textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 23),
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            color: _heroBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 540,
          ),
          child: Text(
            description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 15 : 16,
              height: 1.75,
              color: _textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 33),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              label: _isLoggedIn
                  ? 'Ver minhas metas'
                  : 'Conhecer o programa',
              icon: Icons.arrow_forward,
              primary: true,
              onPressed: () => _scrollTo(
                _isLoggedIn ? _metasKey : _sobreKey,
              ),
            ),
            _buildActionButton(
              label: 'Materiais de apoio',
              icon: Icons.menu_book_outlined,
              primary: false,
              onPressed: () => _scrollTo(
                _materiaisKey,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildIntroVisual(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, isMobile ? 440.0 : 520.0);
        final scale = width / 520.0;
        final order = [0, 1, 2];
        if (_hoveredHeroCard != null && order.contains(_hoveredHeroCard)) {
          order.remove(_hoveredHeroCard);
          order.add(_hoveredHeroCard!);
        }

        Widget cardAt(int index) {
          if (index == 0) {
            return Positioned(
              left: 10 * scale,
              top: 42 * scale,
              child: _buildHoverableHeroCard(
                index: 0,
                child: Transform.rotate(
                  angle: -0.105,
                  child: _buildVisualCard(
                    width: 294 * scale,
                    height: 340 * scale,
                    scale: scale,
                    background: const Color(0xFFF8FCFF),
                    accent: _heroBlue,
                    icon: Icons.favorite_border_rounded,
                    number: '01',
                    category: 'BENEFÍCIOS PARA A SAÚDE',
                    title: 'Seu corpo começa a se recuperar',
                    description: 'Após parar de fumar, o organismo inicia um processo gradual de recuperação que continua ao longo do tempo.',
                    illustration: _buildHeroInformationIllustration(
                      Icons.favorite_rounded,
                      'Primeiras horas',
                      'O organismo já começa a reagir',
                      _heroBlue,
                      scale,
                    ),
                  ),
                ),
              ),
            );
          }
          if (index == 1) {
            return Positioned(
              right: 6 * scale,
              top: 5 * scale,
              child: _buildHoverableHeroCard(
                index: 1,
                child: Transform.rotate(
                  angle: 0.095,
                  child: _buildVisualCard(
                    width: 272 * scale,
                    height: 332 * scale,
                    scale: scale,
                    background: const Color(0xFFDCECF7),
                    accent: _heroBlue,
                    icon: Icons.psychology_outlined,
                    number: '02',
                    category: 'ENTENDA O PROCESSO',
                    title: 'Os primeiros dias sem cigarro',
                    description: 'Ansiedade, irritabilidade e vontade de fumar podem surgir na abstinência e tendem a diminuir com o tempo.',
                    illustration: _buildHeroInformationIllustration(
                      Icons.trending_down_rounded,
                      'É uma fase',
                      'Os sintomas tendem a diminuir',
                      _heroBlue,
                      scale,
                    ),
                  ),
                ),
              ),
            );
          }
          return Positioned(
            left: 125 * scale,
            bottom: 16 * scale,
            child: _buildHoverableHeroCard(
              index: 2,
              child: Transform.rotate(
                angle: -0.055,
                child: _buildVisualCard(
                  width: 320 * scale,
                  height: 255 * scale,
                  scale: scale,
                  background: _heroBlue,
                  accent: Colors.white,
                  icon: Icons.groups_outlined,
                  number: '03',
                  category: 'APOIO AO TRATAMENTO',
                  title: 'Você não precisa fazer isso sozinho',
                  description: 'O acompanhamento profissional e as turmas de apoio ajudam a enfrentar dificuldades durante o tratamento.',
                  illustration: _buildHeroInformationIllustration(
                    Icons.people_outline_rounded,
                    'Apoio contínuo',
                    'Acompanhamento em cada etapa',
                    Colors.white,
                    scale,
                  ),
                ),
              ),
            ),
          );
        }

        return Center(
          child: SizedBox(
            width: width,
            height: 480 * scale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [for (final index in order) cardAt(index)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoverableHeroCard({
    required int index,
    required Widget child,
  }) {
    return MouseRegion(
      onEnter: (_) {
        if (_hoveredHeroCard != index) {
          setState(() => _hoveredHeroCard = index);
        }
      },
      onExit: (_) {
        if (_hoveredHeroCard == index) {
          setState(() => _hoveredHeroCard = null);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (_hoveredHeroCard != index) {
            setState(() => _hoveredHeroCard = index);
          }
        },
        child: child,
      ),
    );
  }

  Widget _buildVisualCard({
    required double width,
    required double height,
    required double scale,
    required Color background,
    required Color accent,
    required IconData icon,
    required String number,
    required String category,
    required String title,
    required String description,
    required Widget illustration,
  }) {
    final dark = background == _heroBlue;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(19 * scale),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17 * scale),
        border: Border.all(
          color: dark ? const Color(0xFF365C78) : const Color(0xFFBDD6E8),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34 * scale,
                height: 34 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(9 * scale),
                ),
                child: Icon(icon, color: accent, size: 19 * scale),
              ),
              const Spacer(),
              Text(
                number,
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: 24 * scale,
                  color: accent.withOpacity(0.65),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Text(
            category,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: accent,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'DMSerifDisplay',
              fontSize: 21 * scale,
              height: 1.1,
              color: dark ? Colors.white : _textPrimary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5 * scale,
              height: 1.4,
              color: dark ? Colors.white.withOpacity(0.88) : const Color(0xFF52616B),
            ),
          ),
          const Spacer(),
          illustration,
        ],
      ),
    );
  }

  Widget _buildHeroInformationIllustration(
    IconData icon,
    String value,
    String description,
    Color accent,
    double scale,
  ) {
    final light = accent == Colors.white;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: light ? Colors.white.withOpacity(0.12) : const Color(0xFFE1EDF6),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(
          color: light ? Colors.white.withOpacity(0.18) : const Color(0xFFCADDEB),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20 * scale),
          SizedBox(width: 9 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5 * scale,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9 * scale,
                    height: 1.3,
                    color: accent.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isMobile = width < 768;
    final padding = _horizontalPadding(width);
    return Container(
      width: double.infinity,
      color: _quickBackground,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 64 : 94,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1320,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeading(
                number: '01',
                eyebrow: 'ACESSO RÁPIDO',
                title: 'O que você precisa fazer?',
                description:
                    'Encontre as principais ferramentas de acompanhamento do Desfumo.',
                icon: Icons.grid_view_rounded,
                accent: _menta900,
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 30 : 42),
              LayoutBuilder(
                builder: (context, innerConstraints) {
                  final columns =
                      innerConstraints.maxWidth < 650
                          ? 1
                          : innerConstraints.maxWidth < 1050
                              ? 2
                              : 4;
                  const spacing = 16.0;
                  final itemWidth =
                      (innerConstraints.maxWidth -
                              spacing * (columns - 1)) /
                          columns;
                  final actions = <_QuickActionData>[
                    _QuickActionData(
                      icon: Icons.groups_outlined,
                      title: 'Turmas de apoio',
                      description:
                          'Encontre unidades e turmas disponíveis.',
                      background: const Color(0xFFD9F0E6),
                      foreground: _menta900,
                      onTap: _isLoggedIn
                          ? _openUPAScreen
                          : _openLogin,
                    ),
                    _QuickActionData(
                      icon: Icons.assignment_outlined,
                      title: 'Minhas matrículas',
                      description:
                          'Consulte o andamento das suas inscrições.',
                      background: const Color(0xFFE8E5F4),
                      foreground: const Color(0xFF65568D),
                      onTap: _isLoggedIn
                          ? _openMyEnrollments
                          : _openLogin,
                    ),
                    _QuickActionData(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Registrar sintomas',
                      description:
                          'Registre como você está se sentindo.',
                      background: const Color(0xFFE1EDF6),
                      foreground: const Color(0xFF426E8C),
                      onTap: _isLoggedIn
                          ? _openSintomas
                          : _openLogin,
                    ),
                    _QuickActionData(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Teste de Fagerström',
                      description:
                          'Acesse a avaliação de dependência à nicotina.',
                      background: const Color(0xFFF2D9CC),
                      foreground: _terra700,
                      onTap: _isLoggedIn
                          ? _openFagerstrom
                          : _openLogin,
                    ),
                  ];
                  final rows = <Widget>[];
                  for (int start = 0;
                      start < actions.length;
                      start += columns) {
                    final end = math.min(
                      start + columns,
                      actions.length,
                    );
                    final rowItems = actions.sublist(start, end);
                    rows.add(
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            for (int index = 0;
                                index < rowItems.length;
                                index++) ...[
                              if (index > 0)
                                const SizedBox(width: spacing),
                              SizedBox(
                                width: itemWidth,
                                child: _buildQuickAction(
                                  icon: rowItems[index].icon,
                                  title: rowItems[index].title,
                                  description:
                                      rowItems[index].description,
                                  background:
                                      rowItems[index].background,
                                  foreground:
                                      rowItems[index].foreground,
                                  onTap: rowItems[index].onTap,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      for (int index = 0;
                          index < rows.length;
                          index++) ...[
                        if (index > 0)
                          const SizedBox(height: spacing),
                        rows[index],
                      ],
                    ],
                  );
                },
              ),
              if (!_isLoggedIn) ...[
                const SizedBox(height: 22),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 17,
                      color: _textMuted,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Entre na sua conta para utilizar as ferramentas de acompanhamento.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.5,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String description,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 205,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: foreground.withOpacity(0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _surface.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 23),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isLoggedIn ? 'Acessar' : 'Entrar para acessar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    _isLoggedIn
                        ? Icons.arrow_forward
                        : Icons.lock_outline,
                    size: 15,
                    color: foreground,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGoalsSection(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isMobile = width < 768;
    final padding = isMobile
        ? 16.0
        : width < 1200
            ? 32.0
            : 50.0;
    return Container(
      key: _metasKey,
      width: double.infinity,
      color: _goalsBackground,
      padding: EdgeInsets.fromLTRB(
        padding,
        isMobile ? 66 : 100,
        padding,
        isMobile ? 66 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1420,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 14,
                ),
                child: _buildSectionHeading(
                  number: '02',
                  eyebrow: 'ACOMPANHAMENTO PESSOAL',
                  title: 'Minhas metas',
                  description:
                      'Seus indicadores e conquistas em um só lugar.',
                  icon: Icons.flag_outlined,
                  accent: const Color(0xFF8F4A2C),
                  isMobile: isMobile,
                ),
              ),
              SizedBox(height: isMobile ? 30 : 42),
              HomeMetasWidget(
                userData: _userData,
                onRefresh: _carregarDados,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMaterialsSection(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isMobile = width < 768;
    final padding = isMobile
        ? 16.0
        : width < 1200
            ? 32.0
            : 50.0;
    return Container(
      key: _materiaisKey,
      width: double.infinity,
      color: _materialsBackground,
      padding: EdgeInsets.fromLTRB(
        padding,
        isMobile ? 66 : 100,
        padding,
        isMobile ? 66 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1420,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 14,
                ),
                child: _buildSectionHeading(
                  number: _isLoggedIn ? '03' : '02',
                  eyebrow: 'CONTEÚDOS E ORIENTAÇÕES',
                  title: 'Materiais de apoio',
                  description:
                      'Guias, vídeos e informações para consultar durante o acompanhamento.',
                  icon: Icons.menu_book_outlined,
                  accent: const Color(0xFF426E8C),
                  isMobile: isMobile,
                  trailing: const _SectionInfoChip(
                    icon: Icons.library_books_outlined,
                    label: '6 recursos disponíveis',
                    background: _terra50,
                    foreground: _terra700,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 30 : 42),
              HomeMateriaisWidget(
                isLoggedIn: _isLoggedIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildAboutSection(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isMobile = width < 768;
    final padding = isMobile
        ? 16.0
        : width < 1200
            ? 32.0
            : 50.0;
    return Container(
      key: _sobreKey,
      width: double.infinity,
      color: _aboutBackground,
      padding: EdgeInsets.fromLTRB(
        padding,
        isMobile ? 66 : 100,
        padding,
        isMobile ? 74 : 112,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1420,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 14,
                ),
                child: _buildSectionHeading(
                  number: _isLoggedIn ? '04' : '03',
                  eyebrow: 'CONHEÇA O DESFUMO',
                  title: 'Sobre o programa',
                  description:
                      'Entenda como funcionam as turmas de apoio e os recursos disponíveis.',
                  icon: Icons.health_and_safety_outlined,
                  accent: const Color(0xFF65568D),
                  isMobile: isMobile,
                ),
              ),
              SizedBox(height: isMobile ? 30 : 42),
              const HomeSobreWidget(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSectionHeading({
    required String number,
    required String eyebrow,
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required bool isMobile,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accent.withOpacity(0.12),
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: accent,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                eyebrow,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              number,
              style: TextStyle(
                fontFamily: 'DMSerifDisplay',
                fontSize: 25,
                height: 1,
                color: accent.withOpacity(0.5),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 19 : 23),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: isMobile ? 37 : 53,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.7,
            height: 1.12,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: isMobile ? 15 : 18),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile || constraints.maxWidth < 780) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.7,
                      color: _textSecondary,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 17),
                    trailing,
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      height: 1.7,
                      color: _textSecondary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 24),
                  trailing,
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 27),
        Stack(
          children: [
            Container(
              height: 1,
              width: double.infinity,
              color: accent.withOpacity(0.20),
            ),
            Container(
              width: isMobile ? 54 : 78,
              height: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool primary,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: primary ? _heroBlue : _surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary ? _heroBlue : const Color(0xFFCADDEB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary ? _surface : _textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                size: 17,
                color: primary ? _surface : _heroBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGuestHeader(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 768;
    final isTablet =
        constraints.maxWidth >= 768 &&
        constraints.maxWidth < 1200;
    final horizontalPadding =
        isMobile ? 16.0 : (isTablet ? 32.0 : 50.0);
    return Container(
      color: _bgBase,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _menta50,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.smoke_free_outlined,
                  color: _menta900,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESFUMO',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    'Apoio ao Tabagismo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: _textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildGuestMenu(),
        ],
      ),
    );
  }
  Widget _buildGuestMenu() {
    final isMobile =
        MediaQuery.of(context).size.width < 768;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _menta50,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _menta300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openLogin,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.login_outlined,
                  color: _menta900,
                  size: isMobile ? 16 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isMobile
                      ? 'Entrar'
                      : 'Entrar / Cadastrar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: _textPrimary,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
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
class _QuickActionData {
  final IconData icon;
  final String title;
  final String description;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.description,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
}
class _SectionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  const _SectionInfoChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: foreground.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: foreground,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
class _HomeGeometricPainter extends CustomPainter {
  final bool isMobile;

  const _HomeGeometricPainter({required this.isMobile});

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = isMobile ? 27.0 : 43.0;
    const colors = [
      Color(0xFF426E8C),
      Color(0xFF729AB7),
      Color(0xFF9FC1D9),
      Color(0xFFBDD6E8),
      Color(0xFFD4E6F2),
    ];
    const positions = <Offset>[
      Offset(0.91, 0.02), Offset(0.78, 0.05),
      Offset(0.98, 0.09), Offset(0.86, 0.12),
      Offset(0.69, 0.14), Offset(0.93, 0.19),
      Offset(0.79, 0.22), Offset(0.60, 0.24),
      Offset(0.99, 0.27), Offset(0.87, 0.31),
      Offset(0.72, 0.34), Offset(0.54, 0.36),
      Offset(0.94, 0.39), Offset(0.80, 0.42),
      Offset(0.64, 0.45), Offset(0.46, 0.48),
      Offset(0.99, 0.50), Offset(0.88, 0.53),
      Offset(0.73, 0.56), Offset(0.57, 0.59),
      Offset(0.38, 0.62), Offset(0.95, 0.64),
      Offset(0.81, 0.67), Offset(0.65, 0.70),
      Offset(0.49, 0.73), Offset(0.31, 0.76),
      Offset(0.99, 0.78), Offset(0.89, 0.81),
      Offset(0.74, 0.84), Offset(0.57, 0.87),
      Offset(0.40, 0.90), Offset(0.94, 0.93),
      Offset(0.80, 0.96), Offset(0.64, 0.99),
    ];
    for (var i = 0; i < positions.length; i++) {
      final position = positions[i];
      final variation = 0.65 + (i % 5) * 0.11;
      final currentSize = squareSize * variation;
      final opacity = i % 6 == 0 ? 0.35 : (i % 3 == 0 ? 0.27 : 0.18);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.dx * size.width - currentSize / 2,
          position.dy * size.height - currentSize / 2,
          currentSize,
          currentSize,
        ),
        Radius.circular(isMobile ? 7 : 11),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = colors[i % colors.length].withOpacity(opacity)
          ..style = i % 6 == 0 ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = 1.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeGeometricPainter oldDelegate) {
    return oldDelegate.isMobile != isMobile;
  }
}

class _MiniChartPainter extends CustomPainter {
  final Color color;
  const _MiniChartPainter({
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.70),
      Offset(size.width * 0.17, size.height * 0.44),
      Offset(size.width * 0.32, size.height * 0.58),
      Offset(size.width * 0.49, size.height * 0.22),
      Offset(size.width * 0.66, size.height * 0.38),
      Offset(size.width * 0.82, size.height * 0.14),
      Offset(size.width, size.height * 0.27),
    ];
    final path = Path()
      ..moveTo(points.first.dx, points.first.dy);
    for (int index = 1; index < points.length; index++) {
      path.lineTo(points[index].dx, points[index].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final point in points) {
      canvas.drawCircle(
        point,
        3.2,
        Paint()..color = color,
      );
    }
  }
  @override
  bool shouldRepaint(
    covariant _MiniChartPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
