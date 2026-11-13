
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class HomeMateriaisWidget extends StatefulWidget {
  final bool isLoggedIn;

  const HomeMateriaisWidget({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  State<HomeMateriaisWidget> createState() => _HomeMateriaisWidgetState();
}

class _HomeMateriaisWidgetState extends State<HomeMateriaisWidget> {
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

  String _selectedCategory = 'Todos';
  bool _showAllTips = false;

  final List<Map<String, dynamic>> _materiais = const [
    {
      'title': 'Como parar de fumar: um guia completo',
      'subtitle': 'Por: Dr. Lee Chuen Peng - Médico Pneumologista',
      'image':
          'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400',
      'tag': 'Guia',
      'tagIcon': Icons.menu_book_outlined,
      'url':
          'https://www-mountelizabeth-com-sg.translate.goog/health-plus/article/how-to-quit-smoking?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc',
    },
    {
      'title': 'Alimentação que ajuda a parar',
      'subtitle': 'Por: Dra. Mariana Silva - Nutricionista',
      'image':
          'https://media.todojujuy.com/p/5f84a771b8171b18024059aae54d9e83/adjuntos/227/imagenes/003/260/0003260714/970x546/smart/salud.jpg',
      'tag': 'Guia',
      'tagIcon': Icons.menu_book_outlined,
      'url':
          'https://www.riodasostras.rj.gov.br/wp-content/uploads/2023/08/orientacao-nutricional-tabagismo-pdf.pdf',
    },
    {
      'title': 'Exercícios Respiratórios',
      'subtitle': 'Por: Dra. Anna Luyza',
      'image':
          'https://media.istockphoto.com/id/2029462033/photo/young-asian-woman-with-eyes-closed-and-hands-on-chest-breathing-fresh-air-and-feeling-the.jpg?s=170667a&w=0&k=20&c=lsleyvRsACbx1zvglFC5qNkSpEoYP5jQ3yB72_f-6qw=',
      'tag': 'Vídeo',
      'tagIcon': Icons.play_circle_outline,
      'videoId': 'Ghbhtri8em4',
    },
    {
      'title': 'Grupos de Apoio',
      'subtitle': 'Por: Portal RBV',
      'image':
          'https://thumbs.dreamstime.com/b/reuni%C3%A3o-do-grupo-de-apoio-31168555.jpg',
      'tag': 'Vídeo',
      'tagIcon': Icons.play_circle_outline,
      'videoId': 'GpgUjWvyN-s',
    },
    {
      'title': 'O Impacto do Tabagismo na Saúde Mental',
      'subtitle': 'Por: Busca Clínicas de Recuperação',
      'image':
          'https://images.unsplash.com/photo-1734808324535-a314d2042677?q=80&w=1631&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'tag': 'Website',
      'tagIcon': Icons.language_outlined,
      'url':
          'https://www.buscaclinicasderecuperacao.com.br/blog/tabagismo/o-impacto-do-tabagismo-na-saude-mental-e-bem-estar',
    },
    {
      'title': '6 efeitos do cigarro na sua aparência',
      'subtitle': 'Por: Minhavida Beleza',
      'image':
          'https://lirp.cdn-website.com/26492c66/dms3rep/multi/opt/fumante-1024x683-1920w.jpg',
      'tag': 'Website',
      'tagIcon': Icons.language_outlined,
      'url': 'https://www.minhavida.com.br/materias/materia-9311',
    },
  ];

  final List<Map<String, dynamic>> _tips = const [
    {
      'icon': Icons.directions_walk_outlined,
      'title': 'Distrair',
      'description':
          'Levante, mude de ambiente, beba água ou lave o rosto. A fissura dura apenas alguns minutos.',
      'background': _mintLight,
      'foreground': _mintDark,
    },
    {
      'icon': Icons.block_outlined,
      'title': 'Dizer NÃO',
      'description':
          'Fale para si mesmo: "Eu não fumo mais. Isso vai passar." Isso ativa seu controle racional.',
      'background': _terraLight,
      'foreground': _terraDark,
    },
    {
      'icon': Icons.timer_outlined,
      'title': 'Demorar',
      'description':
          'Espere 10 minutos antes de qualquer decisão. O pico da vontade cai rapidamente.',
      'background': _blueLight,
      'foreground': _blueDark,
    },
    {
      'icon': Icons.air_outlined,
      'title': 'Respirar fundo',
      'description':
          'Puxe o ar por 4s, segure por 4s e solte por 6s. Repita 5 vezes para reduzir a ansiedade.',
      'background': _sageLight,
      'foreground': _sageDark,
    },
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Desabafar',
      'description':
          'Fale com alguém ou escreva o que está sentindo. Isso reduz a pressão emocional da fissura.',
      'background': _lavenderLight,
      'foreground': _lavenderDark,
    },
  ];

  List<Map<String, dynamic>> get _filteredMaterials {
    if (_selectedCategory == 'Todos') return _materiais;

    return _materiais
        .where((material) => material['tag'] == _selectedCategory)
        .toList();
  }

  Color _categoryForeground(String category) {
    switch (category) {
      case 'Guia':
        return _terraDark;
      case 'Vídeo':
        return _blueDark;
      case 'Website':
        return _mintDark;
      default:
        return _lavenderDark;
    }
  }

  Color _categoryBackground(String category) {
    switch (category) {
      case 'Guia':
        return _terraLight;
      case 'Vídeo':
        return _blueLight;
      case 'Website':
        return _mintLight;
      default:
        return _lavenderLight;
    }
  }

  void _openMaterial(Map<String, dynamic> material) {
    if (!widget.isLoggedIn) {
      ToastService.showWarning(
        context,
        'Faça login para acessar este conteúdo',
      );
      return;
    }

    if (material.containsKey('videoId')) {
      final videoId = material['videoId'] as String;

      html.window.open(
        'https://www.youtube.com/watch?v=$videoId',
        '_blank',
      );
      return;
    }

    if (material.containsKey('url')) {
      html.window.open(
        material['url'] as String,
        '_blank',
      );
      return;
    }

    ToastService.showWarning(
      context,
      'Em desenvolvimento: ${material['title']}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedTip(isMobile),
            SizedBox(height: isMobile ? 44 : 56),
            _buildLibraryHeading(isMobile),
            const SizedBox(height: 25),
            _buildCategoryFilters(),
            const SizedBox(height: 22),
            _buildMaterialsList(),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedTip(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _lavenderLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _lavenderDark.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 22 : 32),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTipIntroduction(true),
                      const SizedBox(height: 23),
                      _buildTipToggle(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildTipIntroduction(false)),
                      const SizedBox(width: 20),
                      _buildTipToggle(),
                    ],
                  ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _showAllTips
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: _lavenderDark.withOpacity(0.15),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 18 : 28),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columns =
                                constraints.maxWidth >= 760 ? 2 : 1;
                            final spacing = 16.0;
                            final itemWidth =
                                (constraints.maxWidth -
                                    spacing * (columns - 1)) /
                                columns;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: _tips.asMap().entries.map((entry) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: _buildTipItem(
                                    entry.key + 1,
                                    entry.value,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 18 : 28,
                          0,
                          isMobile ? 18 : 28,
                          isMobile ? 18 : 28,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: _surface.withOpacity(0.78),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _lavenderDark.withOpacity(0.12),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 21,
                                color: _lavenderDark,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'A vontade de fumar pode diminuir após alguns minutos. Experimente uma das estratégias acima durante esse período.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                    color: _secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipIntroduction(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 20,
                color: _lavenderDark,
              ),
            ),
            const SizedBox(width: 11),
            Flexible(
              child: Text(
                'ESTRATÉGIA DE ENFRENTAMENTO',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: _lavenderDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          "Técnica dos 5 D's",
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: isMobile ? 30 : 37,
            height: 1.15,
            color: _primary,
          ),
        ),
        const SizedBox(height: 11),
        const Text(
          'Cinco atitudes que você pode experimentar quando sentir vontade de fumar.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.65,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTipToggle() {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _showAllTips = !_showAllTips;
        });
      },
      icon: Icon(
        _showAllTips
            ? Icons.keyboard_arrow_up
            : Icons.keyboard_arrow_down,
        size: 20,
      ),
      label: Text(
        _showAllTips ? 'Recolher orientações' : "Conhecer os 5 D's",
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _lavenderDark,
        backgroundColor: _surface,
        side: BorderSide(
          color: _lavenderDark.withOpacity(0.2),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 17,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  Widget _buildTipItem(
    int number,
    Map<String, dynamic> tip,
  ) {
    final background = tip['background'] as Color;
    final foreground = tip['foreground'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.88),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: foreground.withOpacity(0.13),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tip['icon'] as IconData,
              size: 22,
              color: foreground,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tip['title'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$number'.padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'DMSerifDisplay',
                        fontSize: 20,
                        color: foreground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tip['description'] as String,
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
    );
  }

  Widget _buildLibraryHeading(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 19,
                color: _blueDark,
              ),
              SizedBox(width: 10),
              Text(
                'BIBLIOTECA DE CONTEÚDOS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _blueDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Explore os materiais',
            style: TextStyle(
              fontFamily: 'DMSerifDisplay',
              fontSize: isMobile ? 29 : 35,
              height: 1.15,
              color: _primary,
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            'Selecione um formato para encontrar o conteúdo que procura.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: _secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    const categories = ['Todos', 'Guia', 'Vídeo', 'Website'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = _selectedCategory == category;
          final accent = _categoryForeground(category);
          final background = _categoryBackground(category);

          final label = category == 'Todos'
              ? 'Todos os materiais'
              : category == 'Website'
                  ? 'Sites'
                  : category == 'Guia'
                      ? 'Guias'
                      : 'Vídeos';

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: background,
              backgroundColor: _surface,
              side: BorderSide(
                color: selected
                    ? accent.withOpacity(0.3)
                    : _border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : _secondary,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaterialsList() {
    final materials = _filteredMaterials;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050 ? 2 : 1;
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        if (columns == 1) {
          return Column(
            children: [
              for (var index = 0; index < materials.length; index++) ...[
                _buildMaterialItem(
                  materials[index],
                  constraints.maxWidth < 580,
                ),
                if (index != materials.length - 1)
                  const SizedBox(height: spacing),
              ],
            ],
          );
        }

        final rows = <Widget>[];

        for (var index = 0; index < materials.length; index += 2) {
          final first = materials[index];
          final second =
              index + 1 < materials.length ? materials[index + 1] : null;

          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _buildMaterialItem(first, false),
                  ),
                  const SizedBox(width: spacing),
                  SizedBox(
                    width: itemWidth,
                    child: second != null
                        ? _buildMaterialItem(second, false)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              rows[index],
              if (index != rows.length - 1)
                const SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMaterialItem(
    Map<String, dynamic> material,
    bool isMobile,
  ) {
    final category = material['tag'] as String;
    final accent = _categoryForeground(category);
    final accentBackground = _categoryBackground(category);

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openMaterial(material),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isMobile
              ? _buildMobileMaterial(
                  material,
                  accent,
                  accentBackground,
                )
              : _buildDesktopMaterial(
                  material,
                  accent,
                  accentBackground,
                ),
        ),
      ),
    );
  }

  Widget _buildDesktopMaterial(
    Map<String, dynamic> material,
    Color accent,
    Color accentBackground,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildMaterialImage(material, 124, 124),
        const SizedBox(width: 20),
        Expanded(
          child: _buildMaterialInformation(
            material,
            accent,
            accentBackground,
            false,
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          widget.isLoggedIn
              ? Icons.arrow_outward
              : Icons.lock_outline,
          size: 19,
          color: accent,
        ),
      ],
    );
  }

  Widget _buildMobileMaterial(
    Map<String, dynamic> material,
    Color accent,
    Color accentBackground,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialImage(material, 86, 100),
        const SizedBox(width: 13),
        Expanded(
          child: _buildMaterialInformation(
            material,
            accent,
            accentBackground,
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialImage(
    Map<String, dynamic> material,
    double width,
    double height,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        material['image'] as String,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: _lavenderLight,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: _lavenderDark,
              size: 28,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialInformation(
    Map<String, dynamic> material,
    Color accent,
    Color accentBackground,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: accentBackground,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                material['tagIcon'] as IconData,
                size: 13,
                color: accent,
              ),
              const SizedBox(width: 5),
              Text(
                material['tag'] as String,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        Text(
          material['title'] as String,
          maxLines: isMobile ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isMobile ? 13 : 15,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: _primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          material['subtitle'] as String,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            height: 1.45,
            color: _muted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isLoggedIn
                  ? Icons.open_in_new
                  : Icons.lock_outline,
              size: 14,
              color: accent,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                widget.isLoggedIn
                    ? 'Acessar conteúdo'
                    : 'Entrar para acessar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
