
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminUsuariosWidget extends StatefulWidget {
  const AdminUsuariosWidget({super.key});

  @override
  State<AdminUsuariosWidget> createState() => _AdminUsuariosWidgetState();
}

class _AdminUsuariosWidgetState extends State<AdminUsuariosWidget> {
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

  List<Map<String, dynamic>> _usuarios = [];

  bool _carregando = true;
  bool _atualizando = false;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsuarios = 0;
  int _requestVersion = 0;

  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _carregarUsuarios(inicial: true);
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

  String _texto(dynamic value, [String fallback = 'Não informado']) {
    final texto = value?.toString().trim() ?? '';
    return texto.isEmpty ? fallback : texto;
  }

  String _numeros(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  bool _isAdmin(Map<String, dynamic> usuario) {
    final value = usuario['is_admin'];
    return value == true || value == 1 || value?.toString() == '1';
  }

  String _formatarTelefone(dynamic telefone) {
    final valor = _texto(telefone, '');
    final numeros = _numeros(valor);

    if (numeros.length == 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }

    if (numeros.length == 10) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    }

    return valor.isEmpty ? 'Não informado' : valor;
  }

  String _formatarCpf(dynamic cpf) {
    final valor = _texto(cpf, '');
    final numeros = _numeros(valor);

    if (numeros.length == 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
    }

    return valor.isEmpty ? 'Não informado' : valor;
  }

  String _formatarData(dynamic data) {
    final valor = _texto(data, '');

    if (valor.isEmpty) return 'Não informado';

    final dataLimpa = valor.split(' ').first.split('T').first;
    final partes = dataLimpa.split('-');

    if (partes.length != 3) return dataLimpa;

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  void _onSearchChanged() {
    _searchQuery = _searchController.text;
    _currentPage = 1;

    setState(() {});

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _carregarUsuarios(),
    );
  }

