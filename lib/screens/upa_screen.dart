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
  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _primaryMedium = Color(0xFF1A4A6F);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _successColor = Color(0xFF10B981);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _dangerColor = Color(0xFFEF4444);
  
  List<Map<String, dynamic>> _upaList = [];
  List<Map<String, dynamic>> _paginatedList = [];
  bool _isLoading = false;
  TextEditingController _bairroController = TextEditingController();
  
  int _currentPage = 1;
  int _itemsPerPage = 6;
  int _totalPages = 1;

  final List<String> _bairrosSugeridos = [
    'Centro', 'Vila Oliveira', 'Braz Cubas', 'César de Souza', 'Jundiapeba',
    'Alto Ipiranga', 'Vila Vitória', 'Vila São Francisco', 'Jardim Santista',
    'Vila Lavínia', 'Jardim Armênia', 'Vila Industrial', 'Parque das Varinhas',
    'Residencial Itapety', 'Vila Nova Aparecida',
  ];

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
      _showSnackBar('Erro ao buscar UPAs: $e', _dangerColor);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarPorBairro() async {
    if (_bairroController.text.isEmpty) {
      _showSnackBar('Digite o nome do bairro', _warningColor);
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
      _showSnackBar('Erro ao buscar UPAs: $e', _dangerColor);
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
    if (endIndex > _upaList.length) endIndex = _upaList.length;
    return _upaList.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _paginatedList = _getCurrentPageItems();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: _currentPage > 1 ? _accentColor : Colors.grey.shade400),
            onPressed: _currentPage > 1 ? _previousPage : null,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Página $_currentPage de $_totalPages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _accentColor,
                fontFamily: 'Inter',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: _currentPage < _totalPages ? _accentColor : Colors.grey.shade400),
            onPressed: _currentPage < _totalPages ? _nextPage : null,
          ),
        ],
      ),
    );
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _previousPage() => _goToPage(_currentPage - 1);

  void _abrirModalMatricula(Map<String, dynamic> upa) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: EnrollmentModal(upa: upa, turmas: _turmas),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
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
                  _buildSearchSection(),
                  _isLoading
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(color: _accentColor),
                          ),
                        )
                      : _upaList.isEmpty
                          ? _buildEmptyWidget()
                          : Column(
                              children: [
                                _buildUPACardsList(),
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

Widget _buildSearchSection() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 50),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bairroController,
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do bairro',
                    hintStyle: TextStyle(fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.location_on_outlined, color: _accentColor),
                    suffixIcon: _bairroController.text.isNotEmpty
                        ? IconButton(icon: Icon(Icons.clear), onPressed: _limparBusca)
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onSubmitted: (_) => _buscarPorBairro(),
                ),
              ),
              SizedBox(width: 12),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primaryDark, _primaryMedium]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: _buscarPorBairro,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.room, size: 14, color: _accentColor),
              SizedBox(width: 4),
              Text(
                ' Mogi das Cruzes - Encontre a UPA mais próxima do seu bairro',
                style: TextStyle(fontSize: 12, color: _accentColor, fontFamily: 'Inter'),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bairrosSugeridos.map((bairro) {
              return ActionChip(
                label: Text(bairro, style: TextStyle(fontSize: 12, fontFamily: 'Inter')),
                onPressed: () {
                  setState(() => _bairroController.text = bairro);
                  _buscarPorBairro();
                },
                backgroundColor: _accentColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: _accentColor),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: _buildInfoBanner(),
        ),
      ],
    ),
  );
}

Widget _buildInfoBanner() {
  return Container(
    child: InkWell(
      onTap: _mostrarInformacoesGrupos,
      borderRadius: BorderRadius.circular(8),
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
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700, size: 14),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
            ),
            SizedBox(height: 24),
            Text('Nenhuma UPA encontrada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'Poppins')),
            SizedBox(height: 8),
            Text('Tente buscar por outro bairro', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  Widget _buildUPACardsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20),
      itemCount: _paginatedList.length,
      itemBuilder: (context, index) => _buildUPACard(_paginatedList[index]),
    );
  }

  Widget _buildUPACard(Map<String, dynamic> upa) {
    return Container(
      
      margin: EdgeInsets.only(bottom: 16, left: 30, right: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _abrirModalMatricula(upa),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_primaryDark, _primaryMedium]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.local_hospital_outlined, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(upa['nome'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'Poppins')),
                          SizedBox(height: 4),
                          Text(upa['endereco'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: 'Inter'), maxLines: 2),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
                SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                          SizedBox(width: 6),
                          Expanded(child: Text(upa['telefone'] ?? 'Telefone não informado', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'Inter'))),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.access_time_outlined, size: 14, color: Colors.grey.shade500),
                          SizedBox(width: 6),
                          Expanded(child: Text(upa['horario'] ?? 'Horário não informado', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'Inter'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarInformacoesGrupos() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _InfoModal(),
        ),
      ),
    );
  }
}

