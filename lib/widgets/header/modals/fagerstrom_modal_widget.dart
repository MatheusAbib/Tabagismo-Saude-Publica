import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class FagerstromTestModal extends StatefulWidget {
  final Function(int)? onScoreUpdated;

  const FagerstromTestModal({
    Key? key,
    this.onScoreUpdated,
  }) : super(key: key);

  @override
  State<FagerstromTestModal> createState() => _FagerstromTestModalState();

  static Future<void> show(
    BuildContext context, {
    Function(int)? onScoreUpdated,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final isMobile = size.width < 800;

        return Dialog(
          backgroundColor: const Color(0xFFFFFDF9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(
            size.width < 400 ? 8 : (isMobile ? 12 : 24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE6E5DF)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 700,
              maxHeight: size.height * (isMobile ? 0.92 : 0.88),
            ),
            child: FagerstromTestModal(
              onScoreUpdated: onScoreUpdated,
            ),
          ),
        );
      },
    );
  }
}

class _FagerstromTestModalState extends State<FagerstromTestModal> {
  final AuthService _authService = AuthService();

  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFE6E5DF);

  static const Color _veryLow = Color(0xFF2E8B6A);
  static const Color _low = Color(0xFF789B36);
  static const Color _medium = Color(0xFFD18A28);
  static const Color _high = Color(0xFFC96D43);
  static const Color _veryHigh = Color(0xFFBF554D);

  final List<int?> _respostas = List<int?>.filled(6, null);

  int _score = 0;
  bool _testeRealizado = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  final List<Map<String, dynamic>> _perguntas = [
    {
      'icon': Icons.alarm_outlined,
      'texto': 'Em quanto tempo depois de acordar você fuma o primeiro cigarro?',
      'opcoes': [
        {'texto': 'Dentro de 5 minutos', 'valor': 3},
        {'texto': '6-30 minutos', 'valor': 2},
        {'texto': '31-60 minutos', 'valor': 1},
        {'texto': 'Depois de 60 minutos', 'valor': 0},
      ],
    },
    {
      'icon': Icons.location_disabled_outlined,
      'texto': 'Você acha difícil ficar sem fumar em lugares onde é proibido?',
      'opcoes': [
        {'texto': 'Sim', 'valor': 1},
        {'texto': 'Não', 'valor': 0},
      ],
    },
    {
      'icon': Icons.emoji_emotions_outlined,
      'texto': 'Qual o cigarro do dia que traz mais satisfação?',
      'opcoes': [
        {'texto': 'O primeiro da manhã', 'valor': 1},
        {'texto': 'Outros', 'valor': 0},
      ],
    },
    {
      'icon': Icons.smoking_rooms_outlined,
      'texto': 'Quantos cigarros você fuma por dia?',
      'opcoes': [
        {'texto': 'Menos de 10', 'valor': 0},
        {'texto': 'De 11 a 20', 'valor': 1},
        {'texto': 'De 21 a 30', 'valor': 2},
        {'texto': 'Mais de 31', 'valor': 3},
      ],
    },
    {
      'icon': Icons.wb_sunny_outlined,
      'texto': 'Você fuma mais frequentemente pela manhã?',
      'opcoes': [
        {'texto': 'Sim', 'valor': 1},
        {'texto': 'Não', 'valor': 0},
      ],
    },
    {
      'icon': Icons.sick_outlined,
      'texto':
          'Você fuma mesmo doente quando precisa ficar na cama a maior parte do tempo?',
      'opcoes': [
        {'texto': 'Sim', 'valor': 1},
        {'texto': 'Não', 'valor': 0},
      ],
    },
  ];

  bool get _mostrarResultado => _testeRealizado && !_isEditing;

  int get _quantidadeRespondida {
    return _respostas.where((resposta) => resposta != null).length;
  }

  bool get _todasPerguntasRespondidas {
    return _respostas.every((resposta) => resposta != null);
  }

  @override
  void initState() {
    super.initState();
    _carregarTesteSalvo();
  }

  Future<void> _carregarTesteSalvo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.getUserData();
      final userData = response['user'];

      if (!mounted) return;

      final scoreSalvo = userData['scoreFagestrom'];

      if (scoreSalvo is num && scoreSalvo > 0) {
        setState(() {
          _score = scoreSalvo.toInt();
          _testeRealizado = true;
          _isEditing = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar teste: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _salvarScore() async {
    if (_isSaving || !_todasPerguntasRespondidas) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _authService.updateUserData({
        'scoreFagestrom': _score,
      });

      if (!mounted) return;

      setState(() {
        _testeRealizado = true;
        _isEditing = false;
        _isSaving = false;
      });

      widget.onScoreUpdated?.call(_score);

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'Resultado salvo com sucesso!',
      );
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Não foi possível salvar o resultado. Tente novamente.',
        );
      }
    } finally {
      if (mounted && _isSaving) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _reiniciarTeste() {
    setState(() {
      for (int i = 0; i < _respostas.length; i++) {
        _respostas[i] = null;
      }

      _score = 0;
      _testeRealizado = false;
      _isEditing = true;
    });
  }

  void _selecionarResposta(int index, int valor) {
    if (_isSaving) return;

    setState(() {
      _respostas[index] = valor;
      _score = _respostas.fold<int>(
        0,
        (total, resposta) => total + (resposta ?? 0),
      );
    });
  }

  String _getNivelDependencia(int score) {
    if (score <= 2) return 'Muito Baixa';
    if (score <= 4) return 'Baixa';
    if (score == 5) return 'Média';
    if (score <= 7) return 'Elevada';
    return 'Muito Elevada';
  }

  Color _getNivelColor(int score) {
    if (score <= 2) return _veryLow;
    if (score <= 4) return _low;
    if (score == 5) return _medium;
    if (score <= 7) return _high;
    return _veryHigh;
  }

  IconData _getNivelIcon(int score) {
    if (score <= 2) return Icons.emoji_emotions_outlined;
    if (score <= 4) return Icons.sentiment_satisfied_outlined;
    if (score == 5) return Icons.sentiment_neutral_outlined;
    if (score <= 7) return Icons.sentiment_dissatisfied_outlined;
    return Icons.sentiment_very_dissatisfied_outlined;
  }

  String _getDescricaoNivel(int score) {
    if (score <= 2) {
      return 'Sua pontuação indica um grau muito baixo de dependência física à nicotina. Isso sugere que a necessidade de fumar está menos associada à dependência física, embora hábitos e situações do dia a dia ainda possam influenciar o consumo. Identificar esses momentos e contar com acompanhamento profissional pode ajudar você a avançar no processo de parar de fumar.';
    }

    if (score <= 4) {
      return 'Sua pontuação indica um grau baixo de dependência física à nicotina. Mesmo assim, a vontade de fumar pode aparecer em situações específicas, como após refeições, em momentos de estresse ou durante atividades habituais. Reconhecer esses gatilhos e desenvolver alternativas para lidar com eles pode facilitar a interrupção do tabagismo.';
    }

    if (score == 5) {
      return 'Sua pontuação indica um grau médio de dependência física à nicotina. Isso significa que a ausência do cigarro pode provocar vontade de fumar e sintomas de abstinência. O acompanhamento de profissionais de saúde pode ajudar a organizar estratégias para enfrentar essas dificuldades e avaliar quais formas de tratamento são mais adequadas para você.';
    }

    if (score <= 7) {
      return 'Sua pontuação indica um grau elevado de dependência física à nicotina. Nesse nível, parar de fumar pode provocar sintomas de abstinência mais intensos, como irritabilidade, ansiedade e dificuldade de concentração. O acompanhamento profissional é especialmente importante para planejar a interrupção do consumo e avaliar a necessidade de tratamentos de apoio.';
    }

    return 'Sua pontuação indica um grau muito elevado de dependência física à nicotina. A necessidade frequente de fumar pode tornar a interrupção mais difícil, principalmente devido aos sintomas de abstinência. Procure acompanhamento com uma equipe de saúde para construir um plano de tratamento adequado, que pode incluir apoio comportamental e medicamentos, quando indicados. A pontuação não determina suas chances de conseguir parar de fumar.';
  }

  Color _getSoftColor(Color color) {
    return Color.alphaBlend(
      color.withOpacity(0.09),
      Colors.white,
    );
  }

  Color _getBorderColor(Color color) {
    return Color.alphaBlend(
      color.withOpacity(0.23),
      Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isCompact = constraints.maxWidth < 400;

        final modal = Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(19),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(
              mainAxisSize:
                  _mostrarResultado ? MainAxisSize.min : MainAxisSize.max,
              children: [
                _buildHeader(isMobile),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: _border,
                ),
                if (_isLoading)
                  const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else if (_mostrarResultado)
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 14 : 22),
                      child: _buildResultCard(isMobile),
                    ),
                  )
                else ...[
                  _buildFixedProgress(isMobile),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 14 : 22,
                        14,
                        isMobile ? 14 : 22,
                        22,
                      ),
                      child: _buildQuestionsList(isMobile, isCompact),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        if (_mostrarResultado) {
          return modal;
        }

        return SizedBox(
          height: constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height * 0.85,
          child: modal,
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: isMobile ? 14 : 18,
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 40 : 44,
            height: isMobile ? 40 : 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assessment_outlined,
              color: _primary,
              size: isMobile ? 21 : 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teste de Fagerström',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _foreground,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avalie seu grau de dependência à nicotina',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondary,
                    fontSize: isMobile ? 11 : 12,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSaving ? null : () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.close,
                  color: _secondary,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedProgress(bool isMobile) {
    final progresso = _quantidadeRespondida / _perguntas.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 22,
        15,
        isMobile ? 16 : 22,
        16,
      ),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Progresso do questionário',
                  style: TextStyle(
                    color: _foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Text(
                '$_quantidadeRespondida de ${_perguntas.length} perguntas',
                style: const TextStyle(
                  color: _secondary,
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 6,
              backgroundColor: _softBlue,
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(bool isMobile, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._perguntas.asMap().entries.map((entry) {
          return _buildPerguntaCard(
            index: entry.key,
            pergunta: entry.value,
            isMobile: isMobile,
          );
        }),
        if (_todasPerguntasRespondidas) ...[
          const SizedBox(height: 6),
          _buildScorePreview(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _salvarScore,
              icon: _isSaving
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                      size: 18,
                    ),
              label: Text(
                _isSaving ? 'Salvando...' : 'Salvar resultado',
              ),
              style: _primaryButtonStyle(),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPerguntaCard({
    required int index,
    required Map<String, dynamic> pergunta,
    required bool isMobile,
  }) {
    final opcoes = List<Map<String, dynamic>>.from(
      pergunta['opcoes'],
    );

    final valorSelecionado = _respostas[index];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    pergunta['texto'],
                    style: TextStyle(
                      color: _foreground,
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...opcoes.map((opcao) {
            final valor = opcao['valor'] as int;
            final selecionada = valorSelecionado == valor;

            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSaving
                      ? null
                      : () => _selecionarResposta(index, valor),
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selecionada ? _softBlue : _surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: selecionada ? _primary : _border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selecionada
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selecionada ? _primary : _secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            opcao['texto'],
                            style: TextStyle(
                              color: selecionada ? _primary : _foreground,
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: selecionada
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontFamily: 'Inter',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScorePreview() {
    final nivelColor = _getNivelColor(_score);
    final nivelIcon = _getNivelIcon(_score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSoftColor(nivelColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(nivelColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: nivelColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              nivelIcon,
              color: nivelColor,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado parcial',
                  style: TextStyle(
                    color: _secondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$_score pontos',
                  style: TextStyle(
                    color: nivelColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Dependência ${_getNivelDependencia(_score).toLowerCase()}',
                  style: const TextStyle(
                    color: _foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

  Widget _buildResultCard(bool isMobile) {
    final nivelColor = _getNivelColor(_score);
    final nivelIcon = _getNivelIcon(_score);
    final nivel = _getNivelDependencia(_score);
    final descricao = _getDescricaoNivel(_score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            color: _getSoftColor(nivelColor),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _getBorderColor(nivelColor),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RESULTADO DO TESTE',
                style: TextStyle(
                  color: _secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: isMobile ? 96 : 112,
                height: isMobile ? 96 : 112,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: nivelColor.withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  nivelIcon,
                  color: nivelColor,
                  size: isMobile ? 66 : 76,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '$_score pontos',
                style: TextStyle(
                  color: nivelColor,
                  fontSize: isMobile ? 32 : 38,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: nivelColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Dependência $nivel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                width: double.infinity,
                color: nivelColor.withOpacity(0.18),
              ),
              const SizedBox(height: 18),
              Text(
                descricao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _foreground,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _secondary,
                  side: const BorderSide(color: _border),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                child: const Text('Fechar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _reiniciarTeste,
                icon: const Icon(
                  Icons.refresh,
                  size: 17,
                ),
                label: const Text('Refazer'),
                style: _primaryButtonStyle(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: _softBlue,
      disabledForegroundColor: _secondary,
      elevation: 0,
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    );
  }
}