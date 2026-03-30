import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade800,
            Colors.blue.shade700,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo e título
          Row(
            children: [
              Icon(Icons.smoking_rooms, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Tabagismo App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 24),
          
          // Grid principal - 2 colunas
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Sobre o Projeto'),
                            SizedBox(height: 12),
                            _buildSectionText(
                              'O Tabagismo App é uma plataforma dedicada a ajudar pessoas que desejam parar de fumar, conectando-as a unidades de saúde e grupos de apoio especializados.'
                            ),
                            SizedBox(height: 24),
                            _buildSectionTitle('Nossa Missão'),
                            SizedBox(height: 12),
                            _buildSectionText(
                              'Oferecer suporte, informação e acesso a tratamento para pessoas tabagistas, contribuindo para a redução do tabagismo e a promoção da saúde pública.'
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32),
                      Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, 
                        children: [
                          _buildSectionTitleRight('Contato e Suporte'),  
                          SizedBox(height: 12),
                          _buildContactItemRight(Icons.phone, 'Disque Saúde: 136'),
                          SizedBox(height: 8),
                          _buildContactItemRight(Icons.numbers, 'WhatsApp: (11) 99999-9999'),
                          SizedBox(height: 8),
                          _buildContactItemRight(Icons.email, 'E-mail: contato@tabagismoapp.com.br'),
                          SizedBox(height: 8),
                          _buildContactItemRight(Icons.language, 'Site: www.tabagismoapp.com.br'),
                          SizedBox(height: 24),
                          _buildSectionTitleRight('Recursos Úteis'),
                          SizedBox(height: 12),
                          _buildResourceItemRight(Icons.download, 'APP para parar de fumar - Disponível nas lojas'),
                          SizedBox(height: 8),
                          _buildResourceItemRight(Icons.menu_book, 'Material educativo gratuito'),
                          SizedBox(height: 8),
                          _buildResourceItemRight(Icons.group, 'Grupos de apoio online'),
                          SizedBox(height: 8),
                          _buildResourceItemRight(Icons.flag, 'Metas personalizadas'),
                        ],
                      ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Divider(color: Colors.white.withOpacity(0.3)),
                  SizedBox(height: 24),
                  
                  // Benefícios de Parar de Fumar - em grid
            _buildSectionTitle('Benefícios de Parar de Fumar'),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 4,  // Reduzido de 12 para 8
              children: [
                _buildBenefitItem('20 minutos', 'Pressão e pulsação normalizam'),
                _buildBenefitItem('12 horas', 'CO no sangue normaliza'),
                _buildBenefitItem('2-3 meses', 'Circulação e função pulmonar melhoram'),
                _buildBenefitItem('1-9 meses', 'Tosse e falta de ar diminuem'),
                _buildBenefitItem('1 ano', 'Risco cardíaco cai pela metade'),
                _buildBenefitItem('5 anos', 'Risco de derrame igual a não fumante'),
                _buildBenefitItem('10 anos', 'Risco de câncer de pulmão cai 50%'),
                _buildBenefitItem('15 anos', 'Risco cardíaco igual a não fumante'),
              ],
            ),
                  SizedBox(height: 32),
                  Divider(color: Colors.white.withOpacity(0.3)),
                  SizedBox(height: 24),
                  
                  // Informações Legais e Copyright
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Este aplicativo é uma ferramenta de apoio e não substitui o acompanhamento médico profissional. Sempre consulte um profissional de saúde para orientações personalizadas.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2024 Tabagismo App - Todos os direitos reservados',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Versão 1.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 13,
        height: 1.4,
      ),
    );
  }

Widget _buildSectionTitleRight(String title) {
  return Text(
    title,
    textAlign: TextAlign.right,
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _buildContactItemRight(IconData icon, String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 13,
        ),
      ),
      SizedBox(width: 10),
      Icon(icon, color: Colors.white, size: 16),
    ],
  );
}

Widget _buildResourceItemRight(IconData icon, String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Expanded(
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
          ),
        ),
      ),
      SizedBox(width: 10),
      Icon(icon, color: Colors.white, size: 16),
    ],
  );
}



  Widget _buildBenefitItem(String time, String benefit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 14),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                benefit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}