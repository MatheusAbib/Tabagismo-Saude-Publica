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
  bool _isEditing = false; // Modo de edição

  final List<Map<String, dynamic>> _perguntas = [
    {
      'texto': 'Em quanto tempo depois de acordar você fuma o primeiro cigarro?',
      'opcoes': [
        {'texto': 'Dentro de 5 minutos', 'valor': 3},
        {'texto': '6-30 minutos', 'valor': 2},
        {'texto': '31-60 minutos', 'valor': 1},
        {'texto': 'Depois de 60 minutos', 'valor': 0},
      ],
    },
    {
      'texto': 'Você acha difícil ficar sem fumar em lugares onde é proibido (por exemplo, na igreja, no cinema, em bibliotecas, e outros.)?',
      'opcoes': [
        {'texto': 'Sim', 'valor': 1},
        {'texto': 'Não', 'valor': 0},
      ],
    },
    {
      'texto': 'Qual o cigarro do dia que traz mais satisfação?',
      'opcoes': [
        {'texto': 'O primeiro da manhã', 'valor': 1},
        {'texto': 'Outros', 'valor': 0},
      ],
    },
    {
      'texto': 'Quantos cigarros você fuma por dia?',
      'opcoes': [
        {'texto': 'Menos de 10', 'valor': 0},
        {'texto': 'De 11 a 20', 'valor': 1},
        {'texto': 'De 21 a 30', 'valor': 2},
        {'texto': 'Mais de 31', 'valor': 3},
      ],
    },
    {
      'texto': 'Você fuma mais frequentemente pela manhã?',
      'opcoes': [
        {'texto': 'Sim', 'valor': 1},
        {'texto': 'Não', 'valor': 0},
      ],
    },
    {
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
        // Se já tem um score salvo, carregamos os valores (simulados)
        // Como não salvamos as respostas individuais, só mostramos o resultado
        _score = userData['scoreFagestrom'];
        _testeRealizado = true;
      }
    } catch (e) {
      print('Erro ao carregar teste: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calcularScore() {
    int score = 0;
    if (_pergunta1 != null) score += _pergunta1!;
    if (_pergunta2 != null) score += _pergunta2!;
    if (_pergunta3 != null) score += _pergunta3!;
    if (_pergunta4 != null) score += _pergunta4!;
    if (_pergunta5 != null) score += _pergunta5!;
    if (_pergunta6 != null) score += _pergunta6!;
    
    setState(() {
      _score = score;
      _testeRealizado = true;
    });
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
        SnackBar(content: Text('Teste salvo com sucesso! Seu nível de dependência: ${_getNivelDependencia(_score)}')),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar teste: $e')),
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
    if (score <= 2) return Colors.green;
    if (score <= 4) return Colors.lightGreen;
    if (score == 5) return Colors.orange;
    if (score <= 7) return Colors.deepOrange;
    return Colors.red;
  }

  String _getDescricaoNivel(int score) {
    if (score <= 2) {
      return 'Dependência muito baixa. Ótimo! Você tem um bom controle sobre o tabagismo.';
    } else if (score <= 4) {
      return 'Dependência baixa. Você tem um controle razoável, mas ainda pode melhorar.';
    } else if (score == 5) {
      return 'Dependência média. Você tem um grau moderado de dependência à nicotina.';
    } else if (score <= 7) {
      return 'Dependência elevada. Seu grau de dependência é significativo. Procure ajuda profissional.';
    } else {
      return 'Dependência muito elevada. Você tem alta dependência à nicotina. É essencial buscar tratamento especializado.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste de Fagerström'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          if (_testeRealizado && !_isEditing)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _reiniciarTeste,
              tooltip: 'Refazer teste',
            ),
          if (_testeRealizado && _isEditing)
            IconButton(
              icon: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.save),
              onPressed: _isSaving ? null : _salvarScore,
              tooltip: 'Salvar novo resultado',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teste de Fagerström',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'O teste mede o grau de dependência à nicotina. Responda às perguntas abaixo para descobrir seu nível de dependência.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  if (_testeRealizado && !_isEditing)
                    // Modo de visualização do resultado salvo
                    Card(
                      elevation: 4,
                      color: _getNivelColor(_score).withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Seu Resultado',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '$_score pontos',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _getNivelColor(_score),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Nível: ${_getNivelDependencia(_score)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: _getNivelColor(_score),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _getDescricaoNivel(_score),
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            Divider(),
                            SizedBox(height: 16),
                            Text(
                              'Deseja refazer o teste?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _reiniciarTeste,
                              icon: Icon(Icons.refresh),
                              label: Text('Refazer Teste'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Modo de responder o teste
                    Column(
                      children: [
                        ..._perguntas.asMap().entries.map((entry) {
                          int index = entry.key;
                          var pergunta = entry.value;
                          return _buildPergunta(
                            numero: index + 1,
                            texto: pergunta['texto'],
                            opcoes: pergunta['opcoes'],
                            valorSelecionado: _getValorSelecionado(index),
                            onChanged: (valor) {
                              setState(() {
                                _setValorSelecionado(index, valor);
                                _calcularScore();
                              });
                            },
                          );
                        }).toList(),
                        if (_testeRealizado) ...[
                          SizedBox(height: 24),
                          Card(
                            elevation: 4,
                            color: _getNivelColor(_score).withOpacity(0.1),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    'Resultado',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '$_score pontos',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: _getNivelColor(_score),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Nível: ${_getNivelDependencia(_score)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: _getNivelColor(_score),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _getDescricaoNivel(_score),
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _salvarScore,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green,
                              ),
                              child: _isSaving
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Salvar Resultado',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
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

  Widget _buildPergunta({
    required int numero,
    required String texto,
    required List<Map<String, dynamic>> opcoes,
    required int? valorSelecionado,
    required Function(int?) onChanged,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$numero. $texto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            ...opcoes.map((opcao) {
              return RadioListTile<int>(
                title: Text(opcao['texto']),
                value: opcao['valor'],
                groupValue: valorSelecionado,
                onChanged: onChanged,
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}