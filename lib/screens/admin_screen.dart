import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/admin_usuario_detalhes.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/services/pdf_service.dart';
import 'package:tabagismo_app/services/cep_service.dart';
import 'package:flutter/services.dart';

class AdminScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const AdminScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  int _totalUsuarios = 0;
  int _totalMatriculas = 0;
  int _totalUPAs = 0;
  int _totalRegistrosSintomas = 0;
  int _totalEnfermeiras = 0;

  

List<Map<String, dynamic>> _enfermeiras = [];
bool _carregandoEnfermeiras = true;
List<Map<String, dynamic>> _upasLista = [];
String _searchEnfermeira = '';
TextEditingController _searchEnfermeiraController = TextEditingController();

  


  List<Map<String, dynamic>> _upas = [];
    bool _carregandoUPAs = true;
    int _currentPageUPAs = 1;
    int _totalPagesUPAs = 1;
    int _totalUPAsLista = 0;
    String _searchQueryUPAs = '';
    TextEditingController _searchUPAsController = TextEditingController();
  
  final List<String> _tabTitles = ['Dashboard', 'Usuários', 'UPAs', 'Enfermeiras'];
  
  final Color _primaryColor = const Color(0xFF0F2B3D);
  final Color _accentColor = const Color(0xFF2C7DA0);

@override
void initState() {
  super.initState();
  _carregarEstatisticas();
  _carregarUsuarios();
  _carregarUPAs();
  _carregarEnfermeiras();
}
  
void _showLogoutConfirmationDialog() {
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
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sair da conta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tem certeza que deseja sair?',
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
                        _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Sair',
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

void _performLogout() async {
  final authService = AuthService();
  await authService.logout();
  
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), 
      (route) => false,
    );
  }
}

void _logout() {
  _showLogoutConfirmationDialog();
}

Future<void> _changePassword() async {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C7DA0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock_outline, color: Color(0xFF2C7DA0), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Alterar Senha',
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
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha Atual',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha',
                    prefixIcon: Icon(Icons.lock_reset),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    prefixIcon: Icon(Icons.verified_user),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        onPressed: isLoading ? null : () async {
                          if (newPasswordController.text != confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('As senhas não coincidem'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          try {
                            final authService = AuthService();
                            await authService.changeUserPassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao alterar senha: $e'), backgroundColor: Colors.red.shade400),
                              );
                            }
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Salvar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
    ),
  );
}

  Future<void> _editData() async {
  try {
    final authService = AuthService();
    final response = await authService.getUserData();
    final userData = response['user'];

    final nomeController = TextEditingController(text: userData['nomeCompleto']);
    String? sexoSelecionado = userData['sexo'];
    final emailController = TextEditingController(text: userData['email']);
    final telefoneController = MaskedTextController(
      mask: '(00) 00000-0000',
      text: userData['telefone'] != null ? _formatTelefone(userData['telefone']) : '',
    );
    
    final cpf = userData['cpf'] != null ? _formatCpf(userData['cpf']) : 'Não informado';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C7DA0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_outlined, color: Color(0xFF2C7DA0), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Editar Dados',
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
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: sexoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    items: ['Masculino', 'Feminino', 'Outro'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        sexoSelecionado = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.assignment_ind, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CPF',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                cpf,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      hintText: '(11) 91234-5678',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (telefoneController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Telefone é obrigatório'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }

                                  String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                                  if (telefoneLimpo.length != 11) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Telefone inválido (DDD + 9 dígitos)'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    final authService = AuthService();
                                    await authService.updateUserData({
                                      'nomeCompleto': nomeController.text,
                                      'sexo': sexoSelecionado,
                                      'email': emailController.text,
                                      'telefone': telefoneLimpo,
                                    });

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Dados atualizados com sucesso!'), backgroundColor: Color(0xFF10B981)),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro ao atualizar dados: $e'), backgroundColor: Colors.red.shade400),
                                      );
                                    }
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Salvar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
      ),
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red.shade400),
      );
    }
  }
}

  String _formatTelefone(String telefone) {
    if (telefone.length == 11) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}';
    }
    return telefone;
  }

  String _formatCpf(String cpf) {
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }
  

