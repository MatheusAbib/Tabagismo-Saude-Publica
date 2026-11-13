
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminUsuarioDetalhesScreen extends StatefulWidget {
  final int usuarioId;
  final String usuarioNome;

  const AdminUsuarioDetalhesScreen({
    super.key,
    required this.usuarioId,
    required this.usuarioNome,
  });

  @override
  State<AdminUsuarioDetalhesScreen> createState() =>
      _AdminUsuarioDetalhesScreenState();
}

class _AdminUsuarioDetalhesScreenState
    extends State<AdminUsuarioDetalhesScreen> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Colors.white;
  static const Color _surfaceSoft = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _accent = Color(0xFF426E8C);
  static const Color _accentSoft = Color(0xFFEAF2F7);
  static const Color _primary = Color(0xFF30383E);
  static const Color _secondary = Color(0xFF758087);
  static const Color _success = Color(0xFF34866D);
  static const Color _warning = Color(0xFFC58A3C);
  static const Color _danger = Color(0xFFC76A62);
  static const Color _purple = Color(0xFF8564A7);

  bool _isLoading = true;
  bool _atualizandoMatricula = false;
  String? _erro;

  Map<String, dynamic>? _usuario;
  Map<String, dynamic>? _matricula;
  List<Map<String, dynamic>> _sintomas = [];

  final Map<String, bool> _seriesVisiveis = {
    'Ansiedade': true,
    'Irritabilidade': true,
    'Insônia': true,
    'Fome': true,
    'Concentração': true,
    'Vontade de fumar': true,
  };

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final response =
          await AuthService().getUsuarioDetalhes(widget.usuarioId);

      if (!mounted) return;

      setState(() {
        _usuario = response['usuario'] is Map
            ? Map<String, dynamic>.from(response['usuario'])
            : null;

        _matricula = response['matricula'] is Map
            ? Map<String, dynamic>.from(response['matricula'])
            : null;

        _sintomas = response['sintomas'] is List
            ? (response['sintomas'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : [];

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar os dados do paciente.';
        _isLoading = false;
      });

      ToastService.showError(
        context,
        'Erro ao carregar dados do usuário: $e',
      );
    }
  }

  String _valor(dynamic value) {
    if (value == null) return 'Não informado';

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return 'Não informado';
    }

    return text;
  }

  String _formatarData(dynamic data) {
    if (data == null) return 'Não informado';

    final text = data.toString().trim();

    if (text.isEmpty) return 'Não informado';

    final date = DateTime.tryParse(text);

    if (date == null) return text;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatarTelefone(dynamic telefone) {
    final original = _valor(telefone);

    if (original == 'Não informado') return original;

    final limpo = original.replaceAll(RegExp(r'[^\d]'), '');

    if (limpo.length == 11) {
      return '(${limpo.substring(0, 2)}) '
          '${limpo.substring(2, 7)}-${limpo.substring(7)}';
    }

    if (limpo.length == 10) {
      return '(${limpo.substring(0, 2)}) '
          '${limpo.substring(2, 6)}-${limpo.substring(6)}';
    }

    return original;
  }

  String _formatarCpf(dynamic cpf) {
    final original = _valor(cpf);

    if (original == 'Não informado') return original;

    final limpo = original.replaceAll(RegExp(r'[^\d]'), '');

    if (limpo.length != 11) return original;

    return '${limpo.substring(0, 3)}.'
        '${limpo.substring(3, 6)}.'
        '${limpo.substring(6, 9)}-${limpo.substring(9)}';
  }

  double _numero(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _inteiro(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _alocarTurma(String opcao) async {
    if (_matricula == null || _atualizandoMatricula) return;

    final turmaEscolhida = opcao == 'primeira'
        ? _matricula!['turma_horario']
        : _matricula!['segunda_opcao_turma'];

    final matriculaId = _inteiro(_matricula!['id']);

    if (matriculaId == null ||
        turmaEscolhida == null ||
        turmaEscolhida.toString().trim().isEmpty) {
      ToastService.showError(
        context,
        'Não foi possível identificar a matrícula ou a turma.',
      );
      return;
    }

    setState(() {
      _atualizandoMatricula = true;
    });

    try {
      await AuthService().atualizarMatricula(
        matriculaId,
        'matriculado',
        turmaEscolhida.toString(),
      );

      await _carregarDados();

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'Usuário matriculado com sucesso na turma: $turmaEscolhida',
      );
    } catch (e) {
      if (!mounted) return;

      ToastService.showError(
        context,
        'Erro ao alocar turma: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _atualizandoMatricula = false;
        });
      }
    }
  }

  Future<void> _confirmarMatricula(String opcao) async {
    if (_matricula == null) return;

    final turma = opcao == 'primeira'
        ? _matricula!['turma_horario']
        : _matricula!['segunda_opcao_turma'];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar matrícula',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          content: Text(
            'Deseja matricular ${widget.usuarioNome} na turma '
            '"${_valor(turma)}"?',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.6,
              color: _secondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      await _alocarTurma(opcao);
    }
  }

  Map<String, List<String>> _obterComorbidades() {
    if (_matricula == null) return {};

    final raw = _matricula!['comorbidades'];

    if (raw == null) return {};

    Map<String, dynamic> dados;

    try {
      if (raw is String) {
        final decoded = jsonDecode(raw);

        if (decoded is! Map) return {};

        dados = Map<String, dynamic>.from(decoded);
      } else if (raw is Map) {
        dados = Map<String, dynamic>.from(raw);
      } else {
        return {};
      }
    } catch (_) {
      return {};
    }

    const categorias = {
      'cancer': 'Câncer',
      'cardiovascular': 'Cardiovascular',
      'metabolico': 'Metabólico',
      'psiquiatrico': 'Psiquiátrico',
      'respiratorio': 'Respiratório',
    };

    final resultado = <String, List<String>>{};

    for (final entry in categorias.entries) {
      final lista = dados[entry.key];

      if (lista is! List) continue;

      final valores = <String>[];

      for (final item in lista) {
        dynamic valor;

        if (item is Map) {
          valor = item['valor'];
        } else {
          valor = item;
        }

        final texto = valor?.toString().trim() ?? '';

        if (texto.isNotEmpty &&
            texto.toLowerCase() != 'nenhum' &&
            texto.toLowerCase() != 'null') {
          valores.add(texto);
        }
      }

      if (valores.isNotEmpty) {
        resultado[entry.value] = valores;
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _erro != null
                      ? _buildErro()
                      : RefreshIndicator(
                          color: _accent,
                          onRefresh: _carregarDados,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile =
                                  constraints.maxWidth < 760;

                              final padding = isMobile ? 16.0 : 28.0;

                              return SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  padding,
                                  24,
                                  padding,
                                  40,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1320,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPatientHeader(isMobile),
                                        const SizedBox(height: 22),
                                        _buildOverview(isMobile),
                                        const SizedBox(height: 20),
                                        if (isMobile) ...[
                                          _buildDadosPessoais(),
                                          const SizedBox(height: 16),
                                          _buildMatricula(),
                                          const SizedBox(height: 16),
                                          _buildObjetivos(),
                                        ] else ...[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: _buildDadosPessoais(),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                flex: 4,
                                                child: _buildMatricula(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildObjetivos(),
                                        ],
                                        const SizedBox(height: 20),
                                        _buildEvolucao(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _primary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ficha do paciente',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Atualizar informações',
            onPressed: _isLoading ? null : _carregarDados,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader(bool isMobile) {
    final nome = _valor(
      _usuario?['nome_completo'] ?? widget.usuarioNome,
    );

    final idade = _valor(_usuario?['idade']);
    final sexo = _valor(_usuario?['sexo']);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(54),
                const SizedBox(height: 14),
                _buildPatientIdentity(nome, idade, sexo),
              ],
            )
          : Row(
              children: [
                _buildAvatar(64),
                const SizedBox(width: 18),
                Expanded(
                  child: _buildPatientIdentity(nome, idade, sexo),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(),
              ],
            ),
    );
  }

  Widget _buildAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.52,
        color: _accent,
      ),
    );
  }

  Widget _buildPatientIdentity(
    String nome,
    String idade,
    String sexo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRONTUÁRIO DO PACIENTE',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: _accent,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          nome,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 14,
          runSpacing: 7,
          children: [
            _buildInlineInfo(
              Icons.badge_outlined,
              'ID ${widget.usuarioId}',
            ),
            if (idade != 'Não informado')
              _buildInlineInfo(
                Icons.cake_outlined,
                '$idade anos',
              ),
            if (sexo != 'Não informado')
              _buildInlineInfo(
                Icons.person_outline,
                sexo,
              ),
          ],
        ),
        if (MediaQuery.of(context).size.width < 760) ...[
          const SizedBox(height: 16),
          _buildStatusBadge(),
        ],
      ],
    );
  }

  Widget _buildInlineInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _secondary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = _matricula?['status']?.toString();

    String label;
    Color color;

    switch (status) {
      case 'matriculado':
        label = 'Matriculado';
        color = _success;
        break;
      case 'em_espera':
        label = 'Em espera';
        color = _warning;
        break;
      case 'cancelado':
        label = 'Cancelado';
        color = _danger;
        break;
      default:
        label = status == null
            ? 'Sem matrícula'
            : status.replaceAll('_', ' ');
        color = _secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        border: Border.all(color: color.withOpacity(0.22)),
        borderRadius: BorderRadius.circular(9),
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
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(bool isMobile) {
    final score = _matricula?['score_fagestrom'];
    final sintomas = _sintomas.length;
    final turma = _valor(_matricula?['turma_horario']);

    final items = [
      _OverviewItem(
        'Fagerström',
        _valor(score),
        Icons.monitor_heart_outlined,
        _accent,
      ),
      _OverviewItem(
        'Registros de sintomas',
        sintomas.toString(),
        Icons.show_chart_rounded,
        _purple,
      ),
      _OverviewItem(
        'Turma',
        turma,
        Icons.groups_outlined,
        _success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 550
            ? 1
            : constraints.maxWidth < 900
                ? 2
                : 3;

        final spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: _surface,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: _secondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 19, 19, 17),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
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
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(19),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDadosPessoais() {
    return _buildSection(
      title: 'Dados pessoais',
      subtitle: 'Informações cadastrais do paciente',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _buildDetail(
            'Nome completo',
            _valor(_usuario?['nome_completo']),
            Icons.badge_outlined,
          ),
          _buildDetail(
            'E-mail',
            _valor(_usuario?['email']),
            Icons.mail_outline_rounded,
          ),
          _buildDetail(
            'Telefone',
            _formatarTelefone(_usuario?['telefone']),
            Icons.phone_outlined,
          ),
          _buildDetail(
            'CPF',
            _formatarCpf(_usuario?['cpf']),
            Icons.assignment_ind_outlined,
          ),
          _buildDetail(
            'Sexo',
            _valor(_usuario?['sexo']),
            Icons.person_outline,
          ),
          _buildDetail(
            'Data de nascimento',
            _formatarData(_usuario?['data_nascimento']),
            Icons.calendar_today_outlined,
          ),
          _buildDetail(
            'Idade',
            _usuario?['idade'] == null
                ? 'Não informado'
                : '${_usuario!['idade']} anos',
            Icons.cake_outlined,
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(
    String label,
    String value,
    IconData icon, {
    bool last = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 16,
                color: _secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: _secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: _secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: SelectableText(
                              value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMatricula() {
    if (_matricula == null) {
      return _buildSection(
        title: 'Matrícula',
        subtitle: 'Vínculo com o programa',
        icon: Icons.school_outlined,
        child: _buildEmpty(
          Icons.school_outlined,
          'Sem matrícula ativa',
          'Não há informações de matrícula para este paciente.',
        ),
      );
    }

    final emEspera = _matricula!['status'] == 'em_espera';
    final segundaOpcao = _matricula!['segunda_opcao_turma'];

    return _buildSection(
      title: 'Matrícula',
      subtitle: 'Informações de participação no programa',
      icon: Icons.school_outlined,
      trailing: IconButton(
        tooltip: 'Ver detalhes da matrícula',
        onPressed: _mostrarDetalhesMatricula,
        icon: const Icon(
          Icons.open_in_new_rounded,
          size: 19,
          color: _accent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetail(
            'Unidade de atendimento',
            _valor(_matricula!['upa_nome']),
            Icons.local_hospital_outlined,
          ),
          _buildDetail(
            'Score Fagerström',
            _valor(_matricula!['score_fagestrom']),
            Icons.monitor_heart_outlined,
          ),
          _buildDetail(
            'Medicamento',
            _valor(_matricula!['medicamento']),
            Icons.medication_outlined,
          ),
          _buildDetail(
            'Turma',
            _valor(_matricula!['turma_horario']),
            Icons.groups_outlined,
          ),
          if (segundaOpcao != null)
            _buildDetail(
              'Segunda opção',
              _valor(segundaOpcao),
              Icons.swap_horiz_rounded,
              last: !emEspera,
            ),
          if (emEspera) ...[
            const SizedBox(height: 6),
            const Divider(color: _border),
            const SizedBox(height: 12),
            const Text(
              'Alocação de turma',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecione uma das opções escolhidas pelo paciente.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                height: 1.5,
                color: _secondary,
              ),
            ),
            const SizedBox(height: 14),
            _buildMatriculaActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildMatriculaActions() {
    final temSegunda = _matricula?['segunda_opcao_turma'] != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 400;

        final primeira = FilledButton.icon(
          onPressed: _atualizandoMatricula
              ? null
              : () => _confirmarMatricula('primeira'),
          icon: const Icon(Icons.check_rounded, size: 17),
          label: const Text('Matricular 1ª opção'),
          style: FilledButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        );

        final segunda = OutlinedButton(
          onPressed: _atualizandoMatricula
              ? null
              : () => _confirmarMatricula('segunda'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _accent,
            side: const BorderSide(color: _border),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: const Text('2ª opção'),
        );

        if (!temSegunda) {
          return SizedBox(
            width: double.infinity,
            child: primeira,
          );
        }

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primeira,
              const SizedBox(height: 9),
              segunda,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: primeira),
            const SizedBox(width: 9),
            Expanded(flex: 2, child: segunda),
          ],
        );
      },
    );
  }

  Widget _buildObjetivos() {
    final stopDate = DateTime.tryParse(
      _usuario?['stop_date']?.toString() ?? '',
    );

    return _buildSection(
      title: 'Objetivos e acompanhamento',
      subtitle: 'Metas registradas pelo paciente',
      icon: Icons.flag_outlined,
      child: stopDate == null
          ? _buildEmpty(
              Icons.flag_outlined,
              'Nenhuma meta definida',
              'O paciente ainda não registrou uma data para parar de fumar.',
            )
          : _buildObjetivosContent(stopDate),
    );
  }

  Widget _buildObjetivosContent(DateTime stopDate) {
    final hoje = DateTime.now();

    final inicio = DateTime(
      stopDate.year,
      stopDate.month,
      stopDate.day,
    );

    final atual = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );

    final dias = atual.difference(inicio).inDays;
    final meta = _inteiro(_usuario?['target_days']);
    final progresso = meta != null && meta > 0 && dias >= 0
        ? (dias / meta).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _accentSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _accent.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    color: _accent,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tempo desde a data de parada',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dias < 0
                    ? 'Início em ${-dias} dias'
                    : '$dias ${dias == 1 ? 'dia' : 'dias'}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Data registrada: ${_formatarData(stopDate)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _secondary,
                ),
              ),
              if (meta != null && meta > 0) ...[
                const SizedBox(height: 17),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 7,
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progresso em relação à meta de $meta dias',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 560 ? 1 : 3;
            final gap = 10.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                _buildGoalMetric(
                  width,
                  'Meta',
                  meta == null ? 'Não informada' : '$meta dias',
                  Icons.flag_outlined,
                ),
                _buildGoalMetric(
                  width,
                  'Cigarros por dia',
                  _valor(_usuario?['cigarros_por_dia']),
                  Icons.smoke_free_outlined,
                ),
                _buildGoalMetric(
                  width,
                  'Valor da carteira',
                  _usuario?['valor_carteira'] == null
                      ? 'Não informado'
                      : 'R\$ ${_valor(_usuario?['valor_carteira'])}',
                  Icons.payments_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 11),
        const Text(
          'O período exibido é calculado a partir da data informada pelo paciente e não confirma, por si só, a abstinência.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            height: 1.6,
            color: _secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalMetric(
    double width,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accent, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: _secondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 20,
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: _secondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                height: 1.5,
                color: _secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalhesMatricula() {
    if (_matricula == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
              maxHeight: 650,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    12,
                    14,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: _accent,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Detalhes da matrícula',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
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
                        _buildDialogDetail(
                          'UPA',
                          _valor(_matricula?['upa_nome']),
                        ),
                        _buildDialogDetail(
                          'Escolaridade',
                          _valor(_matricula?['escolaridade']),
                        ),
                        _buildDialogDetail(
                          'Score Fagerström',
                          _valor(_matricula?['score_fagestrom']),
                        ),
                        _buildDialogDetail(
                          'Medicamento',
                          _valor(_matricula?['medicamento']),
                        ),
                        _buildDialogDetail(
                          'Turma',
                          _valor(_matricula?['turma_horario']),
                        ),
                        if (_matricula?['segunda_opcao_turma'] != null)
                          _buildDialogDetail(
                            'Segunda opção',
                            _valor(
                              _matricula?['segunda_opcao_turma'],
                            ),
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Comorbidades',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildComorbidades(),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: _border),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      if (_matricula?['status'] == 'em_espera') ...[
                        _buildDialogMatriculaActions(dialogContext),
                        const SizedBox(height: 9),
                      ],
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: const BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        child: const Text('Fechar'),
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
  }

  Widget _buildDialogMatriculaActions(BuildContext dialogContext) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segunda = _matricula?['segunda_opcao_turma'] != null;

        final primeira = FilledButton(
          onPressed: _atualizandoMatricula
              ? null
              : () {
                  Navigator.pop(dialogContext);
                  _confirmarMatricula('primeira');
                },
          style: FilledButton.styleFrom(
            backgroundColor: _accent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Alocar 1ª opção'),
        );

        if (!segunda) return primeira;

        final segundaAcao = OutlinedButton(
          onPressed: _atualizandoMatricula
              ? null
              : () {
                  Navigator.pop(dialogContext);
                  _confirmarMatricula('segunda');
                },
          child: const Text('2ª opção'),
        );

        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primeira,
              const SizedBox(height: 8),
              segundaAcao,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: primeira),
            const SizedBox(width: 9),
            Expanded(flex: 2, child: segundaAcao),
          ],
        );
      },
    );
  }

  Widget _buildDialogDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: _secondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComorbidades() {
    final dados = _obterComorbidades();

    if (dados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _surfaceSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Nenhuma comorbidade registrada',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: _secondary,
          ),
        ),
      );
    }

    return Column(
      children: dados.entries.map((entry) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                entry.value.join(', '),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 1.5,
                  color: _primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEvolucao() {
    if (_sintomas.isEmpty) {
      return _buildSection(
        title: 'Evolução dos sintomas',
        subtitle: 'Histórico de acompanhamento',
        icon: Icons.show_chart_rounded,
        child: _buildEmpty(
          Icons.monitor_heart_outlined,
          'Sem registros de sintomas',
          'O paciente ainda não possui registros para exibir no gráfico.',
        ),
      );
    }

    final registros = _sintomas.reversed.toList();

    final series = [
      _SymptomSeries(
        'Ansiedade',
        'ansiedade',
        _accent,
      ),
      _SymptomSeries(
        'Irritabilidade',
        'irritabilidade',
        _danger,
      ),
      _SymptomSeries(
        'Insônia',
        'insonia',
        _purple,
      ),
      _SymptomSeries(
        'Fome',
        'fome',
        const Color(0xFFE39A55),
      ),
      _SymptomSeries(
        'Concentração',
        'dificuldade_concentracao',
        _success,
      ),
      _SymptomSeries(
        'Vontade de fumar',
        'vontade_fumar',
        _warning,
      ),
    ];

    final ativos = series
        .where((item) => _seriesVisiveis[item.label] == true)
        .toList();

    final labels = registros.map((registro) {
      final data = DateTime.tryParse(
        registro['data']?.toString() ?? '',
      );

      if (data == null) {
        return _valor(registro['data']);
      }

      return '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}';
    }).toList();

    return _buildSection(
      title: 'Evolução dos sintomas',
      subtitle:
          '${registros.length} ${registros.length == 1 ? 'registro' : 'registros'} de acompanhamento',
      icon: Icons.show_chart_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intensidade dos sintomas',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Selecione os indicadores para mostrar ou ocultar suas linhas.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: series.map((item) {
              final selected =
                  _seriesVisiveis[item.label] ?? false;

              return FilterChip(
                selected: selected,
                showCheckmark: false,
                backgroundColor: _surface,
                selectedColor: item.color.withOpacity(0.1),
                side: BorderSide(
                  color: selected
                      ? item.color.withOpacity(0.4)
                      : _border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: selected
                            ? item.color
                            : _secondary.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? _primary
                            : _secondary,
                      ),
                    ),
                  ],
                ),
                onSelected: (value) {
                  setState(() {
                    _seriesVisiveis[item.label] = value;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(
              10,
              20,
              20,
              10,
            ),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 310,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = [
                    constraints.maxWidth,
                    registros.length * 65.0 + 60,
                    320.0,
                  ].reduce((a, b) => a > b ? a : b);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: registros.length > 1
                              ? (registros.length - 1).toDouble()
                              : 1,
                          minY: 0,
                          maxY: 10,
                          clipData: const FlClipData.all(),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 2,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: _border,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(color: _border),
                              left: BorderSide(color: _border),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 2,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      color: _secondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();

                                  if (index < 0 ||
                                      index >= labels.length ||
                                      value != index.toDouble()) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(top: 9),
                                    child: Text(
                                      labels[index],
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        color: _secondary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData:
                                LineTouchTooltipData(
                              getTooltipItems: (spots) {
                                return spots.map((spot) {
                                  final serie =
                                      ativos[spot.barIndex];

                                  return LineTooltipItem(
                                    '${serie.label}: '
                                    '${spot.y.toStringAsFixed(0)}',
                                    TextStyle(
                                      color: serie.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: ativos.map((serie) {
                            return LineChartBarData(
                              spots: List.generate(
                                registros.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  _numero(
                                    registros[index][serie.key],
                                  ),
                                ),
                              ),
                              isCurved: registros.length > 2,
                              curveSmoothness: 0.2,
                              preventCurveOverShooting: true,
                              color: serie.color,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: registros.length <= 8,
                              ),
                              belowBarData:
                                  BarAreaData(show: false),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Escala de intensidade de 0 a 10. Os dados representam os registros informados pelo paciente.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              height: 1.6,
              color: _secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: _danger,
              size: 42,
            ),
            const SizedBox(height: 14),
            Text(
              _erro ?? 'Erro ao carregar informações.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _primary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewItem(
    this.label,
    this.value,
    this.icon,
    this.color,
  );
}

class _SymptomSeries {
  final String label;
  final String key;
  final Color color;

  const _SymptomSeries(
    this.label,
    this.key,
    this.color,
  );
}
