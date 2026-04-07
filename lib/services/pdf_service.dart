import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> gerarRelatorioDashboard(
    Map<String, dynamic> dados,
    String nomeEnfermeira,
    String nomeUPA,
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text(
                'Desfumo',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Relatório de Dashboard - UPA',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Gerado por: $nomeEnfermeira',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'UPA: $nomeUPA',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 40),
              
              pw.Text(
                'Visão Geral',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Total Usuários', _parseToString(dados['totalUsuarios'])),
                  _buildInfoCard('Em Espera', _parseToString(dados['totalEmEspera'])),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Matriculados', _parseToString(dados['totalMatriculados'])),
                  _buildInfoCard('Cancelados', _parseToString(dados['totalCancelados'])),
                ],
              ),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Demografia',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Maiores de 18', _parseToString(dados['maiores18'])),
                  _buildInfoCard('Menores de 18', _parseToString(dados['menores18'])),
                ],
              ),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Distribuição por Sexo',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildSexoTable(dados['distribuicaoSexo']),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Saúde',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Comorbidade - Câncer', _parseToString(dados['usuariosComCancer'])),
                  _buildInfoCard('Comorbidade - Cardiovascular', _parseToString(dados['usuariosComCardiovascular'])),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  _buildInfoCard('Média Score Fagerström', 
                    _parseToDouble(dados['mediaScoreFagestrom']).toStringAsFixed(1)),
                ],
              ),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Escolaridade',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildEscolaridadeTable(dados['distribuicaoEscolaridade']),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Matrículas por Mês',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildMatriculasPorMes(dados['usuariosPorMes']),
            ],
          ),
        ],
      ),
    );
    
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'relatorio_${nomeUPA.replaceAll(' ', '_')}_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
    );
  }

  static Future<void> gerarRelatorioDashboardCompleto(
    Map<String, dynamic> stats,
    Map<String, dynamic> evolucao,
    String nomeEnfermeira,
    String nomeUPA,
  ) async {
    final pdf = pw.Document();
    
    final alunosAtivos = evolucao['alunos_ativos'] ?? {};
    final alunosConcluidos = evolucao['alunos_concluidos'] ?? {};
    final alunosDetalhados = List<Map<String, dynamic>>.from(evolucao['alunos_detalhados'] ?? []);
    final evolucaoMensalAtivos = List<Map<String, dynamic>>.from(evolucao['evolucao_mensal_ativos'] ?? []);
    final evolucaoMensalConcluidos = List<Map<String, dynamic>>.from(evolucao['evolucao_mensal_concluidos'] ?? []);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text(
                'Desfumo',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Relatório de Dashboard - UPA',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Gerado por: $nomeEnfermeira',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'UPA: $nomeUPA',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 40),
              
              pw.Text(
                'Visão Geral',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Total Usuários', _parseToString(stats['totalUsuarios'])),
                  _buildInfoCard('Em Espera', _parseToString(stats['totalEmEspera'])),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Matriculados', _parseToString(stats['totalMatriculados'])),
                  _buildInfoCard('Cancelados', _parseToString(stats['totalCancelados'])),
                ],
              ),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Evolução dos Alunos',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildEvolucaoCard('Alunos Ativos', alunosAtivos),
                  _buildEvolucaoCard('Alunos Concluídos', alunosConcluidos),
                ],
              ),
              pw.SizedBox(height: 30),
              
              if (evolucaoMensalAtivos.isNotEmpty) ...[
                pw.Text(
                  'Evolução Mensal - Alunos Ativos',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                _buildEvolucaoMensalTable(evolucaoMensalAtivos),
                pw.SizedBox(height: 30),
              ],
              
              if (evolucaoMensalConcluidos.isNotEmpty) ...[
                pw.Text(
                  'Evolução Mensal - Turmas Concluídas',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                _buildEvolucaoMensalConcluidosTable(evolucaoMensalConcluidos),
                pw.SizedBox(height: 30),
              ],
              
              if (alunosDetalhados.isNotEmpty) ...[
                pw.Text(
                  'Situação dos Alunos Ativos',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                _buildAlunosDetalhadosTable(alunosDetalhados),
                pw.SizedBox(height: 30),
              ],
              
              pw.Text(
                'Demografia',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Maiores de 18', _parseToString(stats['maiores18'])),
                  _buildInfoCard('Menores de 18', _parseToString(stats['menores18'])),
                ],
              ),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Distribuição por Sexo',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildSexoTable(stats['distribuicaoSexo']),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Saúde',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Comorbidade - Câncer', _parseToString(stats['usuariosComCancer'])),
                  _buildInfoCard('Comorbidade - Cardiovascular', _parseToString(stats['usuariosComCardiovascular'])),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  _buildInfoCard('Média Score Fagerström', 
                    _parseToDouble(stats['mediaScoreFagestrom']).toStringAsFixed(1)),
                ],
              ),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Escolaridade',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildEscolaridadeTable(stats['distribuicaoEscolaridade']),
              pw.SizedBox(height: 30),
              
              pw.Text(
                'Matrículas por Mês',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildMatriculasPorMes(stats['usuariosPorMes']),
            ],
          ),
        ],
      ),
    );
    
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'relatorio_completo_${nomeUPA.replaceAll(' ', '_')}_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
    );
  }
  
  static String _parseToString(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }
  
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  static pw.Widget _buildInfoCard(String titulo, String valor) {
    return pw.Container(
      width: 250,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            valor,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildEvolucaoCard(String titulo, Map<String, dynamic> dados) {
    final total = _parseToInt(dados['total']);
    final fumando = _parseToInt(dados['fumando']);
    final semFumar = _parseToInt(dados['sem_fumar']);
    final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);
    
    return pw.Container(
      width: 250,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Total: $total', style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: PdfColors.orange, shape: pw.BoxShape.circle)),
              pw.SizedBox(width: 4),
              pw.Text('Fumando: $fumando', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: PdfColors.blue, shape: pw.BoxShape.circle)),
              pw.SizedBox(width: 4),
              pw.Text('Sem fumar: $semFumar', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: 218,
            height: 8,
            decoration: pw.BoxDecoration(
              color: PdfColors.orange200,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Stack(
              children: [
                pw.Container(
                  width: total > 0 ? (semFumar / total) * 218 : 0,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Taxa de sucesso: ${taxaSucesso.toStringAsFixed(1)}%',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildEvolucaoMensalTable(List<Map<String, dynamic>> dados) {
    final rows = dados.map((item) {
      final mes = item['mes'] as String;
      final fumando = _parseToInt(item['fumando']);
      final semFumar = _parseToInt(item['sem_fumar']);
      final total = fumando + semFumar;
      
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(mes, style: pw.TextStyle(fontSize: 11)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(fumando.toString(), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(semFumar.toString(), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(total.toString(), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
        ],
      );
    }).toList();
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Mês', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Fumando', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Sem fumar', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }
  
  static pw.Widget _buildEvolucaoMensalConcluidosTable(List<Map<String, dynamic>> dados) {
    final rows = dados.map((item) {
      final mes = item['mes'] as String;
      final sucesso = _parseToInt(item['sucesso']);
      final insucesso = _parseToInt(item['insucesso']);
      final total = sucesso + insucesso;
      
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(mes, style: pw.TextStyle(fontSize: 11)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(sucesso.toString(), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(insucesso.toString(), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(total.toString(), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
        ],
      );
    }).toList();
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Mês', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Sucesso', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Insucesso', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }
  
  static pw.Widget _buildAlunosDetalhadosTable(List<Map<String, dynamic>> alunos) {
    final rows = alunos.map((aluno) {
      final ultimaObservacao = aluno['ultima_observacao'];
      String situacao = ultimaObservacao == '2- Sem fumar' ? 'Sem fumar' : (ultimaObservacao == '1- Está fumando' ? 'Fumando' : 'Sem registro');
      final semanasFumando = _parseToInt(aluno['semanas_fumando']);
      final semanasSemFumar = _parseToInt(aluno['semanas_sem_fumar']);
      
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(aluno['nome_completo'] ?? '', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('F: $semanasFumando | SF: $semanasSemFumar', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(aluno['turma_horario']?.split(' - ')[0] ?? '-', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: situacao == 'Sem fumar' ? PdfColors.blue100 : (situacao == 'Fumando' ? PdfColors.orange100 : PdfColors.grey100),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Text(
                situacao,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: situacao == 'Sem fumar' ? PdfColors.blue700 : (situacao == 'Fumando' ? PdfColors.orange700 : PdfColors.grey700),
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }).toList();
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Aluno', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Turma', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Situação', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }
  
  static pw.Widget _buildSexoTable(List<dynamic> sexoData) {
    int masculino = 0;
    int feminino = 0;
    int outro = 0;
    
    for (var item in sexoData) {
      if (item['sexo'] == 'Masculino') masculino = _parseToInt(item['total']);
      else if (item['sexo'] == 'Feminino') feminino = _parseToInt(item['total']);
      else outro = _parseToInt(item['total']);
    }
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text(masculino.toString(), style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
              pw.Text('Masculino', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
        pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.pink50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text(feminino.toString(), style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.pink700)),
              pw.Text('Feminino', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
        pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text(outro.toString(), style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.purple700)),
              pw.Text('Outro', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildEscolaridadeTable(List<dynamic> escolaridadeData) {
    final rows = escolaridadeData.map((item) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(item['escolaridade'] ?? 'Não informado', style: pw.TextStyle(fontSize: 11)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(_parseToString(item['total']), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
        ],
      );
    }).toList();
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Escolaridade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Quantidade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }
  
  static pw.Widget _buildMatriculasPorMes(List<dynamic> dados) {
    if (dados.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text('Sem dados disponíveis', style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.center),
      );
    }
    
    final rows = dados.reversed.map((item) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(item['mes'].toString(), style: pw.TextStyle(fontSize: 11)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(_parseToString(item['total']), style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.center),
          ),
        ],
      );
    }).toList();
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Mês', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text('Matrículas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12), textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );
  }

static Future<void> gerarRelatorioAdminDashboardCompleto(
  Map<String, dynamic> stats,
  Map<String, dynamic> evolucao,
  String nomeAdmin,
) async {
  final pdf = pw.Document();
  
  final alunosAtivos = evolucao['alunos_ativos'] ?? {};
  final alunosConcluidos = evolucao['alunos_concluidos'] ?? {};
  final alunosDetalhados = List<Map<String, dynamic>>.from(evolucao['alunos_detalhados'] ?? []);
  final evolucaoMensalAtivos = List<Map<String, dynamic>>.from(evolucao['evolucao_mensal_ativos'] ?? []);
  final usuariosPorMes = List<Map<String, dynamic>>.from(stats['usuariosPorMes'] ?? []);
  
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            pw.Text(
              'Desfumo',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Relatório de Dashboard - Administrador',
              style: pw.TextStyle(
                fontSize: 18,
                color: PdfColors.grey700,
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text(
              'Gerado por: $nomeAdmin',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 40),
            
            pw.Text(
              'Visão Geral do Sistema',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Total Usuários', _parseToString(stats['totalUsuarios'])),
                _buildInfoCard('Enfermeiras', _parseToString(stats['totalEnfermeiras'])),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Matrículas', _parseToString(stats['totalMatriculas'])),
                _buildInfoCard('UPAs', _parseToString(stats['totalUPAs'])),
              ],
            ),
            pw.SizedBox(height: 30),
            
            pw.Text(
              'Evolução dos Alunos',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildEvolucaoCardAdmin('Alunos Ativos', alunosAtivos),
                _buildEvolucaoCardAdmin('Alunos Concluídos', alunosConcluidos),
              ],
            ),
            pw.SizedBox(height: 30),
            
            if (evolucaoMensalAtivos.isNotEmpty) ...[
              pw.Text(
                'Evolução Mensal - Alunos Ativos',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildEvolucaoMensalTable(evolucaoMensalAtivos),
              pw.SizedBox(height: 30),
            ],
            
            if (alunosDetalhados.isNotEmpty) ...[
              pw.Text(
                'Situação dos Alunos Ativos',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildAlunosDetalhadosTable(alunosDetalhados),
              pw.SizedBox(height: 30),
            ],
            
            pw.Text(
              'Demografia',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Maiores de 18', _parseToString(stats['maiores18'])),
                _buildInfoCard('Menores de 18', _parseToString(stats['menores18'])),
              ],
            ),
            pw.SizedBox(height: 30),
            
            pw.Text(
              'Distribuição por Sexo',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            _buildSexoTable(stats['distribuicaoSexo']),
            pw.SizedBox(height: 30),
            
            pw.Text(
              'Saúde',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Comorbidade - Câncer', _parseToString(stats['usuariosComCancer'])),
                _buildInfoCard('Comorbidade - Cardiovascular', _parseToString(stats['usuariosComCardiovascular'])),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                _buildInfoCard('Média Score Fagerström', 
                  _parseToDouble(stats['mediaScoreFagestrom']).toStringAsFixed(1)),
              ],
            ),
            pw.SizedBox(height: 30),
            
            pw.Text(
              'Escolaridade',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            _buildEscolaridadeTable(stats['distribuicaoEscolaridade']),
            pw.SizedBox(height: 30),
            
            if (usuariosPorMes.isNotEmpty) ...[
              pw.Text(
                'Matrículas por Mês',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              _buildMatriculasPorMes(usuariosPorMes),
            ],
          ],
        ),
      ],
    ),
  );
  
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'relatorio_admin_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
  );
}

static pw.Widget _buildEvolucaoCardAdmin(String titulo, Map<String, dynamic> dados) {
  final total = _parseToInt(dados['total']);
  final fumando = _parseToInt(dados['fumando']);
  final semFumar = _parseToInt(dados['sem_fumar']);
  final taxaSucesso = _parseToDouble(dados['taxa_sucesso']);
  
  return pw.Container(
    width: 250,
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Total: $total', style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: PdfColors.orange, shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 4),
            pw.Text('Fumando: $fumando', style: pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: PdfColors.blue, shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 4),
            pw.Text('Sem fumar: $semFumar', style: pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: 218,
          height: 8,
          decoration: pw.BoxDecoration(
            color: PdfColors.orange200,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Stack(
            children: [
              pw.Container(
                width: total > 0 ? (semFumar / total) * 218 : 0,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Taxa de sucesso: ${taxaSucesso.toStringAsFixed(1)}%',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
        ),
      ],
    ),
  );
}



}