Future<void> _carregarEstatisticas() async {
  setState(() => _isLoading = true);
  try {
    final authService = AuthService();
    final response = await authService.getAdminStats();
    
    setState(() {
      _totalUsuarios = response['totalUsuarios'] ?? 0;
      _totalEnfermeiras = response['totalEnfermeiras'] ?? 0;
      _totalMatriculas = response['totalMatriculas'] ?? 0;
      _totalUPAs = response['totalUPAs'] ?? 0;
      _totalRegistrosSintomas = response['totalRegistrosSintomas'] ?? 0;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar estatísticas: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

    List<Map<String, dynamic>> _usuarios = [];
    bool _carregandoUsuarios = true;
    int _currentPage = 1;
    int _totalPages = 1;
    int _totalUsuariosLista = 0;
    String _searchQuery = '';
    TextEditingController _searchController = TextEditingController();

Future<void> _carregarUsuarios({int page = 1}) async {
  _currentPage = page;
  
  try {
    final authService = AuthService();
    final response = await authService.getUsuariosPaginados(
      page: page,
      limit: 8,
      search: _searchQuery,
    );
    
    _usuarios = List<Map<String, dynamic>>.from(response['usuarios']);
    _totalPages = response['totalPages'];
    _totalUsuariosLista = response['total'];
    _carregandoUsuarios = false;
    
    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    _carregandoUsuarios = false;
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar usuários: $e'), backgroundColor: Colors.red.shade400),
      );
    }
  }
}

void _buscarUsuarios() {
  _searchQuery = _searchController.text;
  _carregandoUsuarios = true;
  _currentPage = 1;
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

void _editarUsuario(Map<String, dynamic> usuario) {
  final nomeController = TextEditingController(text: usuario['nome_completo']);
  final emailController = TextEditingController(text: usuario['email']);
  
  final telefoneController = MaskedTextController(
    mask: '(00) 00000-0000',
    text: usuario['telefone'] != null && usuario['telefone'].toString().length == 11 
        ? _formatTelefone(usuario['telefone'].toString()) 
        : usuario['telefone'] ?? '',
  );
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C7DA0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit, color: Color(0xFF2C7DA0), size: 24),
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
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          onPressed: () async {
                            try {
                              final authService = AuthService();
                              final telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                              
                              await authService.atualizarUsuario(
                                usuario['id'],
                                {
                                  'nomeCompleto': nomeController.text,
                                  'sexo': usuario['sexo'] ?? '',
                                  'email': emailController.text,
                                  'telefone': telefoneLimpo,
                                }
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Usuário atualizado com sucesso!'), backgroundColor: Color(0xFF10B981)),
                              );
                              _carregarUsuarios();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red.shade400),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.save, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Salvar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
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
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Header com o menu dropdown
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 50,
                right: 50,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor,
                    const Color(0xFF1A4A6F),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo e título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 29),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Painel Administrativo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Menu dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 52),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bem-vindo, ${_getUserFirstName()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      onSelected: (String value) {
                        switch (value) {
                          case 'editar_dados':
                            _editData();
                            break;
                          case 'alterar_senha':
                            _changePassword();
                            break;
                          case 'sair':
                            _logout();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'editar_dados',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20, color: Color(0xFF0F2B3D)),
                              SizedBox(width: 12),
                              Text('Editar Dados', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'alterar_senha',
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline, size: 20, color: Color(0xFF0F2B3D)),
                              SizedBox(width: 12),
                              Text('Alterar Senha', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'sair',
                          child: Row(
                            children: [
                              Icon(Icons.logout_outlined, size: 20, color: Colors.red.shade400),
                              const SizedBox(width: 12),
                              Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              indicatorColor: _accentColor,
              labelColor: _accentColor,
              unselectedLabelColor: const Color(0xFF64748B),
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
            // Conteúdo
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboard(),
                  _buildUsuariosList(),
                  _buildUPAsList(),
                  _buildEnfermeirasList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

String _getUserFirstName() {
  String nomeCompleto = widget.userData['nome_completo'] ?? 
                        widget.userData['nome'] ?? 
                        widget.userData['name'] ?? 
                        'Admin';
  
  if (nomeCompleto.isNotEmpty && nomeCompleto.contains(' ')) {
    return nomeCompleto.split(' ').first;
  }
  
  return nomeCompleto;
}  


Widget _buildUsuariosList() {
  if (_carregandoUsuarios) {
    return const Center(child: CircularProgressIndicator());
  }
  
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
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
                ),
                onChanged: (_) => _buscarUsuarios(),
              ),
            ),

          ],
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                'Total: $_totalUsuariosLista usuários',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ..._usuarios.map((usuario) => _buildUsuarioCard(usuario)),
              const SizedBox(height: 16),
              _buildPagination(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildPagination() {
  if (_totalPages <= 1) return const SizedBox.shrink();
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: _currentPage > 1 ? () => _carregarUsuarios(page: _currentPage - 1) : null,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(width: 8),
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: _accentColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Página $_currentPageUPAs de $_totalPagesUPAs',
    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _accentColor),
  ),
),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: _currentPage < _totalPages ? () => _carregarUsuarios(page: _currentPage + 1) : null,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ],
  );
}

  Widget _buildUsuarioCard(Map<String, dynamic> usuario) {
    final isAdmin = usuario['is_admin'] == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAdmin ? _accentColor : const Color(0xFF3B82F6),
              child: Text(
                usuario['nome_completo'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        title: Text(
          usuario['nome_completo'],
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
        subtitle: Text(
          usuario['email'],
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Admin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _accentColor)),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
              onPressed: () => _editarUsuario(usuario),
            ),
            IconButton(
              icon: const Icon(Icons.visibility, color: Color(0xFF64748B)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminUsuarioDetalhesScreen(
                      usuarioId: usuario['id'],
                      usuarioNome: usuario['nome_completo'],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildDashboard() {
  return FutureBuilder(
    future: Future.wait([
      AuthService().getAdminDashboardStats(),
      AuthService().getAdminEvolucaoGeral(),
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados: ${snapshot.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _carregarEstatisticas();
                  });
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }
      
      final data = snapshot.data![0];
      final evolucaoData = snapshot.data![1];
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _exportarPDF(data, evolucaoData),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Exportar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(data),
            const SizedBox(height: 24),
            _buildDemographicSection(data),
            const SizedBox(height: 24),
            _buildHealthSection(data),
            const SizedBox(height: 24),
            _buildEvolucaoSection(evolucaoData),
            const SizedBox(height: 24),
            _buildChartSection(data),
          ],
        ),
      );
    },
  );
}

int _adminEvolucaoPage = 0;
int _adminEvolucaoPerPage = 5;

Widget _buildStatsRow(Map<String, dynamic> data) {
  return Row(
    children: [
      Expanded(
        child: _buildStatCard(
          'Total Usuários',
          _parseToInt(data['totalUsuarios']),
          Icons.people,
          const Color(0xFF3B82F6),
        ),
      ),
      const SizedBox(width: 16),
    Expanded(
      child: _buildStatCard(
        'Enfermeiras',
        _parseToInt(data['totalEnfermeiras']),
        Icons.medical_services,
        _accentColor,
      ),
    ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildStatCard(
          'Matrículas',
          _parseToInt(data['totalMatriculas']),
          Icons.school,
          const Color(0xFF10B981),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _buildStatCard(
          'UPAs',
          _parseToInt(data['totalUPAs']),
          Icons.local_hospital,
          const Color(0xFFF59E0B),
        ),
      ),
    ],
  );
}

Widget _buildDemographicSection(Map<String, dynamic> data) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.people_outline, size: 20, color: Color(0xFF2C7DA0)),
              SizedBox(width: 8),
              Text('Demografia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Maiores de 18', '${data['maiores18']} usuários', Icons.person, const Color(0xFF3B82F6))),
                  Expanded(child: _buildInfoItem('Menores de 18', '${data['menores18']} usuários', Icons.child_care, const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 16),
              _buildSexoDistribution(data['distribuicaoSexo']),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildHealthSection(Map<String, dynamic> data) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.health_and_safety, size: 20, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Saúde', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildHealthItem('Comorbidade - Câncer', '${data['usuariosComCancer']} usuários', Icons.health_and_safety, const Color(0xFFEF4444))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHealthItem('Comorbidade - Cardiovascular', '${data['usuariosComCardiovascular']} usuários', Icons.favorite, const Color(0xFFEC4899))),
                ],
              ),
              const SizedBox(height: 16),
          _buildHealthItem('Média Score Fagerström', '${_parseToDouble(data['mediaScoreFagestrom']).toStringAsFixed(1)} pontos', Icons.assessment, _accentColor),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEvolucaoSection(Map<String, dynamic> data) {
  final alunosAtivos = data['alunos_ativos'] ?? {};
  final alunosConcluidos = data['alunos_concluidos'] ?? {};
  
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: Color(0xFF2C7DA0)),
              SizedBox(width: 8),
              Text('Evolução dos Alunos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildAdminEvolucaoCard('Alunos Ativos', alunosAtivos, const Color(0xFF3B82F6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAdminEvolucaoCard('Alunos Concluídos', alunosConcluidos, const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 24),
              _buildAdminEvolucaoChart(data),
              const SizedBox(height: 24),
              _buildAdminAlunosDetalhados(data),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildAdminEvolucaoCard(String titulo, Map<String, dynamic> dados, Color cor) {
  final total = _parseToInt(dados['total']);
  final fumando = _parseToInt(dados['fumando']);
  final semFumar = _parseToInt(dados['sem_fumar']);
  final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cor.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cor)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(total.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFF59E0B), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(fumando.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B))),
                    ],
                  ),
                  const Text('Fumando', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(semFumar.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                    ],
                  ),
                  const Text('Sem fumar', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: total > 0 ? semFumar / total : 0,
          backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          'Taxa de sucesso: ${taxaSucesso.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: taxaSucesso >= 50 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
        ),
      ],
    ),
  );
}

