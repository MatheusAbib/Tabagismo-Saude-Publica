import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/header/modals/sintomas_modal_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/fagerstrom_modal_widget.dart';

class HomeMetasWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onRefresh;

  const HomeMetasWidget({
    Key? key,
    required this.userData,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _HomeMetasWidgetState createState() => _HomeMetasWidgetState();
}

class _HomeMetasWidgetState extends State<HomeMetasWidget> {
  late Map<String, dynamic> _userData;
  int? _scoreFagerstrom;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadFagerstromScore();
  }

  Future<void> _loadFagerstromScore() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      if (userData['scoreFagestrom'] != null && userData['scoreFagestrom'] > 0) {
        if (mounted) {
          setState(() {
            _scoreFagerstrom = userData['scoreFagestrom'];
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar score: $e');
    }
  }

  void _showGoalModal() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

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
              int.parse(parts[2]),
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
              insetPadding: EdgeInsets.all(isSmallMobile ? 4 : (isMobile ? 8 : 20)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 600 : MediaQuery.of(context).size.width * 0.8),
                height: isMobile ? MediaQuery.of(context).size.height * 0.6 : (MediaQuery.of(context).size.height > 800 ? 600 : MediaQuery.of(context).size.height * 0.65),
                constraints: BoxConstraints(maxWidth: 700),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 20),
                        decoration: BoxDecoration(color: const Color(0xFF334155)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.celebration_outlined, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Definir Meta',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    'Registre quando parou de fumar e defina sua meta',
                                    style: TextStyle(fontSize: 10, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          child: Column(
                            children: [
                              _buildGoalModalContent(
                                dataController,
                                metaController,
                                cigarrosController,
                                valorController,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        minimumSize: const Size(double.infinity, 44),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                                          ToastService.showWarning(context, 'Preencha a data (DD/MM/AAAA) e a meta corretamente');
                                        }
                                      },
                                      icon: const Icon(Icons.save, size: 16),
                                      label: const Text(
                                        'Salvar Meta',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E8B6A),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        minimumSize: const Size(double.infinity, 44),
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
                  color: const Color(0xFF2C7DA0).withValues(alpha: 0.1),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569), fontFamily: 'Inter'),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter'),
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
                  color: const Color(0xFF2E8B6A).withValues(alpha: 0.1),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569), fontFamily: 'Inter'),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter'),
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
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B), fontFamily: 'Inter'),
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
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500, fontFamily: 'Inter'),
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
                  color: const Color(0xFFC65D47).withValues(alpha: 0.1),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569), fontFamily: 'Inter'),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter'),
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
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B), fontFamily: 'Inter'),
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
                  color: const Color(0xFF2E8B6A).withValues(alpha: 0.1),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569), fontFamily: 'Inter'),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter'),
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
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B), fontFamily: 'Inter'),
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
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Uma carteira geralmente tem 20 cigarros',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w500, fontFamily: 'Inter'),
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
        widget.onRefresh();
        ToastService.showSuccess(context, 'Meta definida com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Erro ao salvar meta: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1100;

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

  Widget _buildAcoesRapidasCard() {
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
                  'Sintomas Diários',
                  'Registre e acompanhe sua evolução de sintomas.',
                  const Color(0xFF1F4E6E),
                  () => SintomasModalWidget.show(context),
                  '',
                ),
                const Divider(height: 24),
                      _buildAcaoRapidaItem(
                        Icons.assessment_outlined,
                        'Teste de Fagerström',
                        'Avalie sua dependência à nicotina.',
                        const Color(0xFFD97706),
                        () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                child: Container(
                                  width: MediaQuery.of(context).size.width > 800 ? 850 : MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height > 800 ? 750 : MediaQuery.of(context).size.height * 0.85,
                                  constraints: BoxConstraints(maxWidth: 850),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: FagerstromTestModal(
                                      onScoreUpdated: (score) {
                                        ToastService.showSuccess(context, 'Teste de Fagerström finalizado! Score: $score');
                                        _loadFagerstromScore();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        _scoreFagerstrom != null ? 'Score: $_scoreFagerstrom' : '',
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcaoRapidaItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap, String status) {
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
                color: color.withValues(alpha: 0.1),
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
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F4E6E),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
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
            color: Colors.black.withValues(alpha: 0.08),
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
                              color: getNivelColor(_scoreFagerstrom!).withValues(alpha: 0.15),
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
                                    color: getNivelColor(_scoreFagerstrom!).withValues(alpha: 0.15),
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
                            onPressed: () => FagerstromTestModal.show(context, onScoreUpdated: (score) {
                              ToastService.showSuccess(context, 'Teste de Fagerström finalizado! Score: $score');
                              _loadFagerstromScore();
                            }),
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
                          border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withValues(alpha: 0.1),
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
                          onPressed: () => FagerstromTestModal.show(context, onScoreUpdated: (score) {
                            ToastService.showSuccess(context, 'Teste de Fagerström finalizado! Score: $score');
                            _loadFagerstromScore();
                          }),
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
            color: Colors.black.withValues(alpha: 0.08),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
}