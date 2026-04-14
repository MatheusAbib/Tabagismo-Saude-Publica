import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/screens/admin_usuario_detalhes.dart';
import 'package:tabagismo_app/services/pdf_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:tabagismo_app/screens/cronograma_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'historico_turma_screen.dart';
import 'dart:async';

class EnfermeiraScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const EnfermeiraScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EnfermeiraScreenState createState() => _EnfermeiraScreenState();
}

class _EnfermeiraScreenState extends State<EnfermeiraScreen> {
  
  final Color _primaryColor = const Color(0xFF0F2B3D);
  final Color _accentColor = const Color(0xFF2C7DA0);

  List<Map<String, dynamic>> _usuarios = [];
  bool _carregandoUsuarios = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsuarios = 0;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  int _alunosPage = 0;
  int _alunosPerPage = 5;

  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['Dashboard', 'Usuários', 'Cronogramas', 'Lista de Presença', 'Turmas Concluídas'];

  String _statusFiltro = 'todos'; 
  final List<Map<String, dynamic>> _filtros = [
  {'valor': 'todos', 'label': 'Todos', 'cor': Color(0xFF64748B)},
  {'valor': 'em_espera', 'label': 'Em Espera', 'cor': Color(0xFFF59E0B)},
  {'valor': 'matriculado', 'label': 'Matriculados', 'cor': Color(0xFF10B981)},
  {'valor': 'cancelada', 'label': 'Cancelados', 'cor': Color(0xFFEF4444)},
];
  
  String _upaNome = '';

  @override
  void initState() {
    super.initState();
    
    final nome = widget.userData['upa_nome'];
    _upaNome = (nome != null && nome.toString().isNotEmpty) ? nome : 'Carregando...';
    _carregarUsuarios();
  }

Widget _buildCronogramasList() {
  return FutureBuilder(
    future: AuthService().getTurmasComCronograma(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar turmas: ${snapshot.error}'),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }
      
      final turmas = List<Map<String, dynamic>>.from(snapshot.data!['turmas']);
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: turmas.map((turma) => _buildTurmaCronogramaCard(turma)).toList(),
        ),
      );
    },
  );
}

Widget _buildTurmaCronogramaCard(Map<String, dynamic> turma) {
  final aulas = List<Map<String, dynamic>>.from(turma['aulas'] ?? []);
  final horarioFixo = turma['horario'];
  
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today, color: _accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turma['nome'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Horário: $horarioFixo • ${turma['vagas_ocupadas']}/${turma['vagas_totais']} alunos',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirModalCronograma(turma),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar Aula'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        if (aulas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Nenhuma aula cadastrada. Clique em "Adicionar Aula" para criar o cronograma.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: aulas.length,
            itemBuilder: (context, index) {
              final aula = aulas[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _accentColor.withOpacity(0.1),
                  child: Text('${aula['numero_aula']}', style: TextStyle(color: _accentColor)),
                ),
                title: Text('Aula ${aula['numero_aula']}'),
                subtitle: Text('${aula['data_formatada']} • ${aula['horario']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () => _confirmarDeletarAula(turma['id'], aula['id']),
                ),
              );
            },
          ),
      ],
    ),
  );
}

