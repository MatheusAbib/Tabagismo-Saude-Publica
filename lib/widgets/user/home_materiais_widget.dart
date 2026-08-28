import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:tabagismo_app/services/toast_service.dart';

class HomeMateriaisWidget extends StatelessWidget {
  final bool isLoggedIn;

  const HomeMateriaisWidget({Key? key, required this.isLoggedIn}) : super(key: key);

  final List<Map<String, dynamic>> _materiais = const [
    {
      'title': 'Guia Completo para Parar de Fumar',
      'subtitle': "Por: Ronaldo Laranjeira",
      'icon': Icons.auto_awesome,
      'color': Color(0xFFC65D47),
      'image': 'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400',
      'tag': 'Guia',
      'tagIcon': Icons.menu_book,
    },
    {
      'title': 'Alimentação que ajuda a parar',
      'subtitle': "Por: Nutricionista Dra. Mariana Silva",
      'icon': Icons.restaurant,
      'color': Color(0xFFC65D47),
      'image': 'https://media.todojujuy.com/p/5f84a771b8171b18024059aae54d9e83/adjuntos/227/imagenes/003/260/0003260714/970x546/smart/salud.jpg',
      'tag': 'Guia',
      'tagIcon': Icons.menu_book,
      'url': 'https://www.riodasostras.rj.gov.br/wp-content/uploads/2023/08/orientacao-nutricional-tabagismo-pdf.pdf',
    },
    {
      'title': 'Exercícios Respiratórios',
      'subtitle': "Por: Dra. Anna Luyza",
      'icon': Icons.self_improvement,
      'color': Color(0xFF2E8B6A),
      'image': 'https://media.istockphoto.com/id/2029462033/photo/young-asian-woman-with-eyes-closed-and-hands-on-chest-breathing-fresh-air-and-feeling-the.jpg?s=170667a&w=0&k=20&c=lsleyvRsACbx1zvglFC5qNkSpEoYP5jQ3yB72_f-6qw=',
      'tag': 'Vídeo',
      'tagIcon': Icons.play_circle_outline,
      'videoId': 'Ghbhtri8em4',
    },
    {
      'title': 'Grupos de Apoio',
      'subtitle': "Por: Portal RBV",
      'icon': Icons.group,
      'color': Color(0xFF2E8B6A),
      'image': 'https://thumbs.dreamstime.com/b/reuni%C3%A3o-do-grupo-de-apoio-31168555.jpg',
      'tag': 'Vídeo',
      'tagIcon': Icons.play_circle_outline,
      'videoId': 'GpgUjWvyN-s',
    },
    {
      'title': 'O Impacto do Tabagismo na Saúde Mental',
      'subtitle': "Por: Busca Clínicas de Recuperação",
      'icon': Icons.psychology,
      'color': Color(0xFF6B21A8),
      'image': 'https://images.unsplash.com/photo-1734808324535-a314d2042677?q=80&w=1631&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'tag': 'Website',
      'tagIcon': Icons.language,
      'url': 'https://www.buscaclinicasderecuperacao.com.br/blog/tabagismo/o-impacto-do-tabagismo-na-saude-mental-e-bem-estar',
    },
    {
      'title': '6 efeitos do cigarro na sua aparência',
      'subtitle': "Por: Minhavida Beleza",
      'icon': Icons.face,
      'color': Color(0xFF6B21A8),
      'image': 'https://lirp.cdn-website.com/26492c66/dms3rep/multi/opt/fumante-1024x683-1920w.jpg',
      'tag': 'Website',
      'tagIcon': Icons.language,
      'url': 'https://www.minhavida.com.br/materias/materia-9311',
    },
  ];

  void _openPDF(String pdfFileName) {
    html.window.open('/assets/pdf/$pdfFileName', '_blank');
  }

  void _openYouTubeVideo(String videoId) {
    html.window.open('https://www.youtube.com/watch?v=$videoId', '_blank');
  }

  void _openWebsite(String url) {
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1100;

    if (isMobile) {
      return _buildMateriaisGrid(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _buildTipCard(context),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 8,
          child: _buildMateriaisGrid(context),
        ),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, size: 28, color: Color(0xFF1F4E6E)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Técnica dos 5 D\'s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTipItem(
                  context,
                  Icons.directions_walk,
                  'Distrair',
                  'Levante, mude de ambiente, beba água ou lave o rosto. A fissura dura apenas alguns minutos.',
                  const Color(0xFF1F4E6E),
                ),
                const SizedBox(height: 24),
                _buildTipItem(
                  context,
                  Icons.block,
                  'Dizer NÃO',
                  'Fale para si mesmo: "Eu não fumo mais. Isso vai passar." Isso ativa seu controle racional.',
                  const Color(0xFFC65D47),
                ),
                const SizedBox(height: 24),
                _buildTipItem(
                  context,
                  Icons.timer,
                  'Demorar',
                  'Espere 10 minutos antes de qualquer decisão. O pico da vontade cai rapidamente.',
                  const Color(0xFFD97706),
                ),
                const SizedBox(height: 24),
                _buildTipItem(
                  context,
                  Icons.air,
                  'Respirar fundo',
                  'Puxe o ar por 4s, segure por 4s e solte por 6s. Repita 5 vezes para reduzir a ansiedade.',
                  const Color(0xFF2E8B6A),
                ),
                const SizedBox(height: 24),
                _buildTipItem(
                  context,
                  Icons.chat_bubble_outline,
                  'Desabafar',
                  'Fale com alguém ou escreva o que está sentindo. Isso reduz a pressão emocional da fissura.',
                  const Color(0xFF6B21A8),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 20, color: Color(0xFFD97706)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A vontade passa mesmo que você não fume. Aguente alguns minutos.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Inter',
                          ),
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
    );
  }

  Widget _buildTipItem(BuildContext context, IconData icon, String title, String description, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: isMobile ? 20 : 28, color: color),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: const Color(0xFF475569),
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMateriaisGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 720,
        crossAxisSpacing: isMobile ? 16.0 : 24.0,
        mainAxisSpacing: isMobile ? 20.0 : 24.0,
        mainAxisExtent: 320,
      ),
      itemCount: _materiais.length,
      itemBuilder: (context, index) {
        return _buildMaterialCard(context, _materiais[index]);
      },
    );
  }

  Widget _buildMaterialCard(BuildContext context, Map<String, dynamic> material) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  material['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: material['color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(material['tagIcon'], size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        material['tag'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  material['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (material.containsKey('subtitle')) ...[
                  const SizedBox(height: 4),
                  Text(
                    material['subtitle'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F4E6E),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    if (!isLoggedIn) {
                      ToastService.showWarning(context, 'Faça login para acessar este conteúdo');
                      return;
                    }

                    if (material['title'] == 'Guia Completo para Parar de Fumar') {
                      _openPDF('GuiaPratico.pdf');
                    } else if (material.containsKey('videoId')) {
                      _openYouTubeVideo(material['videoId']);
                    } else if (material.containsKey('url')) {
                      _openWebsite(material['url']);
                    } else {
                      ToastService.showWarning(context, 'Em desenvolvimento: ${material['title']}');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: material['color']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(double.infinity, 40),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}