Widget _buildAdminEvolucaoChart(Map<String, dynamic> data) {
  final evolucaoAtivos = List<Map<String, dynamic>>.from(data['evolucao_mensal_ativos'] ?? []);
  
  if (evolucaoAtivos.isEmpty) {
    return const Center(child: Text('Sem dados para exibir', style: TextStyle(color: Color(0xFF64748B))));
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Evolução Mensal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      _buildAdminMensalChart(evolucaoAtivos, 'Alunos Ativos'),
    ],
  );
}

Widget _buildAdminMensalChart(List<Map<String, dynamic>> dados, String titulo) {
  final maxValor = dados.fold<int>(0, (max, item) {
    final fumando = _parseToInt(item['fumando']);
    final semFumar = _parseToInt(item['sem_fumar']);
    final total = fumando + semFumar;
    return total > max ? total : max;
  });
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
      const SizedBox(height: 8),
      SizedBox(
        height: 180,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: dados.map((item) {
              final mes = item['mes'] as String;
              final fumando = _parseToInt(item['fumando']).toDouble();
              final semFumar = _parseToInt(item['sem_fumar']).toDouble();
              final total = fumando + semFumar;
              final altura = maxValor > 0 ? (total / maxValor) * 120 : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(total.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 35,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        if (altura > 0)
                          Column(
                            children: [
                              if (semFumar > 0)
                                Container(
                                  width: 35,
                                  height: (semFumar / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              if (fumando > 0)
                                Container(
                                  width: 35,
                                  height: (fumando / total) * altura,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.vertical(
                                      top: semFumar > 0 ? Radius.zero : Radius.circular(6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 45,
                      child: Text(
                        mes.substring(5),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendaItem(const Color(0xFFF59E0B), 'Fumando'),
          const SizedBox(width: 16),
          _buildLegendaItem(const Color(0xFF3B82F6), 'Sem fumar'),
        ],
      ),
    ],
  );
}

Widget _buildAdminAlunosDetalhados(Map<String, dynamic> data) {
  final alunos = List<Map<String, dynamic>>.from(data['alunos_detalhados'] ?? []);
  
  if (alunos.isEmpty) {
    return const SizedBox.shrink();
  }
  
  final totalPages = (alunos.length / _adminEvolucaoPerPage).ceil();
  final startIndex = _adminEvolucaoPage * _adminEvolucaoPerPage;
  final endIndex = startIndex + _adminEvolucaoPerPage > alunos.length ? alunos.length : startIndex + _adminEvolucaoPerPage;
  final alunosPaginados = alunos.sublist(startIndex, endIndex);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Situação Atual dos Alunos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Expanded(child: Text('Aluno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  SizedBox(width: 80, child: Text('Turma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                  SizedBox(width: 80, child: Text('Situação', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                ],
              ),
            ),
            ...alunosPaginados.map((aluno) {
              final ultimaObservacao = aluno['ultima_observacao'];
              final semanasFumando = _parseToInt(aluno['semanas_fumando']);
              final semanasSemFumar = _parseToInt(aluno['semanas_sem_fumar']);
              
              String situacao;
              Color situacaoCor;
              
              if (ultimaObservacao == '2- Sem fumar') {
                situacao = 'Sem fumar';
                situacaoCor = const Color(0xFF3B82F6);
              } else if (ultimaObservacao == '1- Está fumando') {
                situacao = 'Fumando';
                situacaoCor = const Color(0xFFF59E0B);
              } else {
                situacao = 'Sem registro';
                situacaoCor = const Color(0xFF94A3B8);
              }
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(aluno['nome_completo'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(
                            'F: $semanasFumando • SF: $semanasSemFumar',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        aluno['turma_horario']?.split(' - ')[0] ?? '-',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: situacaoCor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          situacao,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: situacaoCor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _adminEvolucaoPage > 0 ? () {
                        setState(() {
                          _adminEvolucaoPage--;
                        });
                      } : null,
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
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_adminEvolucaoPage + 1} de $totalPages',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _accentColor),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _adminEvolucaoPage < totalPages - 1 ? () {
                        setState(() {
                          _adminEvolucaoPage++;
                        });
                      } : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildChartSection(Map<String, dynamic> data) {
  final usuariosPorMes = data['usuariosPorMes'] as List;
  
  if (usuariosPorMes.isEmpty) {
    return Container();
  }
  
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.show_chart, size: 20, color: Color(0xFF2C7DA0)),
              SizedBox(width: 8),
              Text('Matrículas por Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: usuariosPorMes.reversed.toList().isEmpty
                ? const Center(child: Text('Sem dados'))
                : _buildAdminBarChart(usuariosPorMes.reversed.toList()),
          ),
        ),
      ],
    ),
  );
}

Widget _buildAdminBarChart(List<dynamic> dados) {
  List<String> meses = [];
  List<double> valores = [];
  
  for (var item in dados) {
    meses.add(item['mes']);
    double valor = _parseToDouble(item['total']);
    valores.add(valor);
  }
  
  if (valores.isEmpty) {
    return const Center(child: Text('Sem dados', style: TextStyle(color: Color(0xFF64748B))));
  }
  
  final maxValor = valores.reduce((a, b) => a > b ? a : b);
  
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(dados.length, (index) {
      double altura = 0;
      if (maxValor > 0) {
        altura = (valores[index] / maxValor) * 150;
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valores[index].toInt().toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: altura,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(meses[index].toString().substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      );
    }),
  );
}

Widget _buildInfoItem(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildHealthItem(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSexoDistribution(List<dynamic> sexoData) {
  int masculino = 0;
  int feminino = 0;
  int outro = 0;
  
  for (var item in sexoData) {
    final total = _parseToInt(item['total']);
    if (item['sexo'] == 'Masculino') masculino = total;
    else if (item['sexo'] == 'Feminino') feminino = total;
    else outro = total;
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Distribuição por Sexo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _buildSexoBar('Masculino', masculino, const Color(0xFF3B82F6))),
          const SizedBox(width: 12),
          Expanded(child: _buildSexoBar('Feminino', feminino, const Color(0xFFEC4899))),
          const SizedBox(width: 12),
          Expanded(child: _buildSexoBar('Outro', outro, _accentColor)),
        ],
      ),
    ],
  );
}

Widget _buildSexoBar(String label, int total, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(total.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    ),
  );
}

Widget _buildLegendaItem(Color cor, String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        texto,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
    ],
  );
}


int _parseToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed ?? 0;
  }
  return 0;
}

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed ?? 0.0;
  }
  return 0.0;
}

