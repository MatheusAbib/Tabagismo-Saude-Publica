import 'package:flutter/material.dart';
import 'package:tabagismo_app/widgets/login_cadastro_widget.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/main.dart';
import 'package:tabagismo_app/services/loader_service.dart';

class SobreScreen extends StatefulWidget {
  const SobreScreen({super.key});

  @override
  State<SobreScreen> createState() => _SobreScreenState();
}

class _SobreScreenState extends State<SobreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoaderService.show(context, message: 'Carregando...');
      Future.delayed(const Duration(milliseconds: 600), () {
        LoaderService.hide();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 919;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallMobile = screenWidth < 480;
    final horizontalPadding = isMobile ? (isSmallMobile ? 12.0 : 16.0) : (isTablet ? 32.0 : 50.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
slivers: [
  SliverAppBar(
    pinned: true,
    backgroundColor: const Color(0xFF334155),
    elevation: 0,
    titleSpacing: 0,
    toolbarHeight: isSmallMobile ? 56 : 64,
    title: Padding(
      padding: EdgeInsets.only(left: horizontalPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Icon(
              Icons.smoke_free_outlined,
              color: Colors.white,
              size: isSmallMobile ? 20 : 24,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DESFUMO',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: isSmallMobile ? 20 : 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  color: Colors.white,
                  height: 0.9,
                ),
              ),
              if (!isSmallMobile)
                const Text(
                  'Apoio ao Tabagismo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    height: 0.9,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
   actions: [
  Padding(
    padding: EdgeInsets.only(right: horizontalPadding),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => _showAuthModal(context, initialTab: 0),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            padding: isSmallMobile
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: isSmallMobile ? const Size(40, 35) : null,
            visualDensity: VisualDensity.compact,
          ),
          child: isSmallMobile
              ? const Icon(Icons.login_outlined, size: 20)
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login_outlined, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          onPressed: () => _showAuthModal(context, initialTab: 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8B6A),
            foregroundColor: Colors.white,
            padding: isSmallMobile
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            minimumSize: isSmallMobile ? const Size(40, 32) : null,
            visualDensity: VisualDensity.compact,
          ),
          child: isSmallMobile
              ? const Icon(Icons.person_add_outlined, size: 22)
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_outlined, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
        ),
      ],
    ),
  ),
],
  ),
  SliverToBoxAdapter(
    child: Column(
      children: [
        _buildHeroSection(context),
        _buildSobreSection(context),
        _buildBeneficiosSection(context),
        _buildProgramaInfoSection(context),
        const FooterWidget(),
      ],
    ),
  ),
],
      ),
    );
  }

