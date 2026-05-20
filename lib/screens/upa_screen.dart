import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';
import 'package:tabagismo_app/screens/fagerstrom_test_modal.dart';
import 'package:tabagismo_app/screens/my_enrollments_screen.dart';

class UPAScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  
  const UPAScreen({Key? key, this.userData, this.onNameUpdated}) : super(key: key);

  @override
  _UPAScreenState createState() => _UPAScreenState();
}

class _UPAScreenState extends State<UPAScreen> {
  final _authService = AuthService();
final Color _primaryDark = const Color(0xFF334155);
final Color _accentColor = const Color(0xFF1F4E6E);
final Color _successColor = const Color(0xFF2E8B6A);
  
  List<Map<String, dynamic>> _upaList = [];
  List<Map<String, dynamic>> _paginatedList = [];
  bool _isLoading = false;
  TextEditingController _bairroController = TextEditingController();
  
  int _currentPage = 1;
  int _itemsPerPage = 6;
  int _totalPages = 1;


  @override
  void initState() {
    super.initState();
    _buscarTodasUPAs();
  }

  
Timer? _debounce;

void _onSearchChanged(String value) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 400), () {
    final query = value.trim();

    if (query.isEmpty) {
      _buscarTodasUPAs();
      return;
    }

    _buscarPorBairro(query);
  });
}

