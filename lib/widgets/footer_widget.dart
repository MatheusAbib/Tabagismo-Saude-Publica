import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 32.0 : 50.0);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 48,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 25,
      ),
      decoration: BoxDecoration(
      color: const Color(0xFF334155),  
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       Row(
  children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(35),
      ),
      child: const Icon(
        Icons.smoke_free_outlined,
        color: Colors.white,
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
        letterSpacing: 2,
      ),
    ),
  ],
),
  ],
),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 32),
          
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobileFooter = constraints.maxWidth < 800;
              
              if (isMobileFooter) {
                return Column(
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
                  Expanded(flex: 5, child: _buildAboutSection()),
                  const SizedBox(width: 48),
                  Expanded(flex: 4, child: _buildContactSection()),
                  const SizedBox(width: 48),
                  Expanded(flex: 4, child: _buildResourcesSection()),
                ],
              );
            },
          ),
          
          const SizedBox(height: 40),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 24),
          
          _buildBenefitsGrid(),
          
          const SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Desfumo - Todos os direitos reservados',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isMobile ? 9 : 11,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SOBRE O PROJETO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'O Desfumo é uma plataforma dedicada a ajudar pessoas que desejam parar de fumar, conectando-as a unidades de saúde e grupos de apoio especializados.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
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
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Icons.phone_outlined, 'Disque Saúde: 136'),
        const SizedBox(height: 12),
        _buildContactItem(Icons.numbers, '(11) 99999-9999'),
        const SizedBox(height: 12),
        _buildContactItem(Icons.email_outlined, 'contato@desfumo.com'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C7DA0).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'Inter',
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
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 12),
        _buildResourceItem(Icons.menu_book_outlined, 'Material educativo gratuito'),
        const SizedBox(height: 12),
        _buildResourceItem(Icons.group_outlined, 'Turmas de apoio'),
        const SizedBox(height: 12),
        _buildResourceItem(Icons.flag_outlined, 'Metas personalizadas'),
      ],
    );
  }

  Widget _buildResourceItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C7DA0).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsGrid() {
    final List<Map<String, String>> benefits = [
      {'time': '20 minutos', 'benefit': 'Pressão e pulsação normalizam'},
      {'time': '12 horas', 'benefit': 'CO no sangue normaliza'},
      {'time': '2-3 meses', 'benefit': 'Circulação melhora'},
      {'time': '1-9 meses', 'benefit': 'Tosse e falta de ar diminuem'},
      {'time': '1 ano', 'benefit': 'Risco cardíaco cai pela metade'},
      {'time': '5 anos', 'benefit': 'Risco de derrame igual a não fumante'},
      {'time': '10 anos', 'benefit': 'Risco de câncer de pulmão cai 50%'},
      {'time': '15 anos', 'benefit': 'Risco cardíaco igual a não fumante'},
    ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 700 ? 3 : (isMobile ? 1 : 2));
        final childAspectRatio = isMobile ? 8.0 : 6.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'BENEFÍCIOS DE PARAR DE FUMAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isMobile ? 12 : 24,
                mainAxisSpacing: isMobile ? 16 : 20,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: benefits.length,
              itemBuilder: (context, index) {
                return _buildBenefitItem(
                  context,
                  benefits[index]['time']!,
                  benefits[index]['benefit']!,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(BuildContext context, String time, String benefit) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: const Icon(Icons.check_circle, color: Color(0xFF2E8B6A), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                benefit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isMobile ? 11 : 12,
                  fontFamily: 'Inter',
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}