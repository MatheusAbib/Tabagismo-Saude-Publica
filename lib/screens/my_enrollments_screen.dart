import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header_widget.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  
  const MyEnrollmentsScreen({Key? key, this.userData, this.onNameUpdated}) : super(key: key);

  @override
  _MyEnrollmentsScreenState createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> {
  final _enrollmentService = EnrollmentService();
  List<Map<String, dynamic>> _enrollments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _enrollmentService.getMyEnrollments();
      
      if (response['success'] == true || response['data'] != null) {
        setState(() {
          _enrollments = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Erro ao carregar matrículas';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar matrículas: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _verDetalhes(Map<String, dynamic> enrollment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          child: DetailsModal(
            enrollment: enrollment,
            onCancel: () => _confirmarCancelamento(enrollment),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarCancelamento(Map<String, dynamic> enrollment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Matrícula'),
        content: Text(
          'Tem certeza que deseja cancelar sua matrícula na ${enrollment['upa_nome']}?\n\n'
          'Turma: ${enrollment['turma_horario']}\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelarMatricula(enrollment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Sim, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarMatricula(Map<String, dynamic> enrollment) async {
    setState(() => _isLoading = true);
    
    try {
      await _enrollmentService.cancelEnrollment(enrollment['id']);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matrícula cancelada com sucesso!')),
      );
      
      await _loadEnrollments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar matrícula: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera':
        return 'Em Espera';
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(
            userName: widget.userData?['nomeCompleto'] ?? 'Usuário',
            userData: widget.userData,
            onNameUpdated: widget.onNameUpdated,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.grey.shade50,
                    child: InkWell(
                      onTap: _mostrarInformacoesGrupos,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Como funcionam as turmas e grupos de apoio?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                                  SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(fontSize: 16, color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadEnrollments,
                                    child: Text('Tentar Novamente'),
                                  ),
                                ],
                              ),
                            )
                          : _enrollments.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.list_alt, size: 80, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'Você ainda não tem matrículas',
                                        style: TextStyle(fontSize: 18, color: Colors.grey),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Vá em "Encontrar UPAs" e se matricule em uma turma',
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(16),
                                  itemCount: _enrollments.length,
                                  itemBuilder: (context, index) {
                                    final enrollment = _enrollments[index];
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    enrollment['upa_nome'] ?? 'UPA não identificada',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    if (enrollment['status'] == 'em_espera')
                                                      IconButton(
                                                        icon: Icon(Icons.delete_outline, color: Colors.red),
                                                        onPressed: () => _confirmarCancelamento(enrollment),
                                                        tooltip: 'Cancelar matrícula',
                                                      ),
                                                    IconButton(
                                                      icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                                                      onPressed: () => _verDetalhes(enrollment),
                                                      tooltip: 'Ver detalhes',
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(enrollment['status'] ?? 'em_espera').withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        _getStatusText(enrollment['status'] ?? 'em_espera'),
                                                        style: TextStyle(
                                                          color: _getStatusColor(enrollment['status'] ?? 'em_espera'),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Turma: ${enrollment['turma_horario'] ?? 'Não informado'}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            if (enrollment['segunda_opcao_turma'] != null && enrollment['segunda_opcao_turma'].isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: 4),
                                                child: Text(
                                                  '2ª opção: ${enrollment['segunda_opcao_turma']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange.shade700,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Data da matrícula: ${_formatDate(enrollment['created_at'])}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            if (enrollment['status'] == 'em_espera')
                                              Padding(
                                                padding: EdgeInsets.only(top: 12),
                                                child: Text(
                                                  '📌 Aguardando confirmação da UPA. Em até 5 dias você receberá o contato.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            if (enrollment['status'] == 'confirmada')
                                              Padding(
                                                padding: EdgeInsets.only(top: 12),
                                                child: Text(
                                                  '✅ Matrícula confirmada! Em breve você receberá mais informações.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            if (enrollment['status'] == 'cancelada')
                                              Padding(
                                                padding: EdgeInsets.only(top: 12),
                                                child: Text(
                                                  '❌ Matrícula cancelada',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                  FooterWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInformacoesGrupos() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Como Funcionam as Turmas'),
              backgroundColor: Colors.blue.shade700,
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    icon: Icons.how_to_reg,
                    title: 'Processo de Matrícula',
                    content: 'Após realizar sua matrícula em uma das turmas disponíveis, você entrará na lista de espera. Em até 5 dias úteis, a UPA entrará em contato pelo telefone cadastrado para confirmar sua vaga e fornecer mais informações sobre o início das atividades.',
                    color: Colors.blue,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.calendar_today,
                    title: 'Frequência dos Encontros',
                    content: 'O programa de apoio é estruturado da seguinte forma:\n\n'
                        '• Primeiro mês: Encontros SEMANAIS (1 vez por semana)\n'
                        '• Meses seguintes: Encontros QUINZENAIS (a cada 15 dias)\n\n'
                        'Cada encontro tem duração aproximada de 2 horas e é conduzido por profissionais de saúde especializados.',
                    color: Colors.green,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.group_work,
                    title: 'Dinâmica dos Grupos',
                    content: 'Os grupos são espaços acolhedores e sigilosos onde você encontrará apoio para sua jornada de abandono do tabagismo. A dinâmica inclui:\n\n'
                        '📌 Roda de Conversa: Compartilhamento de experiências e desafios com outros participantes\n\n'
                        '📌 Educação em Saúde: Informações sobre os efeitos do tabagismo e benefícios de parar de fumar\n\n'
                        '📌 Estratégias de Enfrentamento: Técnicas para lidar com a fissura, ansiedade e sintomas de abstinência\n\n'
                        '📌 Atividades Práticas: Exercícios respiratórios, relaxamento e mindfulness\n\n'
                        '📌 Acompanhamento Individual: Profissionais disponíveis para orientação personalizada\n\n'
                        '📌 Material de Apoio: Recebimento de materiais educativos e folders informativos\n\n'
                        '📌 Rede de Apoio: Criação de vínculos com outras pessoas que estão na mesma jornada',
                    color: Colors.orange,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.medical_services,
                    title: 'Acompanhamento Profissional',
                    content: 'Os grupos são coordenados por uma equipe multidisciplinar composta por:\n\n'
                        '• Médicos especialistas em tabagismo\n'
                        '• Psicólogos\n'
                        '• Enfermeiros\n'
                        '• Educadores físicos\n\n'
                        'Todos os profissionais são capacitados para oferecer o melhor suporte durante todo o processo.',
                    color: Colors.purple,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.phone_android,
                    title: 'Comunicação e Suporte',
                    content: 'Além dos encontros presenciais, você receberá:\n\n'
                        '✓ Mensagens de apoio e lembretes dos encontros via WhatsApp\n'
                        '✓ Material informativo complementar\n'
                        '✓ Acompanhamento via telefone nos intervalos entre encontros\n'
                        '✓ Grupo de suporte online para troca de experiências',
                    color: Colors.teal,
                  ),
                  SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.emoji_events,
                    title: 'Benefícios do Programa',
                    content: 'Participar do programa oferece:\n\n'
                        '🏆 Aumento significativo nas chances de parar de fumar\n'
                        '🏆 Redução dos sintomas de abstinência\n'
                        '🏆 Melhora na qualidade de vida e saúde\n'
                        '🏆 Economia financeira significativa\n'
                        '🏆 Rede de apoio e novas amizades\n'
                        '🏆 Acompanhamento profissional contínuo',
                    color: Colors.amber,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lembre-se: cada passo dado é uma vitória! Você não está sozinho nessa jornada.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        backgroundColor: Colors.blue.shade700,
                      ),
                      child: Text(
                        'Entendi',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Data não disponível';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

class DetailsModal extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  final VoidCallback? onCancel;

  const DetailsModal({Key? key, required this.enrollment, this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> comorbidades = {};
    if (enrollment['comorbidades'] != null) {
      if (enrollment['comorbidades'] is String) {
        try {
          comorbidades = Map<String, dynamic>.from(
            json.decode(enrollment['comorbidades'])
          );
        } catch (e) {
          comorbidades = {};
        }
      } else {
        comorbidades = Map<String, dynamic>.from(enrollment['comorbidades']);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Detalhes da Matrícula'),
          backgroundColor: Colors.blue.shade700,
          actions: [
            if (enrollment['status'] == 'em_espera' && onCancel != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  onCancel!(); // Adicione ! para garantir que não é null
                },
                tooltip: 'Cancelar matrícula',
              ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('UPA', enrollment['upa_nome'] ?? 'Não informado'),
            SizedBox(height: 12),
            _buildInfoCard('Turma', enrollment['turma_horario'] ?? 'Não informado'),
            SizedBox(height: 12),
            if (enrollment['segunda_opcao_turma'] != null && enrollment['segunda_opcao_turma'].isNotEmpty)
              _buildInfoCard(
                'Segunda Opção', 
                enrollment['segunda_opcao_turma'],
                color: Colors.orange,
              ),
            SizedBox(height: 12),
            _buildInfoCard('Data da Matrícula', _formatDate(enrollment['created_at'])),
            SizedBox(height: 12),
            _buildInfoCard('Status', _getStatusText(enrollment['status'] ?? 'em_espera'),
                color: _getStatusColor(enrollment['status'] ?? 'em_espera')),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Informações Pessoais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoCard('Escolaridade', enrollment['escolaridade'] ?? 'Não informado'),
            SizedBox(height: 12),
            _buildInfoCard('Score Fagestrom', enrollment['score_fagestrom']?.toString() ?? 'Não informado'),
            SizedBox(height: 12),
            _buildInfoCard('Medicamento', enrollment['medicamento'] ?? 'Não informado'),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Comorbidades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildComorbidadesSection('Câncer', comorbidades['cancer'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Cardiovascular', comorbidades['cardiovascular'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Metabólico', comorbidades['metabolico'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Psiquiátrico', comorbidades['psiquiatrico'] ?? []),
            SizedBox(height: 12),
            _buildComorbidadesSection('Respiratório', comorbidades['respiratorio'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color? color}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComorbidadesSection(String titulo, List<dynamic> comorbidades) {
    if (comorbidades.isEmpty) {
      return SizedBox.shrink();
    }

    List<String> itens = [];
    for (var item in comorbidades) {
      if (item is Map) {
        String valor = item['valor'] ?? '';
        if (item['outroTexto'] != null && item['outroTexto'].toString().isNotEmpty) {
          valor = '${valor}: ${item['outroTexto']}';
        }
        itens.add(valor);
      } else if (item is String) {
        itens.add(item);
      }
    }

    if (itens.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: itens.map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: Colors.grey.shade200,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Data não disponível';
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'em_espera':
        return 'Em Espera';
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_espera':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}