Future<void> _buscarTodasUPAs() async {
  setState(() => _isLoading = true);
  try {
    final upas = await _authService.searchUPA('');
    setState(() {
      _upaList = upas;
      _currentPage = 1;
      _updatePagination();
    });
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _buscarPorBairro(String bairro) async {
  setState(() => _isLoading = true);
  try {
    final upas = await _authService.searchUPA(bairro);
    setState(() {
      _upaList = upas;
      _currentPage = 1;
      _updatePagination();
    });
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

void _abrirModalMatricula(Map<String, dynamic> upa) async {
  try {
    final authService = AuthService();
    final response = await authService.verificarMatriculaAtiva();
    
    if (response['hasActiveEnrollment']) {
      final matricula = response['enrollment'];
      final statusTexto = matricula['status'] == 'em_espera' ? 'em espera' : 'ativa';
      
showDialog(
  context: context,
  builder: (context) => Dialog(
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
              color: const Color(0xFFD97706).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Matrícula Existente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Você já possui uma matrícula $statusTexto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 16, color: const Color(0xFF1F4E6E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        matricula['upa_nome'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: const Color(0xFF1F4E6E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        matricula['turma_horario'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aguarde a conclusão ou cancele a matrícula atual antes de realizar uma nova.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyEnrollmentsScreen(
                          userData: widget.userData,
                          onNameUpdated: widget.onNameUpdated,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text(
                    'Ver Matrículas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4E6E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: EnrollmentModal(
            upa: upa,
            userData: widget.userData,
            onNameUpdated: widget.onNameUpdated,
          ),
        ),
      ),
    );
  } catch (e) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: EnrollmentModal(
            upa: upa,
            userData: widget.userData,
            onNameUpdated: widget.onNameUpdated,
          ),
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isTablet = MediaQuery.of(context).size.width < 1000;

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 16 : (isTablet ? 32 : 50),
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: TextField(
            controller: _bairroController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Digite o nome do bairro',
              prefixIcon: Icon(Icons.location_on_outlined, color: _accentColor),
              suffixIcon: _bairroController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _limparBusca,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _accentColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmptyWidget() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma UPA encontrada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar por outro bairro',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildUPACardsList() {
  final width = MediaQuery.of(context).size.width;
  
  int crossAxisCount;
  double horizontalPadding;
  double childAspectRatio;
  
  if (width < 480) {
    crossAxisCount = 1;
    horizontalPadding = 12.0;
    childAspectRatio = 1.6;
  } else if (width < 600) {
    crossAxisCount = 1;
    horizontalPadding = 16.0;
    childAspectRatio = 2.4;
  } else if (width < 700) {
    crossAxisCount = 1;
    horizontalPadding = 20.0;
    childAspectRatio = 2.6;
  } else if (width < 830) {
    crossAxisCount = 1;
    horizontalPadding = 16.0;
    childAspectRatio = 3;
  } else if (width < 900) {
    crossAxisCount = 2;
    horizontalPadding = 28.0;
    childAspectRatio = 1.7;
  } else if (width < 1000) {
    crossAxisCount = 2;
    horizontalPadding = 32.0;
    childAspectRatio = 1.9;
  } else if (width < 1100) {
    crossAxisCount = 2;
    horizontalPadding = 36.0;
    childAspectRatio = 2.1;
  } else if (width < 1200) {
    crossAxisCount = 2;
    horizontalPadding = 40.0;
    childAspectRatio = 2.3;
  } else if (width < 1300) {
    crossAxisCount = 2;
    horizontalPadding = 45.0;
    childAspectRatio = 2.5;
  } else if (width < 1400) {
    crossAxisCount = 2;
    horizontalPadding = 45.0;
    childAspectRatio = 2.7;
  } else if (width < 1500) {
    crossAxisCount = 2;
    horizontalPadding = 50.0;
    childAspectRatio = 2.9;
  } else if (width < 1600) {
    crossAxisCount = 2;
    horizontalPadding = 50.0;
    childAspectRatio = 3.2;
  } else if (width < 1700) {
    crossAxisCount = 2;
    horizontalPadding = 50.0;
    childAspectRatio = 3.4;
  }  
  else {
    crossAxisCount = 2;
    horizontalPadding = 50.0;
    childAspectRatio = 4.5;
  }
  
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
    ),
    itemCount: _paginatedList.length,
    itemBuilder: (context, index) => _buildUPACard(_paginatedList[index]),
  );
}

Widget _buildUPACard(Map<String, dynamic> upa) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final telefoneFormatado = _formatarTelefone(upa['telefone'] ?? '');

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: _primaryDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_hospital_outlined, color: _primaryDark, size: isMobile ? 14 : 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  upa['nome'] ?? 'UPA',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: _primaryDark,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: isMobile ? 12 : 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      upa['endereco'] ?? 'Endereço não informado',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF475569),
                        fontFamily: 'Inter',
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: isMobile ? 12 : 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      telefoneFormatado,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF475569),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_outlined, size: isMobile ? 12 : 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      upa['horario'] ?? 'Horário não informado',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF475569),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
// No método _buildUPACard, substitua o SizedBox do botão por:

const SizedBox(height: 12),
const Divider(color: Color(0xFFE5E7EB), height: 1),
const SizedBox(height: 8),
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    OutlinedButton.icon(
      onPressed: () => _abrirModalMatricula(upa),
      icon: Icon(Icons.school_outlined, size: isMobile ? 14 : 16, color: _successColor),
      label: Text(
        'Matricular-se',
        style: TextStyle(color: _successColor, fontWeight: FontWeight.w500, fontSize: isMobile ? 11 : 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _successColor),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

String _formatarTelefone(String telefone) {
  if (telefone.isEmpty) return 'Telefone não informado';
  String apenasNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
  if (apenasNumeros.length == 10) {
    return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
  } else if (apenasNumeros.length == 11) {
    return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
  }
  return telefone;
}
}

class StatelessWidget {
        
}


class EnrollmentModal extends StatefulWidget {
  final Map<String, dynamic> upa;
  final Map<String, dynamic>? userData; 
  final Function(String)? onNameUpdated; 

  const EnrollmentModal({
    Key? key, 
    required this.upa,
    this.userData,
    this.onNameUpdated,
  }) : super(key: key);

  @override
  _EnrollmentModalState createState() => _EnrollmentModalState();
}

class _EnrollmentModalState extends State<EnrollmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _enrollmentService = EnrollmentService();
  final _authService = AuthService();
  
  
  final Color _primaryDark = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF1F4E6E);
final Color _successColor = const Color(0xFF2E8B6A);
final Color _warningColor = const Color(0xFFD97706);
final Color _dangerColor = const Color(0xFFC65D47);
  
  String? _turmaSelecionada;
  String? _segundaOpcaoTurma;  
  String? _escolaridade;
  int? _scoreFagestrom;
  String? _medicamento;
  bool _isLoadingScore = true;
  bool _isSubmitting = false;
  bool _carregandoTurmas = true;
  String? _outroMedicamento;

  
  List<Map<String, dynamic>> _turmasComVagas = [];

  @override
  void initState() {
    super.initState();
    _carregarScoreUsuario();
    _carregarTurmasComVagas();
  }

  Future<void> _carregarTurmasComVagas() async {
    setState(() => _carregandoTurmas = true);
    try {
      final response = await _enrollmentService.getTurmasPorUPA(widget.upa['id']);
      setState(() {
        _turmasComVagas = List<Map<String, dynamic>>.from(response['turmas']);
        _carregandoTurmas = false;
      });
    } catch (e) {
      print('Erro ao carregar turmas: $e');
      setState(() => _carregandoTurmas = false);
      _showSnackBar('Erro ao carregar turmas: $e', _dangerColor);
    }
  }

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
                  color: const Color(0xFF2E8B6A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: Color(0xFF2E8B6A),
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
                'Deseja realmente se matricular em ${widget.upa['nome']}?\n\nApós a confirmação, você entrará na lista de espera e receberá contato em até 5 dias úteis.',
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitEnrollment();
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text(
                            'Confirmar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8B6A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

  bool _isSelected(String categoria, String valor) => _comorbidades[categoria]!.any((item) => item['valor'] == valor);
  bool _isNenhumSelected(String categoria) => _comorbidades[categoria]!.any((item) => item['valor'] == 'nenhum');

Future<void> _submitEnrollment() async {
  if (_formKey.currentState!.validate()) {
    if (_turmaSelecionada == null) {
      _showSnackBar('Selecione uma turma', _warningColor);
      return;
    }
    if ((_scoreFagestrom == null || _scoreFagestrom == 0) && !_isLoadingScore) {
      _showSnackBar('Você precisa fazer o teste de Fagerström antes de se matricular', _warningColor);
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
  'medicamento': _medicamento == 'Outro' ? (_outroMedicamento ?? '') : _medicamento,
  'comorbidades': _comorbidades,
};
      await _enrollmentService.enroll(data);
      Navigator.pop(context);
      _showSnackBar('Matrícula realizada com sucesso! Você está na lista de espera.', _successColor);
    } catch (e) {
      String errorMessage = e.toString();
      
      if (errorMessage.contains('já possui uma matrícula')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber, color: Color(0xFFD97706), size: 28),
                SizedBox(width: 12),
                Text('Matrícula Existente', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              errorMessage.replaceFirst('Exception: ', ''),
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
             actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyEnrollmentsScreen(
                    userData: widget.userData, 
                    onNameUpdated: widget.onNameUpdated,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F4E6E),
            ),
            child: const Text('Ver Minhas Matrículas'),
              ),
            ],
          ),
        );
      } else {
        _showSnackBar('Erro ao realizar matrícula: $e', _dangerColor);
      }
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
  bool isFormValid = _turmaSelecionada != null &&
      _escolaridade != null &&
      _medicamento != null &&
      (_scoreFagestrom != null && _scoreFagestrom! > 0);

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Matrícula',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.upa['nome'] ?? 'UPA',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTurmaSection('Primeira opção', _turmaSelecionada, (value) => setState(() => _turmaSelecionada = value)),
                    const SizedBox(height: 20),
                    _buildTurmaSection('Segunda opção', _segundaOpcaoTurma, (value) => setState(() => _segundaOpcaoTurma = value), isOptional: true),
                    const SizedBox(height: 24),
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 20),
                    const Text(
                      'Informações Pessoais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEscolaridadeField(),
                    const SizedBox(height: 16),
                    _buildMedicamentoField(),
                    const SizedBox(height: 16),
                    _buildScoreFieldCompact(),
                    const SizedBox(height: 24),
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Comorbidades',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Opcional',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Inter'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione as condições de saúde existentes',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 16),
                    _buildComorbidadesGrid(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isFormValid && !_isSubmitting ? _showConfirmationDialog : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successColor,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
             : const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
      SizedBox(width: 8),
      Text(
        'Confirmar Matrícula',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



Widget _buildEscolaridadeField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Escolaridade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonFormField<String>(
          value: _escolaridade,
          isExpanded: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: Icon(Icons.expand_more, color: _accentColor),
          dropdownColor: Colors.white,
          items: _escolaridades.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _escolaridade = value),
          validator: (v) => v == null ? 'Selecione a escolaridade' : null,
        ),
      ),
    ],
  );
}

