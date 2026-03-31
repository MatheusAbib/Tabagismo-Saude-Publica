import 'package:flutter/material.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _userData;
  int _currentBannerIndex = 0;
  
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Você não está sozinho',
      'subtitle': 'Milhares de pessoas já pararam de fumar com nossa ajuda',
      'icon': Icons.people_outline,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Grupo-Apoio.png',
    },
    {
      'title': 'Benefícios imediatos',
      'subtitle': 'Após 20 minutos, sua pressão e pulsação voltam ao normal',
      'icon': Icons.favorite_outline,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Beneficios-Imediatos.png',
    },
    {
      'title': 'Economize dinheiro',
      'subtitle': 'Em 1 ano você economiza mais de R7.000',
      'icon': Icons.attach_money_outlined,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Economize.png',
    },
    {
      'title': 'Viva mais e melhor',
      'subtitle': 'Aumente sua expectativa de vida em até 10 anos',
      'icon': Icons.self_improvement_outlined,
      'color': Color(0xFF0F172A),
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
      'image': '/assets/images/Viva-Mais.png',
    },
  ];

  final List<Map<String, dynamic>> _materiais = [
    {
      'title': 'Guia Completo para Parar de Fumar',
      'subtitle': "Por: Ronaldo Laranjeira",
      'description': 'Artigo científico para ser estudado ',
      'icon': Icons.auto_awesome,
      'color': Color(0xFFEF4444),
      'image': 'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400',
      'tag': 'Guia',
    },
    {
      'title': 'Benefícios da Parada',
      'subtitle': "Por: Alessandra Conceição; Paola Paiva; Gustavo Martins",
      'description': 'Saiba como sua saúde melhora a cada dia sem cigarro',
      'icon': Icons.favorite,
      'color': Color(0xFFEF4444),
      'image': 'https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg?w=400',
      'tag': 'Guia',
    },
    {
      'title': 'Exercícios Respiratórios',
      'description': 'Controle a ansiedade e a vontade de fumar',
      'icon': Icons.self_improvement,
      'color': Color(0xFF10B981),
      'image': 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=400',
      'tag': 'Prático',
    },
    {
      'title': 'Grupos de Apoio',
      'description': 'Encontre pessoas que estão na mesma jornada',
      'icon': Icons.group,
      'color': Color(0xFF8B5CF6),
      'image': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
      'tag': 'Comunidade',
    },
     {
      'title': 'Grupos de Apoio',
      'description': 'Encontre pessoas que estão na mesma jornada',
      'icon': Icons.group,
      'color': Color(0xFF8B5CF6),
      'image': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
      'tag': 'Comunidade',
    },
     {
      'title': 'Grupos de Apoio',
      'description': 'Encontre pessoas que estão na mesma jornada',
      'icon': Icons.group,
      'color': Color(0xFF8B5CF6),
      'image': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
      'tag': 'Comunidade',
    },
  ];

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _startAutoCarousel();
  }

  void _startAutoCarousel() {
    Future.delayed(Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        });
        _startAutoCarousel();
      }
    });
  }

  void _updateUserName(String newName) {
    setState(() {
      _userData['nomeCompleto'] = newName;
    });
  }

    void _openPDF(String pdfFileName) {
      html.window.open('/assets/pdf/$pdfFileName', '_blank');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF8FAFC),
        child: Column(
          children: [
            HeaderWidget(
              userName: _userData['nomeCompleto'],
              userData: _userData,
              onNameUpdated: _updateUserName,
              showBackButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroBanner(),
                    Padding(
                      padding: EdgeInsets.only(left: 50, right: 50),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildSidebarContent(),
                          ),
                          SizedBox(width: 32),
                          Expanded(
                            flex: 8,
                            child: _buildMaterialsGrid(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48),
                    FooterWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    final banner = _banners[_currentBannerIndex];
    return Container(
      height: 800,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 32),
      child: Stack(
        children: [
          Image.network(
            banner['image'],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 50,
            right: 50,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner['title'],
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    banner['subtitle'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: List.generate(_banners.length, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 8),
                        width: _currentBannerIndex == index ? 32 : 8,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: _currentBannerIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        _buildTipCard(),
        SizedBox(height: 24),
        _buildStatsCard(),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 22),
                SizedBox(width: 12),
                Text(
                  'Dica do Dia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.psychology_outlined, color: Color(0xFFF59E0B), size: 32),
                ),
                SizedBox(height: 20),
                Text(
                  'Técnica dos 5 D\'s',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Distraia • Diga não • Dance • Durma • Desabafe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.show_chart_outlined, color: Color(0xFF3B82F6), size: 22),
                SizedBox(width: 12),
                Text(
                  'Benefícios em Números',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                _buildStatItem('20 min', 'Pressão e pulsação normalizam', Icons.favorite_outline, Color(0xFFEF4444)),
                SizedBox(height: 20),
                _buildStatItem('12 horas', 'Monóxido de carbono no sangue normaliza', Icons.air_outlined, Color(0xFF3B82F6)),
                SizedBox(height: 20),
                _buildStatItem('1 ano', 'Risco de doença cardíaca cai 50%', Icons.health_and_safety_outlined, Color(0xFF10B981)),
                SizedBox(height: 20),
                _buildStatItem('10 anos', 'Risco de câncer de pulmão reduz 50%', Icons.coronavirus_outlined, Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Materiais de Apoio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Veja os Materiais',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.9,
          ),
          itemCount: _materiais.length,
          itemBuilder: (context, index) {
            return _buildMaterialCard(_materiais[index]);
          },
        ),
      ],
    );
  }

Widget _buildMaterialCard(Map<String, dynamic> material) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                material['image'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: material['color'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  material['tag'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (material.containsKey('subtitle')) ...[
                SizedBox(height: 4),
                Text(
                  material['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3B82F6),
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8),
              Text(
                material['description'],
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
              onPressed: () {
                if (material['title'] == 'Guia Completo para Parar de Fumar') {
                  _openPDF('GuiaPratico.pdf');
                } else if (material['title'] == 'Benefícios da Parada') {
                  _openPDF('Beneficios.pdf');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Em desenvolvimento: ${material['title']}')),
                  );
                }
              },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: material['color']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Acessar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: material['color'],
                    ),
                  ),
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