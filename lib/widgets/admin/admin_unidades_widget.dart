import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/cep_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminUPAsWidget extends StatefulWidget {
  const AdminUPAsWidget({Key? key}) : super(key: key);

  @override
  _AdminUPAsWidgetState createState() => _AdminUPAsWidgetState();
}

class _AdminUPAsWidgetState extends State<AdminUPAsWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _dangerColor = const Color(0xFFC65D47);
  final Color _warningColor = const Color(0xFFD97706);

  List<Map<String, dynamic>> _upas = [];
  List<Map<String, dynamic>> _enfermeiras = [];
  bool _carregando = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUPAs = 0;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final authService = AuthService();
      final response = await authService.getUPAs(
        page: _currentPage,
        limit: 8,
        search: _searchQuery,
      );
      final enfermeiras = await authService.getEnfermeiras();
      setState(() {
        _upas = List<Map<String, dynamic>>.from(response['upas']);
        _totalPages = response['totalPages'];
        _totalUPAs = response['total'];
        _enfermeiras = enfermeiras;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      ToastService.showError(context, 'Erro ao carregar dados: $e');
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
      floatingLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: _accentColor,
      ),
      prefixIcon: Icon(icon, color: _accentColor, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFDBDBDB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String _formatarTelefone(String? telefone) {
    if (telefone == null || telefone.isEmpty) return 'Não informado';
    String apenasNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 10) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
    } else if (apenasNumeros.length == 11) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
    }
    return telefone;
  }

  String _formatarCep(String cep) {
    if (cep.isEmpty) return '';
    String limpo = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (limpo.length == 8) {
      return '${limpo.substring(0, 5)}-${limpo.substring(5)}';
    }
    return cep;
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';
    String apenasNumeros = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 11) {
      return '${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}';
    }
    return cpf;
  }

  List<String> _getDiasPermitidos(String horarioFuncionamento) {
    if (horarioFuncionamento.contains('Segunda a Sexta')) {
      return ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira'];
    } else if (horarioFuncionamento.contains('Segunda a Sábado')) {
      return ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
    } else if (horarioFuncionamento.contains('Domingo a Domingo')) {
      return ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'];
    }
    return ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
  }

  List<String> _getHorariosPermitidos(String horarioFuncionamento) {
    RegExp regExp = RegExp(r'(\d{2})h');
    List<String> horariosPermitidos = [];
    
    int horaFechamento = 24;
    if (horarioFuncionamento.contains('às')) {
      String parteFechamento = horarioFuncionamento.split('às').last.trim();
      var match = regExp.firstMatch(parteFechamento);
      if (match != null) {
        horaFechamento = int.parse(match.group(1)!);
      }
    } else if (horarioFuncionamento.contains('24 horas')) {
      horaFechamento = 24;
    }
    
    if (horaFechamento >= 20) {
      horariosPermitidos = ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '16:00 - 18:00', '18:00 - 20:00'];
    } else if (horaFechamento >= 18) {
      horariosPermitidos = ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '16:00 - 18:00'];
    } else if (horaFechamento >= 17) {
      horariosPermitidos = ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00'];
    } else if (horaFechamento >= 12) {
      horariosPermitidos = ['08:00 - 10:00', '10:00 - 12:00'];
    } else {
      horariosPermitidos = ['08:00 - 10:00'];
    }
    
    return horariosPermitidos;
  }

  Future<bool?> _showConfirmDeleteDialog({required String title, required String message}) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.only(
          left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
          right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
          top: 20,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: _dangerColor, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 20.0;

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: isMobile
              ? Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: _buildInputDecoration('Buscar por nome, endereço ou cidade...', Icons.search),
                      onChanged: (value) {
                        _searchQuery = value;
                        _currentPage = 1;
                        _carregarDados();
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _abrirModalUPA(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nova Unidade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(0, 42),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: _buildInputDecoration('Buscar por nome, endereço ou cidade...', Icons.search),
                        onChanged: (value) {
                          _searchQuery = value;
                          _currentPage = 1;
                          _carregarDados();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _abrirModalUPA(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nova Unidade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(0, 56),
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _searchQuery.isEmpty
                      ? 'Todas as Unidades'
                      : 'Resultados para: "$_searchQuery"',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $_totalUPAs unidades',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ..._upas.map((upa) => _buildUPACard(upa)),
                const SizedBox(height: 16),
                _buildPaginacao(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginacao() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _currentPage > 1 ? () {
              setState(() => _currentPage--);
              _carregarDados();
            } : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_currentPage / $_totalPages',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _accentColor),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: _currentPage < _totalPages ? () {
              setState(() => _currentPage++);
              _carregarDados();
            } : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUPACard(Map<String, dynamic> upa) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final telefoneFormatado = _formatarTelefone(upa['telefone']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.local_hospital, color: _accentColor, size: isMobile ? 18 : 24),
        ),
        title: Text(
          upa['nome'],
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: isMobile ? 14 : 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    upa['endereco'] ?? 'Endereço não informado',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.place, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    upa['cep'] != null && upa['cep'].toString().isNotEmpty
                        ? 'CEP: ${_formatarCep(upa['cep'].toString())}'
                        : 'CEP não informado',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.phone, size: isMobile ? 12 : 14, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    telefoneFormatado,
                    style: TextStyle(fontSize: isMobile ? 10 : 11, color: const Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility, color: const Color(0xFF3B82F6), size: isMobile ? 18 : 20),
              onPressed: () => _abrirModalVisualizarUPA(upa),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: _warningColor, size: isMobile ? 18 : 20),
              onPressed: () => _abrirModalUPA(upa: upa),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: _dangerColor, size: isMobile ? 18 : 20),
              onPressed: () => _confirmarDeletarUPA(upa),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirModalVisualizarUPA(Map<String, dynamic> upa) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    List<Map<String, dynamic>> enfermeirasDaUPA = _enfermeiras.where((e) => e['upa_id'] == upa['id']).toList();
    List<Map<String, dynamic>> turmasDaUPA = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (turmasDaUPA.isEmpty) {
              try {
                final authService = AuthService();
                authService.getTurmasPorUPA(upa['id']).then((turmas) {
                  setState(() {
                    turmasDaUPA = List<Map<String, dynamic>>.from(turmas);
                  });
                });
              } catch (e) {
                print('Erro ao carregar turmas: $e');
              }
            }

            Map<String, List<String>> turmasAgrupadas = {};
            for (var turma in turmasDaUPA) {
              String dia = turma['dia_semana'] ?? '';
              String horario = turma['horario'] ?? '';
              if (!turmasAgrupadas.containsKey(dia)) {
                turmasAgrupadas[dia] = [];
              }
              turmasAgrupadas[dia]!.add(horario);
            }

            return Dialog(
              insetPadding: EdgeInsets.only(
                left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                top: 20,
                bottom: 20,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
                width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 500,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_hospital, color: Color(0xFF1F4E6E), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              upa['nome'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: const Color(0xFF64748B)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Endereço',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    upa['endereco'] ?? 'Não informado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.place, size: 16, color: const Color(0xFF64748B)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'CEP',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatarCep(upa['cep']?.toString() ?? ''),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_city, size: 16, color: const Color(0xFF64748B)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Cidade',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    upa['cidade'] ?? 'Não informado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: const Color(0xFF64748B)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Telefone',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatarTelefone(upa['telefone']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 16, color: const Color(0xFF64748B)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Horário',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    upa['horario'] ?? 'Não informado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Dias e Horários de Funcionamento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: turmasDaUPA.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Carregando turmas...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: turmasAgrupadas.entries.map((entry) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: entry.key == turmasAgrupadas.keys.last ? 0 : 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _accentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(Icons.calendar_today, color: _accentColor, size: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: entry.value.map((horario) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _accentColor.withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: _accentColor.withValues(alpha: 0.15),
                                                  ),
                                                ),
                                                child: Text(
                                                  horario,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: _accentColor,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      if (enfermeirasDaUPA.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Enfermeiras Vinculadas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: enfermeirasDaUPA.map((e) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: enfermeirasDaUPA.indexOf(e) == enfermeirasDaUPA.length - 1 ? 0 : 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.medical_services, color: _accentColor, size: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e['nome_completo'],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            e['email'],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            'CPF: ${_formatarCpf(e['cpf'] ?? '')}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          Text(
                                            'Telefone: ${_formatarTelefone(e['telefone'])}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Fechar',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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

  void _abrirModalUPA({Map<String, dynamic>? upa}) async {
    final isEditing = upa != null;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    final nomeController = TextEditingController(text: upa?['nome'] ?? '');
    final cepController = TextEditingController(text: upa?['cep']?.toString() ?? '');
    final ruaController = TextEditingController();
    final numeroController = TextEditingController();
    final bairroController = TextEditingController();
    final cidadeController = TextEditingController(text: upa?['cidade'] ?? 'Mogi das Cruzes');
    final telefoneController = MaskedTextController(
      mask: '(00) 0000-0000',
      text: upa?['telefone'] ?? '',
    );

    String nomeOriginal = upa?['nome'] ?? '';
    String cepOriginal = upa?['cep']?.toString() ?? '';
    String ruaOriginal = '';
    String numeroOriginal = '';
    String bairroOriginal = '';
    String cidadeOriginal = upa?['cidade'] ?? 'Mogi das Cruzes';
    String telefoneOriginal = upa?['telefone'] ?? '';
    String horarioOriginal = upa?['horario'] ?? '';

    if (upa != null && upa['endereco'] != null) {
      final enderecoStr = upa['endereco'].toString();
      if (enderecoStr.contains(' - ')) {
        final partes = enderecoStr.split(' - ');
        final ruaNumero = partes[0];
        bairroOriginal = partes[1];
        if (ruaNumero.contains(',')) {
          final ruaNumeroParts = ruaNumero.split(',');
          ruaOriginal = ruaNumeroParts[0].trim();
          if (ruaNumeroParts.length > 1) {
            numeroOriginal = ruaNumeroParts[1].trim();
          }
        } else {
          ruaOriginal = ruaNumero;
        }
      } else {
        final partes = enderecoStr.split(',');
        if (partes.isNotEmpty) ruaOriginal = partes[0].trim();
        if (partes.length > 1) {
          if (partes[1].contains('-')) {
            final numeroBairro = partes[1].split('-');
            numeroOriginal = numeroBairro[0].trim();
            if (numeroBairro.length > 1) bairroOriginal = numeroBairro[1].trim();
          } else {
            numeroOriginal = partes[1].trim();
            if (partes.length > 2) bairroOriginal = partes[2].trim();
          }
        }
      }
    }

    ruaController.text = ruaOriginal;
    numeroController.text = numeroOriginal;
    bairroController.text = bairroOriginal;

    final List<String> horariosPadrao = [
      '24 horas',
      'Segunda a Sexta: 07h às 17h',
      'Segunda a Sexta: 08h às 18h',
      'Segunda a Sexta: 08h às 20h',
      'Segunda a Sexta: 07h às 19h',
      'Segunda a Sábado: 08h às 17h',
      'Segunda a Sábado: 07h às 19h',
      'Domingo a Domingo: 24 horas',
      'Segunda, Quarta e Sexta: 08h às 12h',
      'Terça e Quinta: 13h às 17h',
    ];

    String horarioAtual = upa?['horario'] ?? '';
    String? horarioSelecionado = horariosPadrao.contains(horarioAtual) ? horarioAtual : null;

    bool isLoading = false;
    bool buscandoCep = false;

    final List<String> diasSemana = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'
    ];

    final List<String> horariosTurmas = [
      '08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '16:00 - 18:00', '18:00 - 20:00'
    ];

    List<Map<String, dynamic>> turmasSelecionadas = [];

    if (isEditing) {
      try {
        final authService = AuthService();
        final turmas = await authService.getTurmasPorUPA(upa!['id']);
        turmasSelecionadas = List<Map<String, dynamic>>.from(turmas);
      } catch (e) {
        print('Erro ao carregar turmas: $e');
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isFormValid() {
              if (nomeController.text.trim().isEmpty) return false;
              if (ruaController.text.trim().isEmpty) return false;
              if (numeroController.text.trim().isEmpty) return false;
              if (bairroController.text.trim().isEmpty) return false;
              if (cidadeController.text.trim().isEmpty) return false;
              String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (telefoneLimpo.length != 10 && telefoneLimpo.length != 11) return false;
              if (horarioSelecionado == null) return false;
              if (turmasSelecionadas.isEmpty) return false;
              return true;
            }

            bool hasChanges() {
              if (nomeController.text.trim() != nomeOriginal) return true;
              String cepLimpo = cepController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (cepLimpo != cepOriginal) return true;
              if (ruaController.text.trim() != ruaOriginal) return true;
              if (numeroController.text.trim() != numeroOriginal) return true;
              if (bairroController.text.trim() != bairroOriginal) return true;
              if (cidadeController.text.trim() != cidadeOriginal) return true;
              String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (telefoneLimpo != telefoneOriginal) return true;
              if (horarioSelecionado != horarioOriginal) return true;
              return false;
            }

            bool canSave() {
              if (!isFormValid()) return false;
              if (isEditing && !hasChanges()) return false;
              return true;
            }

            List<String> diasPermitidos = _getDiasPermitidos(horarioSelecionado ?? '');
            List<String> horariosPermitidos = _getHorariosPermitidos(horarioSelecionado ?? '');

            return Dialog(
              insetPadding: EdgeInsets.only(
                left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                top: 20,
                bottom: 20,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(isSmallMobile ? 12 : 20),
                width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 700,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.95,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(isEditing ? Icons.edit : Icons.add, color: _successColor, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEditing ? 'Editar Unidade' : 'Nova Unidade',
                            style: TextStyle(
                              fontSize: isSmallMobile ? 16 : 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nomeController,
                        onChanged: (_) => setState(() {}),
                        decoration: _buildInputDecoration('Nome da Unidade', Icons.local_hospital),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cepController,
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              onChanged: (value) async {
                                if (value.replaceAll(RegExp(r'[^\d]'), '').length == 8) {
                                  setState(() => buscandoCep = true);
                                  try {
                                    final endereco = await CepService.buscarEndereco(value);
                                    setState(() {
                                      ruaController.text = endereco['logradouro'];
                                      bairroController.text = endereco['bairro'];
                                      cidadeController.text = endereco['cidade'];
                                      buscandoCep = false;
                                    });
                                    ToastService.showSuccess(context, 'Endereço encontrado com sucesso!');
                                  } catch (e) {
                                    setState(() => buscandoCep = false);
                                    ToastService.showError(context, 'Erro ao buscar CEP: $e');
                                  }
                                }
                              },
                              decoration: _buildInputDecoration('CEP', Icons.location_on).copyWith(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (buscandoCep)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: ruaController,
                              onChanged: (_) => setState(() {}),
                              decoration: _buildInputDecoration('Rua', Icons.location_on),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: numeroController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: _buildInputDecoration('Número', Icons.numbers),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: bairroController,
                        onChanged: (_) => setState(() {}),
                        decoration: _buildInputDecoration('Bairro', Icons.location_city),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: cidadeController,
                        enabled: false,
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration('Cidade', Icons.location_city).copyWith(
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: telefoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() {}),
                        decoration: _buildInputDecoration('Telefone', Icons.phone),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: horarioSelecionado,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            hintText: 'Selecione o horário de funcionamento',
                          ),
                          hint: Text(
                            'Selecione o horário de funcionamento',
                            style: TextStyle(
                              fontSize: isSmallMobile ? 12 : 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down, color: _accentColor),
                          dropdownColor: Colors.white,
                          style: TextStyle(
                            fontSize: isSmallMobile ? 13 : 14,
                            color: const Color(0xFF0F172A),
                          ),
                          onChanged: (value) {
                            setState(() {
                              horarioSelecionado = value;
                            });
                          },
                          items: horariosPadrao.map((horario) {
                            return DropdownMenuItem<String>(
                              value: horario,
                              child: Row(
                                children: [
                                  Icon(
                                    horario.contains('24 horas') ? Icons.nightlight_round :
                                    horario.contains('Segunda') ? Icons.today :
                                    Icons.schedule,
                                    size: 16,
                                    color: _accentColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      horario,
                                      style: TextStyle(
                                        fontSize: isSmallMobile ? 12 : 13,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule, color: _accentColor, size: isSmallMobile ? 16 : 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Turmas Disponíveis para Matrícula',
                                  style: TextStyle(
                                    fontSize: isSmallMobile ? 13 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Selecione os dias e horários que esta unidade oferecerá turmas',
                              style: TextStyle(fontSize: isSmallMobile ? 10 : 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                            ...diasSemana.map((dia) {
                              bool diaPermitido = diasPermitidos.contains(dia);
                              int qtdHorariosSelecionados = turmasSelecionadas.where((t) => t['dia_semana'] == dia).length;

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              if (!diaPermitido)
                                                Icon(Icons.block, size: isSmallMobile ? 14 : 16, color: Colors.grey.shade400),
                                              const SizedBox(width: 4),
                                              Text(
                                                dia,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: isSmallMobile ? 11 : 13,
                                                  color: diaPermitido ? const Color(0xFF0F172A) : Colors.grey.shade400,
                                                ),
                                              ),
                                              if (diaPermitido && qtdHorariosSelecionados > 0) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _accentColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    '$qtdHorariosSelecionados',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: _accentColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            alignment: WrapAlignment.start,
                                            children: horariosTurmas.map((horario) {
                                              bool horarioPermitido = horariosPermitidos.contains(horario);
                                              bool isSelected = turmasSelecionadas.any((t) => t['dia_semana'] == dia && t['horario'] == horario);

                                              if (!diaPermitido || !horarioPermitido) {
                                                return Tooltip(
                                                  message: !diaPermitido
                                                      ? 'Unidade não funciona neste dia'
                                                      : 'Unidade não atende neste horário',
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.grey.shade300),
                                                    ),
                                                    child: Text(
                                                      horario,
                                                      style: TextStyle(
                                                        fontSize: isSmallMobile ? 8 : 10,
                                                        color: Colors.grey.shade400,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (isSelected) {
                                                      turmasSelecionadas.removeWhere((t) => t['dia_semana'] == dia && t['horario'] == horario);
                                                    } else {
                                                      turmasSelecionadas.add({
                                                        'dia_semana': dia,
                                                        'horario': horario,
                                                        'vagas_totais': 4,
                                                        'vagas_ocupadas': 0,
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? _accentColor : Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: isSelected ? _accentColor : Colors.grey.shade300,
                                                      width: 1,
                                                    ),
                                                    boxShadow: isSelected ? [
                                                      BoxShadow(
                                                        color: _accentColor.withValues(alpha: 0.2),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ] : [],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (isSelected)
                                                        const Icon(Icons.check_circle, size: 12, color: Colors.white),
                                                      if (isSelected) const SizedBox(width: 4),
                                                      Text(
                                                        horario,
                                                        style: TextStyle(
                                                          fontSize: isSmallMobile ? 9 : 11,
                                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                                          color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 2, color: Colors.grey.shade200),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(double.infinity, 40),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (isLoading || !canSave()) ? null : () async {
                                if (nomeController.text.isEmpty) {
                                  ToastService.showError(context, 'Nome da unidade é obrigatório');
                                  return;
                                }
                                if (ruaController.text.isEmpty) {
                                  ToastService.showError(context, 'Rua é obrigatória');
                                  return;
                                }
                                if (numeroController.text.isEmpty) {
                                  ToastService.showError(context, 'Número é obrigatório');
                                  return;
                                }
                                if (bairroController.text.isEmpty) {
                                  ToastService.showError(context, 'Bairro é obrigatório');
                                  return;
                                }
                                if (telefoneController.text.isEmpty) {
                                  ToastService.showError(context, 'Telefone é obrigatório');
                                  return;
                                }

                                if (horarioSelecionado == null) {
                                  ToastService.showError(context, 'Selecione um horário de funcionamento');
                                  return;
                                }
                                String horarioFinal = horarioSelecionado!;

                                if (turmasSelecionadas.isEmpty) {
                                  ToastService.showError(context, 'Selecione pelo menos uma turma');
                                  return;
                                }

                                String enderecoCompleto = '${ruaController.text}, ${numeroController.text} - ${bairroController.text}';

                                setState(() => isLoading = true);

                                try {
                                  final authService = AuthService();
                                  final data = {
                                    'nome': nomeController.text,
                                    'endereco': enderecoCompleto,
                                    'cep': cepController.text.replaceAll(RegExp(r'[^\d]'), ''),
                                    'cidade': cidadeController.text,
                                    'telefone': telefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
                                    'horario': horarioFinal,
                                    'turmas': turmasSelecionadas.map((t) => ({
                                      'dia_semana': t['dia_semana'],
                                      'horario': t['horario'],
                                      'vagas_totais': t['vagas_totais'],
                                    })).toList(),
                                  };

                                  if (isEditing) {
                                    await authService.atualizarUPAComTurmas(upa!['id'], data);
                                    ToastService.showSuccess(context, 'Unidade "${nomeController.text}" atualizada com sucesso!');
                                  } else {
                                    await authService.criarUPAComTurmas(data);
                                    ToastService.showSuccess(context, 'Unidade "${nomeController.text}" criada com sucesso!');
                                  }

                                  Navigator.pop(context);
                                  _carregarDados();
                                } catch (e) {
                                  ToastService.showError(context, 'Erro ao ${isEditing ? "atualizar" : "criar"} Unidade: $e');
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canSave() ? _successColor : Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(double.infinity, 40),
                              ),
                              child: isLoading
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isEditing ? Icons.save : Icons.add,
                                          size: 16,
                                          color: canSave() ? Colors.white : Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isEditing ? 'Salvar' : 'Criar',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: canSave() ? Colors.white : Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
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

  Future<void> _confirmarDeletarUPA(Map<String, dynamic> upa) async {
    final confirm = await _showConfirmDeleteDialog(
      title: 'Excluir Unidade',
      message: 'Tem certeza que deseja excluir a unidade "${upa['nome']}"?\n\nEsta ação não pode ser desfeita.',
    );

    if (confirm == true) {
      try {
        final authService = AuthService();
        await authService.deletarUPA(upa['id']);
        ToastService.showSuccess(context, 'Unidade "${upa['nome']}" excluída com sucesso!');
        _carregarDados();
      } catch (e) {
        ToastService.showError(context, 'Erro ao excluir unidade: $e');
      }
    }
  }
}