void _abrirModalCronograma(Map<String, dynamic> turma) {
  final numeroAulaController = TextEditingController();
  final dataController = TextEditingController();
  final mesController = TextEditingController();
  bool isLoading = false;
  
  DateTime? dataSelecionada;
  
  final horarioFixo = turma['horario'];
  final Color _successColor = const Color(0xFF10B981);
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_month, color: Color(0xFF2C7DA0), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Adicionar Aula',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: numeroAulaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número da Aula',
                      hintText: 'Ex: 1, 2, 3...',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dataController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data da Aula',
                      hintText: 'Selecione uma data',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onTap: () async {
                      final result = await showCalendarDatePicker2Dialog(
                        context: context,
                        config: CalendarDatePicker2WithActionButtonsConfig(
                          calendarType: CalendarDatePicker2Type.single,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          currentDate: DateTime.now(),
                        ),
                        dialogSize: const Size(325, 400),
                      );
                      if (result != null && result.isNotEmpty) {
                        dataSelecionada = result.first;
                        dataController.text = '${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}';
                        
                        int mesCalculado = ((dataSelecionada!.month - DateTime.now().month) + 12) % 12;
                        mesCalculado = mesCalculado == 0 ? 1 : mesCalculado + 1;
                        if (mesCalculado > 6) mesCalculado = 6;
                        mesController.text = mesCalculado.toString();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: horarioFixo),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Horário',
                      hintText: 'Horário fixo da turma',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: mesController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Mês do Programa',
                      hintText: 'Calculado automaticamente',
                      prefixIcon: Icon(Icons.calendar_month),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        child: ElevatedButton(
                          onPressed: () async {
                            if (numeroAulaController.text.isEmpty || dataSelecionada == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Preencha todos os campos'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            
                            setState(() => isLoading = true);
                            try {
                              await AuthService().adicionarAulaCronograma(
                                turma['id'],
                                int.parse(numeroAulaController.text),
                                dataSelecionada!.toIso8601String().split('T')[0],
                                horarioFixo,
                                int.parse(mesController.text),
                              );
                              Navigator.pop(context);
                              _recarregarTurmasCronograma();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Aula adicionada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                              );
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _successColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Adicionar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _recarregarTurmasCronograma() async {
  setState(() {});
}

void _confirmarDeletarAula(int turmaId, int aulaId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: const Text('Tem certeza que deseja excluir esta aula?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Excluir')),
      ],
    ),
  );
  
  if (confirm == true) {
    try {
      await AuthService().deletarAulaCronograma(aulaId);
      _recarregarTurmasCronograma();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aula excluída com sucesso!'), backgroundColor: Color(0xFF10B981)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }
}



Widget _buildEvolucaoSection(Map<String, dynamic> data) {
  final alunosAtivos = data['alunos_ativos'] ?? {};
  final alunosConcluidos = data['alunos_concluidos'] ?? {};
  
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text('Evolução dos Alunos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildEvolucaoCard('Alunos Ativos', alunosAtivos, const Color(0xFF3B82F6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEvolucaoCard('Alunos Concluídos', alunosConcluidos, const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 24),
              _buildEvolucaoChart(data),
              const SizedBox(height: 24),
              _buildAlunosDetalhados(data),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEvolucaoCard(String titulo, Map<String, dynamic> dados, Color cor) {
  
  final total = _parseToInt(dados['total']);
  final fumando = _parseToInt(dados['fumando']);
  final semFumar = _parseToInt(dados['sem_fumar']);
  final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);
  print('Dados recebidos: ${dados['total']} - ${dados['fumando']} - ${dados['sem_fumar']} - ${dados['taxa_sucesso']}');
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cor.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cor)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(total.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFF59E0B), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(fumando.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B))),
                    ],
                  ),
                  const Text('Fumando', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(semFumar.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                    ],
                  ),
                  const Text('Sem fumar', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: total > 0 ? semFumar / total : 0,
          backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          'Taxa de sucesso: ${taxaSucesso.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: taxaSucesso >= 50 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
        ),
      ],
    ),
  );
}

int _parseToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    return 0;
  }
  return 0;
}

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
    return 0.0;
  }
  return 0.0;
}

Widget _buildEvolucaoChart(Map<String, dynamic> data) {
  final evolucaoAtivos = List<Map<String, dynamic>>.from(data['evolucao_mensal_ativos'] ?? []);
  
  if (evolucaoAtivos.isEmpty) {
    return const Center(child: Text('Sem dados para exibir', style: TextStyle(color: Color(0xFF64748B))));
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Evolução Mensal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      _buildMensalChart(evolucaoAtivos, 'Alunos Ativos'),
    ],
  );
}