Widget _buildMedicamentoField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Medicamento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonFormField<String>(
          value: _medicamento,
          isExpanded: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: Icon(Icons.expand_more, color: _accentColor),
          dropdownColor: Colors.white,
          items: _medicamentos.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _medicamento = value;
              if (value != 'Outro') _outroMedicamento = null;
            });
          },
          validator: (v) => v == null ? 'Selecione o medicamento' : null,
        ),
      ),
      if (_medicamento == 'Outro')
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Digite o medicamento',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (text) => _outroMedicamento = text,
              validator: (value) {
                if (_medicamento == 'Outro' && (value == null || value.isEmpty)) {
                  return 'Digite o nome do medicamento';
                }
                return null;
              },
            ),
          ),
        ),
    ],
  );
}


Widget _buildComorbidadesGrid() {
  final List<Map<String, dynamic>> categorias = [
    {'titulo': 'Câncer', 'categoria': 'cancer', 'opcoes': _opcoesComorbidades['cancer']!, 'icon': Icons.health_and_safety},
    {'titulo': 'Cardiovascular', 'categoria': 'cardiovascular', 'opcoes': _opcoesComorbidades['cardiovascular']!, 'icon': Icons.favorite},
    {'titulo': 'Metabólico', 'categoria': 'metabolico', 'opcoes': _opcoesComorbidades['metabolico']!, 'icon': Icons.science},
    {'titulo': 'Psiquiátrico', 'categoria': 'psiquiatrico', 'opcoes': _opcoesComorbidades['psiquiatrico']!, 'icon': Icons.psychology},
    {'titulo': 'Respiratório', 'categoria': 'respiratorio', 'opcoes': _opcoesComorbidades['respiratorio']!, 'icon': Icons.air},
  ];
  
  return Column(
    children: categorias.map((cat) {
      bool temOutroSelecionado = _comorbidades[cat['categoria']]!.any((item) => 
        item['valor'] == 'outro' || item['valor'] == 'outros');
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(cat['icon'], size: 18, color: _accentColor),
                  const SizedBox(width: 8),
                  Text(
                    cat['titulo'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (cat['opcoes'] as List<String>).map((opcao) {
                  bool isSelected = _isSelected(cat['categoria'], opcao);
                  bool isDisabled = _isNenhumSelected(cat['categoria']) && opcao != 'nenhum';
                  return FilterChip(
                    label: Text(opcao, style: const TextStyle(fontSize: 12, fontFamily: 'Inter')),
                    selected: isSelected,
                    onSelected: isDisabled ? null : (selected) => _toggleComorbidade(cat['categoria'], opcao),
                    backgroundColor: Colors.white,
                    selectedColor: _accentColor.withOpacity(0.15),
                    checkmarkColor: _accentColor,
                    side: BorderSide(
                      color: isSelected ? _accentColor : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    shape: StadiumBorder(),
                  );
                }).toList(),
              ),
            ),
            if (temOutroSelecionado)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Especifique...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (text) {
                      final item = _comorbidades[cat['categoria']]!.firstWhere(
                        (item) => item['valor'] == 'outro' || item['valor'] == 'outros');
                      item['outroTexto'] = text;
                      setState(() {});
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList(),
  );
}

Widget _buildScoreFieldCompact() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Score Fagerström', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark)),
      SizedBox(height: 8),
      if (_isLoadingScore)
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(child: CircularProgressIndicator(color: _accentColor, strokeWidth: 2)),
        )
      else if (_scoreFagestrom != null && _scoreFagestrom! > 0)
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _successColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: _successColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_scoreFagestrom pontos',
                  style: TextStyle(fontWeight: FontWeight.w600, color: _successColor, fontSize: 14),
                ),
              ),
            ],
          ),
        )
      else
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _warningColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: _warningColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Não registrado',
                  style: TextStyle(fontWeight: FontWeight.w500, color: _warningColor, fontSize: 12),
                ),
              ),