void _showAuthModal(BuildContext context, {int initialTab = 0}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(isMobile ? (isSmallMobile ? 8 : 12) : 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        width: isMobile ? double.infinity : 500,
        padding: EdgeInsets.all(isMobile ? (isSmallMobile ? 12 : 16) : 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        child: AuthModal(initialTab: initialTab),
      ),
    ),
  ).then((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  });
}

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 919;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallMobile = screenWidth < 480;

    return Container(
      height: isMobile ? (isSmallMobile ? 500 : 550) : 600,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF0A1628),
                  Color(0xFF1A3A5C),
                  Color(0xFF0D2137),
                ],
              ),
            ),
          ),
          Positioned(
            top: -200,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2E8B6A).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1F4E6E).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? (isSmallMobile ? 16 : 24) : (isTablet ? 48 : 80),
              vertical: isMobile ? 16 : 0,
            ),
            child: isMobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.smoke_free,
                              size: isSmallMobile ? 28 : 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DESFUMO',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: isSmallMobile ? 40 : 48,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  height: 0.8,
                                ),
                              ),
                              Text(
                                'Apoio ao Tabagismo',
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 10 : 12,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isSmallMobile
                            ? 'Apoio Profissional para Vencer o Tabagismo'
                            : 'Apoio Profissional para Você Vencer o Tabagismo',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 22 : 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isSmallMobile
                            ? 'Programa com suporte médico, psicológico e grupos de apoio para você parar de fumar.'
                            : 'Programa completo com suporte médico, psicológico e grupos de apoio para você parar de fumar e transformar sua saúde.',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 13 : 15,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontFamily: 'Inter',
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        children: [
                          _buildEstatisticaItem('50+', 'Usuários ativos', const Color.fromARGB(255, 63, 168, 131), isSmallMobile),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildEstatisticaItem('200+', 'Pessoas ajudadas', const Color(0xFFD97706), isSmallMobile),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildEstatisticaItem('150+', 'UPAs parceiras', const Color.fromARGB(255, 117, 165, 197), isSmallMobile),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 12,
                        children: [
                          _buildTrustBadge(Icons.verified, 'Profissional', const Color.fromARGB(255, 63, 168, 131), isSmallMobile),
                          _buildTrustBadge(Icons.favorite, 'Humanizado', const Color(0xFFD97706), isSmallMobile),
                          _buildTrustBadge(Icons.groups, 'Comunitário', const Color.fromARGB(255, 117, 165, 197), isSmallMobile),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.smoke_free,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DESFUMO',
                                      style: TextStyle(
                                        fontFamily: 'BebasNeue',
                                        fontSize: 48,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 2,
                                        color: Colors.white,
                                        height: 0.8,
                                      ),
                                    ),
                                    Text(
                                      'Apoio ao Tabagismo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildEstatisticaItem('50+', 'Usuários ativos', const Color.fromARGB(255, 63, 168, 131), false),
                                const SizedBox(width: 24),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                const SizedBox(width: 24),
                                _buildEstatisticaItem('200+', 'Pessoas ajudadas', const Color(0xFFD97706), false),
                                const SizedBox(width: 24),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                const SizedBox(width: 24),
                                _buildEstatisticaItem('150+', 'UPAs parceiras', const Color.fromARGB(255, 117, 165, 197), false),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          width: 1,
                          height: 320,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Apoio Profissional para\nVocê Vencer o Tabagismo',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Programa completo com suporte médico, psicológico e grupos de apoio para você parar de fumar e transformar sua saúde.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontFamily: 'Inter',
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showAuthModal(context, initialTab: 1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E8B6A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Quero Parar de Fumar',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => _showAuthModal(context, initialTab: 0),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text(
                                    'Já tenho conta',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              spacing: 20,
                              children: [
                                _buildTrustBadge(Icons.verified, 'Profissional', const Color.fromARGB(255, 63, 168, 131), false),
                                _buildTrustBadge(Icons.favorite, 'Humanizado', const Color(0xFFD97706), false),
                                _buildTrustBadge(Icons.groups, 'Comunitário', const Color.fromARGB(255, 117, 165, 197), false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticaItem(String valor, String label, Color cor, bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: isSmall ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: cor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            color: Colors.white60,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String label, Color color, bool isSmall) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isSmall ? 12 : 14, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 11 : 13,
            color: Colors.white60,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSobreSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallMobile = screenWidth < 480;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? (isSmallMobile ? 16 : 24) : (isTablet ? 48 : 80),
        vertical: isMobile ? 40 : 60,
      ),
      color: Colors.white,
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre o Desfumo',
                  style: TextStyle(
                    fontSize: isSmallMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 3,
                  color: const Color(0xFF1F4E6E),
                ),
                const SizedBox(height: 20),
                Text(
                  'O Desfumo é um programa de apoio ao tabagismo que conecta pessoas que desejam parar de fumar a grupos de apoio em Unidades de Pronto Atendimento (UPAs) e UBSs. Oferecemos acompanhamento profissional, material educativo e uma comunidade de apoio.',
                  style: TextStyle(
                    fontSize: isSmallMobile ? 14 : 15,
                    color: const Color(0xFF475569),
                    fontFamily: 'Inter',
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: isSmallMobile ? 150 : 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/MEDICO.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sobre o Desfumo',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 50,
                        height: 3,
                        color: const Color(0xFF1F4E6E),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'O Desfumo é um programa de apoio ao tabagismo que conecta pessoas que desejam parar de fumar a grupos de apoio em Unidades de Pronto Atendimento (UPAs) e UBSs. Oferecemos acompanhamento profissional, material educativo e uma comunidade de apoio.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          _buildSobreItem(
                            Icons.health_and_safety,
                            'Acompanhamento',
                            'Equipe especializada',
                          ),
                          const SizedBox(width: 32),
                          _buildSobreItem(
                            Icons.school,
                            'Material Educativo',
                            'Conteúdo exclusivo',
                          ),
                          const SizedBox(width: 32),
                          _buildSobreItem(
                            Icons.people,
                            'Comunidade',
                            'Apoio mútuo',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 350,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/MEDICO.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSobreItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1F4E6E).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1F4E6E)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }

Widget _buildBeneficiosSection(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 991;
  final isSmallMobile = screenWidth < 480;
  final isTablet = screenWidth >= 768 && screenWidth < 1200;

  final beneficios = [
    {
      'icon': Icons.group,
      'title': 'Apoio em Grupo',
      'desc': 'Compartilhe experiências e desafios com pessoas que estão na mesma jornada. O apoio mútuo fortalece a determinação.',
      'color': const Color(0xFF1F4E6E)
    },
    {
      'icon': Icons.medical_services,
      'title': 'Acompanhamento Profissional',
      'desc': 'Equipe multidisciplinar formada por médicos, psicólogos e enfermeiros especializados em tabagismo.',
      'color': const Color(0xFF2E8B6A)
    },
    {
      'icon': Icons.psychology,
      'title': 'Suporte Psicológico',
      'desc': 'Apoio com técnicas de enfrentamento para lidar com fissuras, ansiedade e mudanças de comportamento.',
      'color': const Color(0xFF6B21A8)
    },
    {
      'icon': Icons.attach_money,
      'title': 'Economia Financeira',
      'desc': 'Pare de fumar e economize milhares de reais por ano. Invista em saúde e bem-estar.',
      'color': const Color(0xFF0F766E)
    },
    {
      'icon': Icons.favorite,
      'title': 'Saúde e Qualidade de Vida',
      'desc': 'Melhore sua capacidade respiratória, reduza o risco de doenças cardíacas e aumente sua expectativa de vida.',
      'color': const Color(0xFFC65D47)
    },
  ];

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? (isSmallMobile ? 16 : 24) : (isTablet ? 48 : 80),
      vertical: isMobile ? 40 : 60,
    ),
    color: const Color(0xFFF8FAFC),
    child: Column(
      children: [
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B6A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Benefícios do Programa',
          style: TextStyle(
            fontSize: isMobile ? (isSmallMobile ? 24 : 28) : 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            fontFamily: 'Poppins',
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Como o Desfumo pode transformar sua vida?',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF475569),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: beneficios.map((b) {
            return SizedBox(
              width: isMobile ? double.infinity : (isTablet ? 280 : 320),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (b['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(b['icon'] as IconData, size: 26, color: b['color'] as Color),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      b['title'] as String,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: b['color'] as Color,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 60,
                      child: Text(
                        b['desc'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

  Widget _buildProgramaInfoSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 919;
    final isSmallMobile = screenWidth < 480;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    final passos = [
      {'numero': '01', 'titulo': 'Cadastro', 'desc': 'Crie sua conta no Desfumo'},
      {'numero': '02', 'titulo': 'Matrícula', 'desc': 'Escolha uma UPA e turma disponível'},
      {'numero': '03', 'titulo': 'Acompanhamento', 'desc': 'Encontros semanais e quinzenais'},
      {'numero': '04', 'titulo': 'Conclusão', 'desc': 'Celebre sua jornada sem cigarro'},
    ];

    final paddingHorizontal = isMobile ? (isSmallMobile ? 16.0 : 24.0) : (isTablet ? 48.0 : 80.0);
    final spacing = isMobile ? 12.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: isMobile ? 40 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2E8B6A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Como Funciona o Programa',
            style: TextStyle(
              fontSize: isMobile ? (isSmallMobile ? 24 : 28) : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quatro passos para uma vida sem cigarro',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 32),
          isMobile
              ? Wrap(
                  spacing: spacing,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: passos.map((p) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - paddingHorizontal * 2 - spacing) / 2,
                      child: _buildPassoItem(p),
                    );
                  }).toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: passos.map((p) {
                    return Expanded(
                      child: _buildPassoItem(p),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildPassoItem(Map<String, String> p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1F4E6E).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              p['numero']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4E6E),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          p['titulo']!,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          p['desc']!,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontFamily: 'Inter',
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}