Widget _buildMensalChart(List<Map<String, dynamic>> dados, String titulo) {
  final maxValor = dados.fold<int>(0, (max, item) {
    final fumando = _parseToInt(item['fumando']);
    final semFumar = _parseToInt(item['sem_fumar']);
    final total = fumando + semFumar;
    return total > max ? total : max;
  });
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
      const SizedBox(height: 8),
      SizedBox(
        height: 180,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: dados.map((item) {
              final mes = item['mes'] as String;
              final fumando = _parseToInt(item['fumando']).toDouble();
              final semFumar = _parseToInt(item['sem_fumar']).toDouble();
              final total = fumando + semFumar;
              final altura = maxValor > 0 ? (total / maxValor) * 120 : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(total.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 35,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        if (altura > 0)
                          Column(
                            children: [
                              if (semFumar > 0)
                                Container(
                                  width: 35,
                                  height: (semFumar / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              if (fumando > 0)
                                Container(
                                  width: 35,
                                  height: (fumando / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.vertical(
                                      top: semFumar > 0 ? Radius.zero : Radius.circular(6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 45,
                      child: Text(
                        mes.substring(5),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendaItem(const Color(0xFFF59E0B), 'Fumando'),
          const SizedBox(width: 16),
          _buildLegendaItem(const Color(0xFF3B82F6), 'Sem fumar'),
        ],
      ),
    ],
  );
}

Widget _buildAlunosDetalhados(Map<String, dynamic> data) {
  final alunos = List<Map<String, dynamic>>.from(data['alunos_detalhados'] ?? []);
  
  if (alunos.isEmpty) {
    return const SizedBox.shrink();
  }
  
  final totalPages = (alunos.length / _alunosPerPage).ceil();
  final startIndex = _alunosPage * _alunosPerPage;
  final endIndex = (startIndex + _alunosPerPage) > alunos.length ? alunos.length : (startIndex + _alunosPerPage);
  final alunosPaginados = alunos.sublist(startIndex, endIndex);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Situação Atual dos Alunos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Expanded(child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  SizedBox(width: 80, child: Text('Turma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                  SizedBox(width: 80, child: Text('Situação', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                ],
              ),
            ),
            ...alunosPaginados.map((aluno) {
              final ultimaObservacao = aluno['ultima_observacao'];
              final semanasFumando = aluno['semanas_fumando'] ?? 0;
              final semanasSemFumar = aluno['semanas_sem_fumar'] ?? 0;
              
              String situacao;
              Color situacaoCor;
              
              if (ultimaObservacao == '2- Sem fumar') {
                situacao = 'Sem fumar';
                situacaoCor = const Color(0xFF3B82F6);
              } else if (ultimaObservacao == '1- Está fumando') {
                situacao = 'Fumando';
                situacaoCor = const Color(0xFFF59E0B);
              } else {
                situacao = 'Sem registro';
                situacaoCor = const Color(0xFF94A3B8);
              }
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(aluno['nome_completo'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(
                            'F: $semanasFumando • SF: $semanasSemFumar',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        aluno['turma_horario']?.split(' - ')[0] ?? '-',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: situacaoCor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          situacao,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: situacaoCor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _alunosPage > 0 ? () {
                        setState(() {
                          _alunosPage--;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                    const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_alunosPage + 1} de $totalPages',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _accentColor),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _alunosPage < totalPages - 1 ? () {
                        setState(() {
                          _alunosPage++;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}


  Future<void> _changePassword() async {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C7DA0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock_outline, color: Color(0xFF2C7DA0), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Alterar Senha',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha Atual',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha',
                    prefixIcon: Icon(Icons.lock_reset),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    prefixIcon: Icon(Icons.verified_user),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (newPasswordController.text != confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('As senhas não coincidem'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          try {
                            final authService = AuthService();
                            await authService.changeUserPassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao alterar senha: $e'), backgroundColor: Colors.red.shade400),
                              );
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Salvar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(),
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: _accentColor,
                labelColor: _accentColor,
                unselectedLabelColor: const Color(0xFF64748B),
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
                onTap: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                    _searchQuery = '';
                    _searchController.clear();
                    _currentPage = 1;
                    if (index == 1) {
                      _statusFiltro = 'todos';
                    }
                  });
                  if (index == 1) {
                    _carregarUsuarios(page: 1);
                  }
                },
              ),
            ),
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                    children: [
                      _buildDashboard(),
                      _buildUsuariosList(),   
                      _buildCronogramasList(), 
                      _buildListaPresenca(),
                      _buildTurmasConcluidasList(), 
                    ],
                ),
              ),
          ],
        ),
      ),
    );
  }

Widget _buildListaPresenca() {
  return FutureBuilder(
    future: AuthService().getUsuariosMatriculadosComPresencas(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar: ${snapshot.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }
      
      final response = snapshot.data as Map<String, dynamic>;
      final turmas = List<Map<String, dynamic>>.from(response['turmas']);
      final dataAtual = response['dataAtual'] as String;
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Expanded(
                child: turmas.isEmpty
                    ? const Center(child: Text('Nenhum usuário matriculado'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: turmas.asMap().entries.map((entry) {
                            final index = entry.key;
                            final turma = entry.value;
                            DateTime dataSelecionada = DateTime.parse(dataAtual);
                            return _buildTurmaPresenca(
                              turma, 
                              index, 
                              dataSelecionada,
                              (novaTurma) {
                                setState(() {
                                  turmas[index] = novaTurma;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTurmaPresenca(Map<String, dynamic> turma, int turmaIndex, DateTime dataSelecionada, Function(Map<String, dynamic>) onTurmaUpdate) {
  final usuarios = List<Map<String, dynamic>>.from(turma['usuarios']);
  
  return StatefulBuilder(
    builder: (context, setState) {
      bool _salvando = false;
      bool _encerrando = false;
      final DateTime _dataAtual = DateTime.now();
      int vagasOcupadas = usuarios.length;
      int vagasTotais = turma['vagas_totais'] ?? 4;
      
Future<void> salvarPresencas() async {
  setState(() => _salvando = true);
  try {
    final authService = AuthService();
    
    final presencasParaSalvar = usuarios.map((u) => ({
      'matriculaId': u['matricula_id'],
      'status': u['presenca_status'] ?? 'falta',
      'observacao': u['observacao_semanal'], 
    })).toList();
    
    await authService.salvarPresencasEmLote(
      presencasParaSalvar,
      '${_dataAtual.year}-${_dataAtual.month.toString().padLeft(2, '0')}-${_dataAtual.day.toString().padLeft(2, '0')}',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Presenças salvas com sucesso!'), backgroundColor: const Color(0xFF10B981)),
      );
    }
    
    final novaDataStr = '${_dataAtual.year}-${_dataAtual.month.toString().padLeft(2, '0')}-${_dataAtual.day.toString().padLeft(2, '0')}';
    final newResponse = await AuthService().getUsuariosMatriculadosComPresencas(data: novaDataStr);
    if (mounted) {
      final novasTurmas = List<Map<String, dynamic>>.from(newResponse['turmas']);
      onTurmaUpdate(novasTurmas[turmaIndex]);
      setState(() => _salvando = false);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red.shade400),
      );
      setState(() => _salvando = false);
    }
  }
}


      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFFF1F5F9),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.schedule, color: _accentColor, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              turma['nome'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatarProximaAula(turma['proxima_aula']),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: vagasOcupadas >= vagasTotais 
                    ? Colors.red.withOpacity(0.1) 
                    : const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$vagasOcupadas/$vagasTotais vagas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: vagasOcupadas >= vagasTotais ? Colors.red : const Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _verCronogramaTurma(turma),
                icon: Icon(Icons.calendar_month, size: 16, color: _accentColor),
                label: Text('Cronograma', style: TextStyle(fontSize: 12, color: _accentColor)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _accentColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _abrirHistoricoTurma(turma),
                  icon: Icon(Icons.history, size: 16, color: _accentColor),
                  label: Text('Histórico', style: TextStyle(fontSize: 12, color: _accentColor)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _accentColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
    ],
  ),
),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Aluno',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Presença',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                'Observação',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...usuarios.map((usuario) => _buildLinhaPresenca(usuario, setState)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
OutlinedButton.icon(
  onPressed: _encerrando ? null : () => _confirmarEncerrarTurma(turma),
  icon: _encerrando
      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
      : const Icon(Icons.archive, size: 16),
  label: const Text('Encerrar Turma'),
  style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFEF4444),
    side: const BorderSide(color: Color(0xFFEF4444)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _salvando ? null : salvarPresencas,
                        icon: _salvando
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save, size: 16),
                        label: const Text('Salvar Presenças'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
void _abrirHistoricoTurma(Map<String, dynamic> turma) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HistoricoTurmaScreen(
        turmaNome: turma['nome'],
        upaNome: _upaNome,
      ),
    ),
  );
}

String _formatarProximaAula(Map<String, dynamic>? proximaAula) {
  if (proximaAula == null) {
    return 'Nenhuma aula agendada';
  }
  
  final data = proximaAula['data_formatada'];
  final horario = proximaAula['horario'];
  final numero = proximaAula['numero'];
  
  return 'Próxima aula: $data às $horario (Aula $numero)';
}

void _verCronogramaTurma(Map<String, dynamic> turma) {
  final matriculaId = turma['usuarios'].isNotEmpty ? turma['usuarios'][0]['matricula_id'] : null;
  if (matriculaId != null) {
    _verCronograma(matriculaId, turma['nome']);
  }
}

Widget _buildLinhaPresenca(Map<String, dynamic> usuario, Function setState) {
  String? status = usuario['presenca_status'];
  String statusDisplay = status ?? 'nenhum';
  String? observacao = usuario['observacao_semanal'];
  String observacaoDisplay = observacao ?? '';
  
  Map<String, String> statusOptions = {
    'presente': 'Presente',
    'falta': 'Falta',
    'nenhum': '-',
  };
  
  Map<String, Color> statusColors = {
    'presente': const Color(0xFF10B981),
    'falta': const Color(0xFFEF4444),
    'nenhum': const Color(0xFF94A3B8),
  };
  
  Map<String, String> observacaoOptions = {
    '': '-',
    '1- Está fumando': '1- Está fumando',
    '2- Sem fumar': '2- Sem fumar',
  };
  
  Color getObservacaoColor(String? observacao) {
    if (observacao == '1- Está fumando') return const Color(0xFFF59E0B);
    if (observacao == '2- Sem fumar') return const Color(0xFF3B82F6);
    return const Color(0xFF94A3B8);
  }
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            usuario['nome_completo'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: statusColors[statusDisplay]?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statusDisplay,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              iconSize: 18,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColors[statusDisplay],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              items: statusOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: entry.key == 'nenhum' ? const Color(0xFF94A3B8) : statusColors[entry.key],
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null && newValue != 'nenhum') {
                  setState(() {
                    usuario['presenca_status'] = newValue;
                  });
                } else if (newValue == 'nenhum') {
                  setState(() {
                    usuario['presenca_status'] = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 140,
          decoration: BoxDecoration(
            color: getObservacaoColor(observacaoDisplay).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: observacaoDisplay,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              iconSize: 18,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: getObservacaoColor(observacaoDisplay),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              items: observacaoOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: getObservacaoColor(entry.key),
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  usuario['observacao_semanal'] = newValue == '' ? null : newValue;
                });
              },
            ),
          ),
        ),
      ],
    ),
  );
}

void _verCronograma(int matriculaId, String turmaHorario) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CronogramaScreen(
        matriculaId: matriculaId,
        turmaHorario: turmaHorario,
      ),
    ),
  );
}


Widget _buildLegendaItem(Color cor, String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        texto,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
    ],
  );
}

Widget _buildTurmasConcluidasList() {
  return FutureBuilder(
    future: AuthService().getTurmasConcluidas(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar turmas concluídas: ${snapshot.error}'),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }
      
      final turmas = List<Map<String, dynamic>>.from(snapshot.data!['turmas']);
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: turmas.map((turma) => _buildTurmaConcluidaCard(turma)).toList(),
        ),
      );
    },
  );
}


Widget _buildTurmaConcluidaCard(Map<String, dynamic> turma) {
  final cor = turma['tipo_encerramento'] == 'concluida' 
      ? const Color(0xFF10B981) 
      : const Color(0xFFEF4444);
  
  final texto = turma['tipo_encerramento'] == 'concluida' ? 'Concluída' : 'Cancelada';
  
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  turma['tipo_encerramento'] == 'concluida' 
                      ? Icons.check_circle 
                      : Icons.cancel,
                  color: cor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turma['turma_horario'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'UPA: ${turma['upa_nome']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  texto,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.calendar_today,
                'Período',
                '${_formatarData(turma['data_inicio'])} - ${_formatarData(turma['data_fim'])}',
              ),
              _buildInfoRow(
                Icons.people,
                'Total Alunos',
                turma['total_alunos'].toString(),
              ),
              _buildInfoRow(
                Icons.trending_up,
                'Média de Presença',
                '${turma['percentual_medio_presenca']}%',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _verDetalhesTurmaConcluida(turma['id']),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver detalhes'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _accentColor),
                    foregroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

Future<void> _verDetalhesTurmaConcluida(int turmaConcluidaId) async {
  try {
    final response = await AuthService().getDetalhesTurmaConcluida(turmaConcluidaId);
    final turma = response['turma'];
    final alunos = List<Map<String, dynamic>>.from(response['alunos']);
    final datas = List<String>.from(response['datas']);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.history, color: _accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico - ${turma['turma_horario']}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${turma['upa_nome']} • ${turma['tipo_encerramento'] == 'concluida' ? 'Concluída' : 'Cancelada'}',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: const Color(0xFFF1F5F9),
                        child: Row(
                          children: [
                            const SizedBox(width: 200, child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                            const SizedBox(width: 80, child: Text('%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                            ...datas.map((data) => SizedBox(
                              width: 90,
                              child: Column(
                                children: [
                                  Text(
                                    data,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'P/O',
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      ...alunos.map((aluno) {
                        // Converte percentual para double
                        double percentual = 0;
                        if (aluno['percentual_presenca'] != null) {
                          if (aluno['percentual_presenca'] is String) {
                            percentual = double.tryParse(aluno['percentual_presenca']) ?? 0;
                          } else if (aluno['percentual_presenca'] is num) {
                            percentual = (aluno['percentual_presenca'] as num).toDouble();
                          }
                        }
                        
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  aluno['nome_completo'],
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: percentual >= 75 
                                        ? const Color(0xFF10B981).withOpacity(0.1) 
                                        : const Color(0xFFEF4444).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${percentual.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: percentual >= 75 
                                          ? const Color(0xFF10B981) 
                                          : const Color(0xFFEF4444),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              ...datas.map((data) {
                                final status = aluno['presencas'][data];
                                final observacao = aluno['observacoes'][data];
                                
                                String statusText = '';
                                Color statusColor = Colors.grey.shade400;
                                if (status == 'presente') {
                                  statusText = 'P';
                                  statusColor = const Color(0xFF10B981);
                                } else if (status == 'falta') {
                                  statusText = 'F';
                                  statusColor = const Color(0xFFEF4444);
                                }
                                
                                String obsText = '';
                                Color obsColor = Colors.grey.shade400;
                                if (observacao == '1- Está fumando') {
                                  obsText = 'F';
                                  obsColor = const Color(0xFFF59E0B);
                                } else if (observacao == '2- Sem fumar') {
                                  obsText = 'SF';
                                  obsColor = const Color(0xFF3B82F6);
                                }
                                
                                return SizedBox(
                                  width: 90,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32,
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            statusText,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                          ),
                                        ),
                                      ),
                                      if (obsText.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 32,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: obsColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              obsText,
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: obsColor),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar detalhes: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

Future<void> _confirmarEncerrarTurma(Map<String, dynamic> turma) async {
  String? tipoSelecionado;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Encerrar Turma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Turma: ${turma['nome']}\n\nSelecione o tipo de encerramento:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Turma Concluída'),
                        subtitle: const Text('O programa foi finalizado com sucesso'),
                        value: 'concluida',
                        groupValue: tipoSelecionado,
                        onChanged: (value) {
                          setState(() => tipoSelecionado = value);
                        },
                        activeColor: const Color(0xFF10B981),
                      ),
                      const Divider(),
                      RadioListTile<String>(
                        title: const Text('Turma Cancelada'),
                        subtitle: const Text('O programa foi interrompido antes do fim'),
                        value: 'cancelada',
                        groupValue: tipoSelecionado,
                        onChanged: (value) {
                          setState(() => tipoSelecionado = value);
                        },
                        activeColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
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
                        onPressed: tipoSelecionado == null ? null : () async {
                          Navigator.pop(context);
                          await _encerrarTurma(turma, tipoSelecionado!);
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          tipoSelecionado == 'concluida' ? 'Concluir' : 'Cancelar Turma',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tipoSelecionado == 'concluida' 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFEF4444),
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
        );
      },
    ),
  );
}

Future<void> _encerrarTurma(Map<String, dynamic> turma, String tipoEncerramento) async {
  try {
    final authService = AuthService();
    final upaId = widget.userData['upa_id'];
    await authService.encerrarTurma(upaId, turma['nome'], tipoEncerramento);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Turma encerrada com sucesso!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    
    setState(() {});
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao encerrar turma: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 50,
        right: 50,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            const Color(0xFF1A4A6F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(Icons.medical_services, color: Colors.white, size: 29),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel Enfermeira • $_upaNome',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 52),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Bem-vinda, ${_getUserFirstName()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ],
          ),
        ),
        onSelected: (String value) {
          if (value == 'alterar_senha') {
            _changePassword();
          } else if (value == 'sair') {
            _logout();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'alterar_senha',
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: Color(0xFF0F2B3D)),
                SizedBox(width: 12),
                Text('Alterar Senha', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'sair',
            child: Row(
              children: [
                Icon(Icons.logout_outlined, size: 20, color: Colors.red.shade400),
                const SizedBox(width: 12),
                Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserFirstName() {
    String nomeCompleto = widget.userData['nomeCompleto'] ?? 'Enfermeira';
    if (nomeCompleto.isNotEmpty && nomeCompleto.contains(' ')) {
      return nomeCompleto.split(' ').first;
    }
    return nomeCompleto;
  }

void _showLogoutConfirmationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sair da conta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tem certeza que deseja sair?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
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
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _performLogout() async {
  final authService = AuthService();
  await authService.logout();
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}

void _logout() {
  _showLogoutConfirmationDialog();
}

  Widget _buildDashboard() {
  return FutureBuilder(
    future: Future.wait([
      AuthService().getEnfermeiraDashboardStats(),
      AuthService().getEvolucaoGeral(),
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados: ${snapshot.error}'),
            ],
          ),
        );
      }
      
      final data = snapshot.data![0];
      final evolucaoData = snapshot.data![1];
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _exportarPDF(data, evolucaoData),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Exportar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(data),
            const SizedBox(height: 24),
            _buildDemographicSection(data),
            const SizedBox(height: 24),
            _buildHealthSection(data),
            const SizedBox(height: 24),
            _buildEvolucaoSection(evolucaoData),
            const SizedBox(height: 24),
            _buildChartSection(data),
          ],
        ),
      );
    },
  );
}

Future<void> _exportarPDF(Map<String, dynamic> data, Map<String, dynamic> evolucaoData) async {
  try {
    final nomeEnfermeira = widget.userData['nomeCompleto'] ?? _getUserFirstName();
    await PdfService.gerarRelatorioDashboardCompleto(data, evolucaoData, nomeEnfermeira, _upaNome);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

  Widget _buildStatsRow(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Usuários', data['totalUsuarios'].toString(), Icons.people, const Color(0xFF3B82F6))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Em Espera', data['totalEmEspera'].toString(), Icons.hourglass_empty, const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Matriculados', data['totalMatriculados'].toString(), Icons.check_circle, const Color(0xFF10B981))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Cancelados', data['totalCancelados'].toString(), Icons.cancel, const Color(0xFFEF4444))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildDemographicSection(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: Color(0xFF2C7DA0)),
                SizedBox(width: 8),
                Text('Demografia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Maiores de 18', '${data['maiores18']} usuários', Icons.person, const Color(0xFF3B82F6))),
                    Expanded(child: _buildInfoItem('Menores de 18', '${data['menores18']} usuários', Icons.child_care, const Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSexoDistribution(data['distribuicaoSexo']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexoDistribution(List<dynamic> sexoData) {
    int masculino = 0;
    int feminino = 0;
    int outro = 0;
    
    for (var item in sexoData) {
      if (item['sexo'] == 'Masculino') masculino = item['total'];
      else if (item['sexo'] == 'Feminino') feminino = item['total'];
      else outro = item['total'];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Distribuição por Sexo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSexoBar('Masculino', masculino, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _buildSexoBar('Feminino', feminino, const Color(0xFFEC4899))),
            const SizedBox(width: 12),
            Expanded(child: _buildSexoBar('Outro', outro, const Color(0xFF8B5CF6))),
          ],
        ),
      ],
    );
  }

  Widget _buildSexoBar(String label, int total, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(total.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildHealthSection(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.health_and_safety, size: 20, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Saúde', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildHealthItem('Comorbidade - Câncer', '${data['usuariosComCancer']} usuários', Icons.health_and_safety, const Color(0xFFEF4444))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHealthItem('Comorbidade - Cardiovascular', '${data['usuariosComCardiovascular']} usuários', Icons.favorite, const Color(0xFFEC4899))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHealthItem('Média Score Fagerström', '${double.parse(data['mediaScoreFagestrom'].toString()).toStringAsFixed(1)} pontos', Icons.assessment, _accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, dynamic> data) {
    final usuariosPorMes = data['usuariosPorMes'] as List;
    
    if (usuariosPorMes.isEmpty) {
      return Container();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text('Matrículas por Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 250,
              child: usuariosPorMes.reversed.toList().isEmpty
                  ? const Center(child: Text('Sem dados'))
                  : _buildBarChart(usuariosPorMes.reversed.toList()),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildBarChart(List<dynamic> dados) {
  List<String> meses = [];
  List<double> valores = [];
  
  for (var item in dados) {
    meses.add(item['mes']);
    double valor = (item['total'] as num).toDouble();
    valores.add(valor);
  }
  
  if (valores.isEmpty) {
    return const Center(child: Text('Sem dados', style: TextStyle(color: Color(0xFF64748B))));
  }
  
  final maxValor = valores.reduce((a, b) => a > b ? a : b);
  
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(dados.length, (index) {
      double altura = 0;
      if (maxValor > 0) {
        altura = (valores[index] / maxValor) * 150;
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valores[index].toInt().toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
const Icon(Icons.show_chart, size: 20, color: Color(0xFF2C7DA0)),
Container(
  width: 40,
  height: altura,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF2C7DA0), Color(0xFF1A4A6F)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    borderRadius: BorderRadius.circular(8),
  ),
),
          const SizedBox(height: 8),
          Text(meses[index].toString().substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      );
    }),
  );
}

Widget _buildUsuariosList() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou email...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                              onPressed: _limparBusca,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _accentColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (_) => _buscarUsuarios(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFiltrosChips(),
          ],
        ),
      ),
      Expanded(
        child: _carregandoUsuarios
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchQuery.isEmpty 
                          ? _getFiltroTitulo()
                          : 'Resultados para: "$_searchQuery"',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: $_totalUsuarios usuários',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    ..._usuarios.map((usuario) => _buildUsuarioCard(usuario)),
                    const SizedBox(height: 16),
                    _buildPagination(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    ],
  );
}

Widget _buildFiltrosChips() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: _filtros.map((filtro) {
        final isSelected = _statusFiltro == filtro['valor'];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(filtro['label']),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _statusFiltro = filtro['valor'];
                _currentPage = 1; 
                _carregarUsuarios(page: 1);
              });
            },
            backgroundColor: Colors.white,
            selectedColor: (filtro['cor'] as Color).withOpacity(0.1),
            checkmarkColor: filtro['cor'],
            labelStyle: TextStyle(
              color: isSelected ? filtro['cor'] : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? filtro['cor'] : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        );
      }).toList(),
    ),
  );
}

String _getFiltroTitulo() {
  switch (_statusFiltro) {
    case 'todos': return 'Todos os Usuários';
    case 'em_espera': return 'Usuários em Espera';
    case 'matriculado': return 'Usuários Matriculados';
    case 'cancelada': return 'Usuários Cancelados';
    default: return 'Usuários';
  }
}

  String _formatarTelefone(String telefone) {
  if (telefone.isEmpty) return 'Não informado';
  String apenasNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
  if (apenasNumeros.length == 11) {
    return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
  } else if (apenasNumeros.length == 10) {
    return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
  }
  return telefone;
}

String _formatarCpf(String cpf) {
  if (cpf.isEmpty) return 'Não informado';
  String apenasNumeros = cpf.replaceAll(RegExp(r'[^\d]'), '');
  if (apenasNumeros.length == 11) {
    return '${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}';
  }
  return cpf;
}

String _formatarData(String? data) {
  if (data == null || data.isEmpty) return '-';
  String dataLimpa = data.split('T')[0];
  final partes = dataLimpa.split('-');
  if (partes.length != 3) return dataLimpa;
  return '${partes[2]}/${partes[1]}/${partes[0]}';
}

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
  final status = usuario['status'];
  final telefone = usuario['telefone'] ?? '';
  final telefoneFormatado = _formatarTelefone(telefone);
  final cpf = usuario['cpf'] ?? 'Não informado';
  final cpfFormatado = cpf != 'Não informado' ? _formatarCpf(cpf) : cpf;
  final idade = usuario['idade'] ?? 0;
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _accentColor.withOpacity(0.1),
                child: Text(usuario['nome_completo'][0].toUpperCase(), style: TextStyle(color: _accentColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usuario['nome_completo'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF0F172A))),
                    Text(usuario['email'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_getStatusText(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(status))),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.phone, 'Telefone', telefoneFormatado),
              _buildInfoRow(Icons.assignment_ind, 'CPF', cpfFormatado),
              _buildInfoRow(Icons.cake, 'Idade', '$idade anos'),
              if (usuario['turma_horario'] != null)
                _buildInfoRow(Icons.schedule, 'Turma', usuario['turma_horario']),
              const SizedBox(height: 12),
             if (status != 'cancelada')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _verDetalhes(usuario),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Ver detalhes'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _accentColor),
                          foregroundColor: _accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  );
}

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1 ? () => _carregarUsuarios(page: _currentPage - 1) : null,
          style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Página $_currentPage de $_totalPages', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _accentColor)),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < _totalPages ? () => _carregarUsuarios(page: _currentPage + 1) : null,
          style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }

Future<void> _carregarUsuarios({int page = 1}) async {
  setState(() {
    _carregandoUsuarios = true;  
    _currentPage = page;
  });
  
  String statusFilter = '';
  if (_statusFiltro != 'todos') {
    statusFilter = _statusFiltro;
  }
  
  try {
    final authService = AuthService();
    final response = await authService.getUsuariosDaUPA(
      page: page,
      limit: 8,
      search: _searchQuery,
      status: statusFilter,
    );
    
    List<Map<String, dynamic>> usuarios = List<Map<String, dynamic>>.from(response['usuarios']);
    
    if (_statusFiltro == 'todos') {
      usuarios.sort((a, b) {
        final ordemStatus = {
          'em_espera': 0,    
          'matriculado': 1,  
          'cancelada': 2,   
        };
        
        final statusA = a['status'] ?? '';
        final statusB = b['status'] ?? '';
        
        final ordemA = ordemStatus[statusA] ?? 3;
        final ordemB = ordemStatus[statusB] ?? 3;
        
        if (ordemA != ordemB) {
          return ordemA.compareTo(ordemB);
        }
        
        final dataA = a['created_at'] ?? '';
        final dataB = b['created_at'] ?? '';
        return dataB.compareTo(dataA);
      });
    }
    
    setState(() {
      _usuarios = usuarios;
      _totalPages = response['totalPages'];
      _totalUsuarios = response['total'];
      _carregandoUsuarios = false;
    });
  } catch (e) {
    setState(() => _carregandoUsuarios = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar usuários: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

  void _buscarUsuarios() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = _searchController.text;
      _carregarUsuarios(page: 1);
    });
  }

  void _limparBusca() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
    _carregarUsuarios(page: 1);
  }

  void _verDetalhes(Map<String, dynamic> usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUsuarioDetalhesScreen(
          usuarioId: usuario['id'],
          usuarioNome: usuario['nome_completo'],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera': return 'Em Espera';
      case 'confirmada': return 'Confirmada';
      case 'matriculado': return 'Matriculado';
      case 'recusada': return 'Recusada';
      case 'cancelada': return 'Cancelada';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera': return const Color(0xFFF59E0B);
      case 'confirmada': return const Color(0xFF10B981);
      case 'matriculado': return const Color(0xFF8B5CF6);
      case 'recusada': return Colors.red;
      case 'cancelada': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)))),
        ],
      ),
    );
  }
}