TextButton(
  onPressed: () async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height > 800 ? 700 : MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: FagerstromTestModal(
                onScoreUpdated: (score) {
                  _scoreFagestrom = score;
                  setState(() {});
                },
              ),
            ),
          ),
        );
      },
    );
    await _carregarScoreUsuario();
  },
  style: TextButton.styleFrom(
    backgroundColor: _warningColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: Text('Fazer teste', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
),
            ],
          ),
        ),
    ],
  );
}

Widget _buildTurmaSection(String title, String? selected, Function(String?) onChanged, {bool isOptional = false}) {
  if (_carregandoTurmas) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  if (_turmasComVagas.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _warningColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber, color: _warningColor, size: 40),
          const SizedBox(height: 12),
          Text(
            'Nenhuma turma disponível no momento',
            style: TextStyle(fontSize: 14, color: _warningColor, fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      color: isOptional ? _warningColor.withOpacity(0.05) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isOptional ? _warningColor.withOpacity(0.3) : const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isOptional ? _warningColor.withOpacity(0.1) : _accentColor.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              if (isOptional) Icon(Icons.info_outline, color: _warningColor, size: 16),
              if (isOptional) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOptional ? _warningColor : const Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: 8),
                const Text(
                  '(opcional)',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: _turmasComVagas.map((turma) {
              String turmaTexto = '${turma['dia_semana']} - ${turma['horario']}';
              int vagasDisponiveis = turma['vagas_disponiveis'] ?? 0;
              int vagasTotais = turma['vagas_totais'] ?? 4;
              bool estaLotado = turma['status'] == 'lotado' || vagasDisponiveis <= 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selected == turmaTexto ? _accentColor.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == turmaTexto 
                      ? _accentColor 
                      : (estaLotado ? _dangerColor.withOpacity(0.2) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    turmaTexto,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: selected == turmaTexto ? FontWeight.w600 : FontWeight.normal,
                      color: estaLotado ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estaLotado 
                        ? _dangerColor.withOpacity(0.1)
                        : (vagasDisponiveis <= 2 ? _warningColor.withOpacity(0.1) : _successColor.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estaLotado 
                        ? 'Lotado' 
                        : '$vagasDisponiveis/$vagasTotais vagas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: estaLotado 
                          ? _dangerColor
                          : (vagasDisponiveis <= 2 ? _warningColor : _successColor),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  value: turmaTexto,
                  groupValue: selected,
                  onChanged: estaLotado ? null : onChanged,
                  activeColor: _accentColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}
}