import 'package:flutter/material.dart';

class HomeSobreWidget extends StatefulWidget {
  const HomeSobreWidget({Key? key}) : super(key: key);

  @override
  _HomeSobreWidgetState createState() => _HomeSobreWidgetState();
}

class _HomeSobreWidgetState extends State<HomeSobreWidget> {
  bool _isGuiaCardExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1100;

    if (isMobile) {
      return Column(
        children: [
          _buildGuiaCard(),
          const SizedBox(height: 24),
          _buildProgramaInfoCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildGuiaCard(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 7,
          child: _buildProgramaInfoCard(),
        ),
      ],
    );
  }

  Widget _buildGuiaCard() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isGuiaCardExpanded = !_isGuiaCardExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 14 : 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, size: isMobile ? 22 : 28, color: const Color(0xFF1F4E6E)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isMobile ? 'Como usar' : 'Como usar o DESFUMO',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Icon(
                    _isGuiaCardExpanded ? Icons.expand_less : Icons.expand_more,
                    size: isMobile ? 22 : 28,
                    color: const Color(0xFF1F4E6E),
                  ),
                ],
              ),
            ),
          ),
          if (_isGuiaCardExpanded)
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              child: Column(
                children: [
                  _buildGuiaItem(
                    Icons.school_outlined,
                    'Turmas de Apoio',
                    'Encontre UPAs próximas, veja vagas disponíveis e faça sua matrícula em turmas de apoio ao tabagismo.',
                    const Color(0xFF1F4E6E),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  _buildGuiaItem(
                    Icons.list_alt_outlined,
                    'Minhas Matrículas',
                    'Acompanhe suas matrículas, veja o status (em espera, confirmada, cancelada) e gerencie suas inscrições.',
                    const Color(0xFF6B21A8),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  _buildGuiaItem(
                    Icons.assessment_outlined,
                    'Teste de Fagerström',
                    'Avalie seu nível de dependência à nicotina com base em 6 perguntas simples.',
                    const Color(0xFFD97706),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  _buildGuiaItem(
                    Icons.monitor_heart_outlined,
                    'Registrar Sintomas',
                    'Registre diariamente ansiedade, irritabilidade, insônia e outros sintomas em uma escala de 0 a 10.',
                    const Color(0xFF2E8B6A),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  _buildGuiaItem(
                    Icons.show_chart_outlined,
                    'Gráfico de Evolução',
                    'Visualize a evolução dos seus sintomas ao longo do tempo.',
                    const Color(0xFFC65D47),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuiaItem(IconData icon, String title, String description, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: isMobile ? 20 : 28, color: color),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: const Color(0xFF475569),
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgramaInfoCard() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1F4E6E), size: 28),
              SizedBox(width: 12),
              Text(
                'Sobre o Programa de Turmas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoItem(
            Icons.how_to_reg_outlined,
            'Matrícula',
            'Escolha uma UPA e turma disponível. Após a matrícula, você entra na lista de espera. Em até 5 dias úteis, a UPA confirma sua vaga.',
            const Color(0xFF1F4E6E),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.calendar_today_outlined,
            'Frequência',
            'Encontros semanais no primeiro mês e quinzenais depois. Cada encontro dura cerca de 2 horas.',
            const Color(0xFF2E8B6A),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.group_outlined,
            'Dinâmica dos Grupos',
            'Espaço acolhedor com roda de conversa, educação em saúde, técnicas de enfrentamento e atividades práticas.',
            const Color(0xFFD97706),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.medical_services_outlined,
            'Equipe Profissional',
            'Coordenado por médicos especialistas, psicólogos, enfermeiros e educadores físicos.',
            const Color(0xFF6B21A8),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.phone_android_outlined,
            'Suporte Contínuo',
            'Mensagens de apoio, material informativo, acompanhamento telefônico e grupo online.',
            const Color(0xFF14B8A6),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: isMobile ? 20 : 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: const Color(0xFF475569),
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}