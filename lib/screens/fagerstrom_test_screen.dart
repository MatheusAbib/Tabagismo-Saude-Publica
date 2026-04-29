import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';

class FagerstromTestScreen extends StatefulWidget {
  final Function(int)? onScoreUpdated;

  const FagerstromTestScreen({Key? key, this.onScoreUpdated}) : super(key: key);

  @override
  _FagerstromTestScreenState createState() => _FagerstromTestScreenState();
}

class _FagerstromTestScreenState extends State<FagerstromTestScreen> {
  final _authService = AuthService();
  
  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _successColor = Color(0xFF10B981);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _dangerColor = Color(0xFFEF4444);
  
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teste salvo com sucesso!'),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar teste: $e'),
          backgroundColor: _dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    if (score <= 4) return Color(0xFF84CC16);
    if (score == 5) return _warningColor;
    if (score <= 7) return _dangerColor;
    return Color(0xFFDC2626);
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
      return 'Parabéns! Sua dependência é muito baixa. Você tem excelente controle sobre o tabagismo. Continue assim!';
    } else if (score <= 4) {
      return 'Sua dependência é baixa. Você tem um bom controle, mas continue focado em manter-se longe do cigarro.';
    } else if (score == 5) {
      return 'Você tem um grau médio de dependência à nicotina. Busque estratégias para reduzir ainda mais.';
    } else if (score <= 7) {
      return 'Sua dependência é elevada. É importante buscar acompanhamento profissional e apoio especializado.';
    } else {
      return 'Sua dependência é muito elevada. Procure ajuda médica imediatamente. Você não está sozinho nesta jornada.';
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: _primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teste de Fagerström',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
          Text(
            'Avalie seu grau de dependência à nicotina',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    ),
    body: _isLoading
        ? Center(
            child: CircularProgressIndicator(color: _accentColor),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
  );
}
Widget _buildResultCard() {
  Color nivelColor = _getNivelColor(_score);
  return Container(
    margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: nivelColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(
                _getNivelIcon(_score),
                size: 70,
                color: nivelColor,
              ),
              const SizedBox(height: 16),
              Text(
                '$_score pontos',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: nivelColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: nivelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _getNivelDependencia(_score),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: nivelColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _getDescricaoNivel(_score),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _reiniciarTeste,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refazer Teste'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

Widget _buildQuestionsList() {
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
        const SizedBox(height: 24),
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
                : const Icon(Icons.save, size: 18),
            label: Text(
              _isSaving ? 'Salvando...' : 'Salvar Resultado',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
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
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryDark.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$numero',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(icon, size: 20, color: _accentColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryDark,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: opcoes.map((opcao) {
                return RadioListTile<int>(
                  title: Text(
                    opcao['texto'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                      fontFamily: 'Inter',
                    ),
                  ),
                  value: opcao['valor'],
                  groupValue: valorSelecionado,
                  onChanged: onChanged,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: _accentColor,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePreview() {
    Color nivelColor = _getNivelColor(_score);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [nivelColor.withOpacity(0.1), nivelColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: nivelColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: nivelColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getNivelIcon(_score), color: nivelColor, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultado Parcial',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '$_score pontos • ${_getNivelDependencia(_score)}',
                  style: TextStyle(
                    fontSize: 16,
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