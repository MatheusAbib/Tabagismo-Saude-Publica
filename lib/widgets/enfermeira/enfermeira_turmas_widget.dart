import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/cronograma_modal_widget.dart';
import 'package:tabagismo_app/widgets/enfermeira/modals/presenca_historico_modal_widget.dart';

class ListaPresencaWidget extends StatefulWidget {
  final int upaId;

  const ListaPresencaWidget({Key? key, required this.upaId}) : super(key: key);

  @override
  _ListaPresencaWidgetState createState() => _ListaPresencaWidgetState();
}

class _ListaPresencaWidgetState extends State<ListaPresencaWidget> {
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    final padding = isSmallMobile ? 8.0 : (isMobile ? 12.0 : 20.0);

    return FutureBuilder(
      future: AuthService().getUsuariosMatriculadosComPresencas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erro ao carregar: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final response = snapshot.data as Map<String, dynamic>;
        final turmasPorDia = _agruparTurmasPorDia(response['turmas']);

        if (turmasPorDia.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Color(0xFF94A3B8)),
                SizedBox(height: 16),
                Text(
                  'Nenhum usuário matriculado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aguardando matrículas na sua UPA',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: turmasPorDia.entries.map((entry) {
              return _buildDiaCard(entry.key, entry.value);
            }).toList(),
          ),
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> _agruparTurmasPorDia(List<dynamic> turmas) {
    Map<String, List<Map<String, dynamic>>> grupos = {};

    for (var turma in turmas) {
      String nome = turma['nome'] ?? '';
      String diaSemana = nome.split(' - ').first;
      
      if (!grupos.containsKey(diaSemana)) {
        grupos[diaSemana] = [];
      }
      grupos[diaSemana]!.add(turma);
    }

    return grupos;
  }

  Widget _buildDiaCard(String dia, List<Map<String, dynamic>> turmas) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFE2E8F0), const Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calendar_today, color: _accentColor, size: isMobile ? 16 : 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dia,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '${turmas.length} turma(s)',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: const Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...turmas.map((turma) {
            return _buildTurmaPresencaCard(turma);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTurmaPresencaCard(Map<String, dynamic> turma) {
    final usuarios = List<Map<String, dynamic>>.from(turma['usuarios'] ?? []);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 400;
    String nomeCompleto = turma['nome'] ?? '';

    return StatefulBuilder(
      builder: (context, setState) {
        bool _salvando = false;
        int vagasOcupadas = usuarios.length;
        int vagasTotais = turma['vagas_totais'] ?? 4;

          bool podeSalvar() {
            for (var usuario in usuarios) {
              bool temPresenca = usuario['presenca_status'] != null && usuario['presenca_status'] != 'nenhum';
              if (!temPresenca) {
                return false;
              }
            }
            return usuarios.isNotEmpty;
          }

        Future<void> salvarPresencas() async {
          setState(() => _salvando = true);
          try {
            final authService = AuthService();
            final now = DateTime.now();
            final dataStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

            final presencasParaSalvar = usuarios.map((u) => ({
              'matriculaId': u['matricula_id'],
              'status': u['presenca_status'] ?? 'falta',
              'observacao': u['observacao_semanal'],
            })).toList();

            await authService.salvarPresencasEmLote(presencasParaSalvar, dataStr);

            if (mounted) {
              ToastService.showSuccess(context, 'Presenças salvas com sucesso!');
              setState(() => _salvando = false);
            }
          } catch (e) {
            if (mounted) {
              ToastService.showError(context, 'Erro ao salvar presenças: $e');
              setState(() => _salvando = false);
            }
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      nomeCompleto,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: _accentColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$vagasOcupadas/$vagasTotais vagas',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: const Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              isMobile
                  ? _buildListaPresencaMobile(usuarios, setState)
                  : _buildListaPresencaDesktop(usuarios, setState),
              const SizedBox(height: 10),
              isMobile
                  ? _buildMobileActions(usuarios, setState, _salvando, podeSalvar, salvarPresencas, turma)
                  : _buildDesktopActions(usuarios, setState, _salvando, podeSalvar, salvarPresencas, turma),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileActions(List<Map<String, dynamic>> usuarios, Function setState, bool _salvando, bool Function() podeSalvar, Future<void> Function() salvarPresencas, Map<String, dynamic> turma) {
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (_salvando || !podeSalvar()) ? null : salvarPresencas,
            icon: _salvando
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(Icons.save, size: isSmallMobile ? 16 : 18),
            label: Text(
              isSmallMobile ? 'Marcar' : 'Marcar Presenças',
              style: TextStyle(fontSize: isSmallMobile ? 13 : 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_salvando || !podeSalvar()) ? Colors.grey.shade400 : _successColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 12 : 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(0, 42),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: _accentColor, size: isSmallMobile ? 24 : 28),
          offset: const Offset(0, 30),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'cronograma',
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 20, color: _accentColor),
                  const SizedBox(width: 12),
                  Text(
                    'Cronograma',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'historico',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20, color: _accentColor),
                  const SizedBox(width: 12),
                  Text(
                    'Histórico',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'encerrar',
              child: Row(
                children: [
                  Icon(Icons.close, size: 20, color: _dangerColor),
                  const SizedBox(width: 12),
                  Text(
                    'Encerrar Turma',
                    style: TextStyle(
                      fontSize: 14,
                      color: _dangerColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (String value) {
            switch (value) {
              case 'cronograma':
                _verCronogramaTurma(turma);
                break;
              case 'historico':
                _abrirHistoricoTurma(turma);
                break;
              case 'encerrar':
                _confirmarEncerrarTurma(turma);
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildDesktopActions(List<Map<String, dynamic>> usuarios, Function setState, bool _salvando, bool Function() podeSalvar, Future<void> Function() salvarPresencas, Map<String, dynamic> turma) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.more_vert, color: _accentColor),
              const SizedBox(width: 4),
              Text(
                'Opções',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _accentColor,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          offset: const Offset(0, 30),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'cronograma',
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 20, color: _accentColor),
                  const SizedBox(width: 12),
                  Text(
                    'Cronograma',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'historico',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20, color: _accentColor),
                  const SizedBox(width: 12),
                  Text(
                    'Histórico',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'encerrar',
              child: Row(
                children: [
                  Icon(Icons.close, size: 20, color: _dangerColor),
                  const SizedBox(width: 12),
                  Text(
                    'Encerrar Turma',
                    style: TextStyle(
                      fontSize: 14,
                      color: _dangerColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (String value) {
            switch (value) {
              case 'cronograma':
                _verCronogramaTurma(turma);
                break;
              case 'historico':
                _abrirHistoricoTurma(turma);
                break;
              case 'encerrar':
                _confirmarEncerrarTurma(turma);
                break;
            }
          },
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: (_salvando || !podeSalvar()) ? null : salvarPresencas,
          icon: _salvando
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(Icons.save, size: 16),
          label: const Text('Marcar Presenças'),
          style: ElevatedButton.styleFrom(
            backgroundColor: (_salvando || !podeSalvar()) ? Colors.grey.shade400 : _successColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(0, 38),
          ),
        ),
      ],
    );
  }

  Widget _buildListaPresencaMobile(List<Map<String, dynamic>> usuarios, Function setState) {
    final isSmallMobile = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: usuarios.map((usuario) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 4 : 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nome_completo'],
                        style: TextStyle(
                          fontSize: isSmallMobile ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatarCpf(usuario['cpf']?.toString() ?? ''),
                        style: TextStyle(
                          fontSize: isSmallMobile ? 9 : 10,
                          color: const Color(0xFF94A3B8),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallMobile ? 4 : 6),
                SizedBox(
                  width: isSmallMobile ? 60 : 80,
                  child: _buildPresencaDropdown(usuario, setState, isSmallMobile),
                ),
                SizedBox(width: isSmallMobile ? 4 : 6),
                SizedBox(
                  width: isSmallMobile ? 60 : 80,
                  child: _buildObservacaoDropdown(usuario, setState, isSmallMobile),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListaPresencaDesktop(List<Map<String, dynamic>> usuarios, Function setState) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Aluno / CPF',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Presença',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Observação',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...usuarios.map((usuario) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario['nome_completo'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatarCpf(usuario['cpf']?.toString() ?? ''),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildPresencaDropdown(usuario, setState, false),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildObservacaoDropdown(usuario, setState, false),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPresencaDropdown(Map<String, dynamic> usuario, Function setState, bool isSmall) {
    String? status = usuario['presenca_status'];
    String statusDisplay = status ?? 'nenhum';

    Map<String, String> statusOptions = {
      'presente': 'Presente',
      'falta': 'Falta',
      'nenhum': '-',
    };

    Map<String, Color> statusColors = {
      'presente': _successColor,
      'falta': _dangerColor,
      'nenhum': const Color(0xFF94A3B8),
    };

    return Container(
      decoration: BoxDecoration(
        color: statusColors[statusDisplay]?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusDisplay,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: isSmall ? 14 : 18),
          iconSize: isSmall ? 14 : 18,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w500,
            color: statusColors[statusDisplay],
            fontFamily: 'Inter',
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          items: statusOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Center(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: isSmall ? 9 : 11,
                    fontWeight: FontWeight.w500,
                    color: entry.key == 'nenhum' ? const Color(0xFF94A3B8) : statusColors[entry.key],
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null && newValue != 'nenhum') {
              setState(() {
                usuario['presenca_status'] = newValue;
              });
            } else if (newValue == 'nenhum') {
              setState(() {
                usuario['presenca_status'] = null;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildObservacaoDropdown(Map<String, dynamic> usuario, Function setState, bool isSmall) {
    String? observacao = usuario['observacao_semanal'];
    String observacaoDisplay = observacao ?? '';

    Map<String, String> observacaoOptions = {
      '': '-',
      '1- Está fumando': isSmall ? 'Fumando' : 'Fumando',
      '2- Sem fumar': isSmall ? 'Sem fumar' : 'Sem fumar',
    };

    Color getObservacaoColor(String? obs) {
      if (obs == '1- Está fumando') return _warningColor;
      if (obs == '2- Sem fumar') return _accentColor;
      return const Color(0xFF94A3B8);
    }

    return Container(
      decoration: BoxDecoration(
        color: getObservacaoColor(observacao).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: observacaoDisplay,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: isSmall ? 14 : 18),
          iconSize: isSmall ? 14 : 18,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w500,
            color: getObservacaoColor(observacao),
            fontFamily: 'Inter',
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          items: observacaoOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Center(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: isSmall ? 9 : 11,
                    fontWeight: FontWeight.w500,
                    color: getObservacaoColor(entry.key),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              usuario['observacao_semanal'] = newValue == '' ? null : newValue;
            });
          },
        ),
      ),
    );
  }

  String _formatarCpf(String cpf) {
    if (cpf.isEmpty) return 'Não informado';
    String apenasNumeros = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 11) {
      return '${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}';
    }
    return cpf;
  }

void _verCronogramaTurma(Map<String, dynamic> turma) {
  final matriculaId = turma['usuarios'].isNotEmpty ? turma['usuarios'][0]['matricula_id'] : null;
  if (matriculaId != null) {
    _verCronograma(matriculaId, turma['nome']);
  }
}
void _verCronograma(int matriculaId, String turmaHorario) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.only(
          left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
          right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
          top: 20,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.96 : (MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95),
          height: isMobile ? MediaQuery.of(context).size.height * 0.92 : (MediaQuery.of(context).size.height > 800 ? 700 : MediaQuery.of(context).size.height * 0.85),
          constraints: BoxConstraints(maxWidth: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: CronogramaModal(
              matriculaId: matriculaId,
              turmaHorario: turmaHorario,
            ),
          ),
        ),
      );
    },
  );
}

void _abrirHistoricoTurma(Map<String, dynamic> turma) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.only(
          left: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          right: isSmallMobile ? 8 : (isMobile ? 12 : 20),
          top: 20,
          bottom: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.96 : (MediaQuery.of(context).size.width > 1200 ? 1100 : MediaQuery.of(context).size.width * 0.95),
          height: isMobile 
              ? MediaQuery.of(context).size.height * 0.8
              : (MediaQuery.of(context).size.height > 800 ? 750 : MediaQuery.of(context).size.height * 0.85),
          constraints: BoxConstraints(maxWidth: 1100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: HistoricoTurmaModal(
              turmaNome: turma['nome'],
              upaNome: 'Pronto Atendimento Alto Ipiranga',
            ),
          ),
        ),
      );
    },
  );
}

void _confirmarEncerrarTurma(Map<String, dynamic> turma) async {
  String? tipoSelecionado;
  final isMobile = MediaQuery.of(context).size.width < 500;
  final isSmallMobile = MediaQuery.of(context).size.width < 400;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          insetPadding: EdgeInsets.only(
            left: isSmallMobile ? 4 : (isMobile ? 6 : 20),
            right: isSmallMobile ? 4 : (isMobile ? 6 : 20),
            top: 20,
            bottom: 20,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.96 : 420,
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Encerrar Turma',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Turma: ${turma['nome']}\n\nSelecione o tipo de encerramento:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.4,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Turma Concluída'),
                          subtitle: const Text('O programa foi finalizado com sucesso'),
                          value: 'concluida',
                          groupValue: tipoSelecionado,
                          onChanged: (value) {
                            setState(() => tipoSelecionado = value);
                          },
                          activeColor: const Color(0xFF2E8B6A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          dense: true,
                        ),
                        const Divider(),
                        RadioListTile<String>(
                          title: const Text('Turma Cancelada'),
                          subtitle: const Text('O programa foi interrompido antes do fim'),
                          value: 'cancelada',
                          groupValue: tipoSelecionado,
                          onChanged: (value) {
                            setState(() => tipoSelecionado = value);
                          },
                          activeColor: const Color(0xFFC65D47),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          dense: true,
                        ),
                      ],
                    ),
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
                              borderRadius: BorderRadius.circular(14),
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
                          onPressed: tipoSelecionado == null ? null : () async {
                            Navigator.pop(context);
                            await _encerrarTurma(turma, tipoSelecionado!);
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: Text(
                            tipoSelecionado == 'concluida' ? 'Concluir' : 'Cancelar Turma',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tipoSelecionado == 'concluida'
                                ? const Color(0xFF2E8B6A)
                                : const Color(0xFFC65D47),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  Future<void> _encerrarTurma(Map<String, dynamic> turma, String tipoEncerramento) async {
    try {
      await AuthService().encerrarTurma(widget.upaId, turma['nome'], tipoEncerramento);
      ToastService.showSuccess(context, 'Turma encerrada com sucesso!');
      setState(() {});
    } catch (e) {
      ToastService.showError(context, 'Erro ao encerrar turma: $e');
    }
  }
}