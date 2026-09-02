import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminEnfermeirasWidget extends StatefulWidget {
  const AdminEnfermeirasWidget({Key? key}) : super(key: key);

  @override
  _AdminEnfermeirasWidgetState createState() => _AdminEnfermeirasWidgetState();
}

class _AdminEnfermeirasWidgetState extends State<AdminEnfermeirasWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _dangerColor = const Color(0xFFC65D47);

  List<Map<String, dynamic>> _enfermeiras = [];
  List<Map<String, dynamic>> _upasLista = [];
  bool _carregando = true;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _carregandoLista = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _carregarDados();
  }

void _onSearchChanged() {
  setState(() {
    _searchQuery = _searchController.text;
  });
}

  Timer? _debounceTimer;
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _carregarDados();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    _carregandoLista.dispose();
    super.dispose();
  }

Future<void> _carregarDados() async {
  _carregandoLista.value = true;
  try {
    final authService = AuthService();
    final enfermeiras = await authService.getEnfermeiras();
    final upas = await authService.getUPAsLista();
    _enfermeiras = enfermeiras;
    _upasLista = upas;
    _carregando = false;
    _carregandoLista.value = false;
    setState(() {});
  } catch (e) {
    _carregando = false;
    _carregandoLista.value = false;
    setState(() {});
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

  Map<int, List<Map<String, dynamic>>> _agruparPorUPA(List<Map<String, dynamic>> enfermeiras) {
    Map<int, List<Map<String, dynamic>>> grupos = {};
    for (var e in enfermeiras) {
      int upaId = e['upa_id'] ?? 0;
      if (!grupos.containsKey(upaId)) grupos[upaId] = [];
      grupos[upaId]!.add(e);
    }
    return grupos;
  }

  String _getUpaNome(int? upaId) {
    if (upaId == null) return 'Sem unidade vinculada';
    final upa = _upasLista.firstWhere((u) => u['id'] == upaId, orElse: () => {'nome': 'Unidade não encontrada'});
    return upa['nome'];
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';
    String apenasNumeros = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 11) {
      return '${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}';
    }
    return cpf;
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Excluir',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 20.0;
    final enfermeirasFiltradas = _enfermeiras.where((e) {
  final nome = e['nome_completo'].toLowerCase();
  final upaNome = (e['upa_nome'] ?? '').toLowerCase();
  final search = _searchQuery.toLowerCase();
  return nome.contains(search) || upaNome.contains(search);
}).toList();

final grupos = _agruparPorUPA(enfermeirasFiltradas);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: isMobile
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: _buildInputDecoration('Buscar por nome ou unidade...', Icons.search),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _abrirModalEnfermeira(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(0, 56),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: _buildInputDecoration('Buscar por nome ou unidade...', Icons.search),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _abrirModalEnfermeira(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nova Enfermeira'),
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
          child: ValueListenableBuilder(
            valueListenable: _carregandoLista,
            builder: (context, carregando, child) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _searchQuery.isEmpty
                              ? 'Enfermeiras Cadastradas'
                              : 'Resultados para: "$_searchQuery"',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${enfermeirasFiltradas.length} enfermeiras',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        if (enfermeirasFiltradas.isEmpty && !carregando)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                'Nenhuma enfermeira encontrada',
                                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                              ),
                            ),
                          )
                        else
                          ...grupos.entries.map((entry) {
                            final upaId = entry.key == 0 ? null : entry.key;
                            final upaNome = _getUpaNome(upaId);
                            final enfermeirasDaUPA = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _accentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.local_hospital, size: isMobile ? 16 : 18, color: _accentColor),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            upaNome,
                                            style: TextStyle(
                                              fontSize: isMobile ? 14 : 16,
                                              fontWeight: FontWeight.w600,
                                              color: _accentColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _accentColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${enfermeirasDaUPA.length}',
                                            style: TextStyle(
                                              fontSize: isMobile ? 12 : 14,
                                              fontWeight: FontWeight.w600,
                                              color: _accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: enfermeirasDaUPA.map((e) => _buildEnfermeiraCard(e)).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  if (carregando)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnfermeiraCard(Map<String, dynamic> enfermeira) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.medical_services, color: _accentColor, size: isMobile ? 18 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enfermeira['nome_completo'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
                Text(
                  enfermeira['email'],
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  'CPF: ${_formatarCpf(enfermeira['cpf'] ?? '')}',
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: const Color(0xFF3B82F6), size: isMobile ? 18 : 20),
                onPressed: () => _abrirModalEnfermeira(enfermeira: enfermeira),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: _dangerColor, size: isMobile ? 18 : 20),
                onPressed: () => _confirmarDeletarEnfermeira(enfermeira),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirModalEnfermeira({Map<String, dynamic>? enfermeira}) {
    final isEditing = enfermeira != null;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    final nomeController = TextEditingController(text: enfermeira?['nome_completo'] ?? '');
    final emailController = TextEditingController(text: enfermeira?['email'] ?? '');
    final cpfController = MaskedTextController(
      mask: '000.000.000-00',
      text: enfermeira?['cpf'] ?? '',
    );
    final telefoneController = MaskedTextController(
      mask: '(00) 00000-0000',
      text: enfermeira?['telefone'] ?? '',
    );
    final senhaController = TextEditingController();
    int? upaIdSelecionado = enfermeira?['upa_id'];
    bool isLoading = false;

    String nomeOriginal = enfermeira?['nome_completo'] ?? '';
    String emailOriginal = enfermeira?['email'] ?? '';
    String cpfOriginal = enfermeira?['cpf'] ?? '';
    String telefoneOriginal = enfermeira?['telefone'] ?? '';
    int? upaOriginal = enfermeira?['upa_id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isFormValid() {
              if (nomeController.text.trim().isEmpty) return false;
              if (emailController.text.trim().isEmpty) return false;
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) return false;
              String cpfLimpo = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (cpfLimpo.length != 11) return false;
              String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (telefoneLimpo.length != 11) return false;
              if (!isEditing && senhaController.text.isEmpty) return false;
              if (isEditing && senhaController.text.isNotEmpty && senhaController.text.length < 6) return false;
              if (upaIdSelecionado == null) return false;
              return true;
            }

            bool hasChanges() {
              if (nomeController.text.trim() != nomeOriginal) return true;
              if (emailController.text.trim() != emailOriginal) return true;
              String cpfLimpo = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (cpfLimpo != cpfOriginal) return true;
              String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (telefoneLimpo != telefoneOriginal) return true;
              if (upaIdSelecionado != upaOriginal) return true;
              if (senhaController.text.isNotEmpty) return true;
              return false;
            }

            bool canSave() {
              if (!isFormValid()) return false;
              if (isEditing && !hasChanges()) return false;
              return true;
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
                padding: EdgeInsets.all(isSmallMobile ? 16 : 20),
                width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 450,
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
                          child: Icon(isEditing ? Icons.edit : Icons.person_add, color: _accentColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEditing ? 'Editar Enfermeira' : 'Nova Enfermeira',
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
                      decoration: _buildInputDecoration('Nome Completo', Icons.person),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cpfController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('CPF', Icons.assignment_ind),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('Email', Icons.email),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('Telefone', Icons.phone),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: upaIdSelecionado,
                      isExpanded: true,
                      decoration: _buildInputDecoration('Unidade Vinculada', Icons.local_hospital),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('Selecione uma unidade')),
                        ..._upasLista.map((upa) => DropdownMenuItem<int>(
                          value: upa['id'],
                          child: Text(upa['nome']),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => upaIdSelecionado = value);
                      },
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                        decoration: _buildInputDecoration('Senha', Icons.lock),
                      ),
                    ],
                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                        decoration: _buildInputDecoration('Nova Senha (opcional)', Icons.lock_reset),
                      ),
                    ],
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
                                ToastService.showError(context, 'Nome é obrigatório');
                                return;
                              }
                              if (emailController.text.isEmpty) {
                                ToastService.showError(context, 'Email é obrigatório');
                                return;
                              }
                              final cpfLimpo = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
                              if (cpfLimpo.length != 11) {
                                ToastService.showError(context, 'CPF inválido');
                                return;
                              }
                              if (!isEditing && senhaController.text.isEmpty) {
                                ToastService.showError(context, 'Senha é obrigatória');
                                return;
                              }
                              if (isEditing && senhaController.text.isNotEmpty && senhaController.text.length < 6) {
                                ToastService.showError(context, 'A nova senha deve ter pelo menos 6 caracteres');
                                return;
                              }

                              setState(() => isLoading = true);
                              try {
                                final authService = AuthService();
                                final telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');

                                if (isEditing) {
                                  Map<String, dynamic> dados = {
                                    'nomeCompleto': nomeController.text,
                                    'email': emailController.text,
                                    'telefone': telefoneLimpo,
                                    'cpf': cpfLimpo,
                                    'upaId': upaIdSelecionado,
                                  };
                                  if (senhaController.text.isNotEmpty) {
                                    dados['senha'] = senhaController.text;
                                  }
                                  await authService.atualizarEnfermeira(enfermeira!['id'], dados);
                                  ToastService.showSuccess(context, 'Enfermeira "${nomeController.text}" atualizada com sucesso!');
                                } else {
                                  await authService.criarEnfermeira({
                                    'nomeCompleto': nomeController.text,
                                    'email': emailController.text,
                                    'senha': senhaController.text,
                                    'telefone': telefoneLimpo,
                                    'cpf': cpfLimpo,
                                    'upaId': upaIdSelecionado,
                                  });
                                  ToastService.showSuccess(context, 'Enfermeira "${nomeController.text}" criada com sucesso!');
                                }

                                Navigator.pop(context);
                                _carregarDados();
                              } catch (e) {
                                String mensagem = e.toString();
                                if (mensagem.contains('409') || mensagem.contains('CPF já cadastrado')) {
                                  ToastService.showError(context, 'CPF já cadastrado para outra enfermeira');
                                } else if (mensagem.contains('409') || mensagem.contains('Email já cadastrado')) {
                                  ToastService.showError(context, 'Email já cadastrado para outra enfermeira');
                                } else {
                                  ToastService.showError(context, 'Erro ao ${isEditing ? "atualizar" : "criar"} enfermeira: $e');
                                }
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
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarDeletarEnfermeira(Map<String, dynamic> enfermeira) async {
    final confirm = await _showConfirmDeleteDialog(
      title: 'Excluir Enfermeira',
      message: 'Tem certeza que deseja excluir a enfermeira "${enfermeira['nome_completo']}"?\n\nEsta ação não pode ser desfeita.',
    );

    if (confirm == true) {
      try {
        final authService = AuthService();
        await authService.deletarEnfermeira(enfermeira['id']);
        ToastService.showSuccess(context, 'Enfermeira "${enfermeira['nome_completo']}" excluída com sucesso!');
        _carregarDados();
      } catch (e) {
        ToastService.showError(context, 'Erro ao excluir enfermeira: $e');
      }
    }
  }
}