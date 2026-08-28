import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/header/modals/fagerstrom_modal_widget.dart';
import 'package:tabagismo_app/screens/matriculas_screen.dart';

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
  int _itemsPerPage = 8;
  int _totalPages = 1;
  int _ultimaVersao = 0;

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
    } catch (e) {
      ToastService.showError(context, 'Erro ao carregar UPAs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarTodasUPAsSilenciosamente() async {
    try {
      final upas = await _authService.searchUPA('');
      setState(() {
        _upaList = upas;
        _currentPage = 1;
        _updatePagination();
      });
    } catch (e) {
      // ignora erro
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
    } catch (e) {
      ToastService.showError(context, 'Erro ao buscar UPAs: $e');
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

  bool _isPaginationLoading = false;

  void _goToPage(int page) async {
    setState(() {
      _isPaginationLoading = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _currentPage = page;
      _paginatedList = _getCurrentPageItems();
      _isPaginationLoading = false;
    });
  }

  Widget _buildPagination() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (_isPaginationLoading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, 
              color: _currentPage > 1 ? _accentColor : Colors.grey.shade400,
              size: isMobile ? 20 : 24,
            ),
            onPressed: _currentPage > 1 ? _previousPage : null,
            padding: EdgeInsets.all(isMobile ? 6 : 8),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Página $_currentPage de $_totalPages',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: _accentColor,
                fontFamily: 'Inter',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
              color: _currentPage < _totalPages ? _accentColor : Colors.grey.shade400,
              size: isMobile ? 20 : 24,
            ),
            onPressed: _currentPage < _totalPages ? _nextPage : null,
            padding: EdgeInsets.all(isMobile ? 6 : 8),
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
        final isEmEspera = matricula['status'] == 'em_espera';
        
        showDialog(
          context: context,
          builder: (context) => Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width < 500 ? MediaQuery.of(context).size.width * 0.92 : 420,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                      color: isEmEspera 
                        ? const Color(0xFFD97706).withValues(alpha: 0.1)
                        : const Color(0xFF2E8B6A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEmEspera ? Icons.hourglass_empty : Icons.check_circle,
                      size: 48,
                      color: isEmEspera ? const Color(0xFFD97706) : const Color(0xFF2E8B6A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEmEspera ? 'Matrícula em Espera' : 'Matrícula Ativa',
                    style: const TextStyle(
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
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                        if (isEmEspera) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Aguardando confirmação',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEmEspera
                      ? 'Você receberá um contato em até 5 dias úteis para confirmar sua vaga.'
                      : 'Sua matrícula está confirmada. Acompanhe os detalhes na seção de matrículas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            'Fechar',
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
      
      final isMobile = MediaQuery.of(context).size.width < 600;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
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
      final isMobile = MediaQuery.of(context).size.width < 600;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
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
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading) {
            _buscarTodasUPAsSilenciosamente();
          }
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              HeaderWidget(
                title: 'DESFUMO',
                subtitle: 'Apoio ao Tabagismo',
                icon: Icons.smoke_free_outlined,
                userData: widget.userData ?? {},
                isHome: true,
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
                                padding: const EdgeInsets.all(48),
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
                      const FooterWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isSmallMobile ? 12 : 50),
        vertical: isMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encontre uma Unidade de Saúde',
            style: TextStyle(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Busque por bairro e encontre a unidade mais próxima',
            style: TextStyle(
              fontSize: isMobile ? 13 : 15,
              color: const Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
           SizedBox(height: isMobile ? 12 : 20),
          TextField(
            controller: _bairroController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Digite o nome do bairro...',
              prefixIcon: Icon(Icons.search, color: _accentColor),
              suffixIcon: _bairroController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _limparBusca,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _accentColor, width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 14 : 16),
            ),
          ),
          if (_upaList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${_upaList.length} unidades encontradas',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: const Color(0xFF64748B),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off, size: isMobile ? 48 : 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma UPA encontrada',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente buscar por outro bairro',
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
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
  final isMobile = width < 768;
  
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
      crossAxisCount = 1;
      horizontalPadding = 28.0;
      childAspectRatio = 3;
    } else if (width < 1000) {
      crossAxisCount = 1;
      horizontalPadding = 32.0;
      childAspectRatio = 3.5;
    } else if (width < 1100) {
      crossAxisCount = 2;
      horizontalPadding = 36.0;
      childAspectRatio = 1.9;
    } else if (width < 1200) {
      crossAxisCount = 2;
      horizontalPadding = 40.0;
      childAspectRatio = 2.1;
    } else if (width < 1300) {
      crossAxisCount = 2;
      horizontalPadding = 45.0;
      childAspectRatio = 2.2;
    } else if (width < 1400) {
      crossAxisCount = 2;
      horizontalPadding = 45.0;
      childAspectRatio = 2.4;
    } else if (width < 1500) {
      crossAxisCount = 2;
      horizontalPadding = 50.0;
      childAspectRatio = 2.6;
    } else if (width < 1600) {
      crossAxisCount = 2;
      horizontalPadding = 50.0;
      childAspectRatio = 2.8;
    } else if (width < 1700) {
      crossAxisCount = 2;
      horizontalPadding = 50.0;
      childAspectRatio = 3;
    } else {
      crossAxisCount = 2;
      horizontalPadding = 50.0;
      childAspectRatio = 3.5;
    }
  
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isMobile ? 16 : 16),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isMobile ? 12 : 12,
      mainAxisSpacing: isMobile ? 12 : 12,
      childAspectRatio: childAspectRatio,
    ),
    itemCount: _paginatedList.length,
    itemBuilder: (context, index) => _buildUPACard(_paginatedList[index]),
  );
}

Widget _buildUPACard(Map<String, dynamic> upa) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;
  final telefoneFormatado = _formatarTelefone(upa['telefone'] ?? '');
  final cepFormatado = _formatarCep(upa['cep']?.toString() ?? '');
  
  final hasHorario = upa['horario'] != null && upa['horario'].toString().isNotEmpty;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
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
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFE2E8F0), const Color(0xFFF1F5F9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 10),
                    decoration: BoxDecoration(
                      color: _primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_hospital_outlined,
                      color: _primaryDark,
                      size: isMobile ? 16 : 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upa['nome'] ?? 'UPA',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          upa['cidade'] ?? 'Cidade não informada',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: const Color(0xFF64748B),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
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
        Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: isMobile ? 14 : 16,
                          color: const Color(0xFF1F4E6E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: upa['endereco'] ?? 'Endereço não informado',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 13,
                                    color: const Color(0xFF1E293B),
                                    fontFamily: 'Inter',
                                    height: 1.4,
                                  ),
                                ),
                                if (cepFormatado.isNotEmpty)
                                  TextSpan(
                                    text: ' • $cepFormatado',
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 11,
                                      color: const Color(0xFF94A3B8),
                                      fontFamily: 'Inter',
                                      height: 1.4,
                                    ),
                                  ),
                              ],
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
                        Icon(
                          Icons.phone_outlined,
                          size: isMobile ? 14 : 16,
                          color: const Color(0xFF1F4E6E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            telefoneFormatado,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: const Color(0xFF1E293B),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (hasHorario) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: isMobile ? 14 : 16,
                            color: const Color(0xFF1F4E6E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              upa['horario'] ?? 'Horário não informado',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                color: const Color(0xFF1E293B),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: const Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirModalMatricula(upa),
                  icon: Icon(Icons.school_outlined, size: isMobile ? 16 : 18, color: Colors.white),
                  label: Text(
                    isSmallMobile ? 'Matricular' : 'Matricular-se',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _formatarCep(String cep) {
  if (cep.isEmpty) return '';
  String limpo = cep.replaceAll(RegExp(r'[^\d]'), '');
  if (limpo.length == 8) {
    return '${limpo.substring(0, 5)}-${limpo.substring(5)}';
  }
  return cep;
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
  
  final Color _primaryDark = const Color(0xFF0F2B3D);
  final Color _accentColor = const Color(0xFF1F4E6E);
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
      setState(() => _carregandoTurmas = false);
      ToastService.showError(context, 'Erro ao carregar turmas: $e');
    }
  }

  void _showConfirmationDialog() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.92 : 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
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
                    color: const Color(0xFF2E8B6A).withValues(alpha: 0.1),
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
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Deseja realmente se matricular em ${widget.upa['nome']}?\n\nApós a confirmação, você entrará na lista de espera e receberá contato em até 5 dias úteis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: Color(0xFF475569),
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
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
      ToastService.showError(context, 'Erro ao carregar score: $e');
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
        ToastService.showWarning(context, 'Selecione uma turma');
        return;
      }
      if ((_scoreFagestrom == null || _scoreFagestrom == 0) && !_isLoadingScore) {
        ToastService.showWarning(context, 'Você precisa fazer o teste de Fagerström antes de se matricular');
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
        ToastService.showSuccess(context, 'Matrícula realizada com sucesso! Você está na lista de espera.');
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
          ToastService.showError(context, 'Erro ao realizar matrícula: $e');
        }
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

 @override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
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
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMobile ? 'Matrícula' : 'Nova Matrícula',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.upa['nome'] ?? 'UPA',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.white.withValues(alpha: 0.8),
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
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 960;
                        
                        return isSmallScreen
                            ? Column(
                                children: [
                                  _buildTurmaSection('Primeira opção', _turmaSelecionada, (value) => setState(() => _turmaSelecionada = value)),
                                  const SizedBox(height: 16),
                                  _buildTurmaSection('Segunda opção', _segundaOpcaoTurma, (value) => setState(() => _segundaOpcaoTurma = value), isOptional: true),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildTurmaSection('Primeira opção', _turmaSelecionada, (value) => setState(() => _turmaSelecionada = value)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTurmaSection('Segunda opção', _segundaOpcaoTurma, (value) => setState(() => _segundaOpcaoTurma = value), isOptional: true),
                                  ),
                                ],
                              );
                      },
                    ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
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
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    isMobile ? 'Confirmar' : 'Confirmar Matrícula',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
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
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
              hintText: 'Selecione',
              hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Color(0xFF94A3B8)),
            ),
            icon: Icon(Icons.expand_more, color: _accentColor),
            dropdownColor: Colors.white,
            items: _escolaridades.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 13 : 14)),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
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
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
              hintText: 'Selecione',
              hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Color(0xFF94A3B8)),
            ),
            icon: Icon(Icons.expand_more, color: _accentColor),
            dropdownColor: Colors.white,
            items: _medicamentos.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 13 : 14)),
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
                decoration: InputDecoration(
                  hintText: 'Digite o medicamento',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
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
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 14),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(cat['icon'], size: isMobile ? 16 : 18, color: _accentColor),
                    const SizedBox(width: 8),
                    Text(
                      cat['titulo'],
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 10 : 14),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (cat['opcoes'] as List<String>).map((opcao) {
                    bool isSelected = _isSelected(cat['categoria'], opcao);
                    bool isDisabled = _isNenhumSelected(cat['categoria']) && opcao != 'nenhum';
                    return FilterChip(
                      label: Text(opcao, style: TextStyle(fontSize: isMobile ? 10 : 12, fontFamily: 'Inter')),
                      selected: isSelected,
                      onSelected: isDisabled ? null : (selected) => _toggleComorbidade(cat['categoria'], opcao),
                      backgroundColor: Colors.white,
                      selectedColor: _accentColor.withValues(alpha: 0.15),
                      checkmarkColor: _accentColor,
                      side: BorderSide(
                        color: isSelected ? _accentColor : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      shape: const StadiumBorder(),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score Fagerström', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark)),
        const SizedBox(height: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _successColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: _successColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$_scoreFagestrom pontos',
                    style: TextStyle(fontWeight: FontWeight.w600, color: _successColor, fontSize: isMobile ? 13 : 14),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _warningColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: _warningColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Não registrado',
                    style: TextStyle(fontWeight: FontWeight.w500, color: _warningColor, fontSize: isMobile ? 11 : 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Fazer teste', style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
      ],
    );
  }

Widget _buildTurmaSection(String title, String? selected, Function(String?) onChanged, {bool isOptional = false}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
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
        border: Border.all(color: _warningColor.withValues(alpha: 0.3)),
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
      color: isOptional ? _warningColor.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isOptional ? _warningColor.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 14),
          decoration: BoxDecoration(
            color: isOptional ? _warningColor.withValues(alpha: 0.1) : _accentColor.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              if (isOptional) Icon(Icons.info_outline, color: _warningColor, size: 16),
              if (isOptional) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: isOptional ? _warningColor : const Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: 8),
                Text(
                  '(opcional)',
                  style: TextStyle(fontSize: isMobile ? 10 : 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          child: Column(
            children: _turmasComVagas.map((turma) {
              String turmaTexto = '${turma['dia_semana']} - ${turma['horario']}';
              int vagasDisponiveis = turma['vagas_disponiveis'] ?? 0;
              int vagasTotais = turma['vagas_totais'] ?? 4;
              bool estaLotado = turma['status'] == 'lotado' || vagasDisponiveis <= 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: selected == turmaTexto ? _accentColor.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == turmaTexto 
                      ? _accentColor 
                      : (estaLotado ? _dangerColor.withValues(alpha: 0.2) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    turmaTexto,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: selected == turmaTexto ? FontWeight.w600 : FontWeight.normal,
                      color: estaLotado ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: estaLotado 
                        ? _dangerColor.withValues(alpha: 0.1)
                        : (vagasDisponiveis <= 2 ? _warningColor.withValues(alpha: 0.1) : _successColor.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estaLotado 
                        ? 'Lotado' 
                        : '$vagasDisponiveis/$vagasTotais',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 8),
                  dense: isMobile,
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