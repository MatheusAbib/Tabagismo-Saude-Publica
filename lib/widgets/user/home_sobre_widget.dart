
import 'package:flutter/material.dart';

class HomeSobreWidget extends StatefulWidget {
  const HomeSobreWidget({Key? key}) : super(key: key);

  @override
  State<HomeSobreWidget> createState() => _HomeSobreWidgetState();
}

class _HomeSobreWidgetState extends State<HomeSobreWidget> {
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF333333);
  static const Color _secondary = Color(0xFF4E4E4E);
  static const Color _muted = Color(0xFF8A8A85);
  static const Color _border = Color(0xFFE4E0D6);

  static const Color _mintLight = Color(0xFFD9F0E6);
  static const Color _mintDark = Color(0xFF2F7A63);

  static const Color _lavenderLight = Color(0xFFE8E5F4);
  static const Color _lavenderDark = Color(0xFF65568D);

  static const Color _blueLight = Color(0xFFE1EDF6);
  static const Color _blueDark = Color(0xFF426E8C);

  static const Color _terraLight = Color(0xFFF2D9CC);
  static const Color _terraDark = Color(0xFF8F4A2C);

  static const Color _sageLight = Color(0xFFE5EEDC);
  static const Color _sageDark = Color(0xFF54734B);

  int? _expandedProgramItem;

  final List<_GuideItem> _guideItems = const [
    _GuideItem(
      title: 'Turmas de Apoio',
      description:
          'Encontre UPAs próximas, veja vagas disponíveis e faça sua matrícula em turmas de apoio ao tabagismo.',
      icon: Icons.groups_outlined,
      background: _mintLight,
      foreground: _mintDark,
    ),
    _GuideItem(
      title: 'Minhas Matrículas',
      description:
          'Acompanhe suas matrículas, veja o status (em espera, confirmada, cancelada) e gerencie suas inscrições.',
      icon: Icons.assignment_outlined,
      background: _lavenderLight,
      foreground: _lavenderDark,
    ),
    _GuideItem(
      title: 'Teste de Fagerström',
      description:
          'Avalie seu nível de dependência à nicotina com base em 6 perguntas simples.',
      icon: Icons.fact_check_outlined,
      background: _terraLight,
      foreground: _terraDark,
    ),
    _GuideItem(
      title: 'Registrar Sintomas',
      description:
          'Registre diariamente ansiedade, irritabilidade, insônia e outros sintomas em uma escala de 0 a 10.',
      icon: Icons.monitor_heart_outlined,
      background: _blueLight,
      foreground: _blueDark,
    ),
    _GuideItem(
      title: 'Gráfico de Evolução',
      description:
          'Visualize a evolução dos seus sintomas ao longo do tempo.',
      icon: Icons.show_chart_outlined,
      background: _sageLight,
      foreground: _sageDark,
    ),
  ];

  final List<_ProgramItem> _programItems = const [
    _ProgramItem(
      title: 'Matrícula',
      description:
          'Escolha uma UPA e turma disponível. Após a matrícula, você entra na lista de espera. Em até 5 dias úteis, a UPA confirma sua vaga.',
      icon: Icons.how_to_reg_outlined,
      background: _lavenderLight,
      foreground: _lavenderDark,
    ),
    _ProgramItem(
      title: 'Frequência',
      description:
          'Encontros semanais no primeiro mês e quinzenais depois. Cada encontro dura cerca de 2 horas.',
      icon: Icons.calendar_month_outlined,
      background: _blueLight,
      foreground: _blueDark,
    ),
    _ProgramItem(
      title: 'Dinâmica dos Grupos',
      description:
          'Espaço acolhedor com roda de conversa, educação em saúde, técnicas de enfrentamento e atividades práticas.',
      icon: Icons.forum_outlined,
      background: _mintLight,
      foreground: _mintDark,
    ),
    _ProgramItem(
      title: 'Equipe Profissional',
      description:
          'Coordenado por médicos especialistas, psicólogos, enfermeiros e educadores físicos.',
      icon: Icons.medical_services_outlined,
      background: _terraLight,
      foreground: _terraDark,
    ),
    _ProgramItem(
      title: 'Suporte Contínuo',
      description:
          'Mensagens de apoio, material informativo, acompanhamento telefônico e grupo online.',
      icon: Icons.volunteer_activism_outlined,
      background: _sageLight,
      foreground: _sageDark,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isWide = constraints.maxWidth >= 1100;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroduction(isMobile),
            SizedBox(height: isMobile ? 42 : 58),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: _buildGuideSection(false),
                  ),
                  const SizedBox(width: 44),
                  Expanded(
                    flex: 9,
                    child: _buildProgramSection(false),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuideSection(isMobile),
                  SizedBox(height: isMobile ? 48 : 64),
                  _buildProgramSection(isMobile),
                ],
              ),
            SizedBox(height: isMobile ? 42 : 58),
            _buildClosingNote(isMobile),
          ],
        );
      },
    );
  }

  Widget _buildIntroduction(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 23 : 36),
      decoration: BoxDecoration(
        color: _lavenderLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _lavenderDark.withOpacity(0.14),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroIcon(),
                const SizedBox(height: 22),
                _buildIntroText(true),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIntroIcon(),
                const SizedBox(width: 30),
                Expanded(
                  child: _buildIntroText(false),
                ),
              ],
            ),
    );
  }

  Widget _buildIntroIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _lavenderDark.withOpacity(0.12),
        ),
      ),
      child: const Icon(
        Icons.health_and_safety_outlined,
        color: _lavenderDark,
        size: 33,
      ),
    );
  }

  Widget _buildIntroText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACOMPANHAMENTO E ORIENTAÇÃO',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: _lavenderDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Conheça os recursos do Desfumo',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: isMobile ? 27 : 34,
            fontWeight: FontWeight.w400,
            height: 1.15,
            color: _primary,
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'O Desfumo reúne ferramentas de acompanhamento e informações sobre as turmas de apoio ao tabagismo. Veja como utilizar cada recurso e como funciona o programa.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.7,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          eyebrow: 'GUIA DE UTILIZAÇÃO',
          title: 'Como usar o Desfumo',
          description:
              'Conheça as principais ferramentas disponíveis na plataforma.',
          isMobile: isMobile,
          icon: Icons.menu_book_outlined,
          accent: _lavenderDark,
          accentBackground: _lavenderLight,
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: List.generate(
              _guideItems.length,
              (index) => _buildGuideItem(
                index,
                _guideItems[index],
                index == _guideItems.length - 1,
                isMobile,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(
    int index,
    _GuideItem item,
    bool isLast,
    bool isMobile,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 17 : 24,
            vertical: isMobile ? 21 : 25,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isMobile ? 41 : 45,
                height: isMobile ? 41 : 45,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.foreground,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isMobile ? 14 : 15,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: _primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${index + 1}'.padLeft(2, '0'),
                          style: TextStyle(
                            fontFamily: 'DMSerifDisplay',
                            fontSize: 18,
                            color: item.foreground.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        height: 1.65,
                        color: _secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: _border,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildProgramSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          eyebrow: 'TURMAS DE APOIO',
          title: 'Como funciona o programa',
          description:
              'Informações sobre matrícula, encontros e acompanhamento.',
          isMobile: isMobile,
          icon: Icons.groups_outlined,
          accent: _blueDark,
          accentBackground: _blueLight,
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: List.generate(
              _programItems.length,
              (index) => _buildProgramItem(
                index,
                _programItems[index],
                index == _programItems.length - 1,
                isMobile,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 17,
                color: _muted,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Selecione um tópico para consultar os detalhes.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.5,
                    color: _muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgramItem(
    int index,
    _ProgramItem item,
    bool isLast,
    bool isMobile,
  ) {
    final expanded = _expandedProgramItem == index;

    return Column(
      children: [
        Material(
          color: expanded
              ? item.background.withOpacity(0.28)
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(index == 0 ? 18 : 0),
            bottom: Radius.circular(
              isLast && !expanded ? 18 : 0,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedProgramItem = expanded ? null : index;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(index == 0 ? 18 : 0),
              bottom: Radius.circular(
                isLast && !expanded ? 18 : 0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 17 : 22,
                vertical: 19,
              ),
              child: Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(
                      color: item.background,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      item.icon,
                      size: 21,
                      color: item.foreground,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 23,
                      color: expanded
                          ? item.foreground
                          : _secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 17 : 22,
                    0,
                    isMobile ? 17 : 22,
                    22,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: item.background.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.foreground.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        height: 1.7,
                        color: _secondary,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: _border,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildSectionHeading({
    required String eyebrow,
    required String title,
    required String description,
    required bool isMobile,
    required IconData icon,
    required Color accent,
    required Color accentBackground,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: accentBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                eyebrow,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: isMobile ? 28 : 34,
            fontWeight: FontWeight.w400,
            height: 1.15,
            color: _primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 1.7,
            color: _secondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 1,
          width: double.infinity,
          color: accent.withOpacity(0.16),
        ),
      ],
    );
  }

  Widget _buildClosingNote(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _blueDark.withOpacity(0.17),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              size: 23,
              color: _blueDark,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acompanhamento durante o processo',
                  style: TextStyle(
                    fontFamily: 'DMSerifDisplay',
                    fontSize: isMobile ? 23 : 27,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'O programa oferece atividades em grupo, orientações de saúde e acompanhamento profissional para apoiar quem deseja parar de fumar.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.7,
                    color: _secondary,
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

class _GuideItem {
  final String title;
  final String description;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _GuideItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

class _ProgramItem {
  final String title;
  final String description;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _ProgramItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}
