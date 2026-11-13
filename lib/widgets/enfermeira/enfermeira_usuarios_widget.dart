
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/enfermeira/enfermeira_fichaPaciente_widget.dart';

class UsuariosWidget extends StatefulWidget {
  final int upaId;

  const UsuariosWidget({
    super.key,
    required this.upaId,
  });

  @override
  State<UsuariosWidget> createState() => _UsuariosWidgetState();
}

class _UsuariosWidgetState extends State<UsuariosWidget> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _surfaceSoft = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accentColor = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFE1EDF6);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);
  static const Color _successColor = Color(0xFF397C69);
  static const Color _warningColor = Color(0xFFB87935);
  static const Color _dangerColor = Color(0xFFC65D47);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _usuarios = [];

  bool _carregando = true;
  bool _carregandoLista = false;

  int _currentPage = 1;
  int _totalPages = 1;

  int _totalUsuarios = 0;
  int _totalEmEspera = 0;
  int _totalMatriculados = 0;
  int _totalCancelados = 0;

  int _selectedFiltroIndex = 0;
  int _requestId = 0;

  String _searchQuery = '';
  String _statusFiltro = 'todos';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_buscarUsuarios);
    _carregarUsuarios();
    _carregarContadores();
  }

  @override
  void dispose() {
    _requestId++;
    _searchController.removeListener(_buscarUsuarios);
    _searchController.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _texto(dynamic value, {String fallback = 'Não informado'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  BoxDecoration _cardDecoration({
    Color color = _surface,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _border),
    );
  }

  Future<void> _carregarContadores() async {
    try {
      final response = await AuthService().getContadoresUsuarios();

      if (!mounted) return;

      setState(() {
        _totalUsuarios = _toInt(response['total']);
        _totalEmEspera = _toInt(response['em_espera']);
        _totalMatriculados = _toInt(response['matriculado']);
        _totalCancelados = _toInt(response['cancelada']);
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _carregarUsuarios({int page = 1}) async {
    final requestId = ++_requestId;
    final search = _searchQuery;
    final status = _statusFiltro == 'todos' ? '' : _statusFiltro;

    setState(() {
      _carregandoLista = true;
      _currentPage = page;
    });

    try {
      final response = await AuthService().getUsuariosDaUPA(
        page: page,
        limit: 10,
        search: search,
        status: status,
      );

      if (!mounted || requestId != _requestId) return;

      final usuarios = (response['usuarios'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (_statusFiltro == 'todos') {
        const ordemStatus = {
          'em_espera': 0,
          'matriculado': 1,
          'confirmada': 1,
          'cancelada': 2,
          'recusada': 3,
        };

        usuarios.sort((a, b) {
          final statusA = _texto(a['status'], fallback: '');
          final statusB = _texto(b['status'], fallback: '');

          final ordemA = ordemStatus[statusA] ?? 4;
          final ordemB = ordemStatus[statusB] ?? 4;

          if (ordemA != ordemB) {
            return ordemA.compareTo(ordemB);
          }

          final dataA = _texto(a['created_at'], fallback: '');
          final dataB = _texto(b['created_at'], fallback: '');

          return dataB.compareTo(dataA);
        });
      }

      setState(() {
        _usuarios = usuarios;
        _totalPages = _toInt(response['totalPages']).clamp(1, 999999);
        _carregando = false;
        _carregandoLista = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _carregando = false;
        _carregandoLista = false;
      });

      ToastService.showError(
        context,
        'Erro ao carregar usuários: $e',
      );
    }
  }

  Future<void> _atualizar() async {
    await Future.wait([
      _carregarUsuarios(page: _currentPage),
      _carregarContadores(),
    ]);
  }

  void _buscarUsuarios() {
    final value = _searchController.text.trim();

    if (value == _searchQuery) return;

    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });

    _carregarUsuarios(page: 1);
  }

  void _limparBusca() {
    _searchController.clear();
  }

  void _selecionarFiltro(int index) {
    if (_selectedFiltroIndex == index) return;

    const filtros = [
      'todos',
      'em_espera',
      'matriculado',
      'cancelada',
    ];

    setState(() {
      _selectedFiltroIndex = index;
      _statusFiltro = filtros[index];
      _currentPage = 1;
    });

    _carregarUsuarios(page: 1);
  }

  Future<void> _verDetalhes(Map<String, dynamic> usuario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUsuarioDetalhesScreen(
          usuarioId: usuario['id'],
          usuarioNome: usuario['nome_completo'],
        ),
      ),
    );

    if (!mounted) return;

    await _atualizar();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera':
        return 'Em espera';
      case 'confirmada':
        return 'Confirmada';
      case 'matriculado':
        return 'Matriculado';
      case 'recusada':
        return 'Recusada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status.isEmpty ? 'Sem status' : status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera':
        return _warningColor;
      case 'confirmada':
      case 'matriculado':
        return _successColor;
      case 'recusada':
      case 'cancelada':
        return _dangerColor;
      default:
        return _textSecondary;
    }
  }

  Color _getStatusBackground(String status) {
    switch (status) {
      case 'em_espera':
        return const Color(0xFFFAEEDC);
      case 'confirmada':
      case 'matriculado':
        return const Color(0xFFE7F2EC);
      case 'recusada':
      case 'cancelada':
        return const Color(0xFFF8ECEA);
      default:
        return _surfaceSoft;
    }
  }

  String _formatarTelefone(String telefone) {
    if (telefone.isEmpty) return 'Não informado';

    final numeros = telefone.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length == 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }

    if (numeros.length == 10) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    }

    return telefone;
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';

    final numeros = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length == 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
    }

    return cpf;
  }

  String _getFiltroTitulo() {
    switch (_statusFiltro) {
      case 'em_espera':
        return 'Usuários em espera';
      case 'matriculado':
        return 'Usuários matriculados';
      case 'cancelada':
        return 'Usuários cancelados';
      default:
        return 'Todos os usuários';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return ColoredBox(
      color: _background,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: _accentColor,
              onRefresh: _atualizar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width < 400 ? 12 : (mobile ? 16 : 28),
                  vertical: mobile ? 20 : 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(mobile),
                        const SizedBox(height: 26),
                        _buildStatsRow(),
                        const SizedBox(height: 28),
                        _buildSearchSection(mobile),
                        const SizedBox(height: 22),
                        _buildResultsSection(mobile),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(bool mobile) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GERENCIAMENTO DE PARTICIPANTES',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
            color: _accentColor,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Usuários',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 27 : 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.9,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Consulte os participantes, acompanhe as matrículas e acesse as fichas dos pacientes.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            height: 1.6,
            color: _textSecondary,
          ),
        ),
      ],
    );

    final refreshButton = OutlinedButton.icon(
      onPressed: _carregandoLista ? null : _atualizar,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Atualizar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _accentColor,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
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

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 18),
          refreshButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 20),
        refreshButton,
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      _UsuarioStat(
        'Total de usuários',
        _totalUsuarios,
        Icons.people_outline_rounded,
        _accentColor,
        _accentSoft,
      ),
      _UsuarioStat(
        'Em espera',
        _totalEmEspera,
        Icons.hourglass_empty_rounded,
        _warningColor,
        const Color(0xFFFAEEDC),
      ),
      _UsuarioStat(
        'Matriculados',
        _totalMatriculados,
        Icons.how_to_reg_outlined,
        _successColor,
        const Color(0xFFE7F2EC),
      ),
      _UsuarioStat(
        'Cancelados',
        _totalCancelados,
        Icons.person_off_outlined,
        _dangerColor,
        const Color(0xFFF8ECEA),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 4 : 2;
        final gap = width < 400 ? 10.0 : 14.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats.map((stat) {
            return SizedBox(
              width: cardWidth,
              child: _buildStatCard(stat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(_UsuarioStat stat) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: stat.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 21,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            '${stat.value}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 16 : 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Localizar participantes',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Pesquise por nome ou e-mail e filtre pela situação da matrícula.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.5,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 17),
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou e-mail...',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _textSecondary,
                size: 21,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: _limparBusca,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 19,
                        color: _textSecondary,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: _surfaceSoft,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _accentColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 17),
          _buildFiltrosTabs(),
        ],
      ),
    );
  }

  Widget _buildFiltrosTabs() {
    final filtros = [
      _UsuarioFiltro('Todos', _totalUsuarios, _accentColor),
      _UsuarioFiltro('Em espera', _totalEmEspera, _warningColor),
      _UsuarioFiltro('Matriculados', _totalMatriculados, _successColor),
      _UsuarioFiltro('Cancelados', _totalCancelados, _dangerColor),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filtros.length, (index) {
          final filtro = filtros[index];

          return Padding(
            padding: EdgeInsets.only(
              right: index == filtros.length - 1 ? 0 : 9,
            ),
            child: _buildFiltroButton(filtro, index),
          );
        }),
      ),
    );
  }

  Widget _buildFiltroButton(_UsuarioFiltro filtro, int index) {
    final selected = _selectedFiltroIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selecionarFiltro(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? _accentSoft : _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _accentColor : _border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filtro.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _accentColor : _textSecondary,
                ),
              ),
              const SizedBox(width: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : filtro.color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${filtro.count}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? _accentColor : filtro.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(bool mobile) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(mobile ? 16 : 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.people_alt_outlined,
                    color: _accentColor,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _searchQuery.isEmpty
                            ? _getFiltroTitulo()
                            : 'Resultados da busca',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _carregandoLista
                            ? 'Atualizando resultados...'
                            : '${_usuarios.length} usuários nesta página',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_carregandoLista)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: _accentColor,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            color: _border,
            height: 1,
          ),
          if (_carregando && _usuarios.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 75),
              child: Center(
                child: CircularProgressIndicator(
                  color: _accentColor,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (_usuarios.isEmpty)
            _buildEmptyUsuariosWidget()
          else
            Padding(
              padding: EdgeInsets.all(mobile ? 12 : 20),
              child: Column(
                children: [
                  ..._usuarios.map(_buildUsuarioCard),
                  if (_totalPages > 1) ...[
                    const SizedBox(height: 12),
                    _buildPaginacao(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 750;

    final nome = _texto(usuario['nome_completo']);
    final email = _texto(usuario['email']);
    final telefone = _formatarTelefone(
      _texto(usuario['telefone'], fallback: ''),
    );
    final cpf = _formatarCpf(
      _texto(usuario['cpf'], fallback: ''),
    );
    final idade = _texto(usuario['idade'], fallback: '-');
    final turma = _texto(usuario['turma_horario'], fallback: '');
    final status = _texto(usuario['status'], fallback: '');

    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(radius: 13),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(mobile ? 14 : 18),
            decoration: const BoxDecoration(
              color: _surfaceSoft,
              border: Border(
                bottom: BorderSide(color: _border),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: mobile ? 40 : 46,
                  height: mobile ? 40 : 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: mobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: _accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: mobile ? 13 : 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!mobile) ...[
                  const SizedBox(width: 12),
                  _buildStatusBadge(status),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mobile) ...[
                  _buildStatusBadge(status),
                  const SizedBox(height: 17),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 550;

                    if (compact) {
                      return Column(
                        children: [
                          _buildInfoItem(
                            Icons.phone_outlined,
                            'Telefone',
                            telefone,
                          ),
                          const SizedBox(height: 14),
                          _buildInfoItem(
                            Icons.badge_outlined,
                            'CPF',
                            cpf,
                          ),
                          const SizedBox(height: 14),
                          _buildInfoItem(
                            Icons.cake_outlined,
                            'Idade',
                            idade == '-' ? '-' : '$idade anos',
                          ),
                          if (turma.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildInfoItem(
                              Icons.schedule_outlined,
                              'Turma',
                              turma,
                            ),
                          ],
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                Icons.phone_outlined,
                                'Telefone',
                                telefone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.badge_outlined,
                                'CPF',
                                cpf,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.cake_outlined,
                                'Idade',
                                idade == '-' ? '-' : '$idade anos',
                              ),
                            ),
                          ],
                        ),
                        if (turma.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          _buildInfoItem(
                            Icons.schedule_outlined,
                            'Turma',
                            turma,
                          ),
                        ],
                      ],
                    );
                  },
                ),
                if (status != 'cancelada') ...[
                  const SizedBox(height: 18),
                  const Divider(color: _border, height: 1),
                  const SizedBox(height: 16),
                  Align(
                    alignment: mobile
                        ? Alignment.center
                        : Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _verDetalhes(usuario),
                      icon: const Icon(
                        Icons.assignment_ind_outlined,
                        size: 18,
                      ),
                      label: const Text('Ver ficha do paciente'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accentColor,
                        side: const BorderSide(color: _accentColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 13,
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
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            color: _accentColor,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _getStatusBackground(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPaginationButton(
          Icons.chevron_left_rounded,
          _currentPage > 1 && !_carregandoLista
              ? () => _carregarUsuarios(page: _currentPage - 1)
              : null,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: _cardDecoration(
            color: _surfaceSoft,
            radius: 9,
          ),
          child: Text(
            '$_currentPage de $_totalPages',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildPaginationButton(
          Icons.chevron_right_rounded,
          _currentPage < _totalPages && !_carregandoLista
              ? () => _carregarUsuarios(page: _currentPage + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildPaginationButton(
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        foregroundColor: _accentColor,
        disabledForegroundColor:
            _textSecondary.withValues(alpha: 0.35),
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: _border),
        ),
      ),
    );
  }

  Widget _buildEmptyUsuariosWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person_search_outlined,
                size: 30,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nenhum usuário encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Tente ajustar os filtros ou utilizar outro termo na busca.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.6,
                color: _textSecondary,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _limparBusca,
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text('Limpar busca'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accentColor,
                  side: const BorderSide(color: _border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UsuarioStat {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  const _UsuarioStat(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}

class _UsuarioFiltro {
  final String label;
  final int count;
  final Color color;

  const _UsuarioFiltro(
    this.label,
    this.count,
    this.color,
  );
}
