import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/notification_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';

class NotificacoesModal {
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _NotificacoesModalContent(),
    );
  }
}

class _NotificacoesModalContent extends StatefulWidget {
  const _NotificacoesModalContent();

  @override
  State<_NotificacoesModalContent> createState() =>
      _NotificacoesModalContentState();
}

class _NotificacoesModalContentState
    extends State<_NotificacoesModalContent> {
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _foreground = Color(0xFF333333);
  static const Color _secondary = Color(0xFF667078);
  static const Color _primary = Color(0xFF426E8C);
  static const Color _softBlue = Color(0xFFE1EDF6);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _danger = Color(0xFFC65D47);
  static const Color _dangerSoft = Color(0xFFF9EBE7);

  List<Map<String, dynamic>> _notificacoes = [];

  bool _isLoading = true;
  bool _isProcessing = false;

  int get _naoLidas {
    return _notificacoes.where((notif) => !_estaLida(notif)).length;
  }

  bool _estaLida(Map<String, dynamic> notif) {
    final valor = notif['lida'];
    return valor == true || valor == 1 || valor == '1';
  }

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await NotificationService.getNotificacoes();

      if (!mounted) return;

      setState(() {
        _notificacoes = List<Map<String, dynamic>>.from(
          response['notificacoes'] ?? [],
        );
      });
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Erro ao carregar notificações: $e',
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

  Future<void> _marcarTodasComoLidas() async {
    if (_isProcessing || _naoLidas == 0) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await NotificationService.marcarTodasComoLidas();

      if (!mounted) return;

      setState(() {
        _notificacoes = _notificacoes.map((notif) {
          return {
            ...notif,
            'lida': 1,
          };
        }).toList();
      });

      ToastService.showSuccess(
        context,
        'Todas as notificações foram marcadas como lidas.',
      );
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Não foi possível marcar as notificações como lidas.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _marcarComoLida(int id) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await NotificationService.marcarComoLida(id);

      if (!mounted) return;

      setState(() {
        _notificacoes = _notificacoes.map((notif) {
          if (notif['id'] == id) {
            return {
              ...notif,
              'lida': 1,
            };
          }

          return notif;
        }).toList();
      });

      ToastService.showSuccess(
        context,
        'Notificação marcada como lida.',
      );
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Não foi possível marcar a notificação como lida.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _limparNotificacoes() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await NotificationService.limparTodas();

      if (!mounted) return;

      setState(() {
        _notificacoes = [];
      });

      ToastService.showSuccess(
        context,
        'Todas as notificações foram removidas.',
      );
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Não foi possível limpar as notificações.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _confirmarLimparNotificacoes() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isSmallMobile =
            MediaQuery.sizeOf(dialogContext).width < 400;

        return Dialog(
          backgroundColor: _background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 12 : 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _border),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(dialogContext).height - 48,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallMobile ? 20 : 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _danger,
                      size: 31,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Limpar notificações?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: _foreground,
                      fontFamily: 'DMSerifDisplay',
                    ),
                  ),
                  const SizedBox(height: 11),
                  const Text(
                    'Todas as notificações serão removidas do seu histórico. Esta ação não poderá ser desfeita.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: _secondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: _outlineButtonStyle(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _limparNotificacoes();
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 17,
                          ),
                          label: const Text('Limpar'),
                          style: _dangerButtonStyle(),
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
  }

  String _formatarDataHora(String? dataStr) {
    if (dataStr == null || dataStr.isEmpty) return '';

    try {
      final date = DateTime.parse(dataStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.isNegative) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }

      if (diff.inDays >= 1) {
        if (diff.inDays == 1) return 'Ontem';

        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }

      if (diff.inHours >= 1) {
        return 'Há ${diff.inHours}h';
      }

      if (diff.inMinutes >= 1) {
        return 'Há ${diff.inMinutes}min';
      }

      return 'Agora mesmo';
    } catch (e) {
      return '';
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'matricula':
        return Icons.school_outlined;
      case 'sintoma':
        return Icons.monitor_heart_outlined;
      case 'fagerstrom':
        return Icons.assignment_outlined;
      case 'sucesso':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'matricula':
        return 'Matrícula';
      case 'sintoma':
        return 'Acompanhamento';
      case 'fagerstrom':
        return 'Teste de Fagerström';
      case 'sucesso':
        return 'Atualização';
      default:
        return 'Notificação';
    }
  }

  ButtonStyle _outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: _secondary,
      side: const BorderSide(color: _border),
      elevation: 0,
      minimumSize: const Size(0, 44),
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

  ButtonStyle _dangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _danger,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(0, 44),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final isSmallMobile = size.width < 400;

    return Dialog(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 8 : (isMobile ? 12 : 24),
        vertical: isMobile ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 650,
          maxHeight: size.height - (isMobile ? 24 : 48),
        ),
        child: SizedBox(
          height: size.height * (isMobile ? 0.86 : 0.75),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(
              children: [
                _buildHeader(isMobile),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: _border,
                ),
                if (!_isLoading && _notificacoes.isNotEmpty)
                  _buildToolbar(isMobile),
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _notificacoes.isEmpty
                          ? _buildEmptyState()
                          : _buildNotificationList(isMobile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: isMobile ? 14 : 18,
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
              Icons.notifications_none_outlined,
              color: _primary,
              size: 22,
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
                    fontWeight: FontWeight.w600,
                    color: _foreground,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isLoading
                      ? 'Carregando suas atualizações'
                      : _naoLidas > 0
                          ? '$_naoLidas ${_naoLidas == 1 ? 'não lida' : 'não lidas'}'
                          : 'Todas as notificações estão em dia',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _secondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isProcessing
                  ? null
                  : () => Navigator.pop(context),
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

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: 11,
      ),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_notificacoes.length} ${_notificacoes.length == 1 ? 'notificação' : 'notificações'}',
              style: const TextStyle(
                color: _secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (_naoLidas > 0)
            _buildToolbarAction(
              icon: Icons.done_all,
              label: isMobile ? 'Ler todas' : 'Marcar todas como lidas',
              onTap: _isProcessing ? null : _marcarTodasComoLidas,
            ),
          if (_naoLidas > 0)
            const SizedBox(width: 8),
          _buildToolbarAction(
            icon: Icons.delete_outline,
            label: 'Limpar',
            onTap: _isProcessing
                ? null
                : _confirmarLimparNotificacoes,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: onTap == null
                    ? _secondary
                    : isDanger
                        ? _danger
                        : _primary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: onTap == null
                      ? _secondary
                      : isDanger
                          ? _danger
                          : _primary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _primary,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 32,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nenhuma notificação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _foreground,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quando houver novidades sobre seu acompanhamento, elas aparecerão aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _secondary,
                height: 1.6,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(bool isMobile) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: 8,
      ),
      itemCount: _notificacoes.length,
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 1,
          color: _border,
        );
      },
      itemBuilder: (context, index) {
        return _buildNotificationItem(_notificacoes[index]);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif) {
    final isLida = _estaLida(notif);
    final tipo = notif['tipo']?.toString() ?? '';
    final titulo = notif['titulo']?.toString() ?? 'Notificação';
    final mensagem = notif['mensagem']?.toString() ?? '';
    final dataHora = _formatarDataHora(
      notif['data_criacao']?.toString(),
    );
    final id = notif['id'] is int
        ? notif['id'] as int
        : int.tryParse(notif['id']?.toString() ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLida
                  ? const Color(0xFFF3F2EF)
                  : _softBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getTipoIcon(tipo),
              size: 19,
              color: isLida ? _secondary : _primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isLida
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: _foreground,
                          height: 1.4,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    if (!isLida) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: const BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  mensagem,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _secondary,
                    height: 1.55,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _getTipoLabel(tipo),
                      style: const TextStyle(
                        fontSize: 11,
                        color: _secondary,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (dataHora.isNotEmpty)
                      Text(
                        dataHora,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _secondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    if (!isLida && id != null)
                      InkWell(
                        onTap: _isProcessing
                            ? null
                            : () => _marcarComoLida(id),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 14,
                                color: _primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Marcar como lida',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isProcessing
                                      ? _secondary
                                      : _primary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
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
        ],
      ),
    );
  }
}