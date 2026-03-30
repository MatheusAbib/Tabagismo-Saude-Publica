import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';

class UPAScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  
  const UPAScreen({Key? key, this.userData, this.onNameUpdated}) : super(key: key);

  @override
  _UPAScreenState createState() => _UPAScreenState();
}

class _UPAScreenState extends State<UPAScreen> {
  final _authService = AuthService();
  final _enrollmentService = EnrollmentService();
  List<Map<String, dynamic>> _upaList = [];
  List<Map<String, dynamic>> _paginatedList = [];
  bool _isLoading = false;
  TextEditingController _bairroController = TextEditingController();
  
  // Paginação
  int _currentPage = 1;
  int _itemsPerPage = 6;
  int _totalPages = 1;

  final List<String> _bairrosSugeridos = [
    'Centro',
    'Vila Oliveira',
    'Braz Cubas',
    'César de Souza',
    'Jundiapeba',
    'Alto Ipiranga',
    'Vila Vitória',
    'Vila São Francisco',
    'Jardim Santista',
    'Vila Lavínia',
    'Jardim Armênia',
    'Vila Industrial',
    'Parque das Varinhas',
    'Residencial Itapety',
    'Vila Nova Aparecida',
  ];

  // Opções de turmas
  final List<Map<String, String>> _turmas = [
    {'dia': 'Segunda-feira', 'horario': '08:00 - 10:00'},
    {'dia': 'Terça-feira', 'horario': '14:00 - 16:00'},
    {'dia': 'Quarta-feira', 'horario': '18:00 - 20:00'},
    {'dia': 'Quinta-feira', 'horario': '10:00 - 12:00'},
    {'dia': 'Sexta-feira', 'horario': '15:00 - 17:00'},
    {'dia': 'Sábado', 'horario': '09:00 - 11:00'},
  ];

  @override
  void initState() {
    super.initState();
    _buscarTodasUPAs();
  }

