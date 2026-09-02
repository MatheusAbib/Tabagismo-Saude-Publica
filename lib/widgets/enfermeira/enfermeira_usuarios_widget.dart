import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/enfermeira/enfermeira_fichaPaciente_widget.dart';

class UsuariosWidget extends StatefulWidget {
  final int upaId;
  

  const UsuariosWidget({Key? key, required this.upaId}) : super(key: key);

  @override
  _UsuariosWidgetState createState() => _UsuariosWidgetState();
}
final ValueNotifier<bool> _carregandoLista = ValueNotifier(false);

class _UsuariosWidgetState extends State<UsuariosWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);
  final Color _purpleColor = const Color(0xFF6B21A8);

  List<Map<String, dynamic>> _usuarios = [];
  bool _carregando = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsuarios = 0;
  int _totalEmEspera = 0;
  int _totalMatriculados = 0;
  int _totalCancelados = 0;
  String _searchQuery = '';
  String _statusFiltro = 'todos';
  TextEditingController _searchController = TextEditingController();
  int _selectedFiltroIndex = 0;
  

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
    _carregarContadores();
    _searchController.addListener(_buscarUsuarios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_buscarUsuarios);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarContadores() async {
    try {
      final response = await AuthService().getContadoresUsuarios();
      setState(() {
        _totalUsuarios = response['total'] ?? 0;
        _totalEmEspera = response['em_espera'] ?? 0;
        _totalMatriculados = response['matriculado'] ?? 0;
        _totalCancelados = response['cancelada'] ?? 0;
      });
    } catch (e) {
      print('Erro ao carregar contadores: $e');
    }
  }

