import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = Color(0xFF0F2B3D);
    final Color primaryMedium = Color(0xFF1A4A6F);
    final Color accentColor = Color(0xFF2C7DA0);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
      top: 48,
      left: 50,
      right: 50,
      bottom: 25,
    ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryDark,
            primaryMedium,
            Color(0xFF0A1E2C),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Icon(Icons.smoking_rooms_outlined, color: Colors.white, size: 32),
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desfumo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'O lugar onde o fumo deixa de existir',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          SizedBox(height: 32),
          
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;
              
              if (isMobile) {
                return Column(
                  children: [
                    _buildAboutSection(),
                    SizedBox(height: 32),
                    _buildContactSection(),
                    SizedBox(height: 32),
                    _buildResourcesSection(),
                  ],
                );
              }
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildAboutSection()),
                  SizedBox(width: 48),
                  Expanded(flex: 4, child: _buildContactSection()),
                  SizedBox(width: 48),
                  Expanded(flex: 4, child: _buildResourcesSection()),
                ],
              );
            },
          ),
          
          SizedBox(height: 40),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          SizedBox(height: 24),
          
          _buildBenefitsGrid(),
          
          SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),

          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Desfumo - Todos os direitos reservados',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              ),
              Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFFEF4444), size: 12),
                  SizedBox(width: 6),
                  Text(
                    'Versão 2.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
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
        Text(
          'SOBRE O PROJETO',
          style: TextStyle(
            color: Colors.white,
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
        Text(
          'CONTATO E SUPORTE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        _buildContactItem(Icons.phone_outlined, 'Disque Saúde: 136'),
        SizedBox(height: 12),
        _buildContactItem(Icons.numbers, 'WhatsApp: (11) 99999-9999'),
        SizedBox(height: 12),
        _buildContactItem(Icons.email_outlined, 'contato@tabagismoapp.com.br'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xFF2C7DA0).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF2C7DA0), size: 16),
        ),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
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
        Text(
          'RECURSOS ÚTEIS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        _buildResourceItem(Icons.menu_book_outlined, 'Material educativo gratuito'),
        SizedBox(height: 12),
        _buildResourceItem(Icons.group_outlined, 'Grupos de apoio online'),
        SizedBox(height: 12),
        _buildResourceItem(Icons.flag_outlined, 'Metas personalizadas'),
        SizedBox(height: 12),
        _buildResourceItem(Icons.psychology_outlined, 'Técnicas de relaxamento'),
      ],
    );
  }

  Widget _buildResourceItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xFF2C7DA0).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF2C7DA0), size: 16),
        ),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
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
      {'time': '2-3 meses', 'benefit': 'Circulação e função pulmonar melhoram'},
      {'time': '1-9 meses', 'benefit': 'Tosse e falta de ar diminuem'},
      {'time': '1 ano', 'benefit': 'Risco cardíaco cai pela metade'},
      {'time': '5 anos', 'benefit': 'Risco de derrame igual a não fumante'},
      {'time': '10 anos', 'benefit': 'Risco de câncer de pulmão cai 50%'},
      {'time': '15 anos', 'benefit': 'Risco cardíaco igual a não fumante'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF2C7DA0), size: 20),
            SizedBox(width: 8),
            Text(
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
        SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 20,
                childAspectRatio: 6,
              ),
              itemCount: benefits.length,
              itemBuilder: (context, index) {
                return _buildBenefitItem(benefits[index]['time']!, benefits[index]['benefit']!);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String time, String benefit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 4),
              Text(
                benefit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
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