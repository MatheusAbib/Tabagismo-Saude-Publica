import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/notification_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class NotificacoesModal {
  static void show(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _NotificacoesModalContent(
          isMobile: isMobile,
          isSmallMobile: isSmallMobile,
        );
      },
    );
  }
}

class _NotificacoesModalContent extends StatefulWidget {
  final bool isMobile;
  final bool isSmallMobile;

  const _NotificacoesModalContent({
    Key? key,
    required this.isMobile,
    required this.isSmallMobile,
  }) : super(key: key);

  @override
  _NotificacoesModalContentState createState() => _NotificacoesModalContentState();
}

class _NotificacoesModalContentState extends State<_NotificacoesModalContent> {
  List<Map<String, dynamic>> _notificacoes = [];
  bool _isLoading = true;

  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _dangerColor = const Color(0xFFC65D47);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _purpleColor = const Color(0xFF6B21A8);

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    setState(() => _isLoading = true);
    try {
      final response = await NotificationService.getNotificacoes();
      setState(() {
        _notificacoes = List<Map<String, dynamic>>.from(response['notificacoes']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastService.showError(context, 'Erro ao carregar notificações: $e');
    }
  }

  void _marcarTodasComoLidas() async {
    await NotificationService.marcarTodasComoLidas();
    _carregarNotificacoes();
    ToastService.showSuccess(context, 'Todas as notificações marcadas como lidas');
  }

void _confirmarLimparNotificacoes() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.all(isSmallMobile ? 8 : (isMobile ? 12 : 20)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.92 : 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_sweep, size: 40, color: _dangerColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Limpar Notificações',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tem certeza que deseja remover todas as notificações?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                'Esta ação não pode ser desfeita.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
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
                        _carregarNotificacoes();
                        ToastService.showSuccess(context, 'Todas as notificações foram removidas!');
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Sim, limpar',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 44),
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

  void _marcarComoLida(int id) async {
    await NotificationService.marcarComoLida(id);
    _carregarNotificacoes();
    ToastService.showSuccess(context, 'Notificação marcada como lida');
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

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'sucesso': return _successColor;
      case 'matricula': return _purpleColor;
      case 'sintoma': return _accentColor;
      case 'fagerstrom': return _warningColor;
      default: return const Color(0xFFF97316);
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'matricula': return Icons.school;
      case 'sintoma': return Icons.monitor_heart;
      case 'fagerstrom': return Icons.assessment;
      default: return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(widget.isSmallMobile ? 4 : (widget.isMobile ? 8 : 20)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: widget.isMobile ? double.infinity : 700,
        height: widget.isMobile ? MediaQuery.of(context).size.height * 0.92 : 650,
        constraints: BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              _buildHeader(),
if (_notificacoes.isNotEmpty && widget.isMobile)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: _marcarTodasComoLidas,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.done_all, color: _accentColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Ler todas',
                  style: TextStyle(
                    fontSize: 11,
                    color: _accentColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _confirmarLimparNotificacoes,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _dangerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.delete_sweep, color: _dangerColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Limpar',
                  style: TextStyle(
                    fontSize: 11,
                    color: _dangerColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _notificacoes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.all(widget.isMobile ? 8 : 16),
                            itemCount: _notificacoes.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(_notificacoes[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildHeader() {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Container(
    padding: EdgeInsets.all(isMobile ? 12 : 20),
    decoration: const BoxDecoration(
      color: Color(0xFF334155),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificações',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Mantenha-se informado',
                style: TextStyle(
                  fontSize: isMobile ? 9 : 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        if (_notificacoes.isNotEmpty && !widget.isMobile)
          Row(
            children: [
              InkWell(
                onTap: _marcarTodasComoLidas,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.done_all, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Ler todas',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _confirmarLimparNotificacoes,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC65D47).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: const Color(0xFFFCA5A5), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Limpar',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFFFCA5A5),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

  Widget _buildMobileActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _marcarTodasComoLidas,
            child: const Text('Marcar todas', style: TextStyle(color: Color(0xFF2C7DA0), fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 56, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'Nenhuma notificação',
            style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter', fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Você está em dia!',
            style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Inter', fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final dataHora = _formatarDataHora(notif['data_criacao']);
    final cor = _getTipoColor(notif['tipo']);
    final isLida = notif['lida'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLida ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLida ? const Color(0xFFE2E8F0) : cor.withValues(alpha: 0.3),
          width: isLida ? 1 : 1.5,
        ),
        boxShadow: isLida
            ? null
            : [
                BoxShadow(
                  color: cor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getTipoIcon(notif['tipo']), color: cor, size: 20),
        ),
        title: Text(
          notif['titulo'],
          style: TextStyle(
            fontWeight: isLida ? FontWeight.normal : FontWeight.w600,
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
        trailing: !isLida
            ? IconButton(
                icon: Icon(Icons.check_circle_outline, color: cor, size: 20),
                onPressed: () => _marcarComoLida(notif['id']),
              )
            : null,
      ),
    );
  }
}