  Future<void> _carregarUsuarios({
    bool inicial = false,
    int? page,
  }) async {
    final pagina = page ?? _currentPage;
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
      final response = await AuthService().getUsuariosPaginados(
        page: pagina,
        limit: 8,
        search: _searchQuery,
      );

      if (!mounted || request != _requestVersion) return;

      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(
          response['usuarios'] ?? [],
        );
        _totalPages = _toInt(response['totalPages']);
        _totalUsuarios = _toInt(response['total']);
        _currentPage = pagina;
        _carregando = false;
        _atualizando = false;
      });
    } catch (e) {
      if (!mounted || request != _requestVersion) return;

      setState(() {
        _carregando = false;
        _atualizando = false;
      });

      ToastService.showError(
        context,
        'Erro ao carregar usuários: $e',
      );
    }
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
        fontWeight: FontWeight.w600,
        color: _accent,
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
        borderSide: const BorderSide(
          color: _accent,
          width: 1.5,
        ),
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
      child: Icon(
        icon,
        color: color,
        size: size * 0.49,
      ),
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

  Widget _buildCabecalho() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuários',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Consulte e gerencie os usuários cadastrados no sistema.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicadores() {
    final indicadores = [
      _indicador(
        titulo: 'Usuários cadastrados',
        valor: '$_totalUsuarios',
        icon: Icons.people_outline_rounded,
        color: _accent,
      ),
      _indicador(
        titulo: 'Página atual',
        valor: '$_currentPage / ${_totalPages < 1 ? 1 : _totalPages}',
        icon: Icons.layers_outlined,
        color: _success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              indicadores[0],
              const SizedBox(height: 10),
              indicadores[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: indicadores[0]),
            const SizedBox(width: 12),
            Expanded(child: indicadores[1]),
          ],
        );
      },
    );
  }

  Widget _indicador({
    required String titulo,
    required String valor,
    required IconData icon,
    required Color color,
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

  Widget _buildPesquisa() {
    return TextField(
      controller: _searchController,
      decoration: _decoration(
        'Pesquisar usuários',
        Icons.search_rounded,
        hint: 'Buscar por nome, e-mail ou CPF...',
      ).copyWith(
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: _searchController.clear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: _secondary,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final nome = _texto(usuario['nome_completo']);
    final email = _texto(usuario['email']);
    final telefone = _formatarTelefone(usuario['telefone']);
    final admin = _isAdmin(usuario);

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
          final mobile = constraints.maxWidth < 560;

          final conteudo = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _icone(
                admin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline_rounded,
                color: admin ? _success : _accent,
                background: admin
                    ? const Color(0xFFEAF4EF)
                    : _accentSoft,
                size: mobile ? 40 : 46,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                        if (admin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF4EF),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'Administrador',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _success,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _linhaInformacao(
                      Icons.email_outlined,
                      email,
                    ),
                    const SizedBox(height: 7),
                    _linhaInformacao(
                      Icons.phone_outlined,
                      telefone,
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
                icon: Icons.visibility_outlined,
                tooltip: 'Visualizar usuário',
                color: _accent,
                background: _accentSoft,
                onPressed: () => _verDetalhesUsuario(usuario),
              ),
              const SizedBox(width: 7),
              _botaoAcao(
                icon: Icons.edit_outlined,
                tooltip: 'Editar usuário',
                color: _success,
                background: const Color(0xFFEAF4EF),
                onPressed: () => _editarUsuario(usuario),
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
                const SizedBox(height: 9),
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
        Icon(
          icon,
          size: 15,
          color: _secondary,
        ),
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

  Widget _botaoAcao({
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color background,
    required VoidCallback onPressed,
  }) {
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
                    _carregarUsuarios(page: _currentPage - 1);
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
                    _carregarUsuarios(page: _currentPage + 1);
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
          _icone(
            Icons.person_search_outlined,
            size: 56,
          ),
          const SizedBox(height: 15),
          const Text(
            'Nenhum usuário encontrado',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tente pesquisar por outro nome, e-mail ou CPF.',
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

  Widget _detalheLinha(
    IconData icon,
    String titulo,
    String valor, {
    bool ultimo = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultimo ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: _secondary,
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 104,
            child: Text(
              titulo,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
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

  Future<void> _verDetalhesUsuario(
    Map<String, dynamic> usuario,
  ) async {
    late final Future<dynamic> detalhesFuture;

    detalhesFuture = AuthService().getUsuarioDetalhes(usuario['id']);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 530,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                  child: Row(
                    children: [
                      _icone(Icons.person_outline_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _texto(usuario['nome_completo']),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _texto(usuario['email']),
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
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                        color: _secondary,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _border),
                Flexible(
                  child: FutureBuilder<dynamic>(
                    future: detalhesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState !=
                          ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(42),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _accent,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            'Não foi possível carregar os detalhes do usuário.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: _danger,
                            ),
                          ),
                        );
                      }

                      final response = snapshot.data;

                      final dados = response is Map &&
                              response['usuario'] is Map
                          ? Map<String, dynamic>.from(
                              response['usuario'],
                            )
                          : usuario;

                      final upaNome = _texto(
                        dados['upa_nome'] ??
                            dados['unidade_nome'] ??
                            dados['upa']?['nome'],
                        'Não vinculado',
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações pessoais',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
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
                                    Icons.person_outline_rounded,
                                    'Nome',
                                    _texto(dados['nome_completo']),
                                  ),
                                  _detalheLinha(
                                    Icons.email_outlined,
                                    'E-mail',
                                    _texto(dados['email']),
                                  ),
                                  _detalheLinha(
                                    Icons.phone_outlined,
                                    'Telefone',
                                    _formatarTelefone(dados['telefone']),
                                  ),
                                  _detalheLinha(
                                    Icons.badge_outlined,
                                    'CPF',
                                    _formatarCpf(dados['cpf']),
                                  ),
                                  _detalheLinha(
                                    Icons.wc_outlined,
                                    'Sexo',
                                    _texto(dados['sexo']),
                                  ),
                                  _detalheLinha(
                                    Icons.cake_outlined,
                                    'Nascimento',
                                    _formatarData(
                                      dados['data_nascimento'],
                                    ),
                                  ),
                                  _detalheLinha(
                                    Icons.calendar_today_outlined,
                                    'Idade',
                                    _texto(dados['idade']),
                                  ),
                                  _detalheLinha(
                                    Icons.local_hospital_outlined,
                                    'Unidade',
                                    upaNome,
                                    ultimo: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

  Future<void> _editarUsuario(
    Map<String, dynamic> usuario,
  ) async {
    final nomeController = TextEditingController(
      text: _texto(usuario['nome_completo'], ''),
    );

    final emailController = TextEditingController(
      text: _texto(usuario['email'], ''),
    );

    final telefoneController = MaskedTextController(
      mask: '(00) 00000-0000',
      text: _formatarTelefone(usuario['telefone']) == 'Não informado'
          ? ''
          : _formatarTelefone(usuario['telefone']),
    );

    String? sexoSelecionado = usuario['sexo']?.toString();

    const sexos = ['Masculino', 'Feminino', 'Outro'];

    if (!sexos.contains(sexoSelecionado)) {
      sexoSelecionado = null;
    }

    bool salvando = false;

    final detalhesFuture = AuthService().getUsuarioDetalhes(
      usuario['id'],
    );

    final nomeOriginal = nomeController.text.trim();
    final emailOriginal = emailController.text.trim();
    final telefoneOriginal = _numeros(telefoneController.text);

    String? sexoOriginal = sexoSelecionado;

    bool formularioValido() {
      final nome = nomeController.text.trim();
      final email = emailController.text.trim();
      final telefone = _numeros(telefoneController.text);

      final emailValido = RegExp(
        r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
      ).hasMatch(email);

      return nome.isNotEmpty &&
          emailValido &&
          (telefone.isEmpty || telefone.length == 11);
    }

    bool houveAlteracoes() {
      return nomeController.text.trim() != nomeOriginal ||
          emailController.text.trim() != emailOriginal ||
          _numeros(telefoneController.text) != telefoneOriginal ||
          sexoSelecionado != sexoOriginal;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, atualizarModal) {
            Future<void> salvar() async {
              if (!formularioValido() ||
                  !houveAlteracoes() ||
                  salvando) {
                return;
              }

              atualizarModal(() {
                salvando = true;
              });

              try {
                await AuthService().atualizarUsuario(
                  usuario['id'],
                  {
                    'nomeCompleto': nomeController.text.trim(),
                    'sexo': sexoSelecionado,
                    'email': emailController.text.trim(),
                    'telefone': _numeros(telefoneController.text),
                  },
                );

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;

                ToastService.showSuccess(
                  context,
                  'Usuário atualizado com sucesso!',
                );

                await _carregarUsuarios();
              } catch (e) {
                if (!dialogContext.mounted) return;

                ToastService.showError(
                  dialogContext,
                  'Erro ao atualizar usuário: $e',
                );
              } finally {
                if (dialogContext.mounted) {
                  atualizarModal(() {
                    salvando = false;
                  });
                }
              }
            }

            return Dialog(
              backgroundColor: _surface,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _border),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 530,
                  maxHeight:
                      MediaQuery.of(dialogContext).size.height * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                      child: Row(
                        children: [
                          _icone(Icons.edit_outlined),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Editar usuário',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Atualize as informações cadastrais.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: _secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: salvando
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
                      child: FutureBuilder<dynamic>(
                        future: detalhesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _accent,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasData &&
                              snapshot.data is Map &&
                              snapshot.data['usuario'] is Map &&
                              sexoOriginal == null) {
                            final sexoCarregado =
                                snapshot.data['usuario']['sexo']
                                    ?.toString();

                            if (sexos.contains(sexoCarregado)) {
                              sexoOriginal = sexoCarregado;
                              sexoSelecionado ??= sexoCarregado;
                            }
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: nomeController,
                                  enabled: !salvando,
                                  onChanged: (_) =>
                                      atualizarModal(() {}),
                                  decoration: _decoration(
                                    'Nome completo',
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(height: 13),
                                DropdownButtonFormField<String>(
                                  value: sexoSelecionado,
                                  isExpanded: true,
                                  decoration: _decoration(
                                    'Sexo',
                                    Icons.wc_outlined,
                                  ),
                                  items: sexos.map((sexo) {
                                    return DropdownMenuItem(
                                      value: sexo,
                                      child: Text(
                                        sexo,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: _primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: salvando
                                      ? null
                                      : (value) {
                                          atualizarModal(() {
                                            sexoSelecionado = value;
                                          });
                                        },
                                ),
                                const SizedBox(height: 13),
                                TextField(
                                  controller: emailController,
                                  enabled: !salvando,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  onChanged: (_) =>
                                      atualizarModal(() {}),
                                  decoration: _decoration(
                                    'E-mail',
                                    Icons.email_outlined,
                                  ),
                                ),
                                const SizedBox(height: 13),
                                TextField(
                                  controller: telefoneController,
                                  enabled: !salvando,
                                  keyboardType: TextInputType.phone,
                                  onChanged: (_) =>
                                      atualizarModal(() {}),
                                  decoration: _decoration(
                                    'Telefone',
                                    Icons.phone_outlined,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: salvando
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
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _botaoPrincipal(
                              texto: 'Salvar alterações',
                              icon: Icons.check_rounded,
                              onPressed: formularioValido() &&
                                      houveAlteracoes() &&
                                      !salvando
                                  ? salvar
                                  : null,
                              loading: salvando,
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
    emailController.dispose();
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
          onRefresh: () => _carregarUsuarios(),
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
                    _buildCabecalho(),
                    const SizedBox(height: 23),
                    _buildIndicadores(),
                    const SizedBox(height: 22),
                    _buildPesquisa(),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Usuários cadastrados'
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
                          '$_totalUsuarios usuários',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_usuarios.isEmpty)
                      _buildVazio()
                    else
                      ..._usuarios.map(_buildUsuarioCard),
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
