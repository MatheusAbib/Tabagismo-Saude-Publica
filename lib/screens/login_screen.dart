import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/models/user.dart';
import 'package:tabagismo_app/screens/admin_screen.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/utils/validators.dart';
import 'package:tabagismo_app/screens/enfermeira_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:tabagismo_app/widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isRegisterMode = false;

  final Color _primaryDark = Color(0xFF0F2B3D);
      final Color _primaryMedium = Color.fromARGB(255, 19, 56, 85);

  final Color _accentColor = Color(0xFF2C7DA0);

  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _confirmSenhaController = TextEditingController();
  TextEditingController _cpfController =
      MaskedTextController(mask: '000.000.000-00');
  TextEditingController _telefoneController =
      MaskedTextController(mask: '(00) 00000-0000');

  String? _sexoSelecionado;
  DateTime? _dataNascimento;

  bool _obscureText = true;
  bool _obscureConfirmText = true;

  Future<void> _selectDate(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        currentDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
        selectedDayHighlightColor: const Color(0xFF2C7DA0),
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        cancelButton: const Text('Cancelar'),
        okButton: const Text('Confirmar'),
      ),
      dialogSize: const Size(350, 450),
      value: [
        _dataNascimento ??
            DateTime.now().subtract(const Duration(days: 18 * 365))
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

  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      if (_isRegisterMode) {
        if (_senhaController.text != _confirmSenhaController.text) {
          CustomSnackBar.showError(context, 'As senhas não coincidem');
          return;
        }
        if (_sexoSelecionado == null) {
          CustomSnackBar.showWarning(context, 'Selecione o sexo');
          return;
        }
        if (_dataNascimento == null) {
          CustomSnackBar.showWarning(context, 'Selecione a data de nascimento');
          return;
        }

        setState(() => _isLoading = true);

        try {
          final user = User(
            nomeCompleto: _nomeController.text,
            sexo: _sexoSelecionado!,
            dataNascimento: _dataNascimento!,
            idade: Validators.calcularIdade(_dataNascimento!),
            email: _emailController.text,
            senha: _senhaController.text,
            cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
            telefone: _telefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
          );

          await _authService.register(user);
          CustomSnackBar.showSuccess(context, 'Cadastro realizado com sucesso!');

          setState(() {
            _isRegisterMode = false;
            _clearRegisterFields();
          });
        } catch (e) {
          CustomSnackBar.showError(context, 'Erro ao cadastrar');
        } finally {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = true);
        try {
          final response = await _authService.login(
            _emailController.text,
            _senhaController.text,
          );

          final userData = response['user'];
          final tipoUsuario = userData['tipo_usuario'] ?? 'comum';
          final isAdmin = userData['is_admin'] == 1;

          if (mounted) {
            if (isAdmin || tipoUsuario == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminScreen(userData: userData)),
              );
            } else if (tipoUsuario == 'enfermeira') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => EnfermeiraScreen(userData: userData)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(userData: userData)),
              );
            }
          }
        } catch (e) {
          CustomSnackBar.showError(context, 'Erro ao fazer login');
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _clearRegisterFields() {
    _nomeController.clear();
    _confirmSenhaController.clear();
    _cpfController.clear();
    _telefoneController.clear();
    _sexoSelecionado = null;
    _dataNascimento = null;
    _emailController.clear();
    _senhaController.clear();
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _formKey.currentState?.reset();
      _clearRegisterFields();
      _obscureText = true;
      _obscureConfirmText = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;

          return SingleChildScrollView(
            child: Container(
              height: isDesktop ? MediaQuery.of(context).size.height : null,
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 4, child: _buildLeftBanner()),
                        Expanded(
                          flex: 5,
                          child: Stack(
                            children: [
                              Center(child: _buildLoginForm(isDesktop)),
                              _buildDesktopFooterPositioned(constraints),

                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          height: 250,
                          child: _buildLeftBanner(isMobile: true),
                        ),
                        _buildLoginForm(isDesktop),
                        _buildMobileFooter(),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftBanner({bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
     
          color:  _primaryMedium,
        
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 15 : 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(Icons.smoke_free_outlined,
                    size: isMobile ? 40 : 75, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Desfumo',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                  'O lugar onde o fumo deixa de existir',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.85)),
                  textAlign: TextAlign.center,
                ),
              if (!isMobile) ...[
                SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    _buildStatItem('+50', 'Usuários ativos'),
                    _buildStatItem('+200', 'Pessoas ajudadas'),
                    _buildStatItem('+150', 'UPAs parceiras'),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 24,
        vertical: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _isRegisterMode ? Icons.person_add_alt_1_rounded : Icons.login,
                size: 28,
                color: _primaryDark,
              ),
              SizedBox(width: 12),
              Text(
                _isRegisterMode ? 'Criar Conta' : 'Bem-vindo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_isRegisterMode) ...[
                  TextFormField(
                    controller: _nomeController,
                    decoration: _buildInputDecoration(
                        'Nome Completo', Icons.person_outline),
                    validator: Validators.validateNome,
                  ),
                  SizedBox(height: 16),
                  isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _buildCpfField()),
                            SizedBox(width: 16),
                            Expanded(child: _buildPhoneField()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCpfField(),
                            SizedBox(height: 16),
                            _buildPhoneField(),
                          ],
                        ),
                  SizedBox(height: 16),
                  _buildDropdownSexo(),
                  SizedBox(height: 16),
                  _buildDatePicker(),
                  SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration:
                      _buildInputDecoration('E-mail', Icons.email_outlined),
                  validator: Validators.validateEmail,
                ),
                SizedBox(height: 16),
                _buildPasswordField(),
                if (_isRegisterMode) ...[
                  SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                ],
                SizedBox(height: 28),
                _buildSubmitButton(),
                _buildToggleModeButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCpfField() {
    return TextFormField(
      controller: _cpfController,
      keyboardType: TextInputType.number,
      decoration: _buildInputDecoration('CPF', Icons.assignment_ind_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) return 'CPF é obrigatório';
        if (value.replaceAll(RegExp(r'[^\d]'), '').length != 11)
          return 'CPF inválido';
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _telefoneController,
      keyboardType: TextInputType.phone,
      decoration:
          _buildInputDecoration('Telefone Celular', Icons.phone_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Telefone é obrigatório';
        if (value.replaceAll(RegExp(r'[^\d]'), '').length != 11)
          return 'Inválido';
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
        decoration:
            _buildInputDecoration('Data de Nascimento', Icons.cake_outlined),
        child: Text(
          _dataNascimento == null
              ? 'Selecione uma data'
              : _formatDate(_dataNascimento!),
          style: TextStyle(
              fontSize: 14,
              color: _dataNascimento == null
                  ? Colors.grey.shade600
                  : Colors.black87),
        ),
      ),
    );
  }

Widget _buildPasswordField() {
  return TextFormField(
    controller: _senhaController,
    obscureText: _obscureText,
    decoration: _buildInputDecoration('Senha', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,
            size: 18),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    ),
    validator: Validators.validatePassword,
    onFieldSubmitted: (_) => _handleAuth(), 
    textInputAction: TextInputAction.done, 
  );
}

Widget _buildConfirmPasswordField() {
  return TextFormField(
    controller: _confirmSenhaController,
    obscureText: _obscureConfirmText,
    decoration: _buildInputDecoration('Confirmar Senha', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility,
            size: 18),
        onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
      ),
    ),
    validator: (value) => value == null || value.isEmpty ? 'Confirme a senha' : null,
    onFieldSubmitted: (_) => _handleAuth(),
    textInputAction: TextInputAction.done,
  );
}

  Widget _buildSubmitButton() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: _accentColor))
        : ElevatedButton(
            onPressed: _handleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_isRegisterMode ? 'Criar Conta' : 'Entrar',
                style: TextStyle(color: Colors.white)),
          );
  }

  Widget _buildToggleModeButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_isRegisterMode ? 'Já tem uma conta?' : 'Não tem uma conta?',
              style: TextStyle(fontSize: 13)),
          TextButton(
            onPressed: _toggleMode,
            child: Text(_isRegisterMode ? 'Fazer login' : 'Cadastre-se',
                style: TextStyle(
                    color: _accentColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

Widget _buildDesktopFooterPositioned(BoxConstraints constraints) {
  final isMediumScreen = constraints.maxWidth < 1100;
  final isSmallDesktop = constraints.maxWidth < 950;
  
  if (isSmallDesktop) {
    return Positioned(
      bottom: 16,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactItem(Icons.phone_outlined, 'Disque Saúde: 136'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.numbers, 'WhatsApp: (11) 99999-9999'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.email_outlined, 'contato@desfumo.com.br'),
          ],
        ),
      ),
    );
  }
  
  return Positioned(
    bottom: 24,
    right: isMediumScreen ? 24 : 48,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContactItem(Icons.phone_outlined, 'Disque Saúde: 136'),
          const SizedBox(width: 16),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 16),
          _buildContactItem(Icons.numbers, 'WhatsApp: (11) 99999-9999'),
          const SizedBox(width: 16),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 16),
          _buildContactItem(Icons.email_outlined, 'contato@desfumo.com.br'),
        ],
      ),
    ),
  );
}
  Widget _buildMobileFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Divider(),
          _buildContactItem(Icons.phone_outlined, 'Disque Saúde: 136'),
          SizedBox(height: 8),
          _buildContactItem(Icons.email_outlined, 'contato@desfumo.com.br'),
          SizedBox(height: 8),
          _buildContactItem(Icons.numbers, 'WhatsApp: (11) 99999-9999'),

        ],
      ),
    );
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
      borderSide: BorderSide(color: const Color.fromARGB(255, 219, 219, 219), width: 1), 
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _accentColor, width: 1.5), 
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}


  Widget _buildStatItem(String value, String label) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _accentColor, size: 14),
        SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
      ],
    );
  }
}