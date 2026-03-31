import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/models/user.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/utils/validators.dart';

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 18 * 365)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataNascimento) {
      setState(() {
        _dataNascimento = picked;
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
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userData: response['user'])),
          );
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
      body: Row(
        children: [
          Expanded(
            flex: 5,
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
                    padding: EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.smoking_rooms_outlined,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Desfumar',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sua jornada para uma vida sem cigarro',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.85),
                            fontFamily: 'Inter',
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
        
                        SizedBox(height: 24),
                        _buildStatItem('+50', 'Usuários ativos'),
                        SizedBox(height: 12),
                        _buildStatItem('+200', 'Pessoas que pararam de fumar'),
                        SizedBox(height: 12),
                        _buildStatItem('+150', 'UPAs parceiras'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Lado Direito - Formulário
Expanded(
  flex: 7,
  child: Container(
    width: double.infinity,
    color: Colors.white,
    child: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
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
                              size: 34,
                              color: _primaryDark,
                            ),
                            SizedBox(width: 12),
                            Text(
                              _isRegisterMode ? 'Criar Conta' : 'Bem-vindo de volta',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: _primaryDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                                              SizedBox(height: 8),
                      Text(
                        _isRegisterMode 
                          ? 'Preencha os campos abaixo para começar sua jornada' 
                          : 'Entre com suas credenciais para acessar sua conta',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 40),
                      
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
                              SizedBox(height: 18),
                              
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
                              SizedBox(height: 18),
                              
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: _buildInputDecoration('Data de Nascimento', Icons.cake_outlined),
                                  child: Text(
                                    _dataNascimento == null
                                        ? 'Selecione uma data'
                                        : _formatDate(_dataNascimento!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _dataNascimento == null ? Colors.grey.shade600 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              
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
                              SizedBox(height: 18),
                              
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
                              SizedBox(height: 18),
                            ],
                            
                            TextFormField(
                              controller: _emailController,
                              decoration: _buildInputDecoration('E-mail', Icons.email_outlined),
                              validator: Validators.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 18),
                            
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
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _accentColor, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: Validators.validatePassword,
                            ),
                            
                            if (_isRegisterMode) ...[
                              SizedBox(height: 18),
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
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _accentColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Confirme sua senha';
                                  return null;
                                },
                              ),
                            ],
                            
                            SizedBox(height: 32),
                            
                            _isLoading
                                ? Container(
                                    height: 52,
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
                                      minimumSize: Size(double.infinity, 52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      _isRegisterMode ? 'Criar Conta' : 'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                            
                            SizedBox(height: 24),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isRegisterMode 
                                    ? 'Já tem uma conta?' 
                                    : 'Não tem uma conta?',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _toggleMode,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  child: Text(
                                    _isRegisterMode ? 'Fazer login' : 'Cadastre-se',
                                    style: TextStyle(
                                      color: _accentColor,
                                      fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _accentColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _successColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              TextSpan(
                text: ' $label',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}