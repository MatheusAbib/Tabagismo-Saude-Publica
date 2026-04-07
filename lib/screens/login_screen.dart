import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/models/user.dart';
import 'package:tabagismo_app/screens/admin_screen.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/utils/validators.dart';
import 'package:tabagismo_app/screens/enfermeira_screen.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

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
  final Color _primaryMedium = Color(0xFF1A4A6F);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _successColor = Color(0xFF10B981);

  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _confirmSenhaController = TextEditingController();
  TextEditingController _cpfController = MaskedTextController(mask: '000.000.000-00');
  TextEditingController _telefoneController = MaskedTextController(mask: '(00) 00000-0000');
  
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
    value: [_dataNascimento ?? DateTime.now().subtract(const Duration(days: 18 * 365))],
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('As senhas não coincidem'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }

        if (_sexoSelecionado == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selecione o sexo'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (_dataNascimento == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selecione a data de nascimento'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cadastro realizado com sucesso!'),
              backgroundColor: _successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          setState(() {
            _isRegisterMode = false;
            _clearRegisterFields();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar: $e'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
          print('UserData do login: $userData');
          final tipoUsuario = userData['tipo_usuario'] ?? 'comum';
          final isAdmin = userData['is_admin'] == 1;

          if (mounted) {
            if (isAdmin || tipoUsuario == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminScreen(userData: userData)),
              );
            } else if (tipoUsuario == 'enfermeira') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EnfermeiraScreen(userData: userData)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)),
              );
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao fazer login: $e'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primaryDark,
                            _primaryMedium,
                            Color(0xFF0A1E2C),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: Icon(
                                    Icons.smoking_rooms_outlined,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Desfumar',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'O lugar onde o fumo deixa de existir',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.85),
                                    fontFamily: 'Inter',
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 2,
                                  runSpacing: 12,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: _buildStatItem('+50', 'Usuários ativos'),
                                    ),
                                    SizedBox(
                                      width: 140,
                                      child: _buildStatItem('+200', 'Pessoas ajudadas'),
                                    ),
                                    SizedBox(
                                      width: 140,
                                      child: _buildStatItem('+150', 'UPAs parceiras'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isRegisterMode
                                    ? Icons.person_add_alt_1_rounded   
                                    : Icons.login,                  
                                size: 28,
                                color: _primaryDark,
                              ),
                              SizedBox(width: 10),
                              Text(
                                _isRegisterMode ? 'Criar Conta' : 'Bem-vindo',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryDark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            _isRegisterMode 
                              ? 'Preencha os campos para começar' 
                              : 'Entre com suas credenciais',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 30),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_isRegisterMode) ...[
                                  TextFormField(
                                    controller: _nomeController,
                                    decoration: _buildInputDecoration('Nome Completo', Icons.person_outline),
                                    validator: Validators.validateNome,
                                  ),
                                  SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _sexoSelecionado,
                                    decoration: _buildInputDecoration('Sexo', Icons.people_outline),
                                    items: ['Masculino', 'Feminino', 'Outro'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _sexoSelecionado = newValue;
                                      });
                                    },
                                    validator: (value) => value == null ? 'Selecione o sexo' : null,
                                  ),
                                  SizedBox(height: 14),
                                  InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: _buildInputDecoration('Data de Nascimento', Icons.cake_outlined),
                                      child: Text(
                                        _dataNascimento == null
                                            ? 'Selecione uma data'
                                            : _formatDate(_dataNascimento!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _dataNascimento == null ? Colors.grey.shade600 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  TextFormField(
                                    controller: _cpfController,
                                    keyboardType: TextInputType.number,
                                    decoration: _buildInputDecoration('CPF', Icons.assignment_ind_outlined),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'CPF é obrigatório';
                                      String cpfLimpo = value.replaceAll(RegExp(r'[^\d]'), '');
                                      if (cpfLimpo.length != 11) return 'CPF inválido';
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 14),
                                  TextFormField(
                                    controller: _telefoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: _buildInputDecoration('Telefone Celular', Icons.phone_outlined),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Telefone é obrigatório';
                                      String telefoneLimpo = value.replaceAll(RegExp(r'[^\d]'), '');
                                      if (telefoneLimpo.length != 11) return 'Telefone inválido (DDD + 9 dígitos)';
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 14),
                                ],
                                TextFormField(
                                  controller: _emailController,
                                  decoration: _buildInputDecoration('E-mail', Icons.email_outlined),
                                  validator: Validators.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: 14),
                                TextFormField(
                                  controller: _senhaController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    prefixIcon: Icon(Icons.lock_outline, color: _accentColor),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey.shade500,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: _accentColor, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  validator: Validators.validatePassword,
                                  onFieldSubmitted: (_) {
                                    if (!_isRegisterMode) {
                                      _handleAuth();
                                    }
                                  },
                                ),
                                if (_isRegisterMode) ...[
                                  SizedBox(height: 14),
                                  TextFormField(
                                    controller: _confirmSenhaController,
                                    obscureText: _obscureConfirmText,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar Senha',
                                      prefixIcon: Icon(Icons.lock_outline, color: _accentColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmText ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey.shade500,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmText = !_obscureConfirmText;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: _accentColor, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Confirme sua senha';
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _handleAuth(),
                                  ),
                                ],
                                SizedBox(height: 24),
                                _isLoading
                                    ? Container(
                                        height: 44,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: _accentColor,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _handleAuth,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _accentColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          minimumSize: Size(double.infinity, 44),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          _isRegisterMode ? 'Criar Conta' : 'Entrar',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isRegisterMode 
                                        ? 'Já tem uma conta?' 
                                        : 'Não tem uma conta?',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _toggleMode,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: Size(0, 0),
                                      ),
                                      child: Text(
                                        _isRegisterMode ? 'Fazer login' : 'Cadastre-se',
                                        style: TextStyle(
                                          color: _accentColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ],
              ),
            ),
            _buildSimplifiedFooter(),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13),
      prefixIcon: Icon(icon, color: _accentColor, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _accentColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildSimplifiedFooter() {
    final Color footerColor = Color(0xFF0F2B3D);
    final Color accentColor = Color(0xFF2C7DA0);
    
    return Container(
      width: double.infinity,
      color: footerColor,
      padding: EdgeInsets.only(
        top: 32,
        left: 40,
        right: 40,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.smoking_rooms_outlined, color: Colors.white, size: 22),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desfumo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'O lugar onde o fumo deixa de existir',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildAboutSection()),
              SizedBox(width: 32),
              Expanded(flex: 4, child: _buildContactSection()),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Desfumo',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontFamily: 'Inter',
                ),
              ),
              Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFFEF4444), size: 10),
                  SizedBox(width: 4),
                  Text(
                    'Versão 2.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOBRE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Plataforma para ajudar pessoas a parar de fumar, conectando-as a unidades de saúde e grupos de apoio.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            height: 1.4,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    final Color accentColor = Color(0xFF2C7DA0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTATO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildContactItem(Icons.phone_outlined, 'Disque Saúde: 136'),
            ),
            SizedBox(width: 6),
            Expanded(
              child: _buildContactItem(Icons.numbers, 'WhatsApp: (11) 99999-9999'),
            ),
            SizedBox(width: 6),
            Expanded(
              child: _buildContactItem(Icons.email_outlined, 'contato@tabagismoapp.com.br'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    final Color accentColor = Color(0xFF2C7DA0);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: accentColor, size: 12),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}