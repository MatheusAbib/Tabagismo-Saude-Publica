import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/screens/upa_screen.dart';
import 'package:tabagismo_app/screens/my_enrollments_screen.dart';
import 'package:tabagismo_app/screens/fagerstrom_test_modal.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/sintoma_service.dart';


import 'dart:async';
import 'package:tabagismo_app/services/notification_service.dart';

import 'package:fl_chart/fl_chart.dart' as fl_chart;

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
  final _sintomaService = SintomaService();
  final Color _accentColor = const Color(0xFF1F4E6E);
  
  StreamController<Map<String, dynamic>> _notificationStream = StreamController.broadcast();
  Timer? _notificationTimer;
  int _naoLidas = 0;

  @override
  void initState() {
    super.initState();
    _startNotificationPolling();
  }

  void _startNotificationPolling() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _carregarNotificacoes();
    });
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    try {
      final response = await NotificationService.getNotificacoes();
      if (mounted) {
        setState(() {
          _naoLidas = response['naoLidas'] ?? 0;
        });
        _notificationStream.add({
          'naoLidas': response['naoLidas'],
          'notificacoes': response['notificacoes'],
        });
      }
    } catch (e) {
      print('Erro ao carregar notificações: $e');
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _notificationStream.close();
    super.dispose();
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

  Widget _buildNotificationBell() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 10),  
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNotificationsDialog(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none, color: Colors.white, size: 18),
                if (_naoLidas > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Transform.translate(
                      offset: const Offset(8, -8),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _naoLidas > 9 ? '9+' : '$_naoLidas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

void _showNotificationsDialog() async {
  try {
    final response = await NotificationService.getNotificacoes();
    final notificacoes = List<Map<String, dynamic>>.from(response['notificacoes']);
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 700,
            height: isMobile ? MediaQuery.of(context).size.height * 0.85 : 650,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notificações',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Mantenha-se informado',
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (notificacoes.isNotEmpty && !isMobile)
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await NotificationService.marcarTodasComoLidas();
                                  Navigator.pop(context);
                                  _showNotificationsDialog();
                                  _carregarNotificacoes();
                                },
                                child: const Text('Marcar todas', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.white70, size: 20),
                                onPressed: () => _confirmarLimparNotificacoes(),
                              ),
                            ],
                          ),
                        if (notificacoes.isNotEmpty && isMobile)
                          IconButton(
                            icon: const Icon(Icons.delete_sweep, color: Colors.white70, size: 20),
                            onPressed: () => _confirmarLimparNotificacoes(),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  if (notificacoes.isNotEmpty && isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await NotificationService.marcarTodasComoLidas();
                              Navigator.pop(context);
                              _showNotificationsDialog();
                              _carregarNotificacoes();
                            },
                            child: const Text('Marcar todas', style: TextStyle(color: Color(0xFF2C7DA0), fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: notificacoes.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none, size: 64, color: Color(0xFF94A3B8)),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhuma notificação',
                                  style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            itemCount: notificacoes.length,
                            itemBuilder: (context, index) {
                              final notif = notificacoes[index];
                              return _buildNotificationCard(notif);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao carregar notificações: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _confirmarLimparNotificacoes() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width > 500 ? 420 : MediaQuery.of(context).size.width * 0.9,
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
                    color: const Color(0xFFC65D47).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_sweep,
                    size: 48,
                    color: Color(0xFFC65D47),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Limpar Notificações',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tem certeza que deseja remover todas as notificações?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta ação não pode ser desfeita.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
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
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await NotificationService.limparTodas();
                          Navigator.pop(context);
                          _carregarNotificacoes();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Todas as notificações foram removidas!'),
                              backgroundColor: Color(0xFF2E8B6A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Sim, limpar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC65D47),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

  String _formatarDataHora(String? dataStr) {
    if (dataStr == null) return '';
    try {
      DateTime date = DateTime.parse(dataStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays > 0) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h atrás';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}min atrás';
      } else {
        return 'Agora mesmo';
      }
    } catch (e) {
      return '';
    }
  }

Widget _buildNotificationCard(Map<String, dynamic> notif) {
  Color getTipoColor(String tipo) {
    switch (tipo) {
      case 'sucesso': return const Color(0xFF2E8B6A);
      case 'matricula': return const Color(0xFF6B21A8);
      case 'sintoma': return const Color(0xFF1F4E6E);
      case 'fagerstrom': return const Color(0xFFD97706);
      default: return const Color(0xFFF97316);
    }
  }
  
  IconData getTipoIcon(String tipo) {
    switch (tipo) {
      case 'matricula': return Icons.school;
      case 'sintoma': return Icons.monitor_heart;
      case 'fagerstrom': return Icons.assessment;
      default: return Icons.notifications_none;
    }
  }
    
      final dataHora = _formatarDataHora(notif['data_criacao']);
      final cor = getTipoColor(notif['tipo']);
    
   return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: notif['lida'] == 1 ? const Color(0xFFF8FAFC) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: notif['lida'] == 1 ? const Color(0xFFE2E8F0) : cor.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(getTipoIcon(notif['tipo']), color: cor, size: 20),
      ),
      title: Text(
        notif['titulo'],
        style: TextStyle(
          fontWeight: notif['lida'] == 1 ? FontWeight.normal : FontWeight.w600,
          fontSize: 14,
          color: const Color(0xFF0F172A),
          fontFamily: 'Inter',
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notif['mensagem'],
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter'),
          ),
          if (dataHora.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                dataHora,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'Inter'),
              ),
            ),
        ],
      ),
      trailing: notif['lida'] == 0
          ? IconButton(
              icon: Icon(Icons.check_circle_outline, color: cor, size: 20),
              onPressed: () async {
                await NotificationService.marcarComoLida(notif['id']);
                Navigator.pop(context);
                _showNotificationsDialog();
                _carregarNotificacoes();
              },
            )
          : null,
    ),
  );
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
            width: MediaQuery.of(context).size.width > 500 ? 420 : MediaQuery.of(context).size.width * 0.9,
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
                    color: const Color(0xFFC65D47).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Color(0xFFC65D47),
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
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.pop(context);
      _performLogout();
    },
    icon: const Icon(Icons.check, size: 18),
    label: const Text(
      'Sair',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFC65D47),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
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
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  void _logout() {
    _showLogoutConfirmationDialog();
  }

  void _showSintomasModal() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      int ansiedade = 0;
      int irritabilidade = 0;
      int insonia = 0;
      int fome = 0;
      int dificuldadeConcentracao = 0;
      int vontadeFumar = 0;
      String observacoes = '';
      bool isLoading = false;
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height > 800 ? 750 : MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.monitor_heart,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diário de Sintomas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Registre como você se sente hoje',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildSintomaSlider('Ansiedade', Icons.psychology, ansiedade, (value) => setState(() => ansiedade = value), const Color(0xFF1F4E6E)),
                            _buildSintomaSlider('Irritabilidade', Icons.flash_on, irritabilidade, (value) => setState(() => irritabilidade = value), const Color(0xFFC65D47)),
                            _buildSintomaSlider('Insônia', Icons.nightlight_round, insonia, (value) => setState(() => insonia = value), const Color(0xFF6B21A8)),
                            _buildSintomaSlider('Fome', Icons.restaurant, fome, (value) => setState(() => fome = value), const Color(0xFFD97706)),
                            _buildSintomaSlider('Dificuldade de Concentração', Icons.auto_awesome, dificuldadeConcentracao, (value) => setState(() => dificuldadeConcentracao = value), const Color(0xFF2E8B6A)),
                            _buildSintomaSlider('Vontade de Fumar', Icons.smoking_rooms, vontadeFumar, (value) => setState(() => vontadeFumar = value), const Color(0xFFC65D47)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'Observações (opcional)',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Inter'),
                                ),
                                onChanged: (value) => observacoes = value,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () async {
                                  setState(() => isLoading = true);
                                  try {
                                    final hoje = DateTime.now().toIso8601String().split('T')[0];
                                    await _sintomaService.registrarSintoma(
                                      data: hoje,
                                      ansiedade: ansiedade,
                                      irritabilidade: irritabilidade,
                                      insonia: insonia,
                                      fome: fome,
                                      dificuldadeConcentracao: dificuldadeConcentracao,
                                      vontadeFumar: vontadeFumar,
                                      observacoes: observacoes,
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Sintomas registrados com sucesso!'),
                                        backgroundColor: Color(0xFF2E8B6A),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao registrar: $e'), backgroundColor: Color(0xFFC65D47)),
                                    );
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8B6A),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save, size: 18, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Registrar Sintomas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

 void _showSintomasGrafico() async {
  try {
    final sintomas = await _sintomaService.getSintomas(limit: 30);
    
    if (sintomas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ainda não há registros de sintomas. Registre seu primeiro diário!'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width > 1000 ? 1000 : MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height > 800 ? 700 : MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.show_chart,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Evolução dos Sintomas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Acompanhe sua evolução ao longo do tempo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 16,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildLegendaItem(const Color(0xFF1F4E6E), 'Ansiedade'),
                              _buildLegendaItem(const Color(0xFFC65D47), 'Irritabilidade'),
                              _buildLegendaItem(const Color(0xFF6B21A8), 'Insônia'),
                              _buildLegendaItem(const Color(0xFFF97316), 'Fome'),
                              _buildLegendaItem(const Color(0xFF2E8B6A), 'Dificuldade de Concentração'),
                              _buildLegendaItem(const Color(0xFFD97706), 'Vontade de Fumar'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 450,
                            child: _buildSintomasGrafico(sintomas),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar gráfico: $e'), backgroundColor: const Color(0xFFC65D47)),
    );
  }
}

  Widget _buildSintomaSlider(String titulo, IconData icon, int valor, Function(int) onChanged, Color cor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  valor.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: valor.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: cor,
            inactiveColor: cor.withOpacity(0.2),
            onChanged: (value) => onChanged(value.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nenhum', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              Text('Moderado', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              Text('Máximo', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendaItem(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

Widget _buildSintomasGrafico(List<Map<String, dynamic>> sintomas) {
  sintomas = sintomas.reversed.toList();
  
  List<double> ansiedade = [];
  List<double> irritabilidade = [];
  List<double> vontadeFumar = [];
  List<double> insonia = [];
  List<double> fome = [];
  List<double> dificuldadeConcentracao = [];
  List<String> labels = [];

  for (var s in sintomas) {
    ansiedade.add((s['ansiedade'] ?? 0).toDouble());
    irritabilidade.add((s['irritabilidade'] ?? 0).toDouble());
    vontadeFumar.add((s['vontade_fumar'] ?? 0).toDouble());
    insonia.add((s['insonia'] ?? 0).toDouble());
    fome.add((s['fome'] ?? 0).toDouble());
    dificuldadeConcentracao.add((s['dificuldade_concentracao'] ?? 0).toDouble());
    
    final data = DateTime.parse(s['data']);
    labels.add('${data.day}/${data.month}');
  }
  
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Container(
      width: labels.length * 70,
      height: 420,
      child: fl_chart.LineChart(
        fl_chart.LineChartData(
          gridData: fl_chart.FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            horizontalInterval: 2,
            verticalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return fl_chart.FlLine(
                color: const Color(0xFFE2E8F0),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return fl_chart.FlLine(
                color: const Color(0xFFE2E8F0),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: fl_chart.FlTitlesData(
            bottomTitles: fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.3,
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 50,
              ),
            ),
            leftTitles: fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(showTitles: false),
            ),
            rightTitles: const fl_chart.AxisTitles(
              sideTitles: fl_chart.SideTitles(showTitles: false),
            ),
          ),

borderData: fl_chart.FlBorderData(
  show: true,
),
          minX: 0,
          maxX: (sintomas.length - 1).toDouble(),
          minY: 0,
          maxY: 10,
          lineTouchData: fl_chart.LineTouchData(
            enabled: true,
            touchTooltipData: fl_chart.LineTouchTooltipData(
              getTooltipItems: (List<fl_chart.LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return fl_chart.LineTooltipItem(
                    '${spot.y.toInt()}',
                    const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            fl_chart.LineChartBarData(
              spots: List.generate(ansiedade.length, (i) => fl_chart.FlSpot(i.toDouble(), ansiedade[i])),
              isCurved: true,
              color: const Color(0xFF1F4E6E),
              barWidth: 3,
              dotData: const fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(irritabilidade.length, (i) => fl_chart.FlSpot(i.toDouble(), irritabilidade[i])),
              isCurved: true,
              color: const Color(0xFFC65D47),
              barWidth: 3,
              dotData: const fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(vontadeFumar.length, (i) => fl_chart.FlSpot(i.toDouble(), vontadeFumar[i])),
              isCurved: true,
              color: const Color(0xFFD97706),
              barWidth: 3,
              dotData: const fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(insonia.length, (i) => fl_chart.FlSpot(i.toDouble(), insonia[i])),
              isCurved: true,
              color: const Color(0xFF6B21A8),
              barWidth: 3,
              dotData: const fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(fome.length, (i) => fl_chart.FlSpot(i.toDouble(), fome[i])),
              isCurved: true,
              color: const Color(0xFFF97316),
              barWidth: 3,
              dotData: const fl_chart.FlDotData(show: true),
            ),
            fl_chart.LineChartBarData(
              spots: List.generate(dificuldadeConcentracao.length, (i) => fl_chart.FlSpot(i.toDouble(), dificuldadeConcentracao[i])),
              isCurved: true,
              color: const Color(0xFF2E8B6A),
              barWidth: 3,
              dotData: const fl_chart.FlDotData(show: true),
            ),
          ],
        ),
      ),
    ),
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
          return Dialog(
            insetPadding: const EdgeInsets.all(5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width > 500 ? 450 : MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F4E6E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_outline, color: Color(0xFF1F4E6E), size: 24),
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
                    decoration: _buildInputDecoration('Senha Atual', Icons.lock_outline),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('Nova Senha', Icons.lock_reset),
                  ),
                  const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Confirmar Nova Senha', Icons.verified_user),
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
                              await _authService.changeUserPassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Color(0xFF2E8B6A)),
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
                            backgroundColor: const Color(0xFF2E8B6A),
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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: MediaQuery.of(context).size.width > 500 ? 480 : MediaQuery.of(context).size.width * 0.9,
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
                          child: const Icon(Icons.edit_outlined, color: Color(0xFF1F4E6E), size: 24),
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
                        decoration: _buildInputDecoration('Nome Completo', Icons.person),
                      ),
                    const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                      value: sexoSelecionado,
                      decoration: _buildInputDecoration('Sexo', Icons.wc),
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
                      decoration: _buildInputDecoration('Email', Icons.email),
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
                                      await _authService.updateUserData({
                                        'nomeCompleto': nomeController.text,
                                        'sexo': sexoSelecionado,
                                        'email': emailController.text,
                                        'telefone': telefoneLimpo,
                                      });

                                      if (mounted) {
                                        Navigator.pop(context);
                                        if (widget.onNameUpdated != null) {
                                          widget.onNameUpdated!(nomeController.text);
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Dados atualizados com sucesso!'), backgroundColor: Color(0xFF2E8B6A)),
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
                              backgroundColor: const Color(0xFF2E8B6A),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red.shade400),
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
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height > 800 ? 700 : MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: FagerstromTestModal(
              onScoreUpdated: (score) {
                if (widget.userData != null) {
                  widget.userData!['scoreFagestrom'] = score;
                }
              },
            ),
          ),
        ),
      );
    },
  );
}

  @override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 768;
  final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  
  double horizontalPadding = isMobile ? 16 : (isTablet ? 32 : 50);
  
  return Container(
      color: const Color(0xFF334155),  
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      left: horizontalPadding,
      right: horizontalPadding,
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(
                Icons.smoke_free_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
           const Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'DESFUMO',
      style: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
        color: Colors.white,
        height: 0.9, 
      ),
    ),
    Text(
      'Apoio ao Tabagismo',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 0.9, 
      ),
    ),
  ],
),
          ],
        ),
        isMobile ? _buildMobileMenu() : _buildDesktopMenu(),
      ],
    ),
  );
}

