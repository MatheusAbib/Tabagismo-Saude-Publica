
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminEnfermeirasWidget extends StatefulWidget {
  const AdminEnfermeirasWidget({super.key});

  @override
  State<AdminEnfermeirasWidget> createState() =>
      _AdminEnfermeirasWidgetState();
}

class _AdminEnfermeirasWidgetState extends State<AdminEnfermeirasWidget> {
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

  List<Map<String, dynamic>> _enfermeiras = [];
  List<Map<String, dynamic>> _upasLista = [];

  bool _carregando = true;
  bool _atualizando = false;
  String _searchQuery = '';

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

  Future<void> _carregarDados({bool mostrarLoading = true}) async {
    if (mounted) {
      setState(() {
        if (mostrarLoading) {
          _carregando = true;
        } else {
          _atualizando = true;
        }
      });
    }

    try {
      final authService = AuthService();

      final enfermeiras = await authService.getEnfermeiras();
      final upas = await authService.getUPAsLista();

      if (!mounted) return;

      setState(() {
        _enfermeiras = List<Map<String, dynamic>>.from(enfermeiras);
        _upasLista = List<Map<String, dynamic>>.from(upas);
        _carregando = false;
        _atualizando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
        _atualizando = false;
      });

      ToastService.showError(
        context,
        'Erro ao carregar dados: $e',
      );
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _somenteNumeros(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _formatarCpf(String cpf) {
    final numeros = _somenteNumeros(cpf);

    if (numeros.length != 11) {
      return cpf.isEmpty ? 'Não informado' : cpf;
    }

    return '${numeros.substring(0, 3)}.'
        '${numeros.substring(3, 6)}.'
        '${numeros.substring(6, 9)}-'
        '${numeros.substring(9)}';
  }

  String _getUpaNome(int? upaId) {
    if (upaId == null || upaId == 0) {
      return 'Sem unidade vinculada';
    }

    for (final upa in _upasLista) {
      if (_toInt(upa['id']) == upaId) {
        return upa['nome']?.toString() ?? 'Unidade não encontrada';
      }
    }

    return 'Unidade não encontrada';
  }

  Map<int, List<Map<String, dynamic>>> _agruparPorUPA(
    List<Map<String, dynamic>> enfermeiras,
  ) {
    final grupos = <int, List<Map<String, dynamic>>>{};

    for (final enfermeira in enfermeiras) {
      final upaId = _toInt(enfermeira['upa_id']);

      grupos.putIfAbsent(upaId, () => []);
      grupos[upaId]!.add(enfermeira);
    }

    for (final grupo in grupos.values) {
      grupo.sort(
        (a, b) => (a['nome_completo']?.toString() ?? '')
            .toLowerCase()
            .compareTo(
              (b['nome_completo']?.toString() ?? '').toLowerCase(),
            ),
      );
    }

    return Map.fromEntries(
      grupos.entries.toList()
        ..sort(
          (a, b) => _getUpaNome(a.key)
              .toLowerCase()
              .compareTo(_getUpaNome(b.key).toLowerCase()),
        ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: _secondary,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: _secondary,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: _accent,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: _secondary,
        size: 19,
      ),
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
    );
  }

  Widget _buildPageHeader(bool isMobile) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enfermeiras',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Gerencie as profissionais vinculadas às unidades.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _secondary,
          ),
        ),
      ],
    );

    final button = ElevatedButton.icon(
      onPressed: () => _abrirModalEnfermeira(),
      icon: const Icon(
        Icons.add_rounded,
        size: 18,
      ),
      label: const Text('Nova enfermeira'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
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

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 17),
          button,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: heading),
        const SizedBox(width: 16),
        button,
      ],
    );
  }

  Widget _buildSummary(
    int totalFiltrado,
    int unidadesComEnfermeiras,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 520;

        final items = [
          _buildSummaryItem(
            title: 'Enfermeiras cadastradas',
            value: '${_enfermeiras.length}',
            icon: Icons.medical_services_outlined,
            color: _accent,
          ),
          _buildSummaryItem(
            title: 'Unidades atendidas',
            value: '$unidadesComEnfermeiras',
            icon: Icons.local_hospital_outlined,
            color: _success,
          ),
          _buildSummaryItem(
            title: 'Resultados da busca',
            value: '$totalFiltrado',
            icon: Icons.manage_search_rounded,
            color: _accent,
          ),
        ];

        if (isMobile) {
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

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                Text(
                  title,
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

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar por nome ou unidade...',
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: _secondary,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _secondary,
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: _secondary,
                ),
              )
            : null,
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGroup(
    String nomeUnidade,
    List<Map<String, dynamic>> enfermeiras,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    size: 19,
                    color: _accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nomeUnidade,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '${enfermeiras.length}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (int i = 0; i < enfermeiras.length; i++) ...[
                  if (i > 0) const SizedBox(height: 9),
                  _buildEnfermeiraCard(enfermeiras[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnfermeiraCard(Map<String, dynamic> enfermeira) {
    final nome = enfermeira['nome_completo']?.toString() ?? '-';
    final email = enfermeira['email']?.toString() ?? '-';
    final cpf = _formatarCpf(
      enfermeira['cpf']?.toString() ?? '',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 540;

        final info = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: _accent,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: _secondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'CPF: $cpf',
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
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _abrirModalEnfermeira(
                enfermeira: enfermeira,
              ),
              tooltip: 'Editar enfermeira',
              icon: const Icon(
                Icons.edit_outlined,
                size: 19,
              ),
              color: _accent,
              style: IconButton.styleFrom(
                backgroundColor: _accentSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => _confirmarDeletarEnfermeira(
                enfermeira,
              ),
              tooltip: 'Excluir enfermeira',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 19,
              ),
              color: _danger,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFBEDE9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _border),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    info,
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actions,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 12),
                    actions,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person_search_outlined,
              color: _accent,
              size: 26,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Nenhuma enfermeira encontrada',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tente ajustar a busca ou cadastre uma nova profissional.',
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

  Future<bool?> _showConfirmDeleteDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEDE9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _danger,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _secondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
  }

  Future<void> _confirmarDeletarEnfermeira(
    Map<String, dynamic> enfermeira,
  ) async {
    final nome = enfermeira['nome_completo']?.toString() ?? '';

    final confirmado = await _showConfirmDeleteDialog(
      title: 'Excluir enfermeira',
      message:
          'Tem certeza que deseja excluir "$nome"? Esta ação não pode ser desfeita.',
    );

    if (confirmado != true || !mounted) return;

    try {
      await AuthService().deletarEnfermeira(enfermeira['id']);

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'Enfermeira "$nome" excluída com sucesso!',
      );

      await _carregarDados(mostrarLoading: false);
    } catch (e) {
      if (!mounted) return;

      ToastService.showError(
        context,
        'Erro ao excluir enfermeira: $e',
      );
    }
  }

  Future<void> _abrirModalEnfermeira({
    Map<String, dynamic>? enfermeira,
  }) async {
    final isEditing = enfermeira != null;

    final nomeController = TextEditingController(
      text: enfermeira?['nome_completo']?.toString() ?? '',
    );

    final emailController = TextEditingController(
      text: enfermeira?['email']?.toString() ?? '',
    );

    final cpfController = MaskedTextController(
      mask: '000.000.000-00',
      text: enfermeira?['cpf']?.toString() ?? '',
    );

    final telefoneController = MaskedTextController(
      mask: '(00) 00000-0000',
      text: enfermeira?['telefone']?.toString() ?? '',
    );

    final senhaController = TextEditingController();

    int? upaIdSelecionado = enfermeira == null
        ? null
        : _toInt(enfermeira['upa_id']);

    bool isLoading = false;
    bool mostrarSenha = false;

    final nomeOriginal = nomeController.text.trim();
    final emailOriginal = emailController.text.trim();
    final cpfOriginal = _somenteNumeros(cpfController.text);
    final telefoneOriginal = _somenteNumeros(telefoneController.text);
    final upaOriginal = upaIdSelecionado;

    bool isFormValid() {
      if (nomeController.text.trim().isEmpty) return false;

      if (!RegExp(
        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
      ).hasMatch(emailController.text.trim())) {
        return false;
      }

      if (_somenteNumeros(cpfController.text).length != 11) {
        return false;
      }

      if (_somenteNumeros(telefoneController.text).length != 11) {
        return false;
      }

      if (upaIdSelecionado == null || upaIdSelecionado == 0) {
        return false;
      }

      if (!isEditing && senhaController.text.isEmpty) {
        return false;
      }

      if (isEditing &&
          senhaController.text.isNotEmpty &&
          senhaController.text.length < 6) {
        return false;
      }

      return true;
    }

    bool hasChanges() {
      return nomeController.text.trim() != nomeOriginal ||
          emailController.text.trim() != emailOriginal ||
          _somenteNumeros(cpfController.text) != cpfOriginal ||
          _somenteNumeros(telefoneController.text) != telefoneOriginal ||
          upaIdSelecionado != upaOriginal ||
          senhaController.text.isNotEmpty;
    }

    final upasDisponiveis = _upasLista
        .where((upa) => _toInt(upa['id']) != 0)
        .toList();

    if (upaIdSelecionado != null &&
        !upasDisponiveis.any(
          (upa) => _toInt(upa['id']) == upaIdSelecionado,
        )) {
      upaIdSelecionado = null;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final canSave =
                isFormValid() && (!isEditing || hasChanges());

            return Dialog(
              backgroundColor: _surface,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: _border),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 510,
                  maxHeight:
                      MediaQuery.of(dialogContext).size.height * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        20,
                        16,
                        17,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _accentSoft,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_outlined
                                  : Icons.person_add_alt_1_outlined,
                              color: _accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing
                                      ? 'Editar enfermeira'
                                      : 'Nova enfermeira',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isEditing
                                      ? 'Atualize os dados da profissional.'
                                      : 'Preencha os dados para cadastrar.',
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
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                            ),
                            color: _secondary,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DADOS PESSOAIS',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _secondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nomeController,
                              enabled: !isLoading,
                              textCapitalization:
                                  TextCapitalization.words,
                              onChanged: (_) =>
                                  setDialogState(() {}),
                              decoration: _inputDecoration(
                                label: 'Nome completo',
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 13),
                            TextField(
                              controller: cpfController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              onChanged: (_) =>
                                  setDialogState(() {}),
                              decoration: _inputDecoration(
                                label: 'CPF',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                            const SizedBox(height: 13),
                            TextField(
                              controller: emailController,
                              enabled: !isLoading,
                              keyboardType:
                                  TextInputType.emailAddress,
                              onChanged: (_) =>
                                  setDialogState(() {}),
                              decoration: _inputDecoration(
                                label: 'E-mail',
                                icon: Icons.mail_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 13),
                            TextField(
                              controller: telefoneController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.phone,
                              onChanged: (_) =>
                                  setDialogState(() {}),
                              decoration: _inputDecoration(
                                label: 'Telefone',
                                icon: Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'VÍNCULO E ACESSO',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _secondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: upaIdSelecionado,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Unidade vinculada',
                                icon: Icons.local_hospital_outlined,
                              ),
                              items: upasDisponiveis.map((upa) {
                                return DropdownMenuItem<int>(
                                  value: _toInt(upa['id']),
                                  child: Text(
                                    upa['nome']?.toString() ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: _primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        upaIdSelecionado = value;
                                      });
                                    },
                            ),
                            const SizedBox(height: 13),
                            TextField(
                              controller: senhaController,
                              enabled: !isLoading,
                              obscureText: !mostrarSenha,
                              onChanged: (_) =>
                                  setDialogState(() {}),
                              decoration: _inputDecoration(
                                label: isEditing
                                    ? 'Nova senha (opcional)'
                                    : 'Senha',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      mostrarSenha = !mostrarSenha;
                                    });
                                  },
                                  icon: Icon(
                                    mostrarSenha
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 19,
                                    color: _secondary,
                                  ),
                                ),
                              ),
                            ),
                            if (isEditing) ...[
                              const SizedBox(height: 9),
                              const Text(
                                'Deixe em branco para manter a senha atual.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: _secondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: _border,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
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
                            child: ElevatedButton(
                              onPressed: isLoading || !canSave
                                  ? null
                                  : () async {
                                      setDialogState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        final dados = <String, dynamic>{
                                          'nomeCompleto':
                                              nomeController.text.trim(),
                                          'email':
                                              emailController.text.trim(),
                                          'telefone': _somenteNumeros(
                                            telefoneController.text,
                                          ),
                                          'cpf': _somenteNumeros(
                                            cpfController.text,
                                          ),
                                          'upaId': upaIdSelecionado,
                                        };

                                        if (isEditing) {
                                          if (senhaController
                                              .text.isNotEmpty) {
                                            dados['senha'] =
                                                senhaController.text;
                                          }

                                          await AuthService()
                                              .atualizarEnfermeira(
                                            enfermeira['id'],
                                            dados,
                                          );
                                        } else {
                                          dados['senha'] =
                                              senhaController.text;

                                          await AuthService()
                                              .criarEnfermeira(dados);
                                        }

                                        if (!dialogContext.mounted) {
                                          return;
                                        }

                                        Navigator.pop(dialogContext);

                                        if (!mounted) return;

                                        ToastService.showSuccess(
                                          context,
                                          isEditing
                                              ? 'Enfermeira atualizada com sucesso!'
                                              : 'Enfermeira cadastrada com sucesso!',
                                        );

                                        await _carregarDados(
                                          mostrarLoading: false,
                                        );
                                      } catch (e) {
                                        if (!dialogContext.mounted) {
                                          return;
                                        }

                                        final mensagem = e.toString();

                                        String erro;

                                        if (mensagem.contains(
                                          'CPF já cadastrado',
                                        )) {
                                          erro =
                                              'CPF já cadastrado para outra enfermeira.';
                                        } else if (mensagem.contains(
                                          'Email já cadastrado',
                                        )) {
                                          erro =
                                              'E-mail já cadastrado para outra enfermeira.';
                                        } else {
                                          erro =
                                              'Erro ao salvar enfermeira: $e';
                                        }

                                        ToastService.showError(
                                          dialogContext,
                                          erro,
                                        );
                                      } finally {
                                        if (dialogContext.mounted) {
                                          setDialogState(() {
                                            isLoading = false;
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    _accent.withOpacity(0.35),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEditing
                                          ? 'Salvar alterações'
                                          : 'Cadastrar',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
    cpfController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = _searchQuery.trim().toLowerCase();

    final enfermeirasFiltradas = _enfermeiras.where((enfermeira) {
      final nome =
          enfermeira['nome_completo']?.toString().toLowerCase() ?? '';

      final unidade = enfermeira['upa_nome']?.toString().toLowerCase() ??
          _getUpaNome(_toInt(enfermeira['upa_id'])).toLowerCase();

      return nome.contains(search) || unidade.contains(search);
    }).toList();

    final grupos = _agruparPorUPA(enfermeirasFiltradas);

    final unidadesComEnfermeiras = _enfermeiras
        .map((enfermeira) => _toInt(enfermeira['upa_id']))
        .where((id) => id != 0)
        .toSet()
        .length;

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
        final isMobile = constraints.maxWidth < 768;

        return RefreshIndicator(
          color: _accent,
          onRefresh: () => _carregarDados(
            mostrarLoading: false,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 15 : 30,
              vertical: isMobile ? 22 : 30,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1360,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(isMobile),
                    const SizedBox(height: 23),
                    _buildSummary(
                      enfermeirasFiltradas.length,
                      unidadesComEnfermeiras,
                    ),
                    const SizedBox(height: 22),
                    _buildSearch(),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            search.isEmpty
                                ? 'Enfermeiras cadastradas'
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
                            padding: EdgeInsets.only(right: 10),
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
                          '${enfermeirasFiltradas.length} profissionais',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (enfermeirasFiltradas.isEmpty)
                      _buildEmptyState()
                    else
                      for (final entry in grupos.entries)
                        _buildGroup(
                          _getUpaNome(
                            entry.key == 0 ? null : entry.key,
                          ),
                          entry.value,
                        ),
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
