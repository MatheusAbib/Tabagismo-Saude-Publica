import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/models/user.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/utils/validators.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/screens/admin_screen.dart';
import 'package:tabagismo_app/screens/enfermeira_screen.dart';

class AuthModal extends StatefulWidget {
  final int initialTab;
  final ValueNotifier<int> tabIndexNotifier = ValueNotifier(0);
   AuthModal({super.key, this.initialTab = 0});

  @override
  State<AuthModal> createState() => _AuthModalState();
}


class _AuthModalState extends State<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<int> tabIndexNotifier = ValueNotifier(0); 
  final _authService = AuthService();
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Color _accentColor = const Color(0xFF1F4E6E);

  TextEditingController _loginEmailController = TextEditingController();
  TextEditingController _loginSenhaController = TextEditingController();

  TextEditingController _cadastroNomeController = TextEditingController();
  TextEditingController _cadastroEmailController = TextEditingController();
  TextEditingController _cadastroSenhaController = TextEditingController();
  TextEditingController _cadastroConfirmSenhaController = TextEditingController();
  TextEditingController _cadastroCpfController = MaskedTextController(mask: '000.000.000-00');
  TextEditingController _cadastroTelefoneController = MaskedTextController(mask: '(00) 00000-0000');

  String? _sexoSelecionado;
  DateTime? _dataNascimento;

  bool _obscureText = true;
  bool _obscureConfirmText = true;

  bool _hasMinLength = false;
  bool _hasSpecialChar = false;
  bool _hasUpperCase = false;
  bool _hasNumber = false;
  bool _hasStartedTyping = false;

  String _cpfError = '';
  String _emailError = '';

@override
void initState() {
  super.initState();
  _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab,
  );
  widget.tabIndexNotifier.value = widget.initialTab;
  _tabController.addListener(() {
    widget.tabIndexNotifier.value = _tabController.index;
  });
  
  _cadastroSenhaController.addListener(_validatePassword);
  _cadastroSenhaController.addListener(() {
    setState(() {
      _hasStartedTyping = _cadastroSenhaController.text.isNotEmpty;
    });
  });
  _cadastroConfirmSenhaController.addListener(() {
    setState(() {});
  });
  _cadastroCpfController.addListener(_validateCpf);
  _cadastroEmailController.addListener(_validateEmail);
}

void _validatePassword() {
  setState(() {
    final senha = _cadastroSenhaController.text;
    _hasMinLength = senha.length >= 6;
    _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(senha);
    _hasUpperCase = RegExp(r'[A-Z]').hasMatch(senha);
    _hasNumber = RegExp(r'[0-9]').hasMatch(senha);
  });
}

void _validateCpf() {
  setState(() {
    final cpfLimpo = _cadastroCpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfLimpo.isEmpty) {
      _cpfError = '';
    } else if (cpfLimpo.length < 11) {
      _cpfError = 'CPF deve ter 11 dígitos';
    } else if (!_isValidCpf(cpfLimpo)) {
      _cpfError = 'CPF inválido';
    } else {
      _cpfError = '';
    }
  });
}

void _validateEmail() {
  setState(() {
    final email = _cadastroEmailController.text;
    if (email.isNotEmpty && !_isEmailValid(email)) {
      _emailError = 'Email inválido';
    } else {
      _emailError = '';
    }
  });
}

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

bool _isRegisterFormValid() {
  final nome = _cadastroNomeController.text.isNotEmpty;
  final email = _cadastroEmailController.text.isNotEmpty && _emailError.isEmpty && _isEmailValid(_cadastroEmailController.text);
  final cpf = _cadastroCpfController.text.replaceAll(RegExp(r'[^\d]'), '').length == 11 && _cpfError.isEmpty;
  final telefone = _cadastroTelefoneController.text.replaceAll(RegExp(r'[^\d]'), '').length == 11;
  final sexo = _sexoSelecionado != null;
  final dataNascimento = _dataNascimento != null;
  final senhaValida = _hasMinLength && _hasSpecialChar && _hasUpperCase && _hasNumber;
  final confirmSenha = _cadastroConfirmSenhaController.text == _cadastroSenhaController.text && _cadastroConfirmSenhaController.text.isNotEmpty;
  
  return nome && email && cpf && telefone && sexo && dataNascimento && senhaValida && confirmSenha;
}