Future<void> _carregarUsuarios({int page = 1}) async {
  _carregandoLista.value = true;
  _currentPage = page;

  String statusFilter = '';
  if (_statusFiltro != 'todos') {
    statusFilter = _statusFiltro;
  }

  try {
    final response = await AuthService().getUsuariosDaUPA(
      page: page,
      limit: 10,
      search: _searchQuery,
      status: statusFilter,
    );

    List<Map<String, dynamic>> usuarios = List<Map<String, dynamic>>.from(response['usuarios']);

    if (_statusFiltro == 'todos') {
      usuarios.sort((a, b) {
        final ordemStatus = {
          'em_espera': 0,
          'matriculado': 1,
          'cancelada': 2,
        };

        final statusA = a['status'] ?? '';
        final statusB = b['status'] ?? '';

        final ordemA = ordemStatus[statusA] ?? 3;
        final ordemB = ordemStatus[statusB] ?? 3;

        if (ordemA != ordemB) {
          return ordemA.compareTo(ordemB);
        }

        final dataA = a['created_at'] ?? '';
        final dataB = b['created_at'] ?? '';
        return dataB.compareTo(dataA);
      });
    }

    setState(() {
      _usuarios = usuarios;
      _totalPages = response['totalPages'];
      _carregando = false;
    });
    _carregandoLista.value = false;
  } catch (e) {
    _carregandoLista.value = false;
    setState(() => _carregando = false);
    ToastService.showError(context, 'Erro ao carregar usuários: $e');
  }
}

  void _buscarUsuarios() {
    _searchQuery = _searchController.text;
    _carregarUsuarios(page: 1);
  }

  void _limparBusca() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
    _carregarUsuarios(page: 1);
  }

  void _verDetalhes(Map<String, dynamic> usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUsuarioDetalhesScreen(
          usuarioId: usuario['id'],
          usuarioNome: usuario['nome_completo'],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera':
        return 'Em Espera';
      case 'confirmada':
        return 'Confirmada';
      case 'matriculado':
        return 'Matriculado';
      case 'recusada':
        return 'Recusada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera':
        return _warningColor;
      case 'confirmada':
        return _successColor;
      case 'matriculado':
        return _purpleColor;
      case 'recusada':
        return Colors.red;
      case 'cancelada':
        return _dangerColor;
      default:
        return Colors.grey;
    }
  }

  String _formatarTelefone(String telefone) {
    if (telefone.isEmpty) return 'Não informado';
    String apenasNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 11) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
    } else if (apenasNumeros.length == 10) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
    }
    return telefone;
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';
    String apenasNumeros = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 11) {
      return '${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}';
    }
    return cpf;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    final horizontalPadding = isSmallMobile ? 8.0 : (isMobile ? 12.0 : 20.0);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou email...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                          onPressed: _limparBusca,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _accentColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmallMobile ? 10 : 14),
                ),
              ),
              const SizedBox(height: 12),
              _buildFiltrosTabs(isMobile),
            ],
          ),
        ),
       Expanded(
  child: ValueListenableBuilder(
    valueListenable: _carregandoLista,
    builder: (context, carregando, child) {
      return Stack(
        children: [
          if (_carregando && _usuarios.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_usuarios.isEmpty)
            _buildEmptyUsuariosWidget()
          else
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _searchQuery.isEmpty
                        ? _getFiltroTitulo()
                        : 'Resultados para: "$_searchQuery"',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${_usuarios.length} usuários',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: const Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._usuarios.map((usuario) => _buildUsuarioCard(usuario)),
                  const SizedBox(height: 16),
                  if (_totalPages > 1) _buildPaginacao(),
                ],
              ),
            ),
          if (carregando && _usuarios.isNotEmpty)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
    },
  ),
),
      ],
    );
  }

  Widget _buildPaginacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: _currentPage > 1
              ? () {
                  _carregarUsuarios(page: _currentPage - 1);
                }
              : null,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_currentPage de $_totalPages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _accentColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: _currentPage < _totalPages
              ? () {
                  _carregarUsuarios(page: _currentPage + 1);
                }
              : null,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyUsuariosWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum usuário encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou a busca',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosTabs(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFiltroButton('Todos', _totalUsuarios, 0, const Color(0xFF64748B), isMobile),
          const SizedBox(width: 4),
          _buildFiltroButton('Em Espera', _totalEmEspera, 1, _warningColor, isMobile),
          const SizedBox(width: 4),
          _buildFiltroButton('Matriculados', _totalMatriculados, 2, _successColor, isMobile),
          const SizedBox(width: 4),
          _buildFiltroButton('Cancelados', _totalCancelados, 3, _dangerColor, isMobile),
        ],
      ),
    );
  }

  Widget _buildFiltroButton(String label, int count, int index, Color color, bool isMobile) {
    final isSelected = _selectedFiltroIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFiltroIndex = index;
          switch (index) {
            case 0:
              _statusFiltro = 'todos';
              break;
            case 1:
              _statusFiltro = 'em_espera';
              break;
            case 2:
              _statusFiltro = 'matriculado';
              break;
            case 3:
              _statusFiltro = 'cancelada';
              break;
          }
          _currentPage = 1;
          _carregarUsuarios(page: 1);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 11 : 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: isMobile ? 9 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFiltroTitulo() {
    switch (_statusFiltro) {
      case 'todos':
        return 'Todos os Usuários';
      case 'em_espera':
        return 'Usuários em Espera';
      case 'matriculado':
        return 'Usuários Matriculados';
      case 'cancelada':
        return 'Usuários Cancelados';
      default:
        return 'Usuários';
    }
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final status = usuario['status'];
    final telefone = usuario['telefone'] ?? '';
    final telefoneFormatado = _formatarTelefone(telefone);
    final cpf = usuario['cpf'] ?? 'Não informado';
    final cpfFormatado = cpf != 'Não informado' ? _formatarCpf(cpf) : cpf;
    final idade = usuario['idade'] ?? 0;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 18 : 20,
                  backgroundColor: _accentColor.withValues(alpha: 0.1),
                  child: Text(
                    usuario['nome_completo'][0].toUpperCase(),
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nome_completo'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF0F172A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        usuario['email'],
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'Telefone', telefoneFormatado),
                _buildInfoRow(Icons.assignment_ind, 'CPF', cpfFormatado),
                _buildInfoRow(Icons.cake, 'Idade', '$idade anos'),
                if (usuario['turma_horario'] != null)
                  _buildInfoRow(Icons.schedule, 'Turma', usuario['turma_horario']),
                const SizedBox(height: 12),
                if (status != 'cancelada')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _verDetalhes(usuario),
                          icon: Icon(Icons.visibility, size: isMobile ? 16 : 18),
                          label: Text(
                            'Ver Ficha do Paciente',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _accentColor),
                            foregroundColor: _accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}