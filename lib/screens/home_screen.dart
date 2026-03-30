import 'package:flutter/material.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
  }

  void _updateUserName(String newName) {
    setState(() {
      _userData['nomeCompleto'] = newName;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
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
                // Conteúdo existente
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bem-vindo, ${_userData['nomeCompleto']}!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Estamos aqui para ajudar você a parar de fumar.',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Materiais de Ajuda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildMaterialCard(
                        'Dicas para parar de fumar',
                        'Conheça estratégias eficazes para abandonar o cigarro.',
                        Icons.lightbulb_outline,
                        Colors.orange,
                      ),
                      _buildMaterialCard(
                        'Benefícios de parar de fumar',
                        'Saiba como sua saúde melhora após parar de fumar.',
                        Icons.favorite,
                        Colors.red,
                      ),
                      _buildMaterialCard(
                        'Exercícios respiratórios',
                        'Técnicas para controlar a ansiedade e vontade de fumar.',
                        Icons.self_improvement,
                        Colors.green,
                      ),
                      _buildMaterialCard(
                        'Grupos de apoio',
                        'Encontre grupos de apoio próximos a você.',
                        Icons.group,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
                // Footer
                FooterWidget(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMaterialCard(String title, String description, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Em desenvolvimento: $title')),
          );
        },
      ),
    );
  }
}