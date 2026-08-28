import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class AdminUsuariosWidget extends StatefulWidget {
  const AdminUsuariosWidget({Key? key}) : super(key: key);

  @override
  _AdminUsuariosWidgetState createState() => _AdminUsuariosWidgetState();
}

class _AdminUsuariosWidgetState extends State<AdminUsuariosWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);

  List<Map<String, dynamic>> _usuarios = [];
  bool _carregando = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsuarios = 0;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios({int page = 1}) async {
    setState(() {
      _carregando = true;
      _currentPage = page;
    });

    try {
      final authService = AuthService();
      final response = await authService.getUsuariosPaginados(
        page: page,
        limit: 8,
        search: _searchQuery,
      );

      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(response['usuarios']);
        _totalPages = response['totalPages'];
        _totalUsuarios = response['total'];
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      ToastService.showError(context, 'Erro ao carregar usuários: $e');
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
      floatingLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: _accentColor,
      ),
      prefixIcon: Icon(icon, color: _accentColor, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFDBDBDB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
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

  String _formatarData(String? data) {
    if (data == null || data.isEmpty) return '-';
    String dataLimpa = data.split(' ')[0];
    String dataLimpa2 = dataLimpa.split('T')[0];
    final partes = dataLimpa2.split('-');
    if (partes.length != 3) return dataLimpa2;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 20.0;

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: TextField(
            controller: _searchController,
            decoration: _buildInputDecoration('Buscar por nome, email ou CPF...', Icons.search),
            onChanged: (value) {
              _searchQuery = value;
              _currentPage = 1;
              _carregarUsuarios(page: 1);
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _searchQuery.isEmpty
                      ? 'Todos os Usuários'
                      : 'Resultados para: "$_searchQuery"',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $_totalUsuarios usuários',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ..._usuarios.map((usuario) => _buildUsuarioCard(usuario)),
                const SizedBox(height: 16),
                _buildPaginacao(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginacao() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _carregarUsuarios(page: _currentPage);
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
              '$_currentPage / $_totalPages',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _accentColor),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _carregarUsuarios(page: _currentPage);
                  }
                : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final isAdmin = usuario['is_admin'] == 1;
    final isMobile = MediaQuery.of(context).size.width < 500;

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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isAdmin ? _accentColor : const Color(0xFF3B82F6),
          radius: isMobile ? 18 : 20,
          child: Text(
            usuario['nome_completo'][0].toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 16),
          ),
        ),
        title: Text(
          usuario['nome_completo'],
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: isMobile ? 14 : 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              usuario['email'],
              style: TextStyle(fontSize: isMobile ? 11 : 12, color: Color(0xFF64748B)),
            ),
            Text(
              'Telefone: ${_formatarTelefone(usuario['telefone'] ?? '')}',
              style: TextStyle(fontSize: isMobile ? 10 : 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(fontSize: isMobile ? 8 : 10, fontWeight: FontWeight.w600, color: _accentColor),
                ),
              ),
            IconButton(
              icon: Icon(Icons.edit, color: _warningColor, size: isMobile ? 18 : 20),
              onPressed: () => _editarUsuario(usuario),
            ),
            IconButton(
              icon: Icon(Icons.visibility, color: const Color(0xFF3B82F6), size: isMobile ? 18 : 20),
              onPressed: () => _verDetalhesUsuario(usuario),
            ),
          ],
        ),
      ),
    );
  }

  void _editarUsuario(Map<String, dynamic> usuario) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    final nomeController = TextEditingController(text: usuario['nome_completo']);
    final emailController = TextEditingController(text: usuario['email']);
    final telefoneController = MaskedTextController(mask: '(00) 00000-0000', text: usuario['telefone'] ?? '');
    String? sexoSelecionado = usuario['sexo'];
    bool carregandoSexo = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (carregandoSexo && usuario['sexo'] == null) {
              try {
                final authService = AuthService();
                authService.getUsuarioDetalhes(usuario['id']).then((response) {
                  setState(() {
                    sexoSelecionado = response['usuario']['sexo'];
                    carregandoSexo = false;
                  });
                });
              } catch (e) {
                setState(() => carregandoSexo = false);
              }
            }

            bool isFormValid() {
              if (nomeController.text.trim().isEmpty) return false;
              if (emailController.text.trim().isEmpty) return false;
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) return false;
              String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
              if (telefoneLimpo.isNotEmpty && telefoneLimpo.length != 11) return false;
              return true;
            }

            bool hasChanges() {
              if (nomeController.text.trim() != usuario['nome_completo']) return true;
              if (emailController.text.trim() != usuario['email']) return true;
              String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
              String telefoneOriginal = usuario['telefone'] ?? '';
              if (telefoneLimpo != telefoneOriginal) return true;
              if (sexoSelecionado != usuario['sexo']) return true;
              return false;
            }

            bool canSave() {
              if (!isFormValid()) return false;
              if (!hasChanges()) return false;
              return true;
            }

            return Dialog(
              insetPadding: EdgeInsets.only(
                left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                top: 20,
                bottom: 20,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 480,
                padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFF1F4E6E), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Editar Usuário',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nomeController,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('Nome Completo', Icons.person),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: sexoSelecionado,
                      decoration: _buildInputDecoration('Sexo', Icons.wc),
                      items: ['Masculino', 'Feminino', 'Outro'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) => setState(() => sexoSelecionado = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('Email', Icons.email),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      decoration: _buildInputDecoration('Telefone', Icons.phone),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canSave()
                                ? () async {
                                    try {
                                      final authService = AuthService();
                                      final telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                                      await authService.atualizarUsuario(
                                        usuario['id'],
                                        {
                                          'nomeCompleto': nomeController.text,
                                          'sexo': sexoSelecionado,
                                          'email': emailController.text,
                                          'telefone': telefoneLimpo,
                                        }
                                      );
                                      Navigator.pop(context);
                                      ToastService.showSuccess(context, 'Usuário ${usuario['nome_completo']} atualizado com sucesso!');
                                      _carregarUsuarios();
                                    } catch (e) {
                                      ToastService.showError(context, 'Erro ao atualizar usuário: $e');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canSave() ? _successColor : Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save,
                                  size: 18,
                                  color: canSave() ? Colors.white : Colors.grey.shade500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Salvar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: canSave() ? Colors.white : Colors.grey.shade500,
                                  ),
                                ),
                              ],
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
      },
    );
  }

  void _verDetalhesUsuario(Map<String, dynamic> usuario) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    Map<String, dynamic> usuarioDetalhado = usuario;
    String upaNome = 'Não vinculado';
    bool carregando = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (carregando) {
              try {
                final authService = AuthService();
                authService.getUsuarioDetalhes(usuario['id']).then((response) {
                  setState(() {
                    usuarioDetalhado = response['usuario'];
                    carregando = false;
                  });
                });
                authService.verificarMatriculaAtiva().then((response) {
                  if (response['hasActiveEnrollment']) {
                    setState(() {
                      upaNome = response['enrollment']['upa_nome'] ?? 'Não vinculado';
                    });
                  }
                });
              } catch (e) {
                setState(() => carregando = false);
              }
            }

            return Dialog(
              insetPadding: EdgeInsets.only(
                left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
                top: 20,
                bottom: 20,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 480,
                padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_outline, color: Color(0xFF1F4E6E), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuarioDetalhado['nome_completo'] ?? 'Carregando...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                usuarioDetalhado['email'] ?? 'Carregando...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (carregando)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(Icons.badge, 'Nome', usuarioDetalhado['nome_completo'] ?? '-'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.email, 'Email', usuarioDetalhado['email'] ?? '-'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.phone, 'Telefone', _formatarTelefone(usuarioDetalhado['telefone'] ?? '')),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.assignment_ind, 'CPF', _formatarCpf(usuarioDetalhado['cpf'] ?? '')),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.wc, 'Sexo', usuarioDetalhado['sexo'] ?? '-'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.cake, 'Data Nascimento', _formatarData(usuarioDetalhado['data_nascimento'])),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.numbers, 'Idade', usuarioDetalhado['idade']?.toString() ?? '-'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.local_hospital, 'Unidade', upaNome),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text(
                          'Fechar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}