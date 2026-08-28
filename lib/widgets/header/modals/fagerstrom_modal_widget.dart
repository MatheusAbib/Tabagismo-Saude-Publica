import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class FagerstromTestModal extends StatefulWidget {
  final Function(int)? onScoreUpdated;

  const FagerstromTestModal({Key? key, this.onScoreUpdated}) : super(key: key);

  @override
  _FagerstromTestModalState createState() => _FagerstromTestModalState();

  static Future<void> show(BuildContext context, {Function(int)? onScoreUpdated}) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(isSmallMobile ? 4 : (isMobile ? 6 : 20)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
  width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95),
  height: isMobile ? MediaQuery.of(context).size.height * 0.7 : (MediaQuery.of(context).size.height > 800 ? 650 : MediaQuery.of(context).size.height * 0.85),
  constraints: BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: FagerstromTestModal(
                onScoreUpdated: onScoreUpdated,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FagerstromTestModalState extends State<FagerstromTestModal> {
  final _authService = AuthService();
  
  final Color _primaryDark = const Color(0xFF334155);
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);
  
  int? _pergunta1;
  int? _pergunta2;
  int? _pergunta3;
  int? _pergunta4;
  int? _pergunta5;
  int? _pergunta6;
  
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
      'texto': 'Você fuma mesmo doente quando precisa ficar na cama a maior parte do tempo?',
      'opcoes': [
        {'texto': 'Sim', 'valor': 1},
        {'texto': 'Não', 'valor': 0},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _carregarTesteSalvo();
  }

  Future<void> _carregarTesteSalvo() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _authService.getUserData();
      final userData = response['user'];
      
      if (userData['scoreFagestrom'] != null && userData['scoreFagestrom'] > 0) {
        _score = userData['scoreFagestrom'];
        _testeRealizado = true;
      }
    } catch (e) {
      print('Erro ao carregar teste: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarScore() async {
    setState(() => _isSaving = true);
    
    try {
      await _authService.updateUserData({
        'scoreFagestrom': _score,
      });
      
      if (widget.onScoreUpdated != null) {
        widget.onScoreUpdated!(_score);
      }
      
      if (mounted) {
        ToastService.showSuccess(context, 'Teste salvo com sucesso!');
      }
      
      setState(() {
        _isEditing = false;
        _testeRealizado = true;
      });
      
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Erro ao salvar teste');
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _reiniciarTeste() {
    setState(() {
      _pergunta1 = null;
      _pergunta2 = null;
      _pergunta3 = null;
      _pergunta4 = null;
      _pergunta5 = null;
      _pergunta6 = null;
      _score = 0;
      _testeRealizado = false;
      _isEditing = true;
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
    if (score <= 2) return _successColor;
    if (score <= 4) return const Color(0xFF84CC16);
    if (score == 5) return _warningColor;
    if (score <= 7) return _dangerColor;
    return const Color(0xFFC65D47);
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
      return 'Parabéns! Sua dependência é muito baixa. Você tem excelente controle sobre o tabagismo e está no caminho certo para manter-se saudável. Continue assim!';
    } else if (score <= 4) {
      return 'Sua dependência é baixa. Você tem um bom controle, mas continue focado e evite situações que possam gerar recaídas. Mantenha o bom trabalho!';
    } else if (score == 5) {
      return 'Você tem um grau médio de dependência à nicotina. Busque estratégias de enfrentamento para reduzir ainda mais e considere apoio profissional.';
    } else if (score <= 7) {
      return 'Sua dependência é elevada. É importante buscar acompanhamento profissional e apoio especializado para aumentar suas chances de sucesso.';
    } else {
      return 'Sua dependência é muito elevada. Procure ajuda médica imediatamente. Lembre-se: buscar ajuda é um ato de coragem e você não está sozinho.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 14 : 20),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assessment_outlined,
                      color: Colors.white,
                      size: isMobile ? 18 : 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSmallMobile ? 'Fagerström' : 'Teste de Fagerström',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (!isSmallMobile)
                          Text(
                            'Avalie seu grau de dependência à nicotina',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: isMobile ? 18 : 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 12 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_testeRealizado && !_isEditing)
                            _buildResultCard()
                          else
                            _buildQuestionsList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    Color nivelColor = _getNivelColor(_score);
    String nivelTexto = _getNivelDependencia(_score);
    String descricao = _getDescricaoNivel(_score);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? (isSmallMobile ? 28 : 32) : 36),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                nivelColor.withOpacity(0.12),
                nivelColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: nivelColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? (isSmallMobile ? 24 : 28) : 28),
                decoration: BoxDecoration(
                  color: nivelColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNivelIcon(_score),
                  size: isMobile ? (isSmallMobile ? 72 : 80) : 80,
                  color: nivelColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$_score pontos',
                style: TextStyle(
                  fontSize: isMobile ? (isSmallMobile ? 44 : 48) : 52,
                  fontWeight: FontWeight.bold,
                  color: nivelColor,
                  fontFamily: 'Poppins',
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: nivelColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  nivelTexto,
                  style: TextStyle(
                    fontSize: isMobile ? (isSmallMobile ? 16 : 17) : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 2,
                width: 45,
                decoration: BoxDecoration(
                  color: nivelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                descricao,
                style: TextStyle(
                  fontSize: isMobile ? (isSmallMobile ? 14 : 15) : 15,
                  color: const Color(0xFF475569),
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _reiniciarTeste,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text(
                  'Refazer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: [
        ..._perguntas.asMap().entries.map((entry) {
          int index = entry.key;
          var pergunta = entry.value;
          return _buildPerguntaCard(
            numero: index + 1,
            icon: pergunta['icon'],
            texto: pergunta['texto'],
            opcoes: pergunta['opcoes'],
            valorSelecionado: _getValorSelecionado(index),
            onChanged: (valor) {
              setState(() {
                _setValorSelecionado(index, valor);
                _calcularScorePreview();
              });
            },
          );
        }).toList(),
        
        if (_todasPerguntasRespondidas()) ...[
          const SizedBox(height: 16),
          _buildScorePreview(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _salvarScore,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save, size: 16),
              label: Text(
                _isSaving ? 'Salvando...' : 'Salvar Resultado',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _successColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _todasPerguntasRespondidas() {
    return _pergunta1 != null &&
        _pergunta2 != null &&
        _pergunta3 != null &&
        _pergunta4 != null &&
        _pergunta5 != null &&
        _pergunta6 != null;
  }

  void _calcularScorePreview() {
    int score = 0;
    if (_pergunta1 != null) score += _pergunta1!;
    if (_pergunta2 != null) score += _pergunta2!;
    if (_pergunta3 != null) score += _pergunta3!;
    if (_pergunta4 != null) score += _pergunta4!;
    if (_pergunta5 != null) score += _pergunta5!;
    if (_pergunta6 != null) score += _pergunta6!;
    
    setState(() {
      _score = score;
    });
  }

  Widget _buildPerguntaCard({
    required int numero,
    required IconData icon,
    required String texto,
    required List<Map<String, dynamic>> opcoes,
    required int? valorSelecionado,
    required Function(int?) onChanged,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: isMobile ? 26 : 32,
                  height: isMobile ? 26 : 32,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$numero',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: isMobile ? 18 : 20, color: _accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 16),
            child: Column(
              children: opcoes.map((opcao) {
                return RadioListTile<int>(
                  title: Text(
                    opcao['texto'],
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  value: opcao['valor'],
                  groupValue: valorSelecionado,
                  onChanged: onChanged,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: _accentColor,
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePreview() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    Color nivelColor = _getNivelColor(_score);
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [nivelColor.withOpacity(0.1), nivelColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: nivelColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: nivelColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getNivelIcon(_score), color: nivelColor, size: isMobile ? 24 : 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado Parcial',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '$_score pontos • ${_getNivelDependencia(_score)}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: nivelColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int? _getValorSelecionado(int index) {
    switch (index) {
      case 0: return _pergunta1;
      case 1: return _pergunta2;
      case 2: return _pergunta3;
      case 3: return _pergunta4;
      case 4: return _pergunta5;
      case 5: return _pergunta6;
      default: return null;
    }
  }

  void _setValorSelecionado(int index, int? valor) {
    switch (index) {
      case 0: _pergunta1 = valor; break;
      case 1: _pergunta2 = valor; break;
      case 2: _pergunta3 = valor; break;
      case 3: _pergunta4 = valor; break;
      case 4: _pergunta5 = valor; break;
      case 5: _pergunta6 = valor; break;
    }
  }
}