Widget _buildMobileMenu() {
  return Row(
    children: [
      _buildNotificationBell(),
      const SizedBox(width: 8),
      Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 50),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.menu, color: Colors.white, size: 24),
          onSelected: (String value) {
            if (value == 'turmas_apoio') {
              _openUPAScreen();
            } else if (value == 'diario') {
              _showSintomasModal();
            } else if (value == 'grafico') {
              _showSintomasGrafico();
            } else if (value == 'teste_fagerstrom') {
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
            const PopupMenuItem<String>(
              value: 'turmas_apoio',
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF1F4E6E)),
                  SizedBox(width: 12),
                  Text('Turmas de Apoio', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'diario',
              child: Row(
                children: [
                  Icon(Icons.monitor_heart_outlined, size: 20, color: Color(0xFF1F4E6E)),
                  SizedBox(width: 12),
                  Text('Diário de Sintomas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'grafico',
              child: Row(
                children: [
                  Icon(Icons.show_chart, size: 20, color: Color(0xFF2E8B6A)),
                  SizedBox(width: 12),
                  Text('Gráfico de Sintomas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'teste_fagerstrom',
              child: Row(
                children: [
                  Icon(Icons.assessment_outlined, size: 20, color: Color(0xFFD97706)),
                  SizedBox(width: 12),
                  Text('Teste de Fagerström', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'minhas_matriculas',
              child: Row(
                children: [
                  Icon(Icons.list_alt_outlined, size: 20, color: Color(0xFF6B21A8)),
                  SizedBox(width: 12),
                  Text('Minhas Matrículas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'alterar_senha',
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 12),
                  Text('Alterar Senha', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'editar_dados',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 12),
                  Text('Editar Dados', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
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
                  Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontFamily: 'Inter')),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildDesktopMenu() {
  return Row(
    children: [
      Container(
        height: 42,
        margin: const EdgeInsets.only(right: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openUPAScreen,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Turmas de Apoio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: PopupMenuButton<String>(
          offset: const Offset(0, 50),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Bem-vindo, ${widget.userName.split(' ').first}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
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
            if (value == 'diario') {
              _showSintomasModal();
            } else if (value == 'grafico') {
              _showSintomasGrafico();
            } else if (value == 'teste_fagerstrom') {
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
            const PopupMenuItem<String>(
              value: 'diario',
              child: Row(
                children: [
                  Icon(Icons.monitor_heart_outlined, size: 20, color: Color(0xFF1F4E6E)),
                  SizedBox(width: 12),
                  Text('Diário de Sintomas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'grafico',
              child: Row(
                children: [
                  Icon(Icons.show_chart, size: 20, color: Color(0xFF2E8B6A)),
                  SizedBox(width: 12),
                  Text('Gráfico de Sintomas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'teste_fagerstrom',
              child: Row(
                children: [
                  Icon(Icons.assessment_outlined, size: 20, color: Color(0xFFD97706)),
                  SizedBox(width: 12),
                  Text('Teste de Fagerström', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'minhas_matriculas',
              child: Row(
                children: [
                  Icon(Icons.list_alt_outlined, size: 20, color: Color(0xFF6B21A8)),
                  SizedBox(width: 12),
                  Text('Minhas Matrículas', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'alterar_senha',
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 12),
                  Text('Alterar Senha', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'editar_dados',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 12),
                  Text('Editar Dados', style: TextStyle(fontSize: 14, fontFamily: 'Inter')),
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
                  Text('Sair', style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontFamily: 'Inter')),
                ],
              ),
            ),
          ],
        ),
      ),
      _buildNotificationBell(),
    ],
  );
}
}