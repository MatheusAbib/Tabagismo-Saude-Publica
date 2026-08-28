import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/notification_service.dart';

class PollingService extends ChangeNotifier {
  Timer? _timer;
  bool _isRunning = false;
  int _notificacoesNaoLidas = 0;
  bool _temMatriculaAtiva = false;
  Map<String, dynamic>? _ultimaMatricula;
  int _versao = 0;
  
  final AuthService _authService = AuthService();
  
  bool get isRunning => _isRunning;
  int get notificacoesNaoLidas => _notificacoesNaoLidas;
  bool get temMatriculaAtiva => _temMatriculaAtiva;
  Map<String, dynamic>? get ultimaMatricula => _ultimaMatricula;
  int get versao => _versao;

  void startPolling() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _poll();
    });
    _poll();
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> _poll() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) return;

      int notificacoesAntigas = _notificacoesNaoLidas;
      bool matriculaAntiga = _temMatriculaAtiva;

      final response = await NotificationService.getNotificacoes();
      if (response != null) {
        _notificacoesNaoLidas = response['naoLidas'] ?? 0;
      }

      final matriculaResponse = await _authService.verificarMatriculaAtiva();
      if (matriculaResponse != null) {
        _temMatriculaAtiva = matriculaResponse['hasActiveEnrollment'] ?? false;
        _ultimaMatricula = matriculaResponse['enrollment'];
      }

      if (_notificacoesNaoLidas != notificacoesAntigas || _temMatriculaAtiva != matriculaAntiga) {
        _versao++;
        notifyListeners();
      }
    } catch (e) {
      // ignora erros
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}