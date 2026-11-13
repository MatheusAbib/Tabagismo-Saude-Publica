
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/cep_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminUPAsWidget extends StatefulWidget {
  const AdminUPAsWidget({super.key});

  @override
  State<AdminUPAsWidget> createState() => _AdminUPAsWidgetState();
}

class _AdminUPAsWidgetState extends State<AdminUPAsWidget> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _primary = Color(0xFF30383E);
  static const Color _secondary = Color(0xFF758087);
  static const Color _accent = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFEAF2F7);
  static const Color _success = Color(0xFF397C69);
  static const Color _danger = Color(0xFFC65D47);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _upas = [];
  List<Map<String, dynamic>> _enfermeiras = [];

  bool _carregando = true;
  bool _atualizando = false;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUPAs = 0;
  int _requestVersion = 0;

  String _searchQuery = '';
  Timer? _debounceTimer;

  static const List<String> _horariosPadrao = [
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

  static const List<String> _diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _horariosTurmas = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _carregarDados(inicial: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _numeros(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _texto(dynamic value, [String fallback = 'Não informado']) {
    final texto = value?.toString().trim() ?? '';
    return texto.isEmpty ? fallback : texto;
  }

  void _onSearchChanged() {
    _searchQuery = _searchController.text;
    _currentPage = 1;

    setState(() {});

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _carregarDados(),
    );
  }

  Future<void> _carregarDados({bool inicial = false}) async {
    final request = ++_requestVersion;

    if (mounted) {
      setState(() {
        if (inicial) {
          _carregando = true;
        } else {
          _atualizando = true;
        }
      });
    }

    try {
      final auth = AuthService();

      final response = await auth.getUPAs(
        page: _currentPage,
        limit: 8,
        search: _searchQuery,
      );

      final enfermeiras = await auth.getEnfermeiras();

      if (!mounted || request != _requestVersion) return;

      setState(() {
        _upas = List<Map<String, dynamic>>.from(
          response['upas'] ?? [],
        );
        _enfermeiras = List<Map<String, dynamic>>.from(enfermeiras);
        _totalPages = _toInt(response['totalPages']);
        _totalUPAs = _toInt(response['total']);
        _carregando = false;
        _atualizando = false;
      });
    } catch (e) {
      if (!mounted || request != _requestVersion) return;

      setState(() {
        _carregando = false;
        _atualizando = false;
      });

      ToastService.showError(context, 'Erro ao carregar unidades: $e');
    }
  }

  String _formatarTelefone(dynamic telefone) {
    final valor = _texto(telefone, '');
    final numeros = _numeros(valor);

    if (numeros.length == 10) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    }

    if (numeros.length == 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }

    return valor.isEmpty ? 'Não informado' : valor;
  }

  String _formatarCep(dynamic cep) {
    final valor = _texto(cep, '');
    final numeros = _numeros(valor);

    if (numeros.length == 8) {
      return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
    }

    return valor;
  }

  String _formatarCpf(dynamic cpf) {
    final valor = _texto(cpf, '');
    final numeros = _numeros(valor);

    if (numeros.length == 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
    }

    return valor.isEmpty ? 'Não informado' : valor;
  }

  List<String> _getDiasPermitidos(String funcionamento) {
    if (funcionamento.contains('Segunda a Sexta')) {
      return _diasSemana.take(5).toList();
    }

    if (funcionamento.contains('Segunda a Sábado')) {
      return _diasSemana.take(6).toList();
    }

    if (funcionamento.contains('Domingo a Domingo') ||
        funcionamento == '24 horas') {
      return List<String>.from(_diasSemana);
    }

    if (funcionamento.contains('Segunda, Quarta e Sexta')) {
      return [
        'Segunda-feira',
        'Quarta-feira',
        'Sexta-feira',
      ];
    }

    if (funcionamento.contains('Terça e Quinta')) {
      return [
        'Terça-feira',
        'Quinta-feira',
      ];
    }

    return _diasSemana.take(6).toList();
  }

  List<String> _getHorariosPermitidos(String funcionamento) {
    if (funcionamento.isEmpty) return [];

    if (funcionamento.contains('24 horas')) {
      return List<String>.from(_horariosTurmas);
    }

    final match = RegExp(
      r'(\d{1,2})h\s*às\s*(\d{1,2})h',
    ).firstMatch(funcionamento);

    if (match == null) return [];

    final abertura = int.parse(match.group(1)!);
    final fechamento = int.parse(match.group(2)!);

    return _horariosTurmas.where((horario) {
      final partes = horario.split(' - ');
      final inicio = int.parse(partes.first.split(':').first);
      final fim = int.parse(partes.last.split(':').first);

      return inicio >= abertura && fim <= fechamento;
    }).toList();
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: _secondary,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: _secondary,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: _accent,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: _secondary, size: 19),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
    );
  }

  Widget _icone(
    IconData icon, {
    Color color = _accent,
    Color background = _accentSoft,
    double size = 42,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: size * 0.49),
    );
  }

  Widget _tituloSecao(String titulo, {String? descricao}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        if (descricao != null) ...[
          const SizedBox(height: 4),
          Text(
            descricao,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _secondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _botaoPrincipal({
    required String texto,
    required IconData icon,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _accent.withOpacity(0.35),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _resumoItem({
    required String titulo,
    required String valor,
    required IconData icon,
    Color color = _accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _icone(
            icon,
            color: color,
            background: color.withOpacity(0.09),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumo() {
    final items = [
      _resumoItem(
        titulo: 'Unidades cadastradas',
        valor: '$_totalUPAs',
        icon: Icons.local_hospital_outlined,
      ),
      _resumoItem(
        titulo: 'Enfermeiras cadastradas',
        valor: '${_enfermeiras.length}',
        icon: Icons.medical_services_outlined,
        color: _success,
      ),
      _resumoItem(
        titulo: 'Página atual',
        valor: '$_currentPage / ${_totalPages < 1 ? 1 : _totalPages}',
        icon: Icons.layers_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                items[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: items[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCabecalho(bool mobile) {
    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unidades de Saúde',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Gerencie unidades, horários de atendimento e turmas.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _secondary,
          ),
        ),
      ],
    );

    final botao = _botaoPrincipal(
      texto: 'Nova unidade',
      icon: Icons.add_rounded,
      onPressed: () => _abrirModalUPA(),
    );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titulo,
          const SizedBox(height: 17),
          botao,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titulo),
        const SizedBox(width: 15),
        botao,
      ],
    );
  }

  Widget _buildPesquisa() {
    return TextField(
      controller: _searchController,
      decoration: _decoration(
        'Pesquisar unidades',
        Icons.search_rounded,
        hint: 'Buscar por nome, endereço ou cidade...',
      ).copyWith(
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: _searchController.clear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: _secondary,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUPACard(Map<String, dynamic> upa) {
    final nome = _texto(upa['nome']);
    final endereco = _texto(upa['endereco']);
    final cidade = _texto(upa['cidade']);
    final telefone = _formatarTelefone(upa['telefone']);
    final horario = _texto(upa['horario']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 580;

          final conteudo = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _icone(
                Icons.local_hospital_outlined,
                size: mobile ? 40 : 46,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 9),
                    _linhaInformacao(
                      Icons.location_on_outlined,
                      endereco,
                    ),
                    const SizedBox(height: 6),
                    _linhaInformacao(
                      Icons.location_city_outlined,
                      cidade,
                    ),
                    const SizedBox(height: 6),
                    _linhaInformacao(
                      Icons.phone_outlined,
                      telefone,
                    ),
                    const SizedBox(height: 6),
                    _linhaInformacao(
                      Icons.schedule_outlined,
                      horario,
                    ),
                  ],
                ),
              ),
            ],
          );

          final acoes = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _botaoAcao(
                Icons.visibility_outlined,
                'Visualizar unidade',
                _accent,
                _accentSoft,
                () => _abrirModalVisualizarUPA(upa),
              ),
              const SizedBox(width: 6),
              _botaoAcao(
                Icons.edit_outlined,
                'Editar unidade',
                _success,
                const Color(0xFFEAF4EF),
                () => _abrirModalUPA(upa: upa),
              ),
              const SizedBox(width: 6),
              _botaoAcao(
                Icons.delete_outline_rounded,
                'Excluir unidade',
                _danger,
                const Color(0xFFFBEDE9),
                () => _confirmarDeletarUPA(upa),
              ),
            ],
          );

          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                conteudo,
                const SizedBox(height: 15),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: acoes,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: conteudo),
              const SizedBox(width: 15),
              acoes,
            ],
          );
        },
      ),
    );
  }

  Widget _linhaInformacao(IconData icon, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _secondary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _secondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _botaoAcao(
    IconData icon,
    String tooltip,
    Color color,
    Color background,
    VoidCallback onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 19),
      color: color,
      style: IconButton.styleFrom(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  Widget _buildPaginacao() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 && !_atualizando
                ? () {
                    _currentPage--;
                    _carregarDados();
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            style: IconButton.styleFrom(
              backgroundColor: _surface,
              side: const BorderSide(color: _border),
            ),
          ),
          const SizedBox(width: 13),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$_currentPage de $_totalPages',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
          ),
          const SizedBox(width: 13),
          IconButton(
            onPressed: _currentPage < _totalPages && !_atualizando
                ? () {
                    _currentPage++;
                    _carregarDados();
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            style: IconButton.styleFrom(
              backgroundColor: _surface,
              side: const BorderSide(color: _border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _icone(Icons.location_off_outlined, size: 56),
          const SizedBox(height: 15),
          const Text(
            'Nenhuma unidade encontrada',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tente outra pesquisa ou cadastre uma nova unidade.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _secondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmarExclusao(String nome) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _icone(
                    Icons.delete_outline_rounded,
                    color: _danger,
                    background: const Color(0xFFFBEDE9),
                    size: 54,
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'Excluir unidade',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Deseja excluir a unidade "$nome"? Esta ação não pode ser desfeita.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _secondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 23),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _secondary,
                            side: const BorderSide(color: _border),
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _danger,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                          ),
                          child: const Text('Excluir'),
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

    return resultado == true;
  }

  Future<void> _confirmarDeletarUPA(
    Map<String, dynamic> upa,
  ) async {
    final confirmado = await _confirmarExclusao(
      _texto(upa['nome']),
    );

    if (!confirmado || !mounted) return;

    try {
      await AuthService().deletarUPA(upa['id']);

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'Unidade excluída com sucesso!',
      );

      await _carregarDados();
    } catch (e) {
      if (!mounted) return;

      ToastService.showError(
        context,
        'Erro ao excluir unidade: $e',
      );
    }
  }

  Future<void> _abrirModalVisualizarUPA(
    Map<String, dynamic> upa,
  ) async {
    final upaId = _toInt(upa['id']);

    final enfermeiras = _enfermeiras.where(
      (e) => _toInt(e['upa_id']) == upaId,
    ).toList();

    final turmasFuture = AuthService().getTurmasPorUPA(upa['id']);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 580,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                  child: Row(
                    children: [
                      _icone(Icons.local_hospital_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _texto(upa['nome']),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                        color: _secondary,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _border),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tituloSecao('Informações da unidade'),
                        const SizedBox(height: 13),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _background,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            children: [
                              _detalheLinha(
                                'Endereço',
                                _texto(upa['endereco']),
                              ),
                              _detalheLinha(
                                'CEP',
                                _formatarCep(upa['cep']),
                              ),
                              _detalheLinha(
                                'Cidade',
                                _texto(upa['cidade']),
                              ),
                              _detalheLinha(
                                'Telefone',
                                _formatarTelefone(upa['telefone']),
                              ),
                              _detalheLinha(
                                'Funcionamento',
                                _texto(upa['horario']),
                                ultimo: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 23),
                        _tituloSecao(
                          'Turmas disponíveis',
                          descricao:
                              'Dias e horários oferecidos pela unidade.',
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<dynamic>(
                          future: turmasFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Padding(
                                padding: EdgeInsets.all(25),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _accent,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Text(
                                'Não foi possível carregar as turmas.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: _secondary,
                                ),
                              );
                            }

                            final turmas =
                                List<Map<String, dynamic>>.from(
                              snapshot.data ?? [],
                            );

                            if (turmas.isEmpty) {
                              return const Text(
                                'Nenhuma turma cadastrada.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: _secondary,
                                ),
                              );
                            }

                            final agrupadas = <String, List<String>>{};

                            for (final turma in turmas) {
                              final dia = _texto(
                                turma['dia_semana'],
                                '',
                              );
                              final horario = _texto(
                                turma['horario'],
                                '',
                              );

                              agrupadas.putIfAbsent(dia, () => []);

                              if (!agrupadas[dia]!.contains(horario)) {
                                agrupadas[dia]!.add(horario);
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: _background,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: _border),
                              ),
                              child: Column(
                                children: agrupadas.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 7,
                                          runSpacing: 7,
                                          children: entry.value.map((hora) {
                                            return _horarioChip(
                                              hora,
                                              selecionado: true,
                                              onTap: null,
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 23),
                        _tituloSecao(
                          'Enfermeiras vinculadas',
                          descricao:
                              '${enfermeiras.length} profissionais nesta unidade.',
                        ),
                        const SizedBox(height: 12),
                        if (enfermeiras.isEmpty)
                          const Text(
                            'Nenhuma enfermeira vinculada.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: _secondary,
                            ),
                          )
                        else
                          ...enfermeiras.map(
                            (e) => Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: _background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _border),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _icone(
                                    Icons.medical_services_outlined,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _texto(e['nome_completo']),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _primary,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _texto(e['email']),
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 11,
                                            color: _secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'CPF: ${_formatarCpf(e['cpf'])}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            color: _secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Telefone: ${_formatarTelefone(e['telefone'])}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            color: _secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: _border),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _secondary,
                        side: const BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Fechar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detalheLinha(
    String titulo,
    String valor, {
    bool ultimo = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultimo ? 0 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              titulo,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _secondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horarioChip(
    String horario, {
    required bool selecionado,
    required VoidCallback? onTap,
    bool permitido = true,
  }) {
    final cor = !permitido
        ? _secondary
        : selecionado
            ? _accent
            : _primary;

    return InkWell(
      onTap: permitido ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: !permitido
              ? const Color(0xFFF2F2EF)
              : selecionado
                  ? _accentSoft
                  : _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selecionado && permitido ? _accent : _border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selecionado && permitido) ...[
              const Icon(
                Icons.check_rounded,
                size: 13,
                color: _accent,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              horario,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight:
                    selecionado ? FontWeight.w600 : FontWeight.w400,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirModalUPA({
    Map<String, dynamic>? upa,
  }) async {
    final editando = upa != null;

    final nomeController = TextEditingController(
      text: upa?['nome']?.toString() ?? '',
    );

    final cepController = TextEditingController(
      text: _formatarCep(upa?['cep']),
    );

    final ruaController = TextEditingController();
    final numeroController = TextEditingController();
    final bairroController = TextEditingController();

    final cidadeController = TextEditingController(
      text: upa?['cidade']?.toString() ?? 'Mogi das Cruzes',
    );

    final telefoneController = MaskedTextController(
      mask: '(00) 0000-0000',
      text: upa?['telefone']?.toString() ?? '',
    );

    final enderecoOriginal = upa?['endereco']?.toString() ?? '';

    if (enderecoOriginal.isNotEmpty) {
      final partes = enderecoOriginal.split(' - ');

      if (partes.length > 1) {
        bairroController.text = partes.sublist(1).join(' - ').trim();
      }

      final ruaNumero = partes.first;
      final separador = ruaNumero.lastIndexOf(',');

      if (separador >= 0) {
        ruaController.text = ruaNumero.substring(0, separador).trim();
        numeroController.text =
            ruaNumero.substring(separador + 1).trim();
      } else {
        ruaController.text = ruaNumero.trim();
      }
    }

    String? horarioSelecionado = upa?['horario']?.toString();

    if (horarioSelecionado != null &&
        horarioSelecionado.isNotEmpty &&
        !_horariosPadrao.contains(horarioSelecionado)) {
      horarioSelecionado = null;
    }

    List<Map<String, dynamic>> turmasSelecionadas = [];

    if (editando) {
      try {
        final turmas = await AuthService().getTurmasPorUPA(upa['id']);

        turmasSelecionadas = List<Map<String, dynamic>>.from(
          turmas.map((t) => Map<String, dynamic>.from(t)),
        );
      } catch (e) {
        if (!mounted) return;

        ToastService.showError(
          context,
          'Não foi possível carregar as turmas: $e',
        );

        return;
      }
    }

    if (!mounted) return;

    final nomeOriginal = nomeController.text.trim();
    final cepOriginal = _numeros(cepController.text);
    final cidadeOriginal = cidadeController.text.trim();
    final telefoneOriginal = _numeros(telefoneController.text);
    final horarioOriginal = horarioSelecionado;

    final turmasOriginais = turmasSelecionadas
        .map(
          (t) => '${t['dia_semana']}|${t['horario']}|${t['vagas_totais']}',
        )
        .toSet();

    bool carregando = false;
    bool buscandoCep = false;
    int cepRequest = 0;

    bool formularioValido() {
      final telefone = _numeros(telefoneController.text);

      return nomeController.text.trim().isNotEmpty &&
          ruaController.text.trim().isNotEmpty &&
          numeroController.text.trim().isNotEmpty &&
          bairroController.text.trim().isNotEmpty &&
          cidadeController.text.trim().isNotEmpty &&
          (telefone.length == 10 || telefone.length == 11) &&
          horarioSelecionado != null &&
          turmasSelecionadas.isNotEmpty;
    }

    bool houveAlteracoes() {
      final turmasAtuais = turmasSelecionadas
          .map(
            (t) => '${t['dia_semana']}|${t['horario']}|${t['vagas_totais']}',
          )
          .toSet();

      return nomeController.text.trim() != nomeOriginal ||
          _numeros(cepController.text) != cepOriginal ||
          '${ruaController.text.trim()}, ${numeroController.text.trim()} - ${bairroController.text.trim()}' !=
              enderecoOriginal ||
          cidadeController.text.trim() != cidadeOriginal ||
          _numeros(telefoneController.text) != telefoneOriginal ||
          horarioSelecionado != horarioOriginal ||
          turmasAtuais.length != turmasOriginais.length ||
          !turmasAtuais.containsAll(turmasOriginais);
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, atualizarModal) {
            Future<void> buscarCep(String valor) async {
              final cep = _numeros(valor);

              if (cep.length != 8) return;

              final request = ++cepRequest;

              atualizarModal(() {
                buscandoCep = true;
              });

              try {
                final endereco = await CepService.buscarEndereco(cep);

                if (!dialogContext.mounted || request != cepRequest) {
                  return;
                }

                atualizarModal(() {
                  ruaController.text =
                      endereco['logradouro']?.toString() ?? '';
                  bairroController.text =
                      endereco['bairro']?.toString() ?? '';
                  cidadeController.text =
                      endereco['cidade']?.toString() ?? '';
                  buscandoCep = false;
                });

                ToastService.showSuccess(
                  dialogContext,
                  'Endereço encontrado com sucesso!',
                );
              } catch (e) {
                if (!dialogContext.mounted || request != cepRequest) {
                  return;
                }

                atualizarModal(() {
                  buscandoCep = false;
                });

                ToastService.showError(
                  dialogContext,
                  'Erro ao buscar CEP: $e',
                );
              }
            }

            Future<void> salvar() async {
              if (!formularioValido() || carregando) return;

              atualizarModal(() {
                carregando = true;
              });

              try {
                final endereco =
                    '${ruaController.text.trim()}, ${numeroController.text.trim()} - ${bairroController.text.trim()}';

                final dados = <String, dynamic>{
                  'nome': nomeController.text.trim(),
                  'endereco': endereco,
                  'cep': _numeros(cepController.text),
                  'cidade': cidadeController.text.trim(),
                  'telefone': _numeros(telefoneController.text),
                  'horario': horarioSelecionado,
                  'turmas': turmasSelecionadas.map((turma) {
                    return {
                      'dia_semana': turma['dia_semana'],
                      'horario': turma['horario'],
                      'vagas_totais': turma['vagas_totais'] ?? 4,
                    };
                  }).toList(),
                };

                if (editando) {
                  await AuthService().atualizarUPAComTurmas(
                    upa['id'],
                    dados,
                  );
                } else {
                  await AuthService().criarUPAComTurmas(dados);
                }

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                ToastService.showSuccess(
                  context,
                  editando
                      ? 'Unidade atualizada com sucesso!'
                      : 'Unidade cadastrada com sucesso!',
                );

                await _carregarDados();
              } catch (e) {
                if (!dialogContext.mounted) return;

                ToastService.showError(
                  dialogContext,
                  'Erro ao salvar unidade: $e',
                );
              } finally {
                if (dialogContext.mounted) {
                  atualizarModal(() {
                    carregando = false;
                  });
                }
              }
            }

            final diasPermitidos = _getDiasPermitidos(
              horarioSelecionado ?? '',
            );

            final horariosPermitidos = _getHorariosPermitidos(
              horarioSelecionado ?? '',
            );

            final podeSalvar = formularioValido() &&
                (!editando || houveAlteracoes()) &&
                !carregando &&
                !buscandoCep;

            return Dialog(
              backgroundColor: _surface,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: _border),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 740,
                  maxHeight:
                      MediaQuery.of(dialogContext).size.height * 0.94,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 17),
                      child: Row(
                        children: [
                          _icone(
                            editando
                                ? Icons.edit_outlined
                                : Icons.add_business_outlined,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  editando
                                      ? 'Editar unidade'
                                      : 'Nova unidade',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  editando
                                      ? 'Atualize os dados e as turmas.'
                                      : 'Cadastre uma unidade e seus horários.',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: _secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: carregando
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded),
                            color: _secondary,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _tituloSecao('Identificação da unidade'),
                            const SizedBox(height: 15),
                            TextField(
                              controller: nomeController,
                              enabled: !carregando,
                              onChanged: (_) => atualizarModal(() {}),
                              decoration: _decoration(
                                'Nome da unidade',
                                Icons.local_hospital_outlined,
                              ),
                            ),
                            const SizedBox(height: 23),
                            _tituloSecao(
                              'Endereço e contato',
                              descricao:
                                  'Informe o CEP para preencher o endereço automaticamente.',
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: cepController,
                              enabled: !carregando,
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              onChanged: (valor) {
                                atualizarModal(() {});
                                buscarCep(valor);
                              },
                              decoration: _decoration(
                                'CEP',
                                Icons.pin_drop_outlined,
                              ).copyWith(
                                counterText: '',
                                suffixIcon: buscandoCep
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _accent,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final rua = TextField(
                                  controller: ruaController,
                                  enabled: !carregando,
                                  onChanged: (_) =>
                                      atualizarModal(() {}),
                                  decoration: _decoration(
                                    'Rua',
                                    Icons.location_on_outlined,
                                  ),
                                );

                                final numero = TextField(
                                  controller: numeroController,
                                  enabled: !carregando,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) =>
                                      atualizarModal(() {}),
                                  decoration: _decoration(
                                    'Número',
                                    Icons.numbers_rounded,
                                  ),
                                );

                                if (constraints.maxWidth < 450) {
                                  return Column(
                                    children: [
                                      rua,
                                      const SizedBox(height: 12),
                                      numero,
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(flex: 3, child: rua),
                                    const SizedBox(width: 12),
                                    Expanded(child: numero),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: bairroController,
                              enabled: !carregando,
                              onChanged: (_) => atualizarModal(() {}),
                              decoration: _decoration(
                                'Bairro',
                                Icons.map_outlined,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: cidadeController,
                              enabled: false,
                              decoration: _decoration(
                                'Cidade',
                                Icons.location_city_outlined,
                              ).copyWith(
                                fillColor: const Color(0xFFF4F4F1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: telefoneController,
                              enabled: !carregando,
                              keyboardType: TextInputType.phone,
                              onChanged: (_) => atualizarModal(() {}),
                              decoration: _decoration(
                                'Telefone',
                                Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(height: 23),
                            _tituloSecao(
                              'Horário de funcionamento',
                              descricao:
                                  'O horário determina os dias e períodos disponíveis para turmas.',
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: horarioSelecionado,
                              isExpanded: true,
                              decoration: _decoration(
                                'Funcionamento',
                                Icons.schedule_outlined,
                              ),
                              items: _horariosPadrao.map((horario) {
                                return DropdownMenuItem(
                                  value: horario,
                                  child: Text(
                                    horario,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: _primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: carregando
                                  ? null
                                  : (value) {
                                      atualizarModal(() {
                                        horarioSelecionado = value;
                                      });
                                    },
                            ),
                            const SizedBox(height: 24),
                            _tituloSecao(
                              'Turmas disponíveis para matrícula',
                              descricao:
                                  'Selecione os dias e horários oferecidos pela unidade.',
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: _background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  for (final dia in _diasSemana) ...[
                                    Builder(
                                      builder: (context) {
                                        final permitido =
                                            diasPermitidos.contains(dia);

                                        final quantidade =
                                            turmasSelecionadas.where(
                                          (t) => t['dia_semana'] == dia,
                                        ).length;

                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    permitido
                                                        ? Icons
                                                            .calendar_today_outlined
                                                        : Icons
                                                            .block_outlined,
                                                    size: 15,
                                                    color: permitido
                                                        ? _accent
                                                        : _secondary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      dia,
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: permitido
                                                            ? _primary
                                                            : _secondary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (quantidade > 0)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: _accentSoft,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                      ),
                                                      child: Text(
                                                        '$quantidade',
                                                        style:
                                                            const TextStyle(
                                                          fontFamily:
                                                              'Inter',
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _accent,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 7,
                                                runSpacing: 7,
                                                children: _horariosTurmas.map(
                                                  (horario) {
                                                    final habilitado =
                                                        permitido &&
                                                            horariosPermitidos
                                                                .contains(
                                                              horario,
                                                            );

                                                    final selecionado =
                                                        turmasSelecionadas
                                                            .any(
                                                      (t) =>
                                                          t['dia_semana'] ==
                                                              dia &&
                                                          t['horario'] ==
                                                              horario,
                                                    );

                                                    return _horarioChip(
                                                      horario,
                                                      selecionado:
                                                          selecionado,
                                                      permitido: habilitado,
                                                      onTap: carregando ||
                                                              !habilitado
                                                          ? null
                                                          : () {
                                                              atualizarModal(
                                                                () {
                                                                  if (selecionado) {
                                                                    turmasSelecionadas
                                                                        .removeWhere(
                                                                      (t) =>
                                                                          t['dia_semana'] ==
                                                                              dia &&
                                                                          t['horario'] ==
                                                                              horario,
                                                                    );
                                                                  } else {
                                                                    turmasSelecionadas
                                                                        .add({
                                                                      'dia_semana':
                                                                          dia,
                                                                      'horario':
                                                                          horario,
                                                                      'vagas_totais':
                                                                          4,
                                                                      'vagas_ocupadas':
                                                                          0,
                                                                    });
                                                                  }
                                                                },
                                                              );
                                                            },
                                                    );
                                                  },
                                                ).toList(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    if (dia != _diasSemana.last)
                                      const Divider(
                                        height: 1,
                                        color: _border,
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${turmasSelecionadas.length} horários selecionados',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: carregando
                                  ? null
                                  : () =>
                                      Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _secondary,
                                side: const BorderSide(color: _border),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _botaoPrincipal(
                              texto: editando
                                  ? 'Salvar alterações'
                                  : 'Cadastrar',
                              icon: editando
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              onPressed: podeSalvar ? salvar : null,
                              loading: carregando,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nomeController.dispose();
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    telefoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 2.5,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 768;

        return RefreshIndicator(
          color: _accent,
          onRefresh: () => _carregarDados(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 15 : 30,
              vertical: mobile ? 22 : 30,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCabecalho(mobile),
                    const SizedBox(height: 23),
                    _buildResumo(),
                    const SizedBox(height: 22),
                    _buildPesquisa(),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Unidades cadastradas'
                                : 'Resultados da pesquisa',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ),
                        if (_atualizando)
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: _accent,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        Text(
                          '$_totalUPAs unidades',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_upas.isEmpty)
                      _buildVazio()
                    else
                      ..._upas.map(_buildUPACard),
                    _buildPaginacao(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
