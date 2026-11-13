import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class MeusDadosModal {
  static void show(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 800;
    final isSmallMobile = size.width < 480;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFDF9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 8 : (isMobile ? 12 : 20),
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE6E5DF)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.sizeOf(dialogContext).height - 40,
            ),
            child: _MeusDadosModalContent(
              isMobile: isMobile,
              isSmallMobile: isSmallMobile,
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

  const _MeusDadosModalContent({
    required this.isMobile,
    required this.isSmallMobile,
  });

  @override
  State<_MeusDadosModalContent> createState() =>
      _MeusDadosModalContentState();
}

class _MeusDadosModalContentState extends State<_MeusDadosModalContent> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _pageBackground = Color(0xFFFAF8F3);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _success = Color(0xFF2E8B6A);
  static const Color _danger = Color(0xFFC65D47);

  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isAdmin = false;

  String _sexoSelecionado = '';
  String _cpf = '';
  String _dataNascimento = '';
  String _tipoUsuario = 'comum';

  String _nomeOriginal = '';
  String _emailOriginal = '';
  String _telefoneOriginal = '';
  String _sexoOriginal = '';

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final MaskedTextController _telefoneController = MaskedTextController(
    mask: '(00) 00000-0000',
  );

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  String _somenteNumeros(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }

  String _formatTelefone(String telefone) {
    final numeros = _somenteNumeros(telefone);

    if (numeros.length == 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }

    return telefone;
  }

  String _formatCpf(String cpf) {
    final numeros = _somenteNumeros(cpf);

    if (numeros.length == 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
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

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.getUserData();
      final userData = response['user'];

      if (!mounted) return;

      setState(() {
        _nomeController.text = userData['nomeCompleto'] ?? '';
        _nomeOriginal = userData['nomeCompleto'] ?? '';

        _emailController.text = userData['email'] ?? '';
        _emailOriginal = userData['email'] ?? '';

        _sexoSelecionado = userData['sexo'] ?? '';
        _sexoOriginal = userData['sexo'] ?? '';

        _isAdmin = userData['is_admin'] == 1;
        _tipoUsuario = userData['tipo_usuario'] ?? 'comum';

        final telefone = userData['telefone']?.toString() ?? '';

        _telefoneController.text = _formatTelefone(telefone);
        _telefoneOriginal = _somenteNumeros(telefone);

        _cpf = userData['cpf'] != null
            ? _formatCpf(userData['cpf'].toString())
            : 'Não informado';

        _dataNascimento = _formatarData(userData['dataNascimento']);
      });
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Erro ao carregar dados: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isUsuarioComum() {
    return _tipoUsuario == 'comum' && !_isAdmin;
  }

  bool _hasChanges() {
    if (_nomeController.text.trim() != _nomeOriginal) return true;
    if (_emailController.text.trim() != _emailOriginal) return true;

    if (_somenteNumeros(_telefoneController.text) != _telefoneOriginal) {
      return true;
    }

    if (_isUsuarioComum() && _sexoSelecionado != _sexoOriginal) {
      return true;
    }

    return false;
  }

  bool _canSave() {
    if (_nomeController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;

    if (!RegExp(
      r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      return false;
    }

    final telefone = _somenteNumeros(_telefoneController.text);

    if (telefone.isNotEmpty && telefone.length != 11) return false;

    return _hasChanges();
  }

  void _cancelarEdicao() {
    setState(() {
      _nomeController.text = _nomeOriginal;
      _emailController.text = _emailOriginal;
      _telefoneController.text = _formatTelefone(_telefoneOriginal);
      _sexoSelecionado = _sexoOriginal;
      _isEditing = false;
    });
  }

  Future<void> _salvarDados() async {
    if (_isSaving || !_canSave()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final telefone = _somenteNumeros(_telefoneController.text);

      final Map<String, dynamic> data = {
        'nomeCompleto': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': telefone,
      };

      if (_isUsuarioComum()) {
        data['sexo'] = _sexoSelecionado;
      }

      await _authService.updateUserData(data);

      if (!mounted) return;

      ToastService.showSuccess(
        context,
        'Dados atualizados com sucesso!',
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Erro ao atualizar dados: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
  ) {
    final radius = BorderRadius.circular(10);

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 13,
        color: _secondary,
        fontFamily: 'Inter',
      ),
      floatingLabelStyle: const TextStyle(
        color: _primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      prefixIcon: Icon(
        icon,
        color: _primary,
        size: 19,
      ),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFFE5E7E8),
      disabledForegroundColor: _secondary,
      elevation: 0,
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    );
  }

  ButtonStyle _outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: _primary,
      side: const BorderSide(color: _border),
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildReadonlyField(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _secondary,
            size: 19,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _secondary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Não informado' : value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _foreground,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_outline,
            size: 15,
            color: _secondary,
          ),
        ],
      ),
    );
  }

  void _abrirAlterarSenha() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isLoading = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final senha = newPasswordController.text;

            final hasMinLength = senha.length >= 6;
            final hasSpecialChar = RegExp(
              r'[!@#$%^&*(),.?":{}|<>]',
            ).hasMatch(senha);
            final hasUpperCase = RegExp(r'[A-Z]').hasMatch(senha);
            final hasNumber = RegExp(r'[0-9]').hasMatch(senha);

            final senhasConferem =
                confirmPasswordController.text.isNotEmpty &&
                senha == confirmPasswordController.text;

            final canSave =
                currentPasswordController.text.isNotEmpty &&
                hasMinLength &&
                hasSpecialChar &&
                hasUpperCase &&
                hasNumber &&
                senhasConferem;

            Widget strengthItem(String label, bool valid) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    valid
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    color: valid ? _success : _secondary,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          valid ? FontWeight.w600 : FontWeight.w400,
                      color: valid ? _success : _secondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              );
            }

            Widget passwordField({
              required String label,
              required TextEditingController controller,
              required IconData icon,
              required bool obscure,
              required VoidCallback toggle,
            }) {
              return TextField(
                controller: controller,
                obscureText: obscure,
                onChanged: (_) => setDialogState(() {}),
                style: const TextStyle(
                  fontSize: 13,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
                decoration: _buildInputDecoration(
                  label,
                  icon,
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: toggle,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: _secondary,
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: _background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: _border),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 450,
                  maxHeight:
                      MediaQuery.sizeOf(dialogContext).height - 40,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(dialogContext).width < 400
                        ? 16
                        : 22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _softBlue,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: _primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Expanded(
                            child: Text(
                              'Alterar Senha',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _foreground,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close,
                              color: _secondary,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Defina uma nova senha para manter sua conta protegida.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: _secondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 20),
                      passwordField(
                        label: 'Senha Atual',
                        controller: currentPasswordController,
                        icon: Icons.lock_outline,
                        obscure: obscureCurrent,
                        toggle: () {
                          setDialogState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      passwordField(
                        label: 'Nova Senha',
                        controller: newPasswordController,
                        icon: Icons.lock_reset_outlined,
                        obscure: obscureNew,
                        toggle: () {
                          setDialogState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                      ),
                      if (senha.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _pageBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Requisitos da senha',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _foreground,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 14,
                                runSpacing: 10,
                                children: [
                                  strengthItem(
                                    'Mínimo 6 caracteres',
                                    hasMinLength,
                                  ),
                                  strengthItem(
                                    'Letra maiúscula',
                                    hasUpperCase,
                                  ),
                                  strengthItem(
                                    'Número',
                                    hasNumber,
                                  ),
                                  strengthItem(
                                    'Caractere especial',
                                    hasSpecialChar,
                                  ),
                                  strengthItem(
                                    'Senhas coincidem',
                                    senhasConferem,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      passwordField(
                        label: 'Confirmar Nova Senha',
                        controller: confirmPasswordController,
                        icon: Icons.verified_user_outlined,
                        obscure: obscureConfirm,
                        toggle: () {
                          setDialogState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: _outlineButtonStyle(),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isLoading || !canSave
                                  ? null
                                  : () async {
                                      setDialogState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        await _authService
                                            .changeUserPassword(
                                          currentPasswordController.text,
                                          newPasswordController.text,
                                        );

                                        if (!dialogContext.mounted) return;

                                        Navigator.pop(dialogContext);

                                        if (mounted) {
                                          ToastService.showSuccess(
                                            context,
                                            'Senha alterada com sucesso!',
                                          );
                                        }
                                      } catch (e) {
                                        if (dialogContext.mounted) {
                                          ToastService.showError(
                                            dialogContext,
                                            'Erro ao alterar senha: $e',
                                          );
                                        }
                                      } finally {
                                        if (dialogContext.mounted) {
                                          setDialogState(() {
                                            isLoading = false;
                                          });
                                        }
                                      }
                                    },
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save_outlined,
                                      size: 17,
                                    ),
                              label: Text(
                                isLoading ? 'Salvando...' : 'Salvar',
                              ),
                              style: _primaryButtonStyle(),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            color: _primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: Container(
        color: _background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(
              height: 1,
              thickness: 1,
              color: _border,
            ),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  widget.isSmallMobile ? 14 : 22,
                ),
                child: _isEditing
                    ? _buildEdicao()
                    : _buildVisualizacao(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmallMobile ? 14 : 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_outline,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Meus Dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _foreground,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSaving ? null : () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.close,
                  color: _secondary,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizacao() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            widget.isSmallMobile ? 13 : 16,
          ),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.person_outline,
                'Nome',
                _nomeController.text,
              ),
              const Divider(height: 23, color: _border),
              _buildInfoRow(
                Icons.email_outlined,
                'Email',
                _emailController.text,
              ),
              const Divider(height: 23, color: _border),
              _buildInfoRow(
                Icons.phone_outlined,
                'Telefone',
                _telefoneController.text,
              ),
              const Divider(height: 23, color: _border),
              _buildInfoRow(
                Icons.assignment_ind_outlined,
                'CPF',
                _cpf,
              ),
              if (_isUsuarioComum()) ...[
                const Divider(height: 23, color: _border),
                _buildInfoRow(
                  Icons.wc_outlined,
                  'Sexo',
                  _sexoSelecionado.isEmpty
                      ? 'Não informado'
                      : _sexoSelecionado,
                ),
                const Divider(height: 23, color: _border),
                _buildInfoRow(
                  Icons.cake_outlined,
                  'Data Nascimento',
                  _dataNascimento,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                ),
                label: const Text(
                  'Editar Dados',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: _primaryButtonStyle(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _abrirAlterarSenha,
                icon: const Icon(
                  Icons.lock_outline,
                  size: 17,
                ),
                label: const Text(
                  'Alterar Senha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: _outlineButtonStyle(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pageBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 17,
            color: _secondary,
          ),
        ),
        const SizedBox(width: 11),
        SizedBox(
          width: widget.isSmallMobile ? 76 : 110,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _secondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              value.isEmpty ? 'Não informado' : value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _foreground,
                fontFamily: 'Inter',
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEdicao() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            widget.isSmallMobile ? 13 : 16,
          ),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              TextField(
                controller: _nomeController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 13,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
                decoration: _buildInputDecoration(
                  'Nome Completo',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 13,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
                decoration: _buildInputDecoration(
                  'Email',
                  Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 12),
              _buildReadonlyField(
                'CPF',
                _cpf,
                Icons.assignment_ind_outlined,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 13,
                  color: _foreground,
                  fontFamily: 'Inter',
                ),
                decoration: _buildInputDecoration(
                  'Telefone',
                  Icons.phone_outlined,
                ),
              ),
              if (_isUsuarioComum()) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sexoSelecionado.isEmpty
                      ? null
                      : _sexoSelecionado,
                  isExpanded: true,
                  dropdownColor: _surface,
                  decoration: _buildInputDecoration(
                    'Sexo',
                    Icons.wc_outlined,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: _foreground,
                    fontFamily: 'Inter',
                  ),
                  items: [
                    'Masculino',
                    'Feminino',
                    'Outro',
                  ].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sexoSelecionado = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildReadonlyField(
                  'Data Nascimento',
                  _dataNascimento,
                  Icons.cake_outlined,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _cancelarEdicao,
                style: _outlineButtonStyle(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving || !_canSave()
                    ? null
                    : _salvarDados,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save_outlined,
                        size: 17,
                      ),
                label: Text(
                  _isSaving ? 'Salvando...' : 'Salvar',
                ),
                style: _primaryButtonStyle(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}