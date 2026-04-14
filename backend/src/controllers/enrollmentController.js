const pool = require('../config/database');
const notificacaoController = require('./notificacaoController');
console.log('✅ enrollmentController carregado');

exports.createEnrollment = async (req, res) => {
  try {
    console.log('🔵 createEnrollment chamado');
    console.log('🔵 req.userId:', req.userId);
    console.log('🔵 req.body:', JSON.stringify(req.body, null, 2));
    
    const userId = req.userId || req.user?.id;
    
    if (!userId) {
      return res.status(401).json({ message: 'Usuário não autenticado' });
    }

    const {
      upaId,
      upaNome,
      turmaHorario,
      segundaOpcaoTurma,
      escolaridade,
      scoreFagestrom,
      medicamento,
      comorbidades
    } = req.body;

    if (!upaId || !turmaHorario || !escolaridade || !scoreFagestrom || !medicamento) {
      return res.status(400).json({ 
        message: 'Campos obrigatórios não preenchidos',
        missing: { upaId, turmaHorario, escolaridade, scoreFagestrom, medicamento }
      });
    }

    const [matriculaAtiva] = await pool.query(
      `SELECT id, status, upa_nome, turma_horario 
       FROM matriculas 
       WHERE usuario_id = ? AND status IN ('em_espera', 'matriculado')`,
      [userId]
    );

    if (matriculaAtiva.length > 0) {
      const statusTexto = matriculaAtiva[0].status === 'em_espera' ? 'em espera' : 'ativa';
      return res.status(400).json({ 
        message: `Você já possui uma matrícula ${statusTexto} na UPA ${matriculaAtiva[0].upa_nome} (Turma: ${matriculaAtiva[0].turma_horario})`,
        hasActiveEnrollment: true,
        enrollment: matriculaAtiva[0]
      });
    }

    const [turmaPrimeiraOpcao] = await pool.query(
      `SELECT id, vagas_totais, vagas_ocupadas 
       FROM turmas 
       WHERE upa_id = ? AND CONCAT(dia_semana, ' - ', horario) = ?`,
      [upaId, turmaHorario]
    );

    let turmaAlocada = null;
    let turmaHorarioFinal = turmaHorario;
    let segundaOpcaoUtilizada = false;

    if (turmaPrimeiraOpcao.length > 0 && turmaPrimeiraOpcao[0].vagas_ocupadas < turmaPrimeiraOpcao[0].vagas_totais) {
      turmaAlocada = turmaPrimeiraOpcao[0];
    } else if (segundaOpcaoTurma && segundaOpcaoTurma.trim() !== '') {
      const [turmaSegundaOpcao] = await pool.query(
        `SELECT id, vagas_totais, vagas_ocupadas 
         FROM turmas 
         WHERE upa_id = ? AND CONCAT(dia_semana, ' - ', horario) = ?`,
        [upaId, segundaOpcaoTurma]
      );
      
      if (turmaSegundaOpcao.length > 0 && turmaSegundaOpcao[0].vagas_ocupadas < turmaSegundaOpcao[0].vagas_totais) {
        turmaAlocada = turmaSegundaOpcao[0];
        turmaHorarioFinal = segundaOpcaoTurma;
        segundaOpcaoUtilizada = true;
      }
    }

    if (!turmaAlocada) {
      return res.status(400).json({ 
        message: 'Não há vagas disponíveis na primeira e nem na segunda opção de turma.'
      });
    }

    await pool.query('START TRANSACTION');

    let comorbidadesJson = '{}';
    if (comorbidades) {
      try {
        comorbidadesJson = typeof comorbidades === 'string' 
          ? comorbidades 
          : JSON.stringify(comorbidades);
      } catch (e) {
        comorbidadesJson = '{}';
      }
    }

    const [result] = await pool.query(
      `INSERT INTO matriculas 
      (usuario_id, upa_id, upa_nome, turma_horario, segunda_opcao_turma, escolaridade, score_fagestrom, medicamento, comorbidades, status) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId, 
        upaId, 
        upaNome, 
        turmaHorarioFinal,
        segundaOpcaoTurma || null,
        escolaridade, 
        scoreFagestrom, 
        medicamento, 
        comorbidadesJson,
        'em_espera'
      ]
    );

    await pool.query('COMMIT');

    let mensagemSucesso = 'Sua matrícula foi realizada com sucesso! Você está na lista de espera.';
    if (segundaOpcaoUtilizada) {
      mensagemSucesso = `Sua primeira opção (${turmaHorario}) estava lotada. Você foi alocado na segunda opção (${segundaOpcaoTurma}). ${mensagemSucesso}`;
    }

    await notificacaoController.criarNotificacao(
      userId,
      segundaOpcaoUtilizada ? 'Matrícula Realizada (Segunda Opção)' : 'Matrícula Realizada',
      mensagemSucesso + `\n\nUPA: ${upaNome}\nTurma: ${turmaHorarioFinal}\n\nAguarde contato da UPA em até 5 dias úteis para confirmação.`,
      'matricula',
      '/my-enrollments'
    );

    res.status(201).json({ 
      message: mensagemSucesso,
      enrollmentId: result.insertId,
      status: 'em_espera',
      turmaAlocada: turmaHorarioFinal,
      segundaOpcaoUtilizada: segundaOpcaoUtilizada
    });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Erro detalhado:', error);
    res.status(500).json({ 
      message: 'Erro ao realizar matrícula: ' + error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

exports.verificarMatriculaAtiva = async (req, res) => {
  try {
    const userId = req.userId || req.user?.id;
    
    if (!userId) {
      return res.status(401).json({ error: 'Usuário não autenticado' });
    }
    
    const [matriculaAtiva] = await pool.query(
      `SELECT id, status, upa_nome, turma_horario 
       FROM matriculas 
       WHERE usuario_id = ? AND status IN ('em_espera', 'matriculado')`,
      [userId]
    );
    
    if (matriculaAtiva.length > 0) {
      res.json({
        hasActiveEnrollment: true,
        enrollment: matriculaAtiva[0]
      });
    } else {
      res.json({
        hasActiveEnrollment: false,
        enrollment: null
      });
    }
  } catch (error) {
    console.error('Erro ao verificar matrícula ativa:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUserEnrollments = async (req, res) => {
  try {
    const userId = req.userId || req.user?.id;
    
    const [matriculas] = await pool.query(
      `SELECT 
        m.*,
        'matricula' as tipo,
        NULL as percentual_presenca,
        NULL as total_presencas,
        NULL as total_faltas,
        NULL as evolucao
       FROM matriculas m
       WHERE m.usuario_id = ?
       ORDER BY m.created_at DESC`,
      [userId]
    );
    
    const [concluidas] = await pool.query(
      `SELECT 
        ac.id,
        ac.usuario_id,
        tc.upa_id,
        tc.upa_nome,
        tc.turma_horario,
        'concluida' as status,
        'concluida' as status_display,
        ac.created_at,
        ac.percentual_presenca,
        ac.total_presencas,
        ac.total_faltas,
        ac.evolucao,
        'concluida' as tipo,
        tc.tipo_encerramento
       FROM alunos_concluidos ac
       JOIN turmas_concluidas tc ON ac.turma_concluida_id = tc.id
       WHERE ac.usuario_id = ?
       ORDER BY ac.created_at DESC`,
      [userId]
    );
    
    const todasMatriculas = [...matriculas, ...concluidas];
    
    todasMatriculas.sort((a, b) => {
      return new Date(b.created_at) - new Date(a.created_at);
    });
    
    res.json({ 
      success: true,
      data: todasMatriculas,
      count: todasMatriculas.length
    });
  } catch (error) {
    console.error('Erro ao buscar matrículas:', error);
    res.status(500).json({ 
      success: false,
      message: 'Erro ao buscar matrículas: ' + error.message 
    });
  }
};

exports.getCronograma = async (req, res) => {
  try {
    const { matriculaId } = req.params;
    
    const [matricula] = await pool.query(
      `SELECT m.*, u.nome_completo 
       FROM matriculas m
       JOIN usuarios u ON m.usuario_id = u.id
       WHERE m.id = ?`,
      [matriculaId]
    );
    
    if (matricula.length === 0) {
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    const [turma] = await pool.query(
      `SELECT t.id, t.dia_semana, t.horario as turma_horario
       FROM turmas t
       WHERE t.upa_id = ? AND CONCAT(t.dia_semana, ' - ', t.horario) = ?`,
      [matricula[0].upa_id, matricula[0].turma_horario]
    );
    
    if (turma.length === 0) {
      return res.json({
        aulas: [],
        total_aulas: 0,
        data_inicio: '',
        turma: matricula[0].turma_horario,
        proxima_aula: null
      });
    }
    
    const [aulas] = await pool.query(
      `SELECT c.*, DATE_FORMAT(c.data, '%d/%m/%Y') as data_formatada
       FROM cronograma c
       WHERE c.turma_id = ?
       ORDER BY c.numero_aula ASC`,
      [turma[0].id]
    );
    
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    
    let proximaAula = null;
    for (const aula of aulas) {
      const dataAula = new Date(aula.data);
      if (dataAula >= hoje) {
        proximaAula = {
          data_formatada: aula.data_formatada,
          horario: aula.horario,
          numero: aula.numero_aula
        };
        break;
      }
    }
    
    const aulasFormatadas = aulas.map(aula => ({
      numero: aula.numero_aula,
      data: aula.data,
      data_formatada: aula.data_formatada,
      horario: aula.horario,
      mes: aula.mes
    }));
    
    const dataInicio = aulas.length > 0 ? aulas[0].data_formatada : '';
    
    res.json({
      aulas: aulasFormatadas,
      total_aulas: aulas.length,
      data_inicio: dataInicio,
      turma: matricula[0].turma_horario,
      proxima_aula: proximaAula
    });
    
  } catch (error) {
    console.error('Erro ao buscar cronograma:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.updateEnrollmentStatus = async (req, res) => {
  try {
    const { enrollmentId } = req.params;
    const { status, turmaHorario } = req.body;
    
    await pool.query('START TRANSACTION');
    
    const [enrollment] = await pool.query(
      'SELECT upa_id, turma_horario, status as status_atual FROM matriculas WHERE id = ?',
      [enrollmentId]
    );
    
    if (enrollment.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ message: 'Matrícula não encontrada' });
    }
    
    const turmaFinal = turmaHorario || enrollment[0].turma_horario;
    
    if (status === 'matriculado' && enrollment[0].status_atual !== 'matriculado') {
      const [turma] = await pool.query(
        `SELECT id FROM turmas 
         WHERE upa_id = ? AND CONCAT(dia_semana, ' - ', horario) = ?`,
        [enrollment[0].upa_id, turmaFinal]
      );
      
      if (turma.length > 0) {
        await pool.query(
          'UPDATE turmas SET vagas_ocupadas = vagas_ocupadas + 1 WHERE id = ?',
          [turma[0].id]
        );
      }
    }
    
    await pool.query(
      `UPDATE matriculas SET status = ?, turma_horario = ? WHERE id = ?`,
      [status, turmaFinal, enrollmentId]
    );
    
    await pool.query('COMMIT');
    res.json({ message: 'Status atualizado com sucesso', status });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error(error);
    res.status(500).json({ message: 'Erro ao atualizar status: ' + error.message });
  }
};

exports.getMinhasPresencas = async (req, res) => {
  try {
    const usuarioId = req.userId || req.user?.id;
    console.log('Buscando presenças para usuário:', usuarioId);
    
    const [matriculas] = await pool.query(
      'SELECT id FROM matriculas WHERE usuario_id = ? AND status = "matriculado" ORDER BY created_at ASC',
      [usuarioId]
    );
    
    console.log('Matrículas encontradas:', matriculas);
    
    if (matriculas.length === 0) {
      return res.json({ presencas: [], estatisticas: { presentes: 0, faltas: 0, justificadas: 0, total: 0, percentual: '0' }, mensagem: 'Você não possui matrícula ativa' });
    }
    
    let matriculaId = null;
    let presencas = [];
    
    for (let mat of matriculas) {
      const [check] = await pool.query(
        'SELECT COUNT(*) as total FROM presencas WHERE matricula_id = ?',
        [mat.id]
      );
      if (check[0].total > 0) {
        matriculaId = mat.id;
        break;
      }
    }
    
    if (!matriculaId) {
      matriculaId = matriculas[0].id;
    }
    
    console.log('Matrícula ID escolhida:', matriculaId);
    
    const [presencasResult] = await pool.query(
      `SELECT p.data, p.status, p.observacoes
       FROM presencas p
       WHERE p.matricula_id = ?
       ORDER BY p.data DESC`,
      [matriculaId]
    );
    
    presencas = presencasResult;
    console.log('Presenças encontradas:', presencas);
    
    let presentes = 0;
    let faltas = 0;
    let justificadas = 0;
    
    for (let p of presencas) {
      if (p.status === 'presente') presentes++;
      else if (p.status === 'falta') faltas++;
      else if (p.status === 'justificada') justificadas++;
    }
    
    const total = presencas.length;
    const percentual = total > 0 ? ((presentes / total) * 100).toFixed(1) : '0';
    
    res.json({
      presencas,
      estatisticas: {
        presentes,
        faltas,
        justificadas,
        total,
        percentual
      }
    });
  } catch (error) {
    console.error('Erro ao buscar presenças:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getMinhasPresencasPorMatricula = async (req, res) => {
  try {
    const { matriculaId } = req.params;
    const usuarioId = req.userId || req.user?.id;
    
    const [matricula] = await pool.query(
      'SELECT id FROM matriculas WHERE id = ? AND usuario_id = ?',
      [matriculaId, usuarioId]
    );
    
    if (matricula.length === 0) {
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    const [presencas] = await pool.query(
      `SELECT p.data, p.status, p.observacoes
       FROM presencas p
       WHERE p.matricula_id = ?
       ORDER BY p.data DESC`,
      [matriculaId]
    );
    
    let presentes = 0;
    let faltas = 0;
    let justificadas = 0;
    
    for (let p of presencas) {
      if (p.status === 'presente') presentes++;
      else if (p.status === 'falta') faltas++;
      else if (p.status === 'justificada') justificadas++;
    }
    
    const total = presencas.length;
    const percentual = total > 0 ? ((presentes / total) * 100).toFixed(1) : '0';
    
    res.json({
      presencas,
      estatisticas: {
        presentes,
        faltas,
        justificadas,
        total,
        percentual
      }
    });
  } catch (error) {
    console.error('Erro ao buscar presenças:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.cancelEnrollment = async (req, res) => {
  try {
    const { enrollmentId } = req.params;
    const userId = req.userId || req.user?.id;
    
    const [enrollment] = await pool.query(
      'SELECT * FROM matriculas WHERE id = ? AND usuario_id = ?',
      [enrollmentId, userId]
    );
    
    if (enrollment.length === 0) {
      return res.status(404).json({ message: 'Matrícula não encontrada' });
    }
    
    await pool.query('START TRANSACTION');
    
    if (enrollment[0].status === 'matriculado') {
      const [turmaRows] = await pool.query(
        'SELECT id FROM turmas WHERE upa_id = ? AND CONCAT(dia_semana, " - ", horario) = ?',
        [enrollment[0].upa_id, enrollment[0].turma_horario]
      );
      
      if (turmaRows.length > 0) {
        await pool.query(
          'UPDATE turmas SET vagas_ocupadas = vagas_ocupadas - 1 WHERE id = ? AND vagas_ocupadas > 0',
          [turmaRows[0].id]
        );
      }
    }
    
    await pool.query(
      'UPDATE matriculas SET status = ? WHERE id = ?',
      ['cancelada', enrollmentId]
    );
    
    await pool.query('COMMIT');
    
    res.json({ 
      success: true,
      message: 'Matrícula cancelada com sucesso',
      status: 'cancelada'
    });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error(error);
    res.status(500).json({ message: 'Erro ao cancelar matrícula: ' + error.message });
  }
};