@override
void dispose() {
  _tabController.dispose();
  _loginEmailController.dispose();
  _loginSenhaController.dispose();
  _cadastroNomeController.dispose();
  _cadastroEmailController.dispose();
  _cadastroSenhaController.dispose();
  _cadastroConfirmSenhaController.dispose();
  _cadastroCpfController.dispose();
  _cadastroTelefoneController.dispose();
  _loginEmailController.removeListener(_validateEmail);
  _loginSenhaController.removeListener(_validatePassword);
  _cadastroSenhaController.removeListener(_validatePassword);
  _cadastroCpfController.removeListener(_validateCpf);
  _cadastroEmailController.removeListener(_validateEmail);
  super.dispose();
}

  Future<void> _selectDate(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        currentDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
        selectedDayHighlightColor: const Color(0xFF1F4E6E),
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        cancelButton: const Text('Cancelar'),
        okButton: const Text('Confirmar'),
      ),
      dialogSize: const Size(350, 450),
      value: [
        _dataNascimento ?? DateTime.now().subtract(const Duration(days: 18 * 365))
      ],
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _dataNascimento = results.first;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

Future<void> _login() async {
  if (_loginEmailController.text.isEmpty || _loginSenhaController.text.isEmpty) {
    ToastService.showError(context, 'Preencha todos os campos');
    return;
  }
  setState(() => _isLoading = true);
  try {
    final response = await _authService.login(
      _loginEmailController.text.trim(),
      _loginSenhaController.text.trim(),
    );
    if (response['token'] != null) {
      final userData = response['user'];
      final nome = userData['nomeCompleto']?.split(' ').first ?? 'Usuário';
      
      Navigator.pop(context);
      
      ToastService.showSuccess(context, 'Bem-vindo(a) de volta, $nome!');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            final tipoUsuario = userData['tipo_usuario'] ?? 'comum';
            final isAdmin = userData['is_admin'] == 1;
            
            if (isAdmin || tipoUsuario == 'admin') {
              return AdminScreen(userData: userData);
            } else if (tipoUsuario == 'enfermeira') {
              return EnfermeiraScreen(userData: userData);
            } else {
              return HomeScreen(userData: userData);
            }
          },
        ),
      );
    } else {
      ToastService.showError(context, 'Email ou senha inválidos');
    }
  } catch (e) {
    String mensagem = e.toString().replaceAll('Exception: ', '');
    if (mensagem.contains('401') || mensagem.contains('Unauthorized')) {
      ToastService.showError(context, 'Email ou senha inválidos');
    } else {
      ToastService.showError(context, 'Erro ao fazer login: $mensagem');
    }
  } finally {
    setState(() => _isLoading = false);
  }
}
Future<void> _register() async {
  if (_registerFormKey.currentState!.validate()) {
    if (_cadastroSenhaController.text != _cadastroConfirmSenhaController.text) {
      ToastService.showError(context, 'As senhas não coincidem');
      return;
    }
    if (_sexoSelecionado == null) {
      ToastService.showWarning(context, 'Selecione o sexo');
      return;
    }
    if (_dataNascimento == null) {
      ToastService.showWarning(context, 'Selecione a data de nascimento');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = User(
        nomeCompleto: _cadastroNomeController.text,
        sexo: _sexoSelecionado!,
        dataNascimento: _dataNascimento!,
        idade: Validators.calcularIdade(_dataNascimento!),
        email: _cadastroEmailController.text,
        senha: _cadastroSenhaController.text,
        cpf: _cadastroCpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
        telefone: _cadastroTelefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
      );

      await _authService.register(user);
      ToastService.showSuccess(context, 'Cadastro realizado com sucesso!');

      _tabController.animateTo(0);
      _clearRegisterFields();
    } catch (e) {
      String mensagem = e.toString();
      if (mensagem.contains('CPF já cadastrado')) {
        setState(() => _cpfError = 'CPF já cadastrado');
      } else if (mensagem.contains('Email já cadastrado')) {
        setState(() => _emailError = 'Email já cadastrado');
      } else if (mensagem.contains('CPF inválido')) {
        setState(() => _cpfError = 'CPF inválido. Verifique os números.');
      } else {
        ToastService.showError(context, 'Erro ao cadastrar');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

void _clearRegisterFields() {
  _cadastroNomeController.clear();
  _cadastroEmailController.clear();
  _cadastroSenhaController.clear();
  _cadastroConfirmSenhaController.clear();
  _cadastroCpfController.clear();
  _cadastroTelefoneController.clear();
  _sexoSelecionado = null;
  _dataNascimento = null;
  _cpfError = '';
  _emailError = '';
}

  InputDecoration _buildInputDecoration(String label, IconData icon, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIcon: Icon(icon, color: _accentColor, size: 20),
      errorText: errorText,
      errorStyle: const TextStyle(fontSize: 12, color: Color(0xFFC65D47)),
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
        borderSide: BorderSide(color: _accentColor, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

Widget _buildCpfField(TextEditingController controller) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: _buildInputDecoration('CPF', Icons.assignment_ind_outlined, errorText: _cpfError.isEmpty ? null : _cpfError),
    validator: (value) {
      if (value == null || value.isEmpty) return 'CPF é obrigatório';
      final cpfLimpo = value.replaceAll(RegExp(r'[^\d]'), '');
      if (cpfLimpo.length != 11) return 'CPF inválido';
      return null;
    },
  );
}

Widget _buildPhoneField(TextEditingController controller) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.phone,
    decoration: _buildInputDecoration('Telefone Celular', Icons.phone_outlined),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Telefone é obrigatório';
      if (value.replaceAll(RegExp(r'[^\d]'), '').length != 11) return 'Inválido';
      return null;
    },
  );
}

  Widget _buildDropdownSexo() {
    return DropdownButtonFormField<String>(
      value: _sexoSelecionado,
      decoration: _buildInputDecoration('Sexo', Icons.people_outline),
      items: ['Masculino', 'Feminino', 'Outro'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (val) => setState(() => _sexoSelecionado = val),
      validator: (value) => value == null ? 'Selecione o sexo' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: _buildInputDecoration('Aniversário', Icons.cake_outlined),
        child: Text(
          _dataNascimento == null ? 'Aniversário' : _formatDate(_dataNascimento!),
          style: TextStyle(
            fontSize: 14,
            color: _dataNascimento == null ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
      ),
    );
  }

Widget _buildPasswordStrengthIndicator() {
  final isSmallMobile = MediaQuery.of(context).size.width < 400;
  
  bool senhasConferem = _cadastroConfirmSenhaController.text.isNotEmpty && 
                         _cadastroSenhaController.text == _cadastroConfirmSenhaController.text;
  
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 8, bottom: 4),
    padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 16 : 16, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Wrap(
      spacing: isSmallMobile ? 8 : 16,
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? (isSmallMobile ? 8 : 12) : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desfumo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BebasNeue',
                  color: Color(0xFF1F4E6E),
                  letterSpacing: 1,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
  Container(
    padding: EdgeInsets.all(isMobile ? (isSmallMobile ? 4 : 8) : 12),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? (isSmallMobile ? 8 : 10) : 12),
          decoration: BoxDecoration(
            color: const Color(0xFF334155).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smoke_free_outlined,
            size: isMobile ? (isSmallMobile ? 28 : 32) : 40,
            color: _accentColor,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return Column(
              children: [
                Text(
                  _tabController.index == 0 
                      ? 'Bem-vindo de volta' 
                      : 'Bem-vindo ao Desfumo',
                  style: TextStyle(
                    fontSize: isMobile ? (isSmallMobile ? 14 : 16) : 18,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  _tabController.index == 0 
                      ? 'Acesse sua conta para continuar' 
                      : 'Crie sua conta e comece sua jornada',
                  style: TextStyle(
                    fontSize: isMobile ? (isSmallMobile ? 10 : 11) : 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Entrar'),
              Tab(text: 'Cadastrar'),
            ],
            labelColor: _accentColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _accentColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                final isCadastro = _tabController.index == 1;
                return SizedBox(
                  height: isCadastro ? (isMobile ? 560 : 580) : (isMobile ? 220 : 180),
                  child: IndexedStack(
                    index: _tabController.index,
                    children: [
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildLoginForm(),
                      ),
Scrollbar(
  thumbVisibility: true,
  trackVisibility: true,
  thickness: 4,
  radius: const Radius.circular(10),
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: _buildRegisterForm(),
  ),
),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  bool _isValidCpf(String cpf) {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfLimpo.length != 11) return false;
    
    if (RegExp(r'^(\d)\1*$').hasMatch(cpfLimpo)) return false;
    
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpfLimpo[i]) * (10 - i);
    }
    int primeiroDigito = 11 - (soma % 11);
    if (primeiroDigito >= 10) primeiroDigito = 0;
    
    if (int.parse(cpfLimpo[9]) != primeiroDigito) return false;
    
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpfLimpo[i]) * (11 - i);
    }
    int segundoDigito = 11 - (soma % 11);
    if (segundoDigito >= 10) segundoDigito = 0;
    
    return int.parse(cpfLimpo[10]) == segundoDigito;
  }

  Widget _buildLoginForm() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  bool isFormValid() {
    if (_loginEmailController.text.trim().isEmpty) return false;
    if (_loginSenhaController.text.trim().isEmpty) return false;
    if (!_isEmailValid(_loginEmailController.text.trim())) return false;
    return true;
  }

  return Form(
    key: _loginFormKey,
    child: Column(
      children: [
        TextFormField(
          controller: _loginEmailController,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDecoration('E-mail', Icons.email_outlined),
          validator: Validators.validateEmail,
          onFieldSubmitted: (_) => _login(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginSenhaController,
          obscureText: _obscureText,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDecoration('Senha', Icons.lock_outline).copyWith(
            suffixIcon: isMobile
                ? null  
                : IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
          ),
          validator: Validators.validatePassword,
          onFieldSubmitted: (_) => _login(),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || !isFormValid()) ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid() ? _accentColor : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRegisterForm() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Form(
    key: _registerFormKey,
    child: Column(
      children: [
        const SizedBox(height: 20),
        TextFormField(
          controller: _cadastroNomeController,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDecoration('Nome Completo', Icons.person_outline),
          validator: Validators.validateNome,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cadastroEmailController,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDecoration('E-mail', Icons.email_outlined, errorText: _emailError.isEmpty ? null : _emailError),
          validator: Validators.validateEmail,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCpfField(_cadastroCpfController)),
            const SizedBox(width: 12),
            Expanded(child: _buildPhoneField(_cadastroTelefoneController)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdownSexo(),
        const SizedBox(height: 12),
        _buildDatePicker(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cadastroSenhaController,
          obscureText: _obscureText,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDecoration('Senha', Icons.lock_outline).copyWith(
            suffixIcon: isMobile
                ? null
                : IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Digite uma senha';
            if (value.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cadastroConfirmSenhaController,
          obscureText: _obscureConfirmText,
          onChanged: (_) => setState(() {}),
          decoration: _buildInputDecoration('Confirmar Senha', Icons.lock_outline).copyWith(
            suffixIcon: isMobile
                ? null
                : IconButton(
                    icon: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
                  ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Confirme a senha' : null,
          onFieldSubmitted: (_) => _register(),
          textInputAction: TextInputAction.done,
        ),
        if (_hasStartedTyping) _buildPasswordStrengthIndicator(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isRegisterFormValid() && !_isLoading ? _register : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRegisterFormValid() ? const Color(0xFF2E8B6A) : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Cadastrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
}