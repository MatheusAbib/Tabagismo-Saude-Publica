import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class MeusDadosModal {
static void show(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 800;
  final isSmallMobile = MediaQuery.of(context).size.width < 480;
  final Color accentColor = const Color(0xFF1F4E6E);
  final Color successColor = const Color(0xFF2E8B6A);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.only(
          left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          top: 20,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: isMobile ? double.infinity : (MediaQuery.of(context).size.width > 800 ? 500 : MediaQuery.of(context).size.width * 0.85),
          constraints: BoxConstraints(maxWidth: 750),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _MeusDadosModalContent(
              isMobile: isMobile,
              isSmallMobile: isSmallMobile,
              accentColor: accentColor,
              successColor: successColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MeusDadosModalContent extends StatefulWidget {
  final bool isMobile;
  final bool isSmallMobile;
  final Color accentColor;
  final Color successColor;

  const _MeusDadosModalContent({
    Key? key,
    required this.isMobile,
    required this.isSmallMobile,
    required this.accentColor,
    required this.successColor,
  }) : super(key: key);

  @override
  _MeusDadosModalContentState createState() => _MeusDadosModalContentState();
}

class _MeusDadosModalContentState extends State<_MeusDadosModalContent> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String _sexoSelecionado = '';
  String _cpf = '';
  String _dataNascimento = '';
  String _tipoUsuario = 'comum';
  bool _isAdmin = false;
  String _nomeOriginal = '';
  String _emailOriginal = '';
  String _telefoneOriginal = '';
  String _sexoOriginal = '';

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final MaskedTextController _telefoneController = MaskedTextController(mask: '(00) 00000-0000');

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

  String _formatarData(dynamic data) {
    if (data == null || data.toString().isEmpty) return '-';
    try {
      String dataStr = data.toString();
      if (dataStr.contains('T')) {
        dataStr = dataStr.split('T')[0];
      }
      final partes = dataStr.split('-');
      if (partes.length != 3) return dataStr;
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    } catch (e) {
      return data.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

Future<void> _carregarDados() async {
  setState(() => _isLoading = true);
  try {
    final authService = AuthService();
    final response = await authService.getUserData();
    print('RESPOSTA COMPLETA: $response');
    final userData = response['user'];
    print('USER DATA: $userData');
    _nomeController.text = userData['nomeCompleto'] ?? '';
    _nomeOriginal = userData['nomeCompleto'] ?? '';
    _sexoSelecionado = userData['sexo'] ?? '';
    _sexoOriginal = userData['sexo'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _isAdmin = userData['is_admin'] == 1;
    _emailOriginal = userData['email'] ?? '';
    _telefoneController.text = userData['telefone'] != null 
        ? _formatTelefone(userData['telefone']) 
        : '';
    _telefoneOriginal = userData['telefone'] ?? '';
    _cpf = userData['cpf'] != null ? _formatCpf(userData['cpf']) : 'Não informado';
    _tipoUsuario = userData['tipo_usuario'] ?? 'comum';
    if (userData['dataNascimento'] != null) {
      _dataNascimento = _formatarData(userData['dataNascimento']);
    } else {
      _dataNascimento = '-';
    }
  } catch (e) {
    ToastService.showError(context, 'Erro ao carregar dados: $e');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
  bool _hasChanges() {
    if (_nomeController.text.trim() != _nomeOriginal) return true;
    if (_emailController.text.trim() != _emailOriginal) return true;
    String telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (telefoneLimpo != _telefoneOriginal) return true;
    if (_tipoUsuario == 'comum' && _sexoSelecionado != _sexoOriginal) return true;
    return false;
  }

  bool _canSave() {
    if (_nomeController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) return false;
    String telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (telefoneLimpo.isNotEmpty && telefoneLimpo.length != 11) return false;
    if (!_hasChanges()) return false;
    return true;
  }

bool _isUsuarioComum() {
  return _tipoUsuario == 'comum' && !_isAdmin;
}

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      floatingLabelStyle: TextStyle(fontWeight: FontWeight.w600, color: widget.accentColor),
      prefixIcon: Icon(icon, color: widget.accentColor, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: widget.accentColor, width: 1.5),
      ),
      filled: true,
      fillColor: _isEditing ? Colors.grey.shade50 : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _abrirAlterarSenha() {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    
    bool _hasMinLength = false;
    bool _hasSpecialChar = false;
    bool _hasUpperCase = false;
    bool _hasNumber = false;

    void _validatePassword() {
      setState(() {
        final senha = newPasswordController.text;
        _hasMinLength = senha.length >= 6;
        _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(senha);
        _hasUpperCase = RegExp(r'[A-Z]').hasMatch(senha);
        _hasNumber = RegExp(r'[0-9]').hasMatch(senha);
      });
    }

    newPasswordController.addListener(_validatePassword);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool senhaCanSave() {
            if (currentPasswordController.text.isEmpty) return false;
            if (newPasswordController.text.isEmpty) return false;
            if (newPasswordController.text.length < 6) return false;
            if (newPasswordController.text != confirmPasswordController.text) return false;
            if (!_hasSpecialChar || !_hasUpperCase || !_hasNumber) return false;
            return true;
          }

          bool _hasStartedTyping = newPasswordController.text.isNotEmpty;

          Widget _buildStrengthItem(String label, bool isValid) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: isValid ? Colors.green : Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isValid ? Colors.green.shade700 : Colors.grey.shade500,
                    fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            );
          }

          Widget _buildPasswordStrengthIndicator() {
            bool senhasConferem = confirmPasswordController.text.isNotEmpty && 
                                   newPasswordController.text == confirmPasswordController.text;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                alignment: WrapAlignment.start,
                children: [
                  _buildStrengthItem('Mínimo 6 caracteres', _hasMinLength),
                  _buildStrengthItem('Letra maiúscula', _hasUpperCase),
                  _buildStrengthItem('Número', _hasNumber),
                  _buildStrengthItem('Caractere especial', _hasSpecialChar),
                  _buildStrengthItem('Senhas coincidem', senhasConferem),
                ],
              ),
            );
          }

          return Dialog(
            insetPadding: EdgeInsets.all(isSmallMobile ? 4 : 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
              width: isMobile ? MediaQuery.of(context).size.width * 0.92 : 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_outline, color: Color(0xFF1F4E6E), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isSmallMobile ? 'Alterar Senha' : 'Alterar Senha',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 16 : 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    decoration: _buildInputDecoration('Senha Atual', Icons.lock_outline),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    decoration: _buildInputDecoration('Nova Senha', Icons.lock_reset),
                  ),
                  if (_hasStartedTyping) ...[
                    const SizedBox(height: 12),
                    _buildPasswordStrengthIndicator(),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    decoration: _buildInputDecoration('Confirmar Nova Senha', Icons.verified_user),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading || !senhaCanSave() ? null : () async {
                            setState(() => isLoading = true);
                            try {
                              final authService = AuthService();
                              await authService.changeUserPassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                ToastService.showSuccess(context, 'Senha alterada com sucesso!');
                              }
                            } catch (e) {
                              if (mounted) {
                                ToastService.showError(context, 'Erro ao alterar senha: $e');
                              }
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: senhaCanSave() ? widget.successColor : Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save,
                                      size: 16,
                                      color: senhaCanSave() ? Colors.white : Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Salvar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: senhaCanSave() ? Colors.white : Colors.grey.shade500,
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
      ),
    );
  }

@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Container(
    padding: EdgeInsets.all(widget.isSmallMobile ? 16 : 24),
    width: widget.isMobile ? MediaQuery.of(context).size.width * 0.92 : 480,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (!_isEditing)
            _buildVisualizacao()
          else
            _buildEdicao(),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_outline, color: Color(0xFF1F4E6E), size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          widget.isSmallMobile ? 'Meus Dados' : 'Meus Dados',
          style: TextStyle(
            fontSize: widget.isSmallMobile ? 16 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildVisualizacao() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.person, 'Nome', _nomeController.text),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email, 'Email', _emailController.text),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, 'Telefone', _telefoneController.text),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.assignment_ind, 'CPF', _cpf),
              if (_isUsuarioComum()) ...[
                const SizedBox(height: 12),
                _buildInfoRow(Icons.wc, 'Sexo', _sexoSelecionado.isEmpty ? 'Não informado' : _sexoSelecionado),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.cake, 'Data Nascimento', _dataNascimento),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text(
                  'Editar Dados',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4E6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _abrirAlterarSenha,
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text(
                  'Alterar Senha',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.accentColor),
                  foregroundColor: widget.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Não informado' : value,
            style: const TextStyle(
              fontSize: 13,
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

  Widget _buildEdicao() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _nomeController,
                onChanged: (_) => setState(() {}),
                decoration: _buildInputDecoration('Nome Completo', Icons.person),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                onChanged: (_) => setState(() {}),
                decoration: _buildInputDecoration('Email', Icons.email),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assignment_ind, color: Colors.grey.shade600, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CPF',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            _cpf,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration: _buildInputDecoration('Telefone', Icons.phone),
              ),
              if (_isUsuarioComum()) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sexoSelecionado.isEmpty ? null : _sexoSelecionado,
                  decoration: _buildInputDecoration('Sexo', Icons.wc),
                  items: ['Masculino', 'Feminino', 'Outro'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _sexoSelecionado = value ?? ''),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake, color: Colors.grey.shade600, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Nascimento',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              _dataNascimento,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving || !_canSave() ? null : () async {
                  setState(() => _isSaving = true);
                  try {
                    final authService = AuthService();
                    String telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                    Map<String, dynamic> data = {
                      'nomeCompleto': _nomeController.text,
                      'email': _emailController.text,
                      'telefone': telefoneLimpo,
                    };
                    if (_isUsuarioComum()) {
                      data['sexo'] = _sexoSelecionado;
                    }
                    await authService.updateUserData(data);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ToastService.showSuccess(context, 'Dados atualizados com sucesso!');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastService.showError(context, 'Erro ao atualizar dados: $e');
                    }
                  } finally {
                    setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSave() ? widget.successColor : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            size: 16,
                            color: _canSave() ? Colors.white : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _canSave() ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            
          ],
        ),
      ],
    );
  }
}