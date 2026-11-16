
import 'package:flutter/material.dart';
import 'package:tabagismo_app/widgets/header/modals/login_cadastro_widget.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/main.dart';
import 'package:tabagismo_app/services/loader_service.dart';

class SobreScreen extends StatefulWidget {
  const SobreScreen({super.key});

  @override
  State<SobreScreen> createState() => _SobreScreenState();
}

class _SobreScreenState extends State<SobreScreen> {
  static const Color _cream = Color(0xFFFAF8F3);
  static const Color _paper = Color(0xFFFCFBF8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _ink = Color(0xFF333333);
  static const Color _body = Color(0xFF4E4E4E);
  static const Color _muted = Color(0xFF8A8A85);
  static const Color _border = Color(0xFFE4E0D6);
  static const Color _mint = Color(0xFFD9F0E6);
  static const Color _mintBorder = Color(0xFFB8E4D2);
  static const Color _green = Color(0xFF2F7A63);
  static const Color _terra = Color(0xFFF2D9CC);
  static const Color _terraDark = Color(0xFF8F4A2C);
  static const Color _lavender = Color(0xFFE8E5F4);
  static const Color _lavenderDark = Color(0xFF65568D);
  static const Color _blue = Color(0xFFE1EDF6);
  static const Color _blueDark = Color(0xFF426E8C);
  static const Color _sage = Color(0xFFE5EEDC);
  static const Color _sageDark = Color(0xFF54734B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      LoaderService.show(context, message: 'Carregando...');
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) LoaderService.hide();
      });
    });
  }

  double _paddingFor(double width) {
    if (width < 600) return 20;
    if (width < 900) return 32;
    if (width < 1200) return 48;
    return 64;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final small = width < 768;
    final padding = _paddingFor(width);

    return Scaffold(
      backgroundColor: _paper,
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
        

SliverAppBar(
  pinned: true,
  elevation: 0,
  scrolledUnderElevation: 0,
  backgroundColor: const Color(0xFFFFFDF9),
  surfaceTintColor: Colors.transparent,
  toolbarHeight: small ? 68 : 88,
  titleSpacing: 0,
  automaticallyImplyLeading: false,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      color: Color(0xFFFFFDF9),
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFDEDCD5),
          width: 1,
        ),
      ),
    ),
  ),
  title: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: small ? 12 : width < 1200 ? 32 : 50,
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(small ? 7 : 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE1EDF6),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Icon(
            Icons.smoke_free_outlined,
            color: const Color(0xFF426E8C),
            size: small ? 23 : 32,
          ),
        ),
        SizedBox(width: small ? 9 : 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DESFUMO',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: small ? 23 : 28,
                fontWeight: FontWeight.w400,
                letterSpacing: small ? 0.7 : 1,
                color: const Color(0xFF333333),
                height: 0.95,
              ),
            ),
            Text(
              'Apoio ao Tabagismo',
              style: TextStyle(
                color: const Color(0xFF667078),
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: small ? 0.7 : 2,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (small)
          TextButton(
            onPressed: () =>
                _showAuthModal(context, initialTab: 0),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF426E8C),
              backgroundColor: const Color(0xFFE1EDF6),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              minimumSize: const Size(0, 38),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Color(0xFFCADDEB),
                ),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Entrar / Cadastrar'),
          )
        else ...[
          TextButton.icon(
            onPressed: () =>
                _showAuthModal(context, initialTab: 0),
            icon: const Icon(
              Icons.login_outlined,
              size: 18,
            ),
            label: const Text('Entrar'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF426E8C),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () =>
                _showAuthModal(context, initialTab: 1),
            icon: const Icon(
              Icons.person_add_alt_1_outlined,
              size: 18,
            ),
            label: const Text('Criar minha conta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF426E8C),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    ),
  ),
),


          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildSobreSection(context),
                _buildBeneficiosSection(context),
                _buildProgramaInfoSection(context),
                _buildFinalSection(context),
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
    final authModal = AuthModal(initialTab: initialTab);

    authModal.tabIndexNotifier.value = initialTab;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: ValueListenableBuilder(
              valueListenable: authModal.tabIndexNotifier,
              builder: (context, tabIndex, child) {
                final isCadastro = tabIndex == 1;

                return Container(
                  width: isMobile ? double.infinity : 500,
                  height: isMobile && isCadastro ? double.infinity : null,
                  margin: isMobile
                      ? (isCadastro
                          ? EdgeInsets.zero
                          : EdgeInsets.all(isSmallMobile ? 8 : 12))
                      : const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxHeight: isMobile && isCadastro
                        ? double.infinity
                        : (isMobile
                            ? MediaQuery.of(context).size.height * 0.95
                            : 880),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: isMobile && isCadastro
                        ? BorderRadius.zero
                        : BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: isMobile
                        ? (isCadastro
                            ? EdgeInsets.zero
                            : EdgeInsets.all(isSmallMobile ? 8 : 12))
                        : const EdgeInsets.all(20),
                    child: authModal,
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    });
  }

  Widget _buildHeroSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 920;
    final small = width < 480;
    final padding = _paddingFor(width);

    final titleSize = small
        ? 42.0
        : mobile
            ? 54.0
            : width < 1200
                ? 58.0
                : 72.0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _eyebrow(
          'PROGRAMA DE APOIO AO TABAGISMO',
          Icons.health_and_safety_outlined,
          _green,
          _white,
          _mintBorder,
        ),
        const SizedBox(height: 30),
        Text(
          'Parar de fumar\npode ser mais fácil\ncom apoio.',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: titleSize,
            height: 1.06,
            letterSpacing: -1.3,
            color: _ink,
          ),
        ),
        const SizedBox(height: 23),
        Container(
          width: 58,
          height: 3,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 23),
         ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 490),
          child: Text(
            'O Desfumo conecta pessoas que querem parar de fumar a grupos de apoio e acompanhamento profissional. Conheça o programa e saiba como participar.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.8,
              color: _body,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionButton(
              'Quero participar',
              Icons.arrow_forward,
              () => _showAuthModal(context, initialTab: 1),
              primary: true,
            ),
            _actionButton(
              'Já tenho conta',
              Icons.login_outlined,
              () => _showAuthModal(context, initialTab: 0),
              primary: false,
            ),
          ],
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _heroFeature(
              Icons.groups_outlined,
              'Grupos de apoio',
              _mint,
              _green,
            ),
            _heroFeature(
              Icons.medical_services_outlined,
              'Equipe profissional',
              _blue,
              _blueDark,
            ),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: _cream),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: const _SobrePatternPainter(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding,
              mobile ? 52 : 92,
              padding,
              mobile ? 66 : 106,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          content,
                          const SizedBox(height: 45),
                          _buildDoctorVisual(true),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: content),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 5,
                            child: _buildDoctorVisual(false),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildDoctorVisual(bool mobile) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (MediaQuery.sizeOf(context).width < 768) {
        return const SizedBox.shrink();
      }

      final width = constraints.maxWidth;
      final height = 570.0;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: width * 0.09,
                right: width * 0.07,
                top: height * 0.07,
                bottom: height * 0.045,
                child: Container(
                  decoration: BoxDecoration(
                    color: _mint,
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: _mintBorder,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(37),
                    child: CustomPaint(
                      painter: const _DoctorBackgroundPainter(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.025,
                left: width * 0.14,
                child: Transform.rotate(
                  angle: -0.13,
                  child: Container(
                    width: width * 0.16,
                    height: width * 0.16,
                    decoration: BoxDecoration(
                      color: _terra,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: const Color(0xFFE8C4B3),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: width * 0.005,
                bottom: height * 0.06,
                child: Transform.rotate(
                  angle: 0.15,
                  child: Container(
                    width: width * 0.18,
                    height: width * 0.18,
                    decoration: BoxDecoration(
                      color: _lavender,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: const Color(0xFFD8D2EB),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: width * 0.10,
                right: width * 0.09,
                top: height * 0.005,
                bottom: height * 0.05,
                child: Image.asset(
                  'assets/images/MEDICO.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Positioned(
                left: 0,
                bottom: height * 0.13,
                child: _doctorInfoCard(
                  Icons.groups_2_outlined,
                  'Grupos de apoio',
                  'Encontros com outras pessoas',
                  _green,
                  _white,
                  mobile,
                ),
              ),
              Positioned(
                right: -20,
                top: height * 0.11,
                child: _doctorInfoCard(
                  Icons.medical_services_outlined,
                  'Orientação profissional',
                  'Apoio durante o tratamento',
                  _lavenderDark,
                  _lavender,
                  mobile,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _doctorInfoCard(
    IconData icon,
    String title,
    String subtitle,
    Color accent,
    Color background,
    bool mobile,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: mobile ? 190 : 230,
      ),
      padding: EdgeInsets.all(mobile ? 11 : 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: background == _white
              ? _border
              : const Color(0xFFD8D2EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: mobile ? 31 : 37,
            height: mobile ? 31 : 37,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: accent,
              size: mobile ? 17 : 20,
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: mobile ? 10 : 12,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: mobile ? 9 : 10,
                    height: 1.35,
                    color: _body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroFeature(
    IconData icon,
    String label,
    Color background,
    Color foreground,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: foreground),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _body,
          ),
        ),
      ],
    );
  }

  Widget _buildSobreSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 900;
    final padding = _paddingFor(width);

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('01', 'CONHEÇA O PROGRAMA', _lavenderDark),
        const SizedBox(height: 19),
        Text(
          'O que é o\nDesfumo?',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: mobile ? 43 : 55,
            height: 1.08,
            color: _ink,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'O Desfumo é um programa de apoio para pessoas que desejam parar de fumar. Ele reúne orientação profissional, atividades em grupo e materiais educativos em um mesmo ambiente.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 1.8,
            color: _body,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pela plataforma, você pode conhecer as turmas disponíveis, realizar sua matrícula e utilizar recursos para acompanhar seu progresso.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 1.8,
            color: _body,
          ),
        ),
      ],
    );

    final details = Column(
      children: [
        _aboutDetail(
          '01',
          Icons.health_and_safety_outlined,
          'Acompanhamento profissional',
          'Orientações e acompanhamento durante o processo de parar de fumar.',
          _mint,
          _green,
        ),
        const SizedBox(height: 12),
        _aboutDetail(
          '02',
          Icons.groups_outlined,
          'Encontros em grupo',
          'Espaço para conversar sobre dificuldades, experiências e estratégias.',
          _lavender,
          _lavenderDark,
        ),
        const SizedBox(height: 12),
        _aboutDetail(
          '03',
          Icons.menu_book_outlined,
          'Materiais de orientação',
          'Conteúdos para consultar e utilizar durante o acompanhamento.',
          _blue,
          _blueDark,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: _white,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: mobile ? 72 : 112,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    intro,
                    const SizedBox(height: 36),
                    details,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: intro),
                    const SizedBox(width: 85),
                    Expanded(flex: 5, child: details),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _aboutDetail(
    String number,
    IconData icon,
    String title,
    String description,
    Color background,
    Color accent,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: accent.withValues(alpha: 0.13),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: _white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 24, color: accent),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.6,
                    color: _body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiosSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 900;
    final padding = _paddingFor(width);


final benefits = [
  _BenefitData(
    'Apoio em grupo',
    'Converse com pessoas que também estão tentando parar de fumar, compartilhe dificuldades e conheça outras estratégias.',
    Icons.groups_outlined,
    _mint,
    _green,
  ),
  _BenefitData(
    'Acompanhamento profissional',
    'Receba orientações de profissionais de saúde durante as etapas do tratamento.',
    Icons.medical_services_outlined,
    _lavender,
    _lavenderDark,
  ),
  _BenefitData(
    'Suporte psicológico',
    'Conheça formas de lidar com a vontade de fumar e com as mudanças de comportamento.',
    Icons.psychology_outlined,
    _blue,
    _blueDark,
  ),
  _BenefitData(
    'Economia financeira',
    'Reduzir ou interromper o consumo de cigarros também pode diminuir seus gastos mensais.',
    Icons.account_balance_wallet_outlined,
    _terra,
    _terraDark,
  ),
  _BenefitData(
    'Saúde e qualidade de vida',
    'Parar de fumar reduz riscos à saúde e traz benefícios que começam após a interrupção do consumo.',
    Icons.favorite_border,
    _sage,
    _sageDark,
  ),
  _BenefitData(
    'Acompanhamento de metas',
    'Registre seus objetivos, acompanhe seu progresso e consulte suas conquistas ao longo do processo.',
    Icons.flag_outlined,
    const Color(0xFFF3E8D9),
    const Color(0xFF956B3E),
  ),
];

    return Container(
      width: double.infinity,
      color: _cream,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: mobile ? 72 : 108,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('02', 'POR QUE PARTICIPAR', _terraDark),
              const SizedBox(height: 18),
              Text(
                'O apoio vai além\ndos encontros.',
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: mobile ? 42 : 54,
                  height: 1.12,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 15),
               ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 650),
                child: Text(
                  'O programa combina diferentes formas de acompanhamento para ajudar você a lidar com os desafios de parar de fumar.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 1.7,
                    color: _body,
                  ),
                ),
              ),
              const SizedBox(height: 38),
              LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth;
                  final columns = available >= 1080
                      ? 3
                      : available >= 650
                          ? 2
                          : 1;
                  final gap = 16.0;
                  final cardWidth =
                      (available - gap * (columns - 1)) / columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (int i = 0; i < benefits.length; i++)
                        SizedBox(
                          width: cardWidth,
                          child: _benefitCard(
                            benefits[i],
                            i,
                            columns == 3 ? 235 : null,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitCard(
    _BenefitData benefit,
    int index,
    double? minHeight,
  ) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: benefit.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: benefit.accent.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _white.withValues(alpha: 0.66),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  benefit.icon,
                  color: benefit.accent,
                  size: 25,
                ),
              ),
              Text(
                '0${index + 1}',
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: 28,
                  color: benefit.accent.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            benefit.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            benefit.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.65,
              color: _body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramaInfoSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 900;
    final padding = _paddingFor(width);

    final steps = [
      _StepData(
        '01',
        'Cadastro',
        'Crie sua conta para acessar a plataforma.',
        Icons.person_add_alt_1_outlined,
        _mint,
        _green,
      ),
      _StepData(
        '02',
        'Matrícula',
        'Consulte as unidades e escolha uma turma disponível.',
        Icons.event_available_outlined,
        _blue,
        _blueDark,
      ),
      _StepData(
        '03',
        'Acompanhamento',
        'Participe dos encontros e acompanhe suas metas.',
        Icons.groups_outlined,
        _lavender,
        _lavenderDark,
      ),
      _StepData(
        '04',
        'Continuidade',
        'Consulte seus registros e continue utilizando os materiais.',
        Icons.trending_up_outlined,
        _terra,
        _terraDark,
      ),
    ];

    return Container(
      width: double.infinity,
      color: _white,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: mobile ? 72 : 110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('03', 'COMO FUNCIONA', _blueDark),
              const SizedBox(height: 19),
              Text(
                'Do cadastro ao\nacompanhamento.',
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: mobile ? 42 : 54,
                  height: 1.12,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
               ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 650),
                child: Text(
                  'Veja as etapas para começar a participar do programa e utilizar os recursos da plataforma.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 1.7,
                    color: _body,
                  ),
                ),
              ),
              const SizedBox(height: 42),
              LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth;
                  final columns = available >= 1050
                      ? 4
                      : available >= 620
                          ? 2
                          : 1;
                  final gap = 16.0;
                  final cardWidth =
                      (available - gap * (columns - 1)) / columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (int i = 0; i < steps.length; i++)
                        SizedBox(
                          width: cardWidth,
                          child: _stepCard(steps[i]),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCard(_StepData step) {
    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step.number,
                style: TextStyle(
                  fontFamily: 'DMSerifDisplay',
                  fontSize: 39,
                  color: step.accent,
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: step.background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  step.icon,
                  size: 23,
                  color: step.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: 34,
            height: 2,
            color: step.accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 18),
          Text(
            step.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            step.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.65,
              color: _body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 800;
    final padding = _paddingFor(width);

    return Container(
      width: double.infinity,
      color: _white,
      padding: EdgeInsets.fromLTRB(
        padding,
        0,
        padding,
        mobile ? 72 : 110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(mobile ? 28 : 58),
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFC8DFEE),
              ),
            ),
            child: mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _finalIcon(),
                      const SizedBox(height: 22),
                      _finalContent(),
                      const SizedBox(height: 26),
                      _actionButton(
                        'Criar minha conta',
                        Icons.arrow_forward,
                        () => _showAuthModal(context, initialTab: 1),
                        primary: true,
                        background: _blueDark,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _finalIcon(),
                      const SizedBox(width: 30),
                      const Expanded(child: _FinalText()),
                      const SizedBox(width: 24),
                      _actionButton(
                        'Criar minha conta',
                        Icons.arrow_forward,
                        () => _showAuthModal(context, initialTab: 1),
                        primary: true,
                        background: _blueDark,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _finalIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: _white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.how_to_reg_outlined,
        size: 35,
        color: _blueDark,
      ),
    );
  }

  Widget _finalContent() {
    return const _FinalText();
  }

  Widget _sectionLabel(
    String number,
    String label,
    Color accent,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number,
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 22,
            color: accent,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 25,
          height: 1,
          color: accent.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _eyebrow(
    String label,
    IconData icon,
    Color foreground,
    Color background,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required bool primary,
    Color background = _green,
  }) {
    final style = TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    if (primary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: _white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: style,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        side: const BorderSide(color: _mintBorder),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: style,
      ),
    );
  }
}

class _FinalText extends StatelessWidget {
  const _FinalText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Quer participar do Desfumo?',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 34,
            height: 1.15,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 530),
          child: Text(
            'Crie sua conta para consultar turmas disponíveis, realizar sua matrícula e acessar os recursos de acompanhamento.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF4E4E4E),
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitData {
  final String title;
  final String description;
  final IconData icon;
  final Color background;
  final Color accent;

  const _BenefitData(
    this.title,
    this.description,
    this.icon,
    this.background,
    this.accent,
  );
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color background;
  final Color accent;

  const _StepData(
    this.number,
    this.title,
    this.description,
    this.icon,
    this.background,
    this.accent,
  );
}

class _SobrePatternPainter extends CustomPainter {
  const _SobrePatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shapes = [
      _PatternSquare(
        0.025,
        0.10,
        95,
        -0.12,
        const Color(0xFFD9F0E6),
      ),
      _PatternSquare(
        0.18,
        0.80,
        68,
        0.17,
        const Color(0xFFF2D9CC),
      ),
      _PatternSquare(
        0.48,
        0.08,
        45,
        -0.08,
        const Color(0xFFE8E5F4),
      ),
      _PatternSquare(
        0.85,
        0.04,
        110,
        0.15,
        const Color(0xFFE1EDF6),
      ),
      _PatternSquare(
        0.94,
        0.72,
        85,
        -0.19,
        const Color(0xFFD9F0E6),
      ),
      _PatternSquare(
        0.57,
        0.90,
        58,
        0.12,
        const Color(0xFFE8E5F4),
      ),
    ];

    for (final shape in shapes) {
      canvas.save();
      canvas.translate(
        size.width * shape.x,
        size.height * shape.y,
      );
      canvas.rotate(shape.rotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: shape.side,
        height: shape.side,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(shape.side * 0.18),
        ),
        Paint()..color = shape.color.withValues(alpha: 0.52),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SobrePatternPainter oldDelegate) {
    return false;
  }
}

class _DoctorBackgroundPainter extends CustomPainter {
  const _DoctorBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.23);

    final mintPaint = Paint()
      ..color = const Color(0xFF8CD4B9).withValues(alpha: 0.25);

    canvas.drawCircle(
      Offset(size.width * 0.57, size.height * 0.42),
      size.width * 0.36,
      whitePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.10),
      size.width * 0.23,
      mintPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.17,
          size.width * 0.18,
          size.width * 0.18,
        ),
        const Radius.circular(20),
      ),
      whitePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.69,
          size.height * 0.72,
          size.width * 0.20,
          size.width * 0.20,
        ),
        const Radius.circular(23),
      ),
      mintPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DoctorBackgroundPainter oldDelegate) {
    return false;
  }
}

class _PatternSquare {
  final double x;
  final double y;
  final double side;
  final double rotation;
  final Color color;

  const _PatternSquare(
    this.x,
    this.y,
    this.side,
    this.rotation,
    this.color,
  );
}