Future<void> _exportarPDF(Map<String, dynamic> data, Map<String, dynamic> evolucaoData) async {
  try {
    final nomeAdmin = widget.userData['nome_completo'] ?? _getUserFirstName();
    await PdfService.gerarRelatorioAdminDashboardCompleto(data, evolucaoData, nomeAdmin);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}


  Widget _buildStatCard(String titulo, int valor, IconData icon, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: cor),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              valor.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _carregarUPAs({int page = 1}) async {
  setState(() {
    _carregandoUPAs = true;
    _currentPageUPAs = page;
  });
  
  try {
    final authService = AuthService();
    final response = await authService.getUPAs(
      page: page,
      limit: 8,
      search: _searchQueryUPAs,
    );
    
    setState(() {
      _upas = List<Map<String, dynamic>>.from(response['upas']);
      _totalPagesUPAs = response['totalPages'];
      _totalUPAsLista = response['total'];
      _carregandoUPAs = false;
    });
  } catch (e) {
    setState(() => _carregandoUPAs = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar UPAs: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}


String _formatarTelefoneExibicao(String? telefone) {
  if (telefone == null || telefone.isEmpty) return 'Telefone não informado';
  String apenasNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
  if (apenasNumeros.length == 10) {
    return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
  } else if (apenasNumeros.length == 11) {
    return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
  }
  return telefone;
}

void _buscarUPAs() {
  setState(() {
    _searchQueryUPAs = _searchUPAsController.text;
    _currentPageUPAs = 1;
  });
  _carregarUPAs(page: 1);
}

void _limparBuscaUPAs() {
  _searchUPAsController.clear();
  setState(() {
    _searchQueryUPAs = '';
    _currentPageUPAs = 1;
  });
  _carregarUPAs(page: 1);
}

void _abrirModalUPA({Map<String, dynamic>? upa}) async {
  final isEditing = upa != null;
  Map<String, dynamic>? dadosUPA = upa;
  
  if (isEditing && upa['endereco'] != null) {
    try {
      final authService = AuthService();
      dadosUPA = await authService.getUPAById(upa['id']);
    } catch (e) {
      print('Erro ao buscar UPA: $e');
    }
  }
  
  final nomeController = TextEditingController(text: dadosUPA?['nome'] ?? '');
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController(text: 'Mogi das Cruzes');
  final telefoneController = MaskedTextController(mask: '(00) 0000-0000', text: dadosUPA?['telefone'] ?? '');
  
  List<Map<String, dynamic>> turmasDisponiveis = [];
  bool carregandoTurmas = true;
  
  if (dadosUPA != null && dadosUPA['endereco'] != null) {
    final enderecoStr = dadosUPA['endereco'].toString();
    
    if (enderecoStr.contains(' - ')) {
      final partes = enderecoStr.split(' - ');
      final ruaNumero = partes[0];
      bairroController.text = partes[1];
      
      if (ruaNumero.contains(',')) {
        final ruaNumeroParts = ruaNumero.split(',');
        ruaController.text = ruaNumeroParts[0].trim();
        if (ruaNumeroParts.length > 1) {
          numeroController.text = ruaNumeroParts[1].trim();
        }
      } else {
        ruaController.text = ruaNumero;
      }
    } else {
      final partes = enderecoStr.split(',');
      if (partes.isNotEmpty) ruaController.text = partes[0].trim();
      if (partes.length > 1) {
        if (partes[1].contains('-')) {
          final numeroBairro = partes[1].split('-');
          numeroController.text = numeroBairro[0].trim();
          if (numeroBairro.length > 1) bairroController.text = numeroBairro[1].trim();
        } else {
          numeroController.text = partes[1].trim();
          if (partes.length > 2) bairroController.text = partes[2].trim();
        }
      }
    }
  }
  
  if (isEditing) {
    try {
      final authService = AuthService();
      final response = await authService.getTurmasPorUPA(upa['id']);
      turmasDisponiveis = List<Map<String, dynamic>>.from(response);
      carregandoTurmas = false;
    } catch (e) {
      print('Erro ao carregar turmas: $e');
      carregandoTurmas = false;
    }
  }
  
  final List<String> horariosPadrao = [
    '24 horas',
    'Segunda a Sexta: 07h às 17h',
    'Segunda a Sexta: 08h às 18h',
    'Segunda a Sexta: 08h às 20h',
    'Segunda a Sexta: 07h às 19h',
    'Segunda a Sábado: 08h às 17h',
    'Segunda a Sábado: 07h às 19h',
    'Domingo a Domingo: 24 horas',
    'Segunda, Quarta e Sexta: 08h às 12h',
    'Terça e Quinta: 13h às 17h',
    'Outro (especificar manualmente)',
  ];
  
  final List<String> diasSemana = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'
  ];
  
  final List<String> horariosTurmas = [
    '08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '16:00 - 18:00', '18:00 - 20:00'
  ];
  
  // Turmas selecionadas
  List<Map<String, dynamic>> turmasSelecionadas = List.from(turmasDisponiveis);
  
  String horarioAtual = dadosUPA?['horario'] ?? '';
  String? horarioSelecionado = horariosPadrao.contains(horarioAtual) ? horarioAtual : null;
  final horarioPersonalizadoController = TextEditingController(text: horarioAtual);
  bool mostrarCampoPersonalizado = !horariosPadrao.contains(horarioAtual) && horarioAtual.isNotEmpty;
  bool isLoading = false;
  bool buscandoCep = false;
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 700,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(isEditing ? Icons.edit : Icons.add, color: const Color(0xFF10B981), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEditing ? 'Editar UPA' : 'Nova UPA',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
                        decoration: const InputDecoration(
                          labelText: 'Nome da UPA',
                          prefixIcon: Icon(Icons.local_hospital),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cepController,
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              decoration: const InputDecoration(
                                labelText: 'CEP',
                                hintText: '00000-000',
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) async {
                                if (value.replaceAll(RegExp(r'[^\d]'), '').length == 8) {
                                  setState(() => buscandoCep = true);
                                  try {
                                    final endereco = await CepService.buscarEndereco(value);
                                    setState(() {
                                      ruaController.text = endereco['logradouro'];
                                      bairroController.text = endereco['bairro'];
                                      cidadeController.text = endereco['cidade'];
                                      buscandoCep = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Endereço encontrado!'), backgroundColor: Color(0xFF10B981), duration: Duration(seconds: 1)),
                                    );
                                  } catch (e) {
                                    setState(() => buscandoCep = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red.shade400),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          if (buscandoCep)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: ruaController,
                            decoration: const InputDecoration(
                              labelText: 'Rua',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                          ),

                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: 
                            TextField(
                              controller: numeroController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Número',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              ),
                            ),

                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                      TextField(
                        controller: bairroController,
                        decoration: const InputDecoration(
                          labelText: 'Bairro',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: cidadeController,
                      enabled: false,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        labelText: 'Cidade',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        suffixIcon: const Icon(Icons.location_city, color: Color(0xFF2C7DA0), size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                      TextField(
                        controller: telefoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Horário de Funcionamento da UPA',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: horarioSelecionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Selecione o horário padrão',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: horariosPadrao.map((horario) {
                        return DropdownMenuItem<String>(
                          value: horario,
                          child: Text(horario, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          horarioSelecionado = value;
                          mostrarCampoPersonalizado = value == 'Outro (especificar manualmente)';
                          if (value != 'Outro (especificar manualmente)') {
                            horarioPersonalizadoController.text = value ?? '';
                          }
                        });
                      },
                    ),
                    
                    if (mostrarCampoPersonalizado) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: horarioPersonalizadoController,
                        decoration: const InputDecoration(
                          labelText: 'Digite o horário personalizado',
                          hintText: 'Ex: Segunda a Domingo: 08h às 22h',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              children: [
                                Icon(Icons.schedule, color: _accentColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Turmas Disponíveis para Matrícula',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                                ),
                              ],
                            ),

                          const SizedBox(height: 12),
                          Text(
                            'Selecione os dias e horários que esta UPA oferecerá turmas',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ...diasSemana.map((dia) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(dia, style: TextStyle(fontWeight: FontWeight.w500)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: horariosTurmas.map((horario) {
                                            String turmaKey = '$dia - $horario';
                                            bool isSelected = turmasSelecionadas.any((t) => t['dia_semana'] == dia && t['horario'] == horario);
                                            
                                            return FilterChip(
                                              label: Text(horario, style: TextStyle(fontSize: 11)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setState(() {
                                                  if (selected) {
                                                    turmasSelecionadas.add({
                                                      'dia_semana': dia,
                                                      'horario': horario,
                                                      'vagas_totais': 4,
                                                      'vagas_ocupadas': 0,
                                                    });
                                                  } else {
                                                    turmasSelecionadas.removeWhere((t) => t['dia_semana'] == dia && t['horario'] == horario);
                                                  }
                                                });
                                              },
                                              backgroundColor: Colors.grey.shade100,
                                              selectedColor: _accentColor.withOpacity(0.2),
                                              checkmarkColor: _accentColor,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 8, color: Colors.grey.shade200),
                              ],
                            );
                          }).toList(),
                        ],
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            onPressed: () async {
                              if (nomeController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nome da UPA é obrigatório'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              
                              if (ruaController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rua é obrigatória'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              
                              if (numeroController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Número é obrigatório'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              
                              if (bairroController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bairro é obrigatório'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              
                              if (telefoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Telefone é obrigatório'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              
                              String horarioFinal = '';
                              if (mostrarCampoPersonalizado) {
                                if (horarioPersonalizadoController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Digite o horário personalizado'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }
                                horarioFinal = horarioPersonalizadoController.text;
                              } else if (horarioSelecionado != null) {
                                horarioFinal = horarioSelecionado!;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Selecione um horário de funcionamento'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              
                              String enderecoCompleto = '${ruaController.text}, ${numeroController.text} - ${bairroController.text}';
                              
                              setState(() => isLoading = true);
                              
                              try {
                                final authService = AuthService();
                                final data = {
                                  'nome': nomeController.text,
                                  'endereco': enderecoCompleto,
                                  'cidade': cidadeController.text,
                                  'telefone': telefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
                                  'horario': horarioFinal,
                                  'turmas': turmasSelecionadas.map((t) => ({
                                    'dia_semana': t['dia_semana'],
                                    'horario': t['horario'],
                                    'vagas_totais': t['vagas_totais'],
                                  })).toList(),
                                };
                                
                                if (isEditing) {
                                  await authService.atualizarUPAComTurmas(upa!['id'], data);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('UPA atualizada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                                  );
                                } else {
                                  await authService.criarUPAComTurmas(data);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('UPA criada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                                  );
                                }
                                
                                Navigator.pop(context);
                                _carregarUPAs(page: _currentPageUPAs);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red.shade400),
                                );
                              } finally {
                                setState(() => isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(isEditing ? Icons.save : Icons.add, size: 18, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(isEditing ? 'Salvar' : 'Criar', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ],
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
        },
      );
    },
  );
}

Future<void> _confirmarDeletarUPA(Map<String, dynamic> upa) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: Text('Tem certeza que deseja excluir a UPA "${upa['nome']}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
            child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  
  if (confirm == true) {
    try {
      final authService = AuthService();
      await authService.deletarUPA(upa['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UPA excluída com sucesso!'), backgroundColor: Color(0xFF10B981)),
      );
      _carregarUPAs(page: _currentPageUPAs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red.shade400),
      );
    }
  }
}

Widget _buildUPAsList() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchUPAsController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, endereço ou cidade...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  suffixIcon: _searchQueryUPAs.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                          onPressed: _limparBuscaUPAs,
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
                ),
                onChanged: (_) => _buscarUPAs(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _abrirModalUPA(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova UPA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: _carregandoUPAs
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchQueryUPAs.isEmpty 
                          ? 'Todas as UPAs'
                          : 'Resultados para: "$_searchQueryUPAs"',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: $_totalUPAsLista unidades',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    ..._upas.map((upa) => _buildUPACard(upa)),
                    const SizedBox(height: 16),
                    _buildPaginacaoUPAs(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    ],
  );
}

Widget _buildUPACard(Map<String, dynamic> upa) {
  final telefoneBruto = upa['telefone'] ?? '';
  final telefoneFormatado = _formatarTelefoneExibicao(telefoneBruto);
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: ListTile(
leading: Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: _accentColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: const Icon(Icons.local_hospital, color: Color(0xFF2C7DA0), size: 24),
),
      title: Text(
        upa['nome'],
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  upa['endereco'] ?? 'Endereço não informado',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.phone, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  telefoneFormatado,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
            onPressed: () => _abrirModalUPA(upa: upa),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
            onPressed: () => _confirmarDeletarUPA(upa),
          ),
        ],
      ),
    ),
  );
}


Future<void> _carregarEnfermeiras() async {
  setState(() => _carregandoEnfermeiras = true);
  try {
    final authService = AuthService();
    final enfermeiras = await authService.getEnfermeiras();
    final upas = await authService.getUPAsLista();
    setState(() {
      _enfermeiras = enfermeiras;
      _upasLista = upas;
      _carregandoEnfermeiras = false;
    });
  } catch (e) {
    setState(() => _carregandoEnfermeiras = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar enfermeiras: $e'), backgroundColor: Colors.red.shade400),
    );
  }
}

void _buscarEnfermeiras() {
  setState(() {
    _searchEnfermeira = _searchEnfermeiraController.text.toLowerCase();
  });
}

void _limparBuscaEnfermeiras() {
  _searchEnfermeiraController.clear();
  setState(() {
    _searchEnfermeira = '';
  });
}

List<Map<String, dynamic>> _getEnfermeirasFiltradas() {
  if (_searchEnfermeira.isEmpty) {
    return _enfermeiras;
  }
  return _enfermeiras.where((e) {
    return e['nome_completo'].toLowerCase().contains(_searchEnfermeira) ||
           (e['upa_nome'] != null && e['upa_nome'].toLowerCase().contains(_searchEnfermeira));
  }).toList();
}

Map<int, List<Map<String, dynamic>>> _agruparEnfermeirasPorUPA(List<Map<String, dynamic>> enfermeiras) {
  Map<int, List<Map<String, dynamic>>> grupos = {};
  
  for (var enfermeira in enfermeiras) {
    int upaId = enfermeira['upa_id'] ?? 0;
    if (!grupos.containsKey(upaId)) {
      grupos[upaId] = [];
    }
    grupos[upaId]!.add(enfermeira);
  }
  
  return grupos;
}

String _getUpaNome(int? upaId) {
  if (upaId == null) return 'Sem UPA vinculada';
  final upa = _upasLista.firstWhere((u) => u['id'] == upaId, orElse: () => {'nome': 'UPA não encontrada'});
  return upa['nome'];
}

void _abrirModalEnfermeira({Map<String, dynamic>? enfermeira}) {
  final isEditing = enfermeira != null;
  final nomeController = TextEditingController(text: enfermeira?['nome_completo'] ?? '');
  final emailController = TextEditingController(text: enfermeira?['email'] ?? '');
  final telefoneController = MaskedTextController(
    mask: '(00) 00000-0000',
    text: enfermeira?['telefone'] ?? '',
  );
  final senhaController = TextEditingController();
  int? upaIdSelecionado = enfermeira?['upa_id'];
  bool isLoading = false;
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C7DA0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(isEditing ? Icons.edit : Icons.person_add, color: const Color(0xFF2C7DA0), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing ? 'Editar Enfermeira' : 'Nova Enfermeira',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  const SizedBox(height: 16),
                 TextField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: upaIdSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'UPA Vinculada',
                            prefixIcon: Icon(Icons.local_hospital),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text('Selecione uma UPA')),
                      ..._upasLista.map((upa) => DropdownMenuItem<int>(
                        value: upa['id'],
                        child: Text(upa['nome']),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        upaIdSelecionado = value;
                      });
                    },
                  ),
                  if (!isEditing) ...[
                    const SizedBox(height: 16),
                     TextField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                  ],
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
                          onPressed: () async {
                            if (nomeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nome é obrigatório'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            if (emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Email é obrigatório'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            if (!isEditing && senhaController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Senha é obrigatória'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            
                            setState(() => isLoading = true);
                            
                            try {
                              final authService = AuthService();
                              final telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                              
                              if (isEditing) {
                                await authService.atualizarEnfermeira(enfermeira!['id'], {
                                  'nomeCompleto': nomeController.text,
                                  'email': emailController.text,
                                  'telefone': telefoneLimpo,
                                  'upaId': upaIdSelecionado,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enfermeira atualizada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                                );
                              } else {
                                await authService.criarEnfermeira({
                                  'nomeCompleto': nomeController.text,
                                  'email': emailController.text,
                                  'senha': senhaController.text,
                                  'telefone': telefoneLimpo,
                                  'upaId': upaIdSelecionado,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enfermeira criada com sucesso!'), backgroundColor: Color(0xFF10B981)),
                                );
                              }
                              
                              Navigator.pop(context);
                              _carregarEnfermeiras();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red.shade400),
                              );
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                         style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(isEditing ? Icons.save : Icons.add, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(isEditing ? 'Salvar' : 'Criar', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

Future<void> _confirmarDeletarEnfermeira(Map<String, dynamic> enfermeira) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: Text('Tem certeza que deseja excluir a enfermeira "${enfermeira['nome_completo']}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
            child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  
  if (confirm == true) {
    try {
      final authService = AuthService();
      await authService.deletarEnfermeira(enfermeira['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enfermeira excluída com sucesso!'), backgroundColor: Color(0xFF10B981)),
      );
      _carregarEnfermeiras();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red.shade400),
      );
    }
  }
}

Widget _buildEnfermeirasList() {
  final enfermeirasFiltradas = _getEnfermeirasFiltradas();
  final grupos = _agruparEnfermeirasPorUPA(enfermeirasFiltradas);
  
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchEnfermeiraController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome da enfermeira ou UPA...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  suffixIcon: _searchEnfermeira.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                          onPressed: _limparBuscaEnfermeiras,
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
                ),
                onChanged: (_) => _buscarEnfermeiras(),
              ),
            ),
            const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _abrirModalEnfermeira(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova Enfermeira'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
      Expanded(
        child: _carregandoEnfermeiras
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchEnfermeira.isEmpty 
                          ? 'Enfermeiras Cadastradas'
                          : 'Resultados para: "$_searchEnfermeira"',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${enfermeirasFiltradas.length} enfermeiras',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    ...grupos.entries.map((entry) {
                      final upaId = entry.key;
                      final upaNome = _getUpaNome(upaId == 0 ? null : upaId);
                      final enfermeirasDaUPA = entry.value;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_hospital, size: 16, color: _accentColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    upaNome,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${enfermeirasDaUPA.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ...enfermeirasDaUPA.map((enfermeira) => _buildEnfermeiraCard(enfermeira)),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                    if (grupos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'Nenhuma enfermeira encontrada',
                            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    ],
  );
}

Widget _buildEnfermeiraCard(Map<String, dynamic> enfermeira) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: ListTile(
leading: Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: _accentColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: const Icon(Icons.local_hospital, color: Color(0xFF2C7DA0), size: 24),
),
      title: Text(
        enfermeira['nome_completo'],
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            enfermeira['email'],
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            'UPA: ${enfermeira['upa_nome'] ?? 'Não vinculada'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
            onPressed: () => _abrirModalEnfermeira(enfermeira: enfermeira),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
            onPressed: () => _confirmarDeletarEnfermeira(enfermeira),
          ),
        ],
      ),
    ),
  );
}



Widget _buildPaginacaoUPAs() {
  if (_totalPagesUPAs <= 1) return const SizedBox.shrink();
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: _currentPageUPAs > 1 ? () => _carregarUPAs(page: _currentPageUPAs - 1) : null,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Página $_currentPage de $_totalPages',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _accentColor),
            ),
          ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: _currentPageUPAs < _totalPagesUPAs ? () => _carregarUPAs(page: _currentPageUPAs + 1) : null,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ],
  );
}
}