  Future<void> _buscarTodasUPAs() async {
    setState(() => _isLoading = true);
    
    try {
      final upas = await _authService.searchUPA('');
      setState(() {
        _upaList = upas;
        _updatePagination();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar UPAs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarPorBairro() async {
    if (_bairroController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite o nome do bairro')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final upas = await _authService.searchUPA(_bairroController.text);
      setState(() {
        _upaList = upas;
        _currentPage = 1;
        _updatePagination();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar UPAs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limparBusca() {
    _bairroController.clear();
    _buscarTodasUPAs();
  }

  void _updatePagination() {
    _totalPages = (_upaList.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    _paginatedList = _getCurrentPageItems();
  }

  List<Map<String, dynamic>> _getCurrentPageItems() {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _upaList.length) {
      endIndex = _upaList.length;
    }
    return _upaList.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _paginatedList = _getCurrentPageItems();
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _goToPage(_currentPage - 1);
    }
  }

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage > 1 ? _previousPage : null,
            color: _currentPage > 1 ? Colors.blue : Colors.grey,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Página $_currentPage de $_totalPages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages ? _nextPage : null,
            color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _abrirModalMatricula(Map<String, dynamic> upa) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.9,
          child: EnrollmentModal(upa: upa, turmas: _turmas),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        HeaderWidget(
          userName: widget.userData?['nomeCompleto'] ?? 'Usuário',
          userData: widget.userData,
          onNameUpdated: widget.onNameUpdated,
          showBackButton: true,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _bairroController,
                              decoration: InputDecoration(
                                hintText: 'Digite o nome do bairro',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.location_on),
                                suffixIcon: _bairroController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: _limparBusca,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _buscarPorBairro,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                              shape: CircleBorder(),
                            ),
                            child: Icon(Icons.search),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '📍 Mogi das Cruzes - Encontre a UPA mais próxima do seu bairro',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _bairrosSugeridos.map((bairro) {
                          return ActionChip(
                            label: Text(bairro),
                            onPressed: () {
                              setState(() {
                                _bairroController.text = bairro;
                                _buscarPorBairro();
                              });
                            },
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                      InkWell(
                        onTap: _mostrarInformacoesGrupos,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Como funcionam as turmas e grupos de apoio?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _upaList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off, size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhuma UPA encontrada neste bairro',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tente buscar por outro bairro',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16),
                            itemCount: _paginatedList.length,
                            itemBuilder: (context, index) {
                              final upa = _paginatedList[index];
                              return _buildUPACard(upa);
                            },
                          ),
                              if (_upaList.length > 6) _buildPagination(),
                            ],
                          ),
                FooterWidget(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void _mostrarInformacoesGrupos() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Como Funcionam as Turmas'),
            backgroundColor: Colors.blue.shade700,
            actions: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  icon: Icons.how_to_reg,
                  title: 'Processo de Matrícula',
                  content: 'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a UPA entrará em contato pelo telefone cadastrado para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
                  color: Colors.blue,
                ),
                SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.calendar_today,
                  title: 'Frequência dos Encontros',
                  content: 'O programa de apoio é estruturado da seguinte forma:\n\n'
                      '• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n'
                      '• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\n'
                      'Cada encontro tem duração aproximada de 2 horas e é conduzido por profissionais de saúde especializados.',
                  color: Colors.green,
                ),
                SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.group_work,
                  title: 'Dinâmica dos Grupos',
                  content: 'Os grupos são espaços acolhedores e sigilosos onde você encontrará apoio para sua jornada de abandono do tabagismo. A dinâmica inclui:\n\n'
                      '📌 Roda de Conversa: Compartilhamento de experiências e desafios com outros participantes\n\n'
                      '📌 Educação em Saúde: Informações sobre os efeitos do tabagismo e benefícios de parar de fumar\n\n'
                      '📌 Estratégias de Enfrentamento: Técnicas para lidar com a fissura, ansiedade e sintomas de abstinência\n\n'
                      '📌 Atividades Práticas: Exercícios respiratórios, relaxamento e mindfulness\n\n'
                      '📌 Acompanhamento Individual: Profissionais disponíveis para orientação personalizada\n\n'
                      '📌 Material de Apoio: Recebimento de materiais educativos e folders informativos\n\n'
                      '📌 Rede de Apoio: Criação de vínculos com outras pessoas que estão na mesma jornada',
                  color: Colors.orange,
                ),
                SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.medical_services,
                  title: 'Acompanhamento Profissional',
                  content: 'Os grupos são coordenados por uma equipe multidisciplinar composta por:\n\n'
                      '• Médicos especialistas em tabagismo\n'
                      '• Psicólogos\n'
                      '• Enfermeiros\n'
                      '• Educadores físicos\n\n'
                      'Todos os profissionais são capacitados para oferecer o melhor suporte durante todo o processo.',
                  color: Colors.purple,
                ),
                SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.phone_android,
                  title: 'Comunicação e Suporte',
                  content: 'Além dos encontros presenciais, você receberá:\n\n'
                      '✓ Mensagens de apoio e lembretes dos encontros via WhatsApp\n'
                      '✓ Material informativo complementar\n'
                      '✓ Acompanhamento via telefone nos intervalos entre encontros\n'
                      '✓ Grupo de suporte online para troca de experiências',
                  color: Colors.teal,
                ),
                SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.emoji_events,
                  title: 'Benefícios do Programa',
                  content: 'Participar do programa oferece:\n\n'
                      '🏆 Aumento significativo nas chances de parar de fumar\n'
                      '🏆 Redução dos sintomas de abstinência\n'
                      '🏆 Melhora na qualidade de vida e saúde\n'
                      '🏆 Economia financeira significativa\n'
                      '🏆 Rede de apoio e novas amizades\n'
                      '🏆 Acompanhamento profissional contínuo',
                  color: Colors.amber,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lembre-se: cada passo dado é uma vitória! Você não está sozinho nessa jornada.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.blue.shade700,
                    ),
                    child: Text(
                      'Entendi',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildInfoSection({
  required IconData icon,
  required String title,
  required String content,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(color: color, width: 4),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildUPACard(Map<String, dynamic> upa) {
  return Card(
    margin: EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () => _abrirModalMatricula(upa),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_hospital, color: Colors.blue.shade700),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upa['nome'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        upa['endereco'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          upa['telefone'] ?? 'Telefone não informado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          upa['horario'] ?? 'Horário não informado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
}

class EnrollmentModal extends StatefulWidget {
  final Map<String, dynamic> upa;
  final List<Map<String, String>> turmas;

  const EnrollmentModal({Key? key, required this.upa, required this.turmas}) : super(key: key);

  @override
  _EnrollmentModalState createState() => _EnrollmentModalState();
}

class _EnrollmentModalState extends State<EnrollmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _enrollmentService = EnrollmentService();
  final _authService = AuthService();
  
  String? _turmaSelecionada;
  String? _segundaOpcaoTurma;  
  String? _escolaridade;
  int? _scoreFagestrom;
  String? _medicamento;
  bool _isLoadingScore = true;
  
  // ... resto das variáveis
  
  // Comorbidades
  Map<String, List<Map<String, dynamic>>> _comorbidades = {
    'cancer': [],
    'cardiovascular': [],
    'metabolico': [],
    'psiquiatrico': [],
    'respiratorio': [],
  };

  bool _isSubmitting = false;

  final List<String> _escolaridades = [
    'Fundamental',
    'Médio',
    'Superior',
    'Pós-graduação'
  ];

  final List<String> _medicamentos = [
    'Nenhum',
    'Adesivo de nicotina',
    'Goma de nicotina',
    'Pastilha de nicotina',
    'Outro'
  ];

  final Map<String, List<String>> _opcoesComorbidades = {
    'cancer': [
      'bexiga', 'útero', 'esôfago', 'estomago', 'faringe', 
      'fígado', 'laringe', 'leucemia', 'pâncreas', 'pulmão', 
      'rim', 'outros', 'nenhum'
    ],
    'cardiovascular': [
      'angina', 'avc', 'HÁ', 'trombose', 'outros', 'nenhum'
    ],
    'metabolico': [
      'DM 1', 'DM 2'
    ],
    'psiquiatrico': [
      'depressão', 'esquizofrenia', 'bipolar', 'ansiedade', 'outro', 'nenhum'
    ],
    'respiratorio': [
      'asma', 'bronquite', 'enfisema', 'infecção respiratória', 'covid', 'outro', 'nenhum'
    ],
  };

  @override
  void initState() {
    super.initState();
    _carregarScoreUsuario();
  }

  Future<void> _carregarScoreUsuario() async {
    setState(() => _isLoadingScore = true);
    
    try {
      final response = await _authService.getUserData();
      final userData = response['user'];
      
      if (userData['scoreFagestrom'] != null && userData['scoreFagestrom'] > 0) {
        setState(() {
          _scoreFagestrom = userData['scoreFagestrom'];
        });
      }
    } catch (e) {
      print('Erro ao carregar score: $e');
    } finally {
      setState(() => _isLoadingScore = false);
    }
  }

  void _toggleComorbidade(String categoria, String valor) {
    setState(() {
      final lista = _comorbidades[categoria]!;
      final index = lista.indexWhere((item) => item['valor'] == valor);
      
      if (valor == 'nenhum') {
        if (index == -1) {
          _comorbidades[categoria] = [{'valor': 'nenhum', 'outroTexto': null}];
        } else {
          _comorbidades[categoria] = [];
        }
      } else {
        final hasNenhum = lista.any((item) => item['valor'] == 'nenhum');
        if (hasNenhum) {
          _comorbidades[categoria] = [];
        }
        
        if (index == -1) {
          lista.add({'valor': valor, 'outroTexto': valor == 'outro' || valor == 'outros' ? '' : null});
        } else {
          lista.removeAt(index);
        }
      }
    });
  }

  void _updateOutroTexto(String categoria, String valor, String texto) {
    setState(() {
      final index = _comorbidades[categoria]!.indexWhere((item) => item['valor'] == valor);
      if (index != -1) {
        _comorbidades[categoria]![index]['outroTexto'] = texto;
      }
    });
  }

  bool _isSelected(String categoria, String valor) {
    return _comorbidades[categoria]!.any((item) => item['valor'] == valor);
  }

  bool _isNenhumSelected(String categoria) {
    return _comorbidades[categoria]!.any((item) => item['valor'] == 'nenhum');
  }

Future<void> _submitEnrollment() async {
  if (_formKey.currentState!.validate()) {
    if (_turmaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione uma turma')),
      );
      return;
    }
    
    if (_scoreFagestrom == null || _scoreFagestrom == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, faça o teste de Fagerström no menu principal primeiro')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
final data = {
  'upaId': widget.upa['id'],
  'upaNome': widget.upa['nome'],
  'turmaHorario': _turmaSelecionada,
  'segundaOpcaoTurma': _segundaOpcaoTurma,  
  'escolaridade': _escolaridade,
  'scoreFagestrom': _scoreFagestrom,
  'medicamento': _medicamento,
  'comorbidades': _comorbidades,
};

      await _enrollmentService.enroll(data);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matrícula realizada com sucesso! Você está na lista de espera.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar matrícula: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Matrícula - ${widget.upa['nome']}'),
      backgroundColor: Colors.blue.shade700,
      actions: [
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de turmas - Primeira opção
            Text(
              'Selecione a turma (primeira opção)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Escolha o dia e horário que prefere participar',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12),
            ...widget.turmas.map((turma) {
              String turmaTexto = '${turma['dia']} - ${turma['horario']}';
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  title: Text(turmaTexto),
                  value: turmaTexto,
                  groupValue: _turmaSelecionada,
                  onChanged: (value) {
                    setState(() {
                      _turmaSelecionada = value;
                    });
                  },
                ),
              );
            }).toList(),
            
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),
            
            // Seção de segunda opção
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Segunda opção (opcional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Caso sua primeira opção não tenha vagas disponíveis, você será alocado para esta turma.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...widget.turmas.map((turma) {
                    String turmaTexto = '${turma['dia']} - ${turma['horario']}';
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: RadioListTile<String>(
                        title: Text(turmaTexto),
                        value: turmaTexto,
                        groupValue: _segundaOpcaoTurma,
                        onChanged: (value) {
                          setState(() {
                            _segundaOpcaoTurma = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),

              Text(
                'Escolaridade',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _escolaridade,
                items: _escolaridades.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _escolaridade = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione a escolaridade';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              Text(
                'Score no teste de Fagestrom',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (_isLoadingScore)
                Center(child: CircularProgressIndicator())
              else if (_scoreFagestrom != null && _scoreFagestrom! > 0)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score já registrado:',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                            Text(
                              '$_scoreFagestrom pontos',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite o score (0-10)',
                    helperText: 'Você ainda não fez o teste de Fagerström',
                    errorText: 'Score é obrigatório. Faça o teste de Fagerström no menu.',
                  ),
                  onChanged: (value) {
                    _scoreFagestrom = int.tryParse(value);
                  },
                  validator: (value) {
                    if (_scoreFagestrom == null || _scoreFagestrom == 0) {
                      return 'Por favor, faça o teste de Fagerström no menu principal';
                    }
                    return null;
                  },
                ),
              
              SizedBox(height: 16),
              
              Text(
                'Faz uso de medicamento para tratamento de tabagismo?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _medicamento,
                items: _medicamentos.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _medicamento = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma opção';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 24),
              
              Text(
                'Comorbidades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              _buildComorbidadeSection('Câncer', 'cancer', _opcoesComorbidades['cancer']!),
              SizedBox(height: 16),
              _buildComorbidadeSection('Cardiovascular', 'cardiovascular', _opcoesComorbidades['cardiovascular']!),
              SizedBox(height: 16),
              _buildComorbidadeSection('Metabólico', 'metabolico', _opcoesComorbidades['metabolico']!),
              SizedBox(height: 16),
              _buildComorbidadeSection('Psiquiátrico', 'psiquiatrico', _opcoesComorbidades['psiquiatrico']!),
              SizedBox(height: 16),
              _buildComorbidadeSection('Respiratório', 'respiratorio', _opcoesComorbidades['respiratorio']!),
              
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEnrollment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Se matricular nessa turma',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComorbidadeSection(String titulo, String categoria, List<String> opcoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opcoes.map((opcao) {
            bool isSelected = _isSelected(categoria, opcao);
            bool isDisabled = _isNenhumSelected(categoria) && opcao != 'nenhum';
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChip(
                  label: Text(opcao),
                  selected: isSelected,
                  onSelected: isDisabled ? null : (selected) {
                    _toggleComorbidade(categoria, opcao);
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue,
                ),
                if (isSelected && (opcao == 'outro' || opcao == 'outros'))
                  Padding(
                    padding: EdgeInsets.only(left: 12, top: 8),
                    child: TextFormField(
                      initialValue: _comorbidades[categoria]!
                          .firstWhere((item) => item['valor'] == opcao)['outroTexto'] as String?,
                      decoration: InputDecoration(
                        hintText: 'Especifique "$opcao"',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (text) {
                        _updateOutroTexto(categoria, opcao, text);
                      },
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}