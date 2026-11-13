import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  static const Color _backgroundColor = Color(0xFFFFFDF9);
  static const Color _titleColor = Color(0xFF333333);
  static const Color _textColor = Color(0xFF667078);
  static const Color _primaryColor = Color(0xFF426E8C);
  static const Color _iconBackgroundColor = Color(0xFFE1EDF6);
  static const Color _dividerColor = Color(0xFFE6E5DF);
  static const Color _topBorderColor = Color(0xFFDEDCD5);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 32.0 : 50.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 48,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 25,
      ),
      decoration: const BoxDecoration(
        color: _backgroundColor,
        border: Border(
          top: BorderSide(
            color: _topBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconBackgroundColor,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.smoke_free_outlined,
                  color: _primaryColor,
                  size: 32,
                ),
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
                      color: _titleColor,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'Apoio ao Tabagismo',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(
            color: _dividerColor,
            thickness: 1,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobileFooter = constraints.maxWidth < 800;

              if (isMobileFooter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAboutSection(),
                    const SizedBox(height: 32),
                    _buildContactSection(),
                    const SizedBox(height: 32),
                    _buildResourcesSection(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildAboutSection(),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 4,
                    child: _buildContactSection(),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 4,
                    child: _buildResourcesSection(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          const Divider(
            color: _dividerColor,
            thickness: 1,
          ),
          const SizedBox(height: 24),
          _buildBenefitsGrid(),
          const SizedBox(height: 32),
          const Divider(
            color: _dividerColor,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 Desfumo - Todos os direitos reservados',
            style: TextStyle(
              color: _textColor,
              fontSize: isMobile ? 9 : 11,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOBRE O PROJETO',
          style: TextStyle(
            color: _titleColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        Text(
          'O Desfumo é uma plataforma dedicada a ajudar pessoas que desejam parar de fumar, conectando-as a unidades de saúde e grupos de apoio especializados.',
          style: TextStyle(
            color: _textColor,
            fontSize: 14,
            height: 1.5,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTATO E SUPORTE',
          style: TextStyle(
            color: _titleColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.phone_outlined,
          'Disque Saúde: 136',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.numbers,
          '(11) 99999-9999',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.email_outlined,
          'contato@desfumo.com',
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _iconBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _textColor,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECURSOS ÚTEIS',
          style: TextStyle(
            color: _titleColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),
        _buildResourceItem(
          Icons.menu_book_outlined,
          'Material educativo gratuito',
        ),
        const SizedBox(height: 12),
        _buildResourceItem(
          Icons.group_outlined,
          'Turmas de apoio',
        ),
        const SizedBox(height: 12),
        _buildResourceItem(
          Icons.flag_outlined,
          'Metas personalizadas',
        ),
      ],
    );
  }

  Widget _buildResourceItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _iconBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _textColor,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsGrid() {
    final List<Map<String, String>> benefits = [
      {
        'time': '20 minutos',
        'benefit': 'Pressão e pulsação normalizam',
      },
      {
        'time': '12 horas',
        'benefit': 'CO no sangue normaliza',
      },
      {
        'time': '2-3 meses',
        'benefit': 'Circulação melhora',
      },
      {
        'time': '1-9 meses',
        'benefit': 'Tosse e falta de ar diminuem',
      },
      {
        'time': '1 ano',
        'benefit': 'Risco cardíaco cai pela metade',
      },
      {
        'time': '5 anos',
        'benefit': 'Risco de derrame igual a não fumante',
      },
      {
        'time': '10 anos',
        'benefit': 'Risco de câncer de pulmão cai 50%',
      },
      {
        'time': '15 anos',
        'benefit': 'Risco cardíaco igual a não fumante',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 500;

        final crossAxisCount = width > 1200
            ? 4
            : width > 700
                ? 3
                : isMobile
                    ? 1
                    : 2;

        final horizontalSpacing = isMobile ? 12.0 : 24.0;
        final verticalSpacing = isMobile ? 16.0 : 20.0;

        final itemWidth =
            (width - horizontalSpacing * (crossAxisCount - 1)) /
                crossAxisCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: _primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'BENEFÍCIOS DE PARAR DE FUMAR',
                    style: TextStyle(
                      color: _titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: horizontalSpacing,
              runSpacing: verticalSpacing,
              children: benefits.map((benefit) {
                return SizedBox(
                  width: itemWidth,
                  child: _buildBenefitItem(
                    benefit['time']!,
                    benefit['benefit']!,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(String time, String benefit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle,
            color: _primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: _titleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                benefit,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}