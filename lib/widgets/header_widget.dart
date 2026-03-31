import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/screens/upa_screen.dart';
import 'package:tabagismo_app/screens/my_enrollments_screen.dart';
import 'package:tabagismo_app/screens/fagerstrom_test_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';

class HeaderWidget extends StatefulWidget {
  final String userName;
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  
  const HeaderWidget({
    Key? key, 
    required this.userName, 
    this.userData,
    this.onNameUpdated,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final _authService = AuthService();
  final Color _primaryColor = Color(0xFF0F2B3D);
  final Color _accentColor = Color(0xFF2C7DA0);
  final Color _grayColor = Color(0xFF9E9E9E);

  void _logout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  void _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.lock_outline, color: _accentColor, size: 26),
                SizedBox(width: 10),
                Text(
                  'Alterar Senha',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FocusScope(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {});
                      },
                      child: TextField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha Atual',
                          labelStyle: TextStyle(color: _grayColor),
                          prefixIcon: Icon(Icons.lock_outline, color: _grayColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _grayColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _grayColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accentColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FocusScope(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {});
                      },
                      child: TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nova Senha',
                          labelStyle: TextStyle(color: _grayColor),
                          prefixIcon: Icon(Icons.lock_reset_outlined, color: _grayColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _grayColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _grayColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accentColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FocusScope(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {});
                      },
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Nova Senha',
                          labelStyle: TextStyle(color: _grayColor),
                          prefixIcon: Icon(Icons.verified_user_outlined, color: _grayColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _grayColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _grayColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accentColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (newPasswordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('As senhas não coincidem')),
                          );
                          return;
                        }
                        
                        setState(() => isLoading = true);
                        
                        try {
                          await _authService.changeUserPassword(
                            currentPasswordController.text,
                            newPasswordController.text,
                          );
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Senha alterada com sucesso!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao alterar senha: $e')),
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Alterar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editData() async {
    try {
      final response = await _authService.getUserData();
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
      String? telefoneError;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.edit_outlined, color: _accentColor, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Editar Dados',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FocusScope(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {});
                          },
                          child: TextField(
                            controller: nomeController,
                            decoration: InputDecoration(
                              labelText: 'Nome Completo',
                              labelStyle: TextStyle(color: _grayColor),
                              prefixIcon: Icon(Icons.person_outline, color: _grayColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _grayColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _grayColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FocusScope(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {});
                          },
                          child: DropdownButtonFormField<String>(
                            value: sexoSelecionado,
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              labelStyle: TextStyle(color: _grayColor),
                              prefixIcon: Icon(Icons.wc_outlined, color: _grayColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _grayColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _grayColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _accentColor, width: 1.5),
                              ),
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
                        ),
                      ),
                      SizedBox(height: 16),
                      FocusScope(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {});
                          },
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: _grayColor),
                              prefixIcon: Icon(Icons.email_outlined, color: _grayColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _grayColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _grayColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical:8),
                        decoration: BoxDecoration(
                          border: Border.all(color: _grayColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.assignment_ind, color: _grayColor, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CPF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _grayColor,
                                    ),
                                  ),
                                  Text(
                                    cpf,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FocusScope(
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {});
                              },
                              child: TextField(
                                controller: telefoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Telefone Celular',
                                  labelStyle: TextStyle(color: _grayColor),
                                  prefixIcon: Icon(Icons.phone_iphone_outlined, color: _grayColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _grayColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _grayColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _accentColor, width: 1.5),
                                  ),
                                  helperText: 'Formato: (DDD) 99999-9999',
                                  errorText: telefoneError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      String telefoneLimpo = value.replaceAll(RegExp(r'[^\d]'), '');
                                      if (telefoneLimpo.length != 11) {
                                        telefoneError = 'Telefone inválido (DDD + 9 dígitos)';
                                      } else {
                                        telefoneError = null;
                                      }
                                    } else {
                                      telefoneError = 'Telefone é obrigatório';
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (telefoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Telefone é obrigatório')),
                            );
                            return;
                          }
                          
                          String telefoneLimpo = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                          if (telefoneLimpo.length != 11) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Telefone inválido (DDD + 9 dígitos)')),
                            );
                            return;
                          }
                          
                          setState(() => isLoading = true);
                          
                          try {
                            await _authService.updateUserData({
                              'nomeCompleto': nomeController.text,
                              'sexo': sexoSelecionado,
                              'email': emailController.text,
                              'telefone': telefoneLimpo,
                            });
                            
                            Navigator.pop(context);
                            
                            if (widget.onNameUpdated != null) {
                              widget.onNameUpdated!(nomeController.text);
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Dados atualizados com sucesso!')),
                            );
                            
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao atualizar dados: $e')),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Salvar'),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
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

  void _openUPAScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UPAScreen(
          userData: widget.userData ?? {'nomeCompleto': widget.userName},
          onNameUpdated: widget.onNameUpdated,
        ),
      ),
    );
  }

  void _openMyEnrollments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyEnrollmentsScreen(
          userData: widget.userData,
          onNameUpdated: widget.onNameUpdated,
        ),
      ),
    );
  }

  void _openFagerstromTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FagerstromTestScreen(
          onScoreUpdated: (score) {
            if (widget.userData != null) {
              widget.userData!['scoreFagestrom'] = score;
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            Color(0xFF1A4A6F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 50,
        right: 50,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                Container(
                  margin: EdgeInsets.only(right: 5),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                    padding: EdgeInsets.all(10),
                    constraints: BoxConstraints(),
                  ),
                ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.smoking_rooms_outlined, color: Colors.white, size: 28),
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desfumo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      fontFamily: 'Poppins',
                    ),
                  ),
 
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openUPAScreen,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Encontrar UPAs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                  offset: Offset(0, 52),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline, color: Colors.white, size: 16),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Bem-vindo, ${widget.userName.split(' ').first}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  onSelected: (String value) {
                    if (value == 'teste_fagerstrom') {
                      _openFagerstromTest();
                    } else if (value == 'minhas_matriculas') {
                      _openMyEnrollments();
                    } else if (value == 'alterar_senha') {
                      _changePassword();
                    } else if (value == 'editar_dados') {
                      _editData();
                    } else if (value == 'sair') {
                      _logout();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'teste_fagerstrom',
                      child: Row(
                        children: [
                          Icon(Icons.assessment_outlined, size: 20, color: _primaryColor),
                          SizedBox(width: 12),
                          Text('Teste de Fagerström', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'minhas_matriculas',
                      child: Row(
                        children: [
                          Icon(Icons.list_alt_outlined, size: 20, color: _primaryColor),
                          SizedBox(width: 12),
                          Text('Minhas Matrículas', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'alterar_senha',
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20, color: _primaryColor),
                          SizedBox(width: 12),
                          Text('Alterar Senha', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'editar_dados',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: _primaryColor),
                          SizedBox(width: 12),
                          Text('Editar Dados', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'sair',
                      child: Row(
                        children: [
                          Icon(Icons.logout_outlined, size: 20, color: Colors.red.shade400),
                          SizedBox(width: 12),
                          Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}