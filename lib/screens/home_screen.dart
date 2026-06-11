import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'dart:html' as html;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _userData;
  int _currentBannerIndex = 0;
  bool _isLoggedIn = false;
  int _selectedTab = 0;
  bool _isTipCardExpanded = true;
  bool _isGuiaCardExpanded = true;
  int? _scoreFagerstrom;

 final GlobalKey<HeaderWidgetState> _headerKey = GlobalKey<HeaderWidgetState>();

  void _showGoalModal() {
    DateTime? existingStopDate;
    int? existingTargetDays;
    int? existingCigarrosPorDia;
    double? existingValorCarteira;
    
    if (_userData.containsKey('stopDate') && _userData['stopDate'] != null) {
      final stopDateStr = _userData['stopDate'].toString();
      if (stopDateStr.isNotEmpty && stopDateStr != 'null') {
        try {
          existingStopDate = DateTime.parse(stopDateStr);
        } catch (e) {
          final parts = stopDateStr.split('-');
          if (parts.length == 3) {
            existingStopDate = DateTime(
              int.parse(parts[0]), 
              int.parse(parts[1]), 
              int.parse(parts[2])
            );
          }
        }
      }
    }
    if (_userData.containsKey('targetDays') && _userData['targetDays'] != null) {
      existingTargetDays = _userData['targetDays'];
    }
    if (_userData.containsKey('cigarrosPorDia') && _userData['cigarrosPorDia'] != null) {
      existingCigarrosPorDia = _userData['cigarrosPorDia'];
    }
    if (_userData.containsKey('valorCarteira') && _userData['valorCarteira'] != null) {
      existingValorCarteira = _userData['valorCarteira'];
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            TextEditingController dataController = TextEditingController(
              text: existingStopDate != null ? _formatDate(existingStopDate) : ''
            );
            TextEditingController metaController = TextEditingController(text: existingTargetDays?.toString() ?? '');
            TextEditingController cigarrosController = TextEditingController(text: existingCigarrosPorDia?.toString() ?? '');
            TextEditingController valorController = TextEditingController(text: existingValorCarteira?.toStringAsFixed(2).replaceAll('.', ',') ?? '');
            
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height > 800 ? 700 : MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.celebration_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Definir Meta',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Registre quando parou de fumar e defina sua meta',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildGoalModalContent(
                                dataController,
                                metaController,
                                cigarrosController,
                                valorController,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final stopDate = _parseDate(dataController.text);
                                        final targetDays = metaController.text.isNotEmpty ? int.tryParse(metaController.text) : null;
                                        final cigarrosPorDia = cigarrosController.text.isNotEmpty ? int.tryParse(cigarrosController.text) : null;
                                        final valorCarteira = valorController.text.isNotEmpty ? double.tryParse(valorController.text.replaceAll(',', '.')) : null;
                                        
                                        if (stopDate != null && targetDays != null && targetDays > 0) {
                                          _saveGoal(
                                            stopDate,
                                            targetDays,
                                            cigarrosPorDia: cigarrosPorDia,
                                            valorCarteira: valorCarteira,
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Preencha a data (DD/MM/AAAA) e a meta corretamente'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.save, size: 16),
                                      label: const Text(
                                        'Salvar Meta',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E8B6A),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalModalContent(
      TextEditingController dataController,
      TextEditingController metaController,
      TextEditingController cigarrosController,
      TextEditingController valorController,
    ) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C7DA0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF1F4E6E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data que parou de fumar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: dataController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/AAAA',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            final oldText = oldValue.text;
                            
                            if (text.length > oldText.length) {
                              if (text.length == 2 || text.length == 4) {
                                return newValue.copyWith(
                                  text: '$text/',
                                  selection: TextSelection.collapsed(offset: text.length + 1),
                                );
                              }
                            } else {
                              if (oldText.length == 3 && text.length == 2) {
                                return newValue.copyWith(
                                  text: text.substring(0, 2),
                                  selection: TextSelection.collapsed(offset: 2),
                                );
                              }
                              if (oldText.length == 5 && text.length == 4) {
                                return newValue.copyWith(
                                  text: text.substring(0, 4),
                                  selection: TextSelection.collapsed(offset: 4),
                                );
                              }
                            }
                            
                            if (text.length == 8 && !text.contains('/')) {
                              final formatted = '${text.substring(0, 2)}/${text.substring(2, 4)}/${text.substring(4, 8)}';
                              return newValue.copyWith(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: 10),
                              );
                            }
                            
                            return newValue;
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8B6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flag, size: 20, color: Color(0xFF2E8B6A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meta em dias',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: metaController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ex: 30, 60, 90',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'dias',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF475569)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informações adicionais para cálculo de economia (opcional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC65D47).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smoking_rooms, size: 20, color: Color(0xFFC65D47)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cigarros por dia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cigarrosController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ex: 20',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'cigarros/dia',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8B6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_money, size: 20, color: Color(0xFF2E8B6A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valor da carteira',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: valorController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ex: 10,00',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'R\$',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Uma carteira geralmente tem 20 cigarros',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.length != 10) return null;
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _saveGoal(DateTime stopDate, int targetDays, {int? cigarrosPorDia, double? valorCarteira}) async {
    try {
      final authService = AuthService();
      
      final formattedDate = '${stopDate.year}-${stopDate.month.toString().padLeft(2, '0')}-${stopDate.day.toString().padLeft(2, '0')}';
      
      await authService.updateGoal(formattedDate, targetDays, cigarrosPorDia, valorCarteira);
      
      if (mounted) {
        final response = await authService.getUserData();
        final userData = response['user'];
        
        setState(() {
          if (userData['stop_date'] != null && userData['stop_date'] != '' && userData['stop_date'] != 'null') {
            _userData['stopDate'] = userData['stop_date'].toString();
          }
          if (userData['target_days'] != null && userData['target_days'] > 0) {
            _userData['targetDays'] = userData['target_days'];
          }
          if (userData['cigarros_por_dia'] != null && userData['cigarros_por_dia'] != '') {
            int? valor = int.tryParse(userData['cigarros_por_dia'].toString());
            if (valor != null && valor > 0) {
              _userData['cigarrosPorDia'] = valor;
            }
          }
          if (userData['valor_carteira'] != null && userData['valor_carteira'] != '') {
            double? valor = double.tryParse(userData['valor_carteira'].toString());
            if (valor != null && valor > 0) {
              _userData['valorCarteira'] = valor;
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta definida com sucesso!'),
            backgroundColor: Color(0xFF2E8B6A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar meta: $e'),
            backgroundColor: const Color(0xFFC65D47),
          ),
        );
      }
    }
  }
    
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
      'subtitle': 'Em 1 ano você economiza mais de R\$7.000',
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

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _checkLoginStatus();
    _startAutoCarousel();
    _loadGoalData();
    _startRealtimeUpdate();
    _loadFagerstromScore();
  }

  void _checkLoginStatus() {
    final userId = _userData['id'];
    final token = _userData['token'];
    
    setState(() {
      _isLoggedIn = (userId != null && userId > 0) || token != null;
    });
  }

  void _startRealtimeUpdate() {
    _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _loadGoalData() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      
      if (mounted) {
        setState(() {
          if (userData['stop_date'] != null && userData['stop_date'] != '' && userData['stop_date'] != 'null') {
            _userData['stopDate'] = userData['stop_date'].toString();
          }
          if (userData['target_days'] != null && userData['target_days'] > 0) {
            _userData['targetDays'] = userData['target_days'];
          }
          if (userData['cigarros_por_dia'] != null && userData['cigarros_por_dia'] != '') {
            int? valor = int.tryParse(userData['cigarros_por_dia'].toString());
            if (valor != null && valor > 0) {
              _userData['cigarrosPorDia'] = valor;
            }
          }
          if (userData['valor_carteira'] != null && userData['valor_carteira'] != '') {
            double? valor = double.tryParse(userData['valor_carteira'].toString());
            if (valor != null && valor > 0) {
              _userData['valorCarteira'] = valor;
            }
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar meta: $e');
    }
  }

  Future<void> _loadFagerstromScore() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      if (userData['scoreFagestrom'] != null && userData['scoreFagestrom'] > 0) {
        setState(() {
          _scoreFagerstrom = userData['scoreFagestrom'];
        });
      }
    } catch (e) {
      print('Erro ao carregar score: $e');
    }
  }
  
  void _startAutoCarousel() {
    Future.delayed(const Duration(seconds: 6), () {
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

  void _openYouTubeVideo(String videoId) {
    html.window.open('https://www.youtube.com/watch?v=$videoId', '_blank');
  }

  void _openWebsite(String url) {
    html.window.open(url, '_blank');
  }

void _showSintomasModal() {
  _headerKey.currentState?.showSintomasModal();
}

void _showSintomasGrafico() {
  _headerKey.currentState?.showSintomasGrafico();
}

void _openFagerstromTest() async {
  await _headerKey.currentState?.openFagerstromTest();
  await _loadFagerstromScore();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
_isLoggedIn 
  ? HeaderWidget(
      key: _headerKey,
      userName: _userData['nomeCompleto']?.toString() ?? 'Usuário',
      userData: _userData,
      onNameUpdated: _updateUserName,
      showBackButton: false,
    )
  : _buildGuestHeader(constraints),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeroBanner(constraints),
                        _buildSectionHeader(),
                        _buildTabBar(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth < 768 ? 16 : 50,
                            vertical: 20,
                          ),
                          child: _buildTabContent(constraints),
                        ),
                        const FooterWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

Widget _buildTabBar() {
  final isMobile = MediaQuery.of(context).size.width < 768;
  
  List<Tab> tabs = [];
  
  if (_isLoggedIn) {
    tabs = const [
      Tab(icon: Icon(Icons.menu_book), text: 'Material de Apoio'),
      Tab(icon: Icon(Icons.flag), text: 'Minhas Metas'),
      Tab(icon: Icon(Icons.info_outline), text: 'Sobre o Programa'),
    ];
  } else {
    tabs = const [
      Tab(icon: Icon(Icons.menu_book), text: 'Material de Apoio'),
      Tab(icon: Icon(Icons.info_outline), text: 'Sobre o Programa'),
    ];
  }
  
  return Container(
    color: Colors.white,
    child: TabBar(
      controller: TabController(
        length: tabs.length,
        initialIndex: _selectedTab < tabs.length ? _selectedTab : 0,
        vsync: _TabBarVSync(),
      ),
      onTap: (index) {
        setState(() {
          _selectedTab = index;
        });
      },
      isScrollable: isMobile,
      indicatorColor: const Color(0xFF1F4E6E),
      indicatorWeight: 3,
      labelColor: const Color(0xFF1F4E6E),
      unselectedLabelColor: const Color(0xFF64748B),
      labelStyle: TextStyle(
        fontSize: isMobile ? 14 : 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: isMobile ? 13 : 14,
        fontFamily: 'Inter',
      ),
      tabs: tabs,
    ),
  );
}

 Widget _buildTabContent(BoxConstraints constraints) {
  final isMobile = constraints.maxWidth < 1100;
  
  if (!_isLoggedIn) {
    switch (_selectedTab) {
      case 0:
        return isMobile
            ? Column(
                children: [
                  _buildTipCard(),
                  const SizedBox(height: 24),
                  _buildMaterialsContent(constraints),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildTipCard(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 8,
                    child: _buildMaterialsContent(constraints),
                  ),
                ],
              );
      case 1:
        return _buildSobreProgramaContent(isMobile);
      default:
        return const SizedBox.shrink();
    }
  }
  
  switch (_selectedTab) {
    case 0:
      return isMobile
          ? Column(
              children: [
                _buildTipCard(),
                const SizedBox(height: 24),
                _buildMaterialsContent(constraints),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildTipCard(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 8,
                  child: _buildMaterialsContent(constraints),
                ),
              ],
            );
            case 1:
              return _buildMetasContent(isMobile);
            case 2:
              return _buildSobreProgramaContent(isMobile);
            default:
              return const SizedBox.shrink();
          }
        }
  Widget _buildAcoesRapidasCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                Icon(Icons.bolt, size: 28, color: Color(0xFF1F4E6E)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ações Rápidas',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAcaoRapidaItem(
                  Icons.monitor_heart_outlined,
                  'Registrar Sintoma',
                  'Registre diáriamente de 0 a 10 como você se sente.',
                  const Color(0xFF2E8B6A),
                  () => _showSintomasModal(),
                ),
                const Divider(height: 24),
                _buildAcaoRapidaItem(
                  Icons.show_chart_outlined,
                  'Ver Gráfico',
                  'Acompanhe sua evolução de sintomas.',
                  const Color(0xFF1F4E6E),
                  () => _showSintomasGrafico(),
                ),
                const Divider(height: 24),
                _buildAcaoRapidaItem(
                  Icons.assessment_outlined,
                  'Teste de Fagerström',
                  'Avalie sua dependência à nicotina com base nesse fomrulário.',
                  const Color(0xFFD97706),
                  () => _openFagerstromTest(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcaoRapidaItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildFagerstromResultCard() {
  String getNivelDependencia(int score) {
    if (score <= 2) return 'Muito Baixa';
    if (score <= 4) return 'Baixa';
    if (score == 5) return 'Média';
    if (score <= 7) return 'Elevada';
    return 'Muito Elevada';
  }

  Color getNivelColor(int score) {
    if (score <= 2) return const Color(0xFF2E8B6A);
    if (score <= 4) return const Color(0xFF84CC16);
    if (score == 5) return const Color(0xFFD97706);
    if (score <= 7) return const Color(0xFFC65D47);
    return const Color(0xFFC65D47);
  }

  IconData getNivelIcon(int score) {
    if (score <= 2) return Icons.emoji_emotions_outlined;
    if (score <= 4) return Icons.sentiment_satisfied_outlined;
    if (score == 5) return Icons.sentiment_neutral_outlined;
    if (score <= 7) return Icons.sentiment_dissatisfied_outlined;
    return Icons.sentiment_very_dissatisfied_outlined;
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.assessment, size: 22, color: Color(0xFF1F4E6E)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resultado Teste de Fagerström',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _scoreFagerstrom != null && _scoreFagerstrom! > 0
              ? Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: getNivelColor(_scoreFagerstrom!).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getNivelIcon(_scoreFagerstrom!),
                            size: 32,
                            color: getNivelColor(_scoreFagerstrom!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_scoreFagerstrom pontos',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: getNivelColor(_scoreFagerstrom!),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getNivelColor(_scoreFagerstrom!).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getNivelDependencia(_scoreFagerstrom!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: getNivelColor(_scoreFagerstrom!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openFagerstromTest,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          'Refazer Teste',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4E6E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assessment_outlined,
                              size: 40,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Teste ainda não realizado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Avalie sua dependência à nicotina',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF92400E),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openFagerstromTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Fazer Teste Agora',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

Widget _buildGoalCard() {
  DateTime? stopDate;
  int? targetDays;
  int? cigarrosPorDia = _userData['cigarrosPorDia'];
  double? valorCarteira = _userData['valorCarteira'];

  if (_userData.containsKey('stopDate') && _userData['stopDate'] != null) {
    final stopDateStr = _userData['stopDate'];
    if (stopDateStr is String && stopDateStr.isNotEmpty) {
      final parts = stopDateStr.split('-');
      if (parts.length == 3) {
        stopDate = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
      }
    }
  }
  
  if (_userData.containsKey('targetDays') && _userData['targetDays'] != null) {
    targetDays = _userData['targetDays'];
  }

  String timeWithoutSmoking = '';
  if (stopDate != null) {
    final now = DateTime.now();
    final diff = now.difference(stopDate);
    final days = diff.inDays;
    
    if (days == 0) {
      timeWithoutSmoking = 'Menos de 1 dia';
    } else if (days == 1) {
      timeWithoutSmoking = '1 dia';
    } else {
      timeWithoutSmoking = '$days dias';
    }
  }
  
  int cigarrosNaoFumados = 0;
  double economia = 0.0;
  
  if (stopDate != null && cigarrosPorDia != null && valorCarteira != null) {
    final days = DateTime.now().difference(stopDate).inDays;
    cigarrosNaoFumados = days * cigarrosPorDia;
    final cigarrosPorCarteira = 20;
    final valorPorCigarro = valorCarteira / cigarrosPorCarteira;
    economia = cigarrosNaoFumados * valorPorCigarro;
  }
  
  List<Widget> _getBadges() {
    List<Widget> badges = [];
    if (stopDate != null) {
      final days = DateTime.now().difference(stopDate).inDays;
      
      if (days >= 7) {
        badges.add(_buildBadge('7 dias', Icons.emoji_events, const Color(0xFFD97706)));
      }
      if (days >= 30) {
        badges.add(_buildBadge('1 mês', Icons.star, const Color(0xFF2E8B6A)));
      }
      if (days >= 365) {
        badges.add(_buildBadge('1 ano', Icons.workspace_premium, const Color(0xFFC65D47)));
      }
    }
    return badges;
  }
  
  int currentDays = stopDate != null ? DateTime.now().difference(stopDate).inDays : 0;
  int progress = targetDays != null && targetDays > 0 ? (currentDays * 100 ~/ targetDays).clamp(0, 100) : 0;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_userData['nomeCompleto']?.toString() ?? 'Usuário')}&background=2C7DA0&color=fff&size=100',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userData['nomeCompleto']?.toString() ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Membro desde ${_userData.containsKey('created_at') && _userData['created_at'] != null ? _formatDate(DateTime.parse(_userData['created_at'].toString())) : DateTime.now().year.toString()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (stopDate != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E8B6A), Color(0xFF257A5C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Tempo sem fumar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeWithoutSmoking,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              'Parou em: ${_formatDate(stopDate)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (targetDays != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            color: Colors.white,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Meta: $currentDays de $targetDays dias ($progress%)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentDays.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F4E6E),
                            ),
                          ),
                          const Text(
                            'Dias',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            targetDays != null ? '$targetDays' : '--',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E8B6A),
                            ),
                          ),
                          const Text(
                            'Meta (dias)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (cigarrosPorDia != null && valorCarteira != null && stopDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$cigarrosNaoFumados',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC65D47),
                              ),
                            ),
                            const Text(
                              'Cigarros não fumados',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'R\$ ${economia.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E8B6A),
                              ),
                            ),
                            const Text(
                              'Economizados',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showGoalModal,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text(
                    'Definir Meta',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_getBadges().isNotEmpty)
          Positioned(
            top: 12,
            right: 12,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: _getBadges(),
            ),
          ),
      ],
    ),
  );
}

Widget _buildBadge(String title, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMetasContent(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildAcoesRapidasCard(),
          const SizedBox(height: 24),
          _buildFagerstromResultCard(),
          const SizedBox(height: 24),
          _buildGoalCard(),
        ],
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildAcoesRapidasCard(),
              const SizedBox(height: 24),
              _buildFagerstromResultCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 8,
          child: _buildGoalCard(),
        ),
      ],
    );
  }

  Widget _buildGuiaCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isGuiaCardExpanded = !_isGuiaCardExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, size: 28, color: Color(0xFF1F4E6E)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Como usar o DESFUMO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Icon(
                    _isGuiaCardExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 28,
                    color: const Color(0xFF1F4E6E),
                  ),
                ],
              ),
            ),
          ),
          if (_isGuiaCardExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildGuiaItem(
                    Icons.school_outlined,
                    'Turmas de Apoio',
                    'Encontre UPAs próximas, veja vagas disponíveis e faça sua matrícula em turmas de apoio ao tabagismo.',
                    const Color(0xFF1F4E6E),
                  ),
                  const SizedBox(height: 24),
                  _buildGuiaItem(
                    Icons.list_alt_outlined,
                    'Minhas Matrículas',
                    'Acompanhe suas matrículas, veja o status (em espera, confirmada, cancelada) e gerencie suas inscrições.',
                    const Color(0xFF6B21A8),
                  ),
                  const SizedBox(height: 24),
                  _buildGuiaItem(
                    Icons.assessment_outlined,
                    'Teste de Fagerström',
                    'Avalie seu nível de dependência à nicotina com base em 6 perguntas simples. O resultado ajuda os profissionais a oferecerem o melhor tratamento.',
                    const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 24),
                  _buildGuiaItem(
                    Icons.monitor_heart_outlined,
                    'Registrar Sintomas',
                    'Registre diariamente ansiedade, irritabilidade, insônia e outros sintomas em uma escala de 0 a 10.',
                    const Color(0xFF2E8B6A),
                  ),
                  const SizedBox(height: 24),
                  _buildGuiaItem(
                    Icons.show_chart_outlined,
                    'Gráfico de Evolução',
                    'Visualize a evolução dos seus sintomas ao longo do tempo e veja seu progresso na jornada sem cigarro.',
                    const Color(0xFFC65D47),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuiaItem(IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
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

  Widget _buildTipCard() {
    Widget buildDItem(
      IconData icon,
      String title,
      String description,
      Color color,
    ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF475569),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isTipCardExpanded = !_isTipCardExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, size: 28, color: Color(0xFF1F4E6E)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Técnica dos 5 D’s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Icon(
                    _isTipCardExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 28,
                    color: const Color(0xFF1F4E6E),
                  ),
                ],
              ),
            ),
          ),
          if (_isTipCardExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  buildDItem(
                    Icons.directions_walk,
                    'Distrair',
                    'Levante, mude de ambiente, beba água ou lave o rosto. A fissura dura apenas alguns minutos.',
                    const Color(0xFF1F4E6E),
                  ),
                  buildDItem(
                    Icons.block,
                    'Dizer NÃO',
                    'Fale para si mesmo: "Eu não fumo mais. Isso vai passar." Isso ativa seu controle racional.',
                    const Color(0xFFC65D47), 
                  ),
                  buildDItem(
                    Icons.timer,
                    'Demorar',
                    'Espere 10 minutos antes de qualquer decisão. O pico da vontade cai rapidamente.',
                    const Color(0xFFD97706), 
                  ),
                  buildDItem(
                    Icons.air,
                    'Respirar fundo',
                    'Puxe o ar por 4s, segure por 4s e solte por 6s. Repita 5 vezes para reduzir a ansiedade.',
                    const Color(0xFF2E8B6A), 
                  ),
                  buildDItem(
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

  Widget _buildSobreProgramaContent(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildGuiaCard(),
          const SizedBox(height: 24),
          _buildProgramaInfoCard(),
        ],
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildGuiaCard(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 7,
          child: _buildProgramaInfoCard(),
        ),
      ],
    );
  }

  Widget _buildProgramaInfoCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1F4E6E), size: 28),
              SizedBox(width: 12),
              Text(
                'Programa de Turmas de Apoio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoItem(
            Icons.how_to_reg_outlined,
            'Processo de Matrícula',
            'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a UPA entrará em contato pelo telefone cadastrado para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
            const Color(0xFF2C7DA0),
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            Icons.calendar_today_outlined,
            'Frequência dos Encontros',
            '• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\nCada encontro tem duração aproximada de 2 horas.',
            const Color(0xFF2E8B6A),
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            Icons.group_outlined,
            'Dinâmica dos Grupos',
            'Os grupos são espaços acolhedores e sigilosos onde você encontrará apoio para sua jornada de abandono do tabagismo. Incluem roda de conversa, educação em saúde, estratégias de enfrentamento, atividades práticas e acompanhamento individual.',
            const Color(0xFFD97706),
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            Icons.medical_services_outlined,
            'Acompanhamento Profissional',
            'Os grupos são coordenados por uma equipe multidisciplinar composta por médicos especialistas em tabagismo, psicólogos, enfermeiros e educadores físicos.',
            const Color(0xFF6B21A8),
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            Icons.phone_android_outlined,
            'Comunicação e Suporte',
            'Além dos encontros presenciais, você receberá mensagens de apoio via WhatsApp, material informativo complementar, acompanhamento telefônico e acesso a grupo de suporte online.',
            const Color(0xFF14B8A6),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 768;
    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
    final double horizontalPadding = isMobile ? 16 : (isTablet ? 32 : 50);
    
    return Container(
      color: const Color(0xFF334155),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.smoke_free_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESFUMO',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Apoio ao Tabagismo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildGuestMenu(),
        ],
      ),
    );
  }

  Widget _buildGuestMenu() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login_outlined, color: Colors.white, size: isMobile ? 16 : 18),
                const SizedBox(width: 8),
                Text(
                  isMobile ? 'Entrar' : 'Entrar / Cadastrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsContent(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isMobile = width < 768;
    final crossAxisSpacing = isMobile ? 16.0 : 24.0;
    final mainAxisSpacing = isMobile ? 20.0 : 24.0;
    final itemHeight = isMobile ? 320.0 : 320.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 720, 
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        mainAxisExtent: itemHeight,
      ),
      itemCount: _materiais.length,
      itemBuilder: (context, index) {
        return _buildMaterialCard(_materiais[index]);
      },
    );
  }

  Widget _buildHeroBanner(BoxConstraints constraints) {
    final banner = _banners[_currentBannerIndex];
    final Color accentColor = const Color(0xFF1F4E6E);
    final isMobile = constraints.maxWidth < 768;
    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
    
    double bannerHeight = isMobile ? 400 : (isTablet ? 550 : 720);
    double titleSize = isMobile ? 32 : (isTablet ? 44 : 56);
    double subtitleSize = isMobile ? 14 : (isTablet ? 16 : 18);
    double leftPadding = isMobile ? 20 : (isTablet ? 40 : 60);
    double rightPadding = isMobile ? 20 : (isTablet ? 40 : 60);
    
    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Image.network(
            banner['image'],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.55),
          ),
          Positioned(
            left: leftPadding,
            right: rightPadding,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'O lugar onde o fumo deixa de existir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 11 : 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.2,
                                height: 1.1,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: isMobile ? 40 : 80,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              banner['subtitle']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 50),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Recursos e Informações',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Recursos selecionados para ajudar na sua jornada',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                    if (!_isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Faça login para acessar este conteúdo'),
                          backgroundColor: Color(0xFFD97706),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    
                    if (material['title'] == 'Guia Completo para Parar de Fumar') {
                      _openPDF('GuiaPratico.pdf');
                    } else if (material.containsKey('videoId')) {
                      _openYouTubeVideo(material['videoId']);
                    } else if (material.containsKey('url')) {
                      _openWebsite(material['url']);
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

class _TabBarVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}