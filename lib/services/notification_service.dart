import 'package:tabagismo_app/services/auth_service.dart';

class NotificationService {
  static Future<Map<String, dynamic>> getNotificacoes() async {
    final authService = AuthService();
    return await authService.getNotificacoes();
  }
  
  static Future<void> marcarComoLida(int id) async {
    final authService = AuthService();
    await authService.marcarNotificacaoComoLida(id);
  }
  
  static Future<void> marcarTodasComoLidas() async {
    final authService = AuthService();
    await authService.marcarTodasNotificacoesComoLidas();
  }
  
  static Future<void> limparTodas() async {
    final authService = AuthService();
    await authService.limparTodasNotificacoes();
  }
}