class _InfoModal extends StatelessWidget {
  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _successColor = Color(0xFF10B981);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _dangerColor = Color(0xFFEF4444);

  
  Widget _infoItem(IconData icon, String text, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 231, 236, 240),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: _primaryDark, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Como Funcionam as Turmas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _primaryDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInfoSection(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Processo de Matrícula',
                  content:
                      'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a UPA entrará em contato pelo telefone cadastrado para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
                  color: _accentColor,
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.calendar_today_outlined,
                  title: 'Frequência dos Encontros',
                  content:
                      'O programa de apoio é estruturado da seguinte forma:\n\n• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\nCada encontro tem duração aproximada de 2 horas.',
                  color: _successColor,
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.group_outlined,
                  title: 'Dinâmica dos Grupos',
                  color: _warningColor,
                  contentWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Os grupos são espaços acolhedores e sigilosos onde você encontrará apoio para sua jornada de abandono do tabagismo.\n',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF475569),
                          fontFamily: 'Inter',
                        ),
                      ),
                      _infoItem(Icons.chat_bubble_outline, 'Roda de Conversa', _warningColor),
                      _infoItem(Icons.health_and_safety_outlined, 'Educação em Saúde', _warningColor),
                      _infoItem(Icons.psychology_outlined, 'Estratégias de Enfrentamento', _warningColor),
                      _infoItem(Icons.fitness_center_outlined, 'Atividades Práticas', _warningColor),
                      _infoItem(Icons.person_outline, 'Acompanhamento Individual', _warningColor),
                      _infoItem(Icons.people_outline, 'Rede de Apoio', _warningColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.medical_services_outlined,
                  title: 'Acompanhamento Profissional',
                  content:
                      'Os grupos são coordenados por uma equipe multidisciplinar composta por:\n\n• Médicos especialistas em tabagismo\n• Psicólogos\n• Enfermeiros\n• Educadores físicos',
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  icon: Icons.phone_android_outlined,
                  title: 'Comunicação e Suporte',
                  content:
                      'Além dos encontros presenciais, você receberá:\n\n✓ Mensagens de apoio via WhatsApp\n✓ Material informativo complementar\n✓ Acompanhamento telefônico\n✓ Grupo de suporte online',
                  color: const Color(0xFF14B8A6),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entendi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoSection({
  required IconData icon,
  required String title,
  String? content,
  Widget? contentWidget,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: color, width: 4)),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (contentWidget != null)
            contentWidget
          else if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
                fontFamily: 'Inter',
              ),
            ),
        ],
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
  
  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _successColor = Color(0xFF10B981);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _dangerColor = Color(0xFFEF4444);
  
  String? _turmaSelecionada;
  String? _segundaOpcaoTurma;  
  String? _escolaridade;
  int? _scoreFagestrom;
  String? _medicamento;
  bool _isLoadingScore = true;
  bool _isSubmitting = false;


  void _showConfirmationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirmar Matrícula',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja realmente se matricular na UPA ${widget.upa['nome']}?\n\nApós a confirmação, você entrará na lista de espera e receberá contato em até 5 dias úteis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _submitEnrollment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
  
  Map<String, List<Map<String, dynamic>>> _comorbidades = {
    'cancer': [],
    'cardiovascular': [],
    'metabolico': [],
    'psiquiatrico': [],
    'respiratorio': [],
  };

  final List<String> _escolaridades = ['Fundamental', 'Médio', 'Superior', 'Pós-graduação'];
  final List<String> _medicamentos = ['Nenhum', 'Adesivo de nicotina', 'Goma de nicotina', 'Pastilha de nicotina', 'Outro'];

  final Map<String, List<String>> _opcoesComorbidades = {
    'cancer': ['bexiga', 'útero', 'esôfago', 'estomago', 'faringe', 'fígado', 'laringe', 'leucemia', 'pâncreas', 'pulmão', 'rim', 'outros', 'nenhum'],
    'cardiovascular': ['angina', 'avc', 'HÁ', 'trombose', 'outros', 'nenhum'],
    'metabolico': ['DM 1', 'DM 2'],
    'psiquiatrico': ['depressão', 'esquizofrenia', 'bipolar', 'ansiedade', 'outro', 'nenhum'],
    'respiratorio': ['asma', 'bronquite', 'enfisema', 'infecção respiratória', 'covid', 'outro', 'nenhum'],
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
        setState(() => _scoreFagestrom = userData['scoreFagestrom']);
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
        if (hasNenhum) _comorbidades[categoria] = [];
        
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
      if (index != -1) _comorbidades[categoria]![index]['outroTexto'] = texto;
    });
  }

  bool _isSelected(String categoria, String valor) => _comorbidades[categoria]!.any((item) => item['valor'] == valor);
  bool _isNenhumSelected(String categoria) => _comorbidades[categoria]!.any((item) => item['valor'] == 'nenhum');

  Future<void> _submitEnrollment() async {
    if (_formKey.currentState!.validate()) {
      if (_turmaSelecionada == null) {
        _showSnackBar('Selecione uma turma', _warningColor);
        return;
      }
      if (_scoreFagestrom == null || _scoreFagestrom == 0) {
        _showSnackBar('Faça o teste de Fagerström no menu principal primeiro', _warningColor);
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
        _showSnackBar('Matrícula realizada com sucesso! Você está na lista de espera.', _successColor);
      } catch (e) {
        _showSnackBar('Erro ao realizar matrícula: $e', _dangerColor);
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Matrícula', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: _primaryDark,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(Icons.local_hospital_outlined, widget.upa['nome'] ?? 'UPA'),
              SizedBox(height: 20),
              _buildTurmaSection('Primeira opção', widget.turmas, _turmaSelecionada, (value) => setState(() => _turmaSelecionada = value)),
              SizedBox(height: 20),
              _buildTurmaSection('Segunda opção (opcional)', widget.turmas, _segundaOpcaoTurma, (value) => setState(() => _segundaOpcaoTurma = value), isOptional: true),
              SizedBox(height: 24),
              _buildDropdownField('Escolaridade', _escolaridades, _escolaridade, (value) => setState(() => _escolaridade = value)),
              SizedBox(height: 16),
              _buildScoreField(),
              SizedBox(height: 16),
              _buildDropdownField('Medicamento para tabagismo', _medicamentos, _medicamento, (value) => setState(() => _medicamento = value)),
              SizedBox(height: 24),
              Text('Comorbidades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'Poppins')),
              SizedBox(height: 16),
              _buildComorbidadeSection('Câncer', 'cancer', _opcoesComorbidades['cancer']!),
              _buildComorbidadeSection('Cardiovascular', 'cardiovascular', _opcoesComorbidades['cardiovascular']!),
              _buildComorbidadeSection('Metabólico', 'metabolico', _opcoesComorbidades['metabolico']!),
              _buildComorbidadeSection('Psiquiátrico', 'psiquiatrico', _opcoesComorbidades['psiquiatrico']!),
              _buildComorbidadeSection('Respiratório', 'respiratorio', _opcoesComorbidades['respiratorio']!),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Confirmar Matrícula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: _accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _accentColor, size: 24)),
        SizedBox(width: 12),
        Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'Poppins'))),
      ],
    );
  }

  Widget _buildTurmaSection(String title, List<Map<String, String>> turmas, String? selected, Function(String?) onChanged, {bool isOptional = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOptional ? _warningColor.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOptional ? _warningColor.withValues(alpha: 0.3) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [if (isOptional) Icon(Icons.info_outline, color: _warningColor, size: 16), SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isOptional ? _warningColor : _primaryDark))]),
          if (isOptional) SizedBox(height: 4),
          if (isOptional) Text('Caso sua primeira opção não tenha vagas', style: TextStyle(fontSize: 11, color: _warningColor)),
          SizedBox(height: 12),
          ...turmas.map((turma) {
            String turmaTexto = '${turma['dia']} - ${turma['horario']}';
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected == turmaTexto ? _accentColor.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected == turmaTexto ? _accentColor : Colors.grey.shade200),
              ),
              child: RadioListTile<String>(
                title: Text(turmaTexto, style: TextStyle(fontFamily: 'Inter')),
                value: turmaTexto,
                groupValue: selected,
                onChanged: onChanged,
                activeColor: _accentColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Selecione $label' : null,
        ),
      ],
    );
  }

  Widget _buildScoreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score Fagerström', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark)),
        SizedBox(height: 8),
        if (_isLoadingScore)
          Center(child: CircularProgressIndicator(color: _accentColor))
        else if (_scoreFagestrom != null && _scoreFagestrom! > 0)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: _successColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _successColor.withValues(alpha: 0.3))),
            child: Row(children: [Icon(Icons.check_circle, color: _successColor), SizedBox(width: 12), Text('Score registrado: $_scoreFagestrom pontos', style: TextStyle(fontWeight: FontWeight.bold, color: _successColor))]),
          )
        else
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Digite o score (0-10)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) => _scoreFagestrom = int.tryParse(value),
            validator: (v) => _scoreFagestrom == null || _scoreFagestrom == 0 ? 'Faça o teste de Fagerström no menu principal' : null,
          ),
      ],
    );
  }

  Widget _buildComorbidadeSection(String titulo, String categoria, List<String> opcoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryDark, fontFamily: 'Poppins')),
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
                  label: Text(opcao, style: TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: isDisabled ? null : (selected) => _toggleComorbidade(categoria, opcao),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: _accentColor.withValues(alpha: 0.2),
                  checkmarkColor: _accentColor,
                ),
                if (isSelected && (opcao == 'outro' || opcao == 'outros'))
                  Padding(
                    padding: EdgeInsets.only(left: 12, top: 8),
                    child: TextFormField(
                      initialValue: _comorbidades[categoria]!.firstWhere((item) => item['valor'] == opcao)['outroTexto'] as String?,
                      decoration: InputDecoration(
                        hintText: 'Especifique "$opcao"',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (text) => _updateOutroTexto(categoria, opcao, text),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}