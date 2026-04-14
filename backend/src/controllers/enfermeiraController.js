const pool = require('../config/database');
const notificacaoController = require('./notificacaoController');


exports.getUsuariosEmEspera = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id, (SELECT nome FROM upas WHERE id = upa_id) as upa_nome FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ usuarios: [], upa_nome: null });
    }
    
    const upaId = enfermeira[0].upa_id;
    const upaNome = enfermeira[0].upa_nome;
    
    const [usuarios] = await pool.execute(
      `SELECT m.id as matricula_id, m.usuario_id, m.upa_nome, m.turma_horario, 
              m.segunda_opcao_turma, m.status, m.created_at, m.escolaridade, 
              m.score_fagestrom, m.medicamento, m.comorbidades,
              u.nome_completo, u.email, u.telefone, u.cpf
       FROM matriculas m
       JOIN usuarios u ON m.usuario_id = u.id
       WHERE m.upa_id = ? AND m.status = 'em_espera'
       ORDER BY m.created_at ASC`,
      [upaId]
    );
    
    res.json({ usuarios, upa_nome: upaNome });
  } catch (error) {
    console.error('Erro ao buscar usuários em espera:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.atualizarStatusMatricula = async (req, res) => {
  try {
    const { matriculaId, status, turmaEscolhida } = req.body;
    
    await pool.query('START TRANSACTION');
    
    const [matricula] = await pool.execute(
      'SELECT usuario_id, upa_id, upa_nome, turma_horario, segunda_opcao_turma, status as status_atual FROM matriculas WHERE id = ?',
      [matriculaId]
    );
    
    if (matricula.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    let turmaParaAlocar = matricula[0].turma_horario;
    
    // Se veio o nome da turma diretamente (padrão do frontend)
    if (turmaEscolhida && turmaEscolhida !== 'primeira' && turmaEscolhida !== 'segunda') {
      turmaParaAlocar = turmaEscolhida;
    }
    // Se turmaEscolhida é 'segunda' e existe segunda opção
    else if (turmaEscolhida === 'segunda' && matricula[0].segunda_opcao_turma) {
      turmaParaAlocar = matricula[0].segunda_opcao_turma;
    }
    
    // SÓ atualiza vagas_ocupadas quando mudar de 'em_espera' para 'matriculado'
    if (status === 'matriculado' && matricula[0].status_atual !== 'matriculado') {
      const [turma] = await pool.execute(
        `SELECT id FROM turmas 
         WHERE upa_id = ? AND CONCAT(dia_semana, ' - ', horario) = ?`,
        [matricula[0].upa_id, turmaParaAlocar]
      );
      
      if (turma.length > 0) {
        await pool.execute(
          'UPDATE turmas SET vagas_ocupadas = vagas_ocupadas + 1 WHERE id = ?',
          [turma[0].id]
        );
      }
    }
    
    await pool.execute(
      'UPDATE matriculas SET status = ?, turma_horario = ? WHERE id = ?',
      [status, turmaParaAlocar, matriculaId]
    );
    
    await pool.query('COMMIT');
    
    if (status === 'matriculado') {
      await notificacaoController.criarNotificacao(
        matricula[0].usuario_id,
        'Matrícula Confirmada',
        'Parabéns! Sua matrícula foi confirmada.\n\nUPA: ' + matricula[0].upa_nome + '\n\nTurma: ' + turmaParaAlocar + '\n\nAcesse "Minhas Matrículas" para mais detalhes.',
        'matricula',
        '/my-enrollments'
      );
    }
    
    res.json({ message: 'Status atualizado com sucesso' });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Erro ao atualizar status:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getDashboardStats = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ error: 'UPA não encontrada' });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [totalUsuarios] = await pool.execute(
      'SELECT COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.upa_id = ?',
      [upaId]
    );
    
    const [totalEmEspera] = await pool.execute(
      'SELECT COUNT(*) as total FROM matriculas WHERE upa_id = ? AND status = "em_espera"',
      [upaId]
    );
    
    const [totalMatriculados] = await pool.execute(
      'SELECT COUNT(*) as total FROM matriculas WHERE upa_id = ? AND status = "matriculado"',
      [upaId]
    );
    
    const [totalCancelados] = await pool.execute(
      'SELECT COUNT(*) as total FROM matriculas WHERE upa_id = ? AND status = "cancelada"',
      [upaId]
    );
    
    const [maiores18] = await pool.execute(
      'SELECT COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.upa_id = ? AND u.idade >= 18',
      [upaId]
    );
    
    const [menores18] = await pool.execute(
      'SELECT COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.upa_id = ? AND u.idade < 18',
      [upaId]
    );
    
    const [usuariosComCancer] = await pool.execute(
      'SELECT COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.upa_id = ? AND m.comorbidades LIKE "%cancer%" AND m.comorbidades NOT LIKE "%nenhum%"',
      [upaId]
    );
    
    const [usuariosComCardiovascular] = await pool.execute(
      'SELECT COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.upa_id = ? AND m.comorbidades LIKE "%cardiovascular%" AND m.comorbidades NOT LIKE "%nenhum%"',
      [upaId]
    );
    
    const [mediaScoreFagestrom] = await pool.execute(
      'SELECT AVG(m.score_fagestrom) as media FROM matriculas m WHERE m.upa_id = ?',
      [upaId]
    );
    
    const [distribuicaoSexo] = await pool.execute(
      'SELECT u.sexo, COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.upa_id = ? GROUP BY u.sexo',
      [upaId]
    );
    
    const [distribuicaoEscolaridade] = await pool.execute(
      'SELECT m.escolaridade, COUNT(*) as total FROM matriculas m WHERE m.upa_id = ? GROUP BY m.escolaridade',
      [upaId]
    );
    
    const [usuariosPorMes] = await pool.execute(
      'SELECT DATE_FORMAT(m.created_at, "%Y-%m") as mes, COUNT(*) as total FROM matriculas m WHERE m.upa_id = ? GROUP BY DATE_FORMAT(m.created_at, "%Y-%m") ORDER BY mes DESC LIMIT 6',
      [upaId]
    );
    
    res.json({
      totalUsuarios: totalUsuarios[0].total,
      totalEmEspera: totalEmEspera[0].total,
      totalMatriculados: totalMatriculados[0].total,
      totalCancelados: totalCancelados[0].total,
      maiores18: maiores18[0].total,
      menores18: menores18[0].total,
      usuariosComCancer: usuariosComCancer[0].total,
      usuariosComCardiovascular: usuariosComCardiovascular[0].total,
      mediaScoreFagestrom: mediaScoreFagestrom[0].media || 0,
      distribuicaoSexo: distribuicaoSexo,
      distribuicaoEscolaridade: distribuicaoEscolaridade,
      usuariosPorMes: usuariosPorMes,
    });
  } catch (error) {
    console.error('Erro ao buscar estatísticas:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.registrarPresenca = async (req, res) => {
  try {
    const { matriculaId, data, status, observacoes } = req.body;
    
    const [existing] = await pool.execute(
      'SELECT id FROM presencas WHERE matricula_id = ? AND data = ?',
      [matriculaId, data]
    );
    
    if (existing.length > 0) {
      await pool.execute(
        'UPDATE presencas SET status = ?, observacoes = ? WHERE matricula_id = ? AND data = ?',
        [status, observacoes, matriculaId, data]
      );
    } else {
      await pool.execute(
        'INSERT INTO presencas (matricula_id, data, status, observacoes) VALUES (?, ?, ?, ?)',
        [matriculaId, data, status, observacoes]
      );
    }
    
    res.json({ message: 'Presença registrada com sucesso' });
  } catch (error) {
    console.error('Erro ao registrar presença:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getPresencasPorMatricula = async (req, res) => {
  try {
    const { matriculaId } = req.params;
    
    const [presencas] = await pool.execute(
      `SELECT p.* 
       FROM presencas p
       WHERE p.matricula_id = ? 
       ORDER BY p.data DESC`,
      [matriculaId]
    );
    
    res.json({ presencas });
  } catch (error) {
    console.error('Erro ao buscar presenças:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.encerrarTurma = async (req, res) => {
  try {
    const { upaId, turmaHorario, tipoEncerramento } = req.body;
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || enfermeira[0].upa_id !== upaId) {
      return res.status(403).json({ error: 'Você não tem permissão para encerrar esta turma' });
    }
    
    const [upa] = await pool.execute('SELECT nome FROM upas WHERE id = ?', [upaId]);
    const upaNome = upa[0].nome;
    
    const [alunos] = await pool.execute(
      `SELECT m.id as matricula_id, m.usuario_id, u.nome_completo, u.email, u.telefone
       FROM matriculas m
       JOIN usuarios u ON m.usuario_id = u.id
       WHERE m.upa_id = ? AND m.turma_horario = ? AND m.status = 'matriculado'`,
      [upaId, turmaHorario]
    );
    
    if (alunos.length === 0) {
      return res.status(404).json({ error: 'Nenhum aluno matriculado nesta turma' });
    }
    
    const [turma] = await pool.execute(
      `SELECT id FROM turmas 
       WHERE upa_id = ? AND CONCAT(dia_semana, ' - ', horario) = ?`,
      [upaId, turmaHorario]
    );
    
    if (turma.length > 0) {
      await pool.execute(
        'UPDATE turmas SET vagas_ocupadas = 0 WHERE id = ?',
        [turma[0].id]
      );
    }
    
    let totalPresencasGeral = 0;
    let totalAulasGeral = 0;
    
    for (let aluno of alunos) {
      const [stats] = await pool.execute(
        `SELECT 
          COUNT(CASE WHEN status = 'presente' THEN 1 END) as presentes,
          COUNT(*) as total
         FROM presencas 
         WHERE matricula_id = ?`,
        [aluno.matricula_id]
      );
      
      aluno.presentes = stats[0].presentes || 0;
      aluno.total_aulas = stats[0].total || 0;
      aluno.percentual = aluno.total_aulas > 0 ? (aluno.presentes / aluno.total_aulas * 100).toFixed(2) : 0;
      
      totalPresencasGeral += aluno.presentes;
      totalAulasGeral += aluno.total_aulas;
    }
    
    const percentualMedio = totalAulasGeral > 0 ? (totalPresencasGeral / totalAulasGeral * 100).toFixed(2) : 0;
    const dataFim = new Date().toISOString().split('T')[0];
    
    const [primeiraAula] = await pool.execute(
      `SELECT MIN(data) as data_inicio FROM presencas p
       JOIN matriculas m ON p.matricula_id = m.id
       WHERE m.upa_id = ? AND m.turma_horario = ?`,
      [upaId, turmaHorario]
    );
    
    const dataInicio = primeiraAula[0].data_inicio || dataFim;
    
    const [result] = await pool.execute(
      `INSERT INTO turmas_concluidas 
       (upa_id, upa_nome, turma_horario, data_inicio, data_fim, total_alunos, total_presencas, percentual_medio_presenca, tipo_encerramento)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [upaId, upaNome, turmaHorario, dataInicio, dataFim, alunos.length, totalPresencasGeral, percentualMedio, tipoEncerramento]
    );
    
    const turmaConcluidaId = result.insertId;
    
    for (let aluno of alunos) {
      const evolucao = await getEvolucaoAluno(aluno.matricula_id);
      
      await pool.execute(
        `INSERT INTO alunos_concluidos 
         (turma_concluida_id, usuario_id, nome_completo, email, telefone, percentual_presenca, total_presencas, total_faltas, evolucao)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [turmaConcluidaId, aluno.usuario_id, aluno.nome_completo, aluno.email, aluno.telefone, 
         aluno.percentual, aluno.presentes, aluno.total_aulas - aluno.presentes, JSON.stringify(evolucao)]
      );
      
      const titulo = tipoEncerramento === 'concluida' ? 'Turma Concluída!' : 'Turma Cancelada';
      const mensagem = tipoEncerramento === 'concluida'
        ? `Parabéns! Você concluiu o programa com sucesso na turma ${turmaHorario} da ${upaNome}. Seu percentual de presença foi de ${aluno.percentual}%!`
        : `Infelizmente a turma ${turmaHorario} da ${upaNome} foi cancelada. Entre em contato com a UPA para mais informações.`;
      
      await notificacaoController.criarNotificacao(
        aluno.usuario_id,
        titulo,
        mensagem,
        tipoEncerramento === 'concluida' ? 'sucesso' : 'alerta',
        '/my-enrollments'
      );
    }
    
    await pool.execute(
      `DELETE FROM presencas 
       WHERE matricula_id IN (SELECT id FROM matriculas WHERE upa_id = ? AND turma_horario = ? AND status = 'matriculado')`,
      [upaId, turmaHorario]
    );
    
    await pool.execute(
      `DELETE FROM matriculas 
       WHERE upa_id = ? AND turma_horario = ? AND status = 'matriculado'`,
      [upaId, turmaHorario]
    );
    
    res.json({ 
      message: `Turma ${tipoEncerramento === 'concluida' ? 'concluída' : 'cancelada'} com sucesso`,
      total_alunos: alunos.length,
      turma_concluida_id: turmaConcluidaId
    });
    
  } catch (error) {
    console.error('Erro ao encerrar turma:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getTurmasConcluidas = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ turmas: [] });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [turmas] = await pool.execute(
      `SELECT * FROM turmas_concluidas 
       WHERE upa_id = ? AND tipo_encerramento = 'concluida'
       ORDER BY data_fim DESC`,
      [upaId]
    );
    
    res.json({ turmas });
  } catch (error) {
    console.error('Erro ao buscar turmas concluídas:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getDetalhesTurmaConcluida = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [turma] = await pool.execute(
      'SELECT * FROM turmas_concluidas WHERE id = ?',
      [id]
    );
    
    if (turma.length === 0) {
      return res.status(404).json({ error: 'Turma não encontrada' });
    }
    
    const [alunos] = await pool.execute(
      `SELECT ac.*, u.nome_completo, u.email, u.telefone
       FROM alunos_concluidos ac
       JOIN usuarios u ON ac.usuario_id = u.id
       WHERE ac.turma_concluida_id = ?
       ORDER BY u.nome_completo ASC`,
      [id]
    );
    
    const [datas] = await pool.execute(
      `SELECT DISTINCT DATE_FORMAT(p.data, '%d/%m/%Y') as data
       FROM presencas p
       JOIN matriculas m ON p.matricula_id = m.id
       WHERE m.turma_horario = ? AND m.upa_id = ?
       ORDER BY p.data ASC`,
      [turma[0].turma_horario, turma[0].upa_id]
    );
    
    const listaDatas = datas.map(d => d.data);
    
    const alunosComPresencas = [];
    
    for (const aluno of alunos) {
      const presencasPorData = {};
      const observacoesPorData = {};
      
      for (const data of listaDatas) {
        const [presenca] = await pool.execute(
          `SELECT status, observacoes 
           FROM presencas p
           JOIN matriculas m ON p.matricula_id = m.id
           WHERE m.usuario_id = ? AND DATE_FORMAT(p.data, '%d/%m/%Y') = ?`,
          [aluno.usuario_id, data]
        );
        
        if (presenca.length > 0) {
          presencasPorData[data] = presenca[0].status;
          observacoesPorData[data] = presenca[0].observacoes;
        } else {
          presencasPorData[data] = null;
          observacoesPorData[data] = null;
        }
      }
      
      alunosComPresencas.push({
        id: aluno.id,
        nome_completo: aluno.nome_completo,
        email: aluno.email,
        telefone: aluno.telefone,
        percentual_presenca: aluno.percentual_presenca,
        presencas: presencasPorData,
        observacoes: observacoesPorData,
      });
    }
    
    res.json({
      turma: turma[0],
      alunos: alunosComPresencas,
      datas: listaDatas
    });
  } catch (error) {
    console.error('Erro ao buscar detalhes da turma concluída:', error);
    res.status(500).json({ error: error.message });
  }
};

async function getEvolucaoAluno(matriculaId) {
  const [observacoes] = await pool.execute(
    `SELECT data, observacoes as observacao_semanal
     FROM presencas 
     WHERE matricula_id = ? AND observacoes IS NOT NULL
     ORDER BY data ASC`,
    [matriculaId]
  );
  
  const evolucao = [];
  let fumandoCount = 0;
  let semFumarCount = 0;
  
  for (let obs of observacoes) {
    if (obs.observacao_semanal === '1- Está fumando') {
      fumandoCount++;
    } else if (obs.observacao_semanal === '2- Sem fumar') {
      semFumarCount++;
    }
    evolucao.push({
      data: obs.data,
      status: obs.observacao_semanal
    });
  }
  
  return {
    historico: evolucao,
    total_semanas: observacoes.length,
    semanas_fumando: fumandoCount,
    semanas_sem_fumar: semFumarCount,
    taxa_sucesso: observacoes.length > 0 ? (semFumarCount / observacoes.length * 100).toFixed(2) : 0
  };
}

exports.getEvolucaoGeral = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ 
        alunos_ativos: { total: 0, fumando: 0, sem_fumar: 0, taxa_sucesso: 0 },
        alunos_concluidos: { total: 0, fumando: 0, sem_fumar: 0, taxa_sucesso: 0 },
        evolucao_mensal_ativos: [],
        evolucao_mensal_concluidos: [],
        alunos_detalhados: []
      });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [alunosAtivos] = await pool.execute(
      `SELECT COUNT(DISTINCT u.id) as total
       FROM usuarios u
       INNER JOIN matriculas m ON u.id = m.usuario_id
       WHERE m.upa_id = ? AND m.status = 'matriculado'`,
      [upaId]
    );
    
    const [alunosConcluidos] = await pool.execute(
      `SELECT IFNULL(SUM(total_alunos), 0) as total FROM turmas_concluidas WHERE upa_id = ?`,
      [upaId]
    );
    
    let fumandoAtivos = 0;
    let semFumarAtivos = 0;
    
    if (alunosAtivos[0].total > 0) {
      const [fumandoResult] = await pool.execute(
        `SELECT COUNT(DISTINCT p.matricula_id) as total
         FROM presencas p
         INNER JOIN matriculas m ON p.matricula_id = m.id
         WHERE m.upa_id = ? AND m.status = 'matriculado' 
         AND p.observacoes = '1- Está fumando'
         AND p.data = (SELECT MAX(data) FROM presencas WHERE matricula_id = p.matricula_id AND observacoes IS NOT NULL)`,
        [upaId]
      );
      fumandoAtivos = fumandoResult[0].total || 0;
      
      const [semFumarResult] = await pool.execute(
        `SELECT COUNT(DISTINCT p.matricula_id) as total
         FROM presencas p
         INNER JOIN matriculas m ON p.matricula_id = m.id
         WHERE m.upa_id = ? AND m.status = 'matriculado' 
         AND p.observacoes = '2- Sem fumar'
         AND p.data = (SELECT MAX(data) FROM presencas WHERE matricula_id = p.matricula_id AND observacoes IS NOT NULL)`,
        [upaId]
      );
      semFumarAtivos = semFumarResult[0].total || 0;
    }
    
    let fumandoConcluidos = 0;
    let semFumarConcluidos = 0;
    
    if (alunosConcluidos[0].total > 0) {
      const [fumandoConcluidosResult] = await pool.execute(
        `SELECT COUNT(*) as total
         FROM alunos_concluidos ac
         INNER JOIN turmas_concluidas tc ON ac.turma_concluida_id = tc.id
         WHERE tc.upa_id = ? AND ac.evolucao LIKE '%1- Está fumando%'`,
        [upaId]
      );
      fumandoConcluidos = fumandoConcluidosResult[0].total || 0;
      
      const [semFumarConcluidosResult] = await pool.execute(
        `SELECT COUNT(*) as total
         FROM alunos_concluidos ac
         INNER JOIN turmas_concluidas tc ON ac.turma_concluida_id = tc.id
         WHERE tc.upa_id = ? AND ac.evolucao LIKE '%2- Sem fumar%'`,
        [upaId]
      );
      semFumarConcluidos = semFumarConcluidosResult[0].total || 0;
    }
    
    const [evolucaoMensal] = await pool.execute(
      `SELECT 
        DATE_FORMAT(p.data, '%Y-%m') as mes,
        SUM(CASE WHEN p.observacoes = '1- Está fumando' THEN 1 ELSE 0 END) as fumando,
        SUM(CASE WHEN p.observacoes = '2- Sem fumar' THEN 1 ELSE 0 END) as sem_fumar
       FROM presencas p
       INNER JOIN matriculas m ON p.matricula_id = m.id
       WHERE m.upa_id = ? AND m.status = 'matriculado' AND p.observacoes IS NOT NULL
       GROUP BY DATE_FORMAT(p.data, '%Y-%m')
       ORDER BY mes ASC
       LIMIT 12`,
      [upaId]
    );
    
    const [evolucaoConcluidosMensal] = await pool.execute(
      `SELECT 
        DATE_FORMAT(tc.data_fim, '%Y-%m') as mes,
        COUNT(*) as total
       FROM alunos_concluidos ac
       INNER JOIN turmas_concluidas tc ON ac.turma_concluida_id = tc.id
       WHERE tc.upa_id = ?
       GROUP BY DATE_FORMAT(tc.data_fim, '%Y-%m')
       ORDER BY mes ASC
       LIMIT 12`,
      [upaId]
    );
    
    const evolucaoMensalConcluidosFormatada = evolucaoConcluidosMensal.map(item => ({
      mes: item.mes,
      sucesso: 0,
      insucesso: item.total
    }));
    
    const [alunosDetalhados] = await pool.execute(
      `SELECT u.id, u.nome_completo, m.turma_horario,
        (SELECT observacoes FROM presencas 
         WHERE matricula_id = m.id AND observacoes IS NOT NULL 
         ORDER BY data DESC LIMIT 1) as ultima_observacao,
        IFNULL((SELECT COUNT(*) FROM presencas WHERE matricula_id = m.id AND observacoes = '1- Está fumando'), 0) as semanas_fumando,
        IFNULL((SELECT COUNT(*) FROM presencas WHERE matricula_id = m.id AND observacoes = '2- Sem fumar'), 0) as semanas_sem_fumar
       FROM usuarios u
       INNER JOIN matriculas m ON u.id = m.usuario_id
       WHERE m.upa_id = ? AND m.status = 'matriculado'
       ORDER BY u.nome_completo ASC`,
      [upaId]
    );
    
    const totalAtivos = alunosAtivos[0].total || 0;
    const totalConcluidos = alunosConcluidos[0].total || 0;
    
    const taxaSucessoAtivos = totalAtivos > 0 ? ((semFumarAtivos / totalAtivos) * 100).toFixed(1) : 0;
    const taxaSucessoConcluidos = totalConcluidos > 0 ? ((semFumarConcluidos / totalConcluidos) * 100).toFixed(1) : 0;
    
    res.json({
      alunos_ativos: {
        total: totalAtivos,
        fumando: fumandoAtivos,
        sem_fumar: semFumarAtivos,
        taxa_sucesso: parseFloat(taxaSucessoAtivos)
      },
      alunos_concluidos: {
        total: totalConcluidos,
        fumando: fumandoConcluidos,
        sem_fumar: semFumarConcluidos,
        taxa_sucesso: parseFloat(taxaSucessoConcluidos)
      },
      evolucao_mensal_ativos: evolucaoMensal,
      evolucao_mensal_concluidos: evolucaoMensalConcluidosFormatada,
      alunos_detalhados: alunosDetalhados
    });
    
  } catch (error) {
    console.error('Erro ao buscar evolução geral:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getPresencasDaUPA = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    const { data } = req.query;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ presencas: [] });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const query = `
      SELECT p.*, m.id as matricula_id, u.nome_completo, u.email, m.turma_horario
      FROM presencas p
      JOIN matriculas m ON p.matricula_id = m.id
      JOIN usuarios u ON m.usuario_id = u.id
      WHERE m.upa_id = ? ${data ? 'AND p.data = ?' : ''}
      ORDER BY p.data DESC, u.nome_completo ASC
    `;
    
    const params = data ? [upaId, data] : [upaId];
    const [presencas] = await pool.execute(query, params);
    
    res.json({ presencas });
  } catch (error) {
    console.error('Erro ao buscar presenças da UPA:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getEstatisticasPresenca = async (req, res) => {
  try {
    const { matriculaId } = req.params;
    
    const [total] = await pool.execute(
      'SELECT COUNT(*) as total FROM presencas WHERE matricula_id = ?',
      [matriculaId]
    );
    
    const [presentes] = await pool.execute(
      'SELECT COUNT(*) as total FROM presencas WHERE matricula_id = ? AND status = "presente"',
      [matriculaId]
    );
    
    const [faltas] = await pool.execute(
      'SELECT COUNT(*) as total FROM presencas WHERE matricula_id = ? AND status = "falta"',
      [matriculaId]
    );
    
    res.json({
      total: total[0].total,
      presentes: presentes[0].total,
      faltas: faltas[0].total,
    });
  } catch (error) {
    console.error('Erro ao buscar estatísticas:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUsuariosMatriculadosComPresencas = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    const { data } = req.query;
    const dataAtual = data || new Date().toISOString().split('T')[0];
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ usuarios: [], dataAtual });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [usuarios] = await pool.execute(
      `SELECT u.id, u.nome_completo, u.email, m.id as matricula_id, m.turma_horario
       FROM usuarios u
       INNER JOIN matriculas m ON u.id = m.usuario_id
       WHERE m.upa_id = ? AND m.status = 'matriculado'
       ORDER BY m.turma_horario ASC, u.nome_completo ASC`,
      [upaId]
    );
    
    const turmasMap = {};
    
    for (let usuario of usuarios) {
      const turma = usuario.turma_horario;
      if (!turmasMap[turma]) {
        turmasMap[turma] = {
          usuarios: [],
          turma_id: null
        };
        
        const [turmaInfo] = await pool.execute(
          'SELECT id, vagas_totais FROM turmas WHERE upa_id = ? AND CONCAT(dia_semana, " - ", horario) = ?',
          [upaId, turma]
        );
        if (turmaInfo.length > 0) {
          turmasMap[turma].turma_id = turmaInfo[0].id;
          turmasMap[turma].vagas_totais = turmaInfo[0].vagas_totais;
        }
      }
      
      const [presenca] = await pool.execute(
        'SELECT status, observacoes FROM presencas WHERE matricula_id = ? AND data = ?',
        [usuario.matricula_id, dataAtual]
      );
      
      usuario.presenca_status = presenca.length > 0 ? presenca[0].status : null;
      usuario.presenca_observacoes = presenca.length > 0 ? presenca[0].observacoes : null;
      usuario.observacao_semanal = presenca.length > 0 ? presenca[0].observacoes : null;
      
      turmasMap[turma].usuarios.push(usuario);
    }
    
    const turmas = [];
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    
    for (const [nome, dataTurma] of Object.entries(turmasMap)) {
      let proximaAula = null;
      
      if (dataTurma.turma_id) {
        const [cronogramaRows] = await pool.execute(
          `SELECT c.*, 
                  DATE_FORMAT(c.data, '%d/%m/%Y') as data_formatada
           FROM cronograma c
           WHERE c.turma_id = ? 
           ORDER BY c.data ASC`,
          [dataTurma.turma_id]
        );
        
        for (const aula of cronogramaRows) {
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
      }
      
      turmas.push({
        nome: nome,
        usuarios: dataTurma.usuarios,
        vagas_totais: dataTurma.vagas_totais || 4,
        proxima_aula: proximaAula
      });
    }
    
    res.json({ turmas, dataAtual });
  } catch (error) {
    console.error('Erro ao buscar usuários matriculados:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.salvarPresencasEmLote = async (req, res) => {
  try {
    const { presencas, data } = req.body;
    
    console.log('Dados recebidos no backend:');
    console.log('Data:', data);
    console.log('Presenças:', JSON.stringify(presencas, null, 2));
    
    for (let item of presencas) {
      console.log(`Processando matricula ${item.matriculaId}: status=${item.status}, observacao=${item.observacao}`);
      
      const [existing] = await pool.execute(
        'SELECT id FROM presencas WHERE matricula_id = ? AND data = ?',
        [item.matriculaId, data]
      );
      
      if (existing.length > 0) {
        await pool.execute(
          'UPDATE presencas SET status = ?, observacoes = ? WHERE matricula_id = ? AND data = ?',
          [item.status, item.observacao || null, item.matriculaId, data]
        );
      } else {
        await pool.execute(
          'INSERT INTO presencas (matricula_id, data, status, observacoes) VALUES (?, ?, ?, ?)',
          [item.matriculaId, data, item.status, item.observacao || null]
        );
      }
    }
    
    res.json({ message: 'Presenças salvas com sucesso' });
  } catch (error) {
    console.error('Erro ao salvar presenças:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getHistoricoDetalhado = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ turmas: [] });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [turmas] = await pool.execute(
      `SELECT DISTINCT m.turma_horario
       FROM matriculas m
       WHERE m.upa_id = ? AND m.status = 'matriculado'
       ORDER BY m.turma_horario ASC`,
      [upaId]
    );
    
    const resultado = [];
    
    for (let turma of turmas) {
      const [usuarios] = await pool.execute(
        `SELECT u.id, u.nome_completo, m.id as matricula_id
         FROM usuarios u
         INNER JOIN matriculas m ON u.id = m.usuario_id
         WHERE m.upa_id = ? AND m.turma_horario = ? AND m.status = 'matriculado'
         ORDER BY u.nome_completo ASC`,
        [upaId, turma.turma_horario]
      );
      
      const [datas] = await pool.execute(
        `SELECT DISTINCT p.data, 
                DATE_FORMAT(p.data, '%d/%m/%Y') as data_formatada
         FROM presencas p
         JOIN matriculas m ON p.matricula_id = m.id
         WHERE m.upa_id = ? AND m.turma_horario = ?
         ORDER BY p.data ASC`,
        [upaId, turma.turma_horario]
      );
      
      const usuariosComPresencas = [];
      
      for (let usuario of usuarios) {
        const presencasPorData = {};
        const observacoesPorData = {};
        
        for (let data of datas) {
          const [presenca] = await pool.execute(
            'SELECT status, observacoes FROM presencas WHERE matricula_id = ? AND data = ?',
            [usuario.matricula_id, data.data]
          );
          presencasPorData[data.data_formatada] = presenca.length > 0 ? presenca[0].status : null;
          observacoesPorData[data.data_formatada] = presenca.length > 0 ? presenca[0].observacoes : null;
        }
        
        usuariosComPresencas.push({
          id: usuario.id,
          nome: usuario.nome_completo,
          presencas: presencasPorData,
          observacoes: observacoesPorData
        });
      }
      
      resultado.push({
        turma: turma.turma_horario,
        datas: datas.map(d => d.data_formatada),
        usuarios: usuariosComPresencas
      });
    }
    
    res.json({ turmas: resultado });
  } catch (error) {
    console.error('Erro ao buscar histórico detalhado:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getHistoricoPorUsuario = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ turmas: [] });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [usuarios] = await pool.execute(
      `SELECT u.id, u.nome_completo, u.email, m.id as matricula_id, m.turma_horario
       FROM usuarios u
       INNER JOIN matriculas m ON u.id = m.usuario_id
       WHERE m.upa_id = ? AND m.status = 'matriculado'
       ORDER BY m.turma_horario ASC, u.nome_completo ASC`,
      [upaId]
    );
    
    const turmasMap = {};
    
    for (let usuario of usuarios) {
      const turma = usuario.turma_horario;
      if (!turmasMap[turma]) {
        turmasMap[turma] = [];
      }
      
      const [stats] = await pool.execute(
        `SELECT 
          COUNT(CASE WHEN status = 'presente' THEN 1 END) as presentes,
          COUNT(CASE WHEN status = 'falta' THEN 1 END) as faltas,
          COUNT(*) as total
         FROM presencas 
         WHERE matricula_id = ?`,
        [usuario.matricula_id]
      );
      
      usuario.presentes = stats[0].presentes || 0;
      usuario.faltas = stats[0].faltas || 0;
      usuario.total_presencas = stats[0].total || 0;
      
      const percentual = usuario.total_presencas > 0 
        ? (usuario.presentes / usuario.total_presencas) * 100 
        : 0;
      usuario.percentual_presenca = percentual.toFixed(1);
      
      turmasMap[turma].push(usuario);
    }
    
    const turmas = Object.keys(turmasMap).map(turma => ({
      nome: turma,
      usuarios: turmasMap[turma]
    }));
    
    res.json({ turmas });
  } catch (error) {
    console.error('Erro ao buscar histórico por usuário:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getHistoricoPresencas = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ historico: [] });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [historico] = await pool.execute(
      `SELECT p.data, 
              COUNT(CASE WHEN p.status = 'presente' THEN 1 END) as presentes,
              COUNT(CASE WHEN p.status = 'falta' THEN 1 END) as faltas,
              COUNT(p.id) as total
       FROM presencas p
       JOIN matriculas m ON p.matricula_id = m.id
       WHERE m.upa_id = ?
       GROUP BY p.data
       ORDER BY p.data DESC
       LIMIT 30`,
      [upaId]
    );
    
    res.json({ historico });
  } catch (error) {
    console.error('Erro ao buscar histórico:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUsuariosDaUPA = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const status = req.query.status || '';
    
    const offset = (page - 1) * limit;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ usuarios: [], total: 0, totalPages: 0 });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    let query = `SELECT u.id, u.nome_completo, u.email, u.telefone, u.cpf, u.idade, u.created_at,
                        m.id as matricula_id, m.turma_horario, m.segunda_opcao_turma, m.status, m.escolaridade, m.score_fagestrom, m.medicamento, m.comorbidades
                 FROM usuarios u
                 INNER JOIN matriculas m ON u.id = m.usuario_id
                 WHERE m.upa_id = ?`;
    
    let countQuery = `SELECT COUNT(*) as total
                      FROM usuarios u
                      INNER JOIN matriculas m ON u.id = m.usuario_id
                      WHERE m.upa_id = ?`;
    
    let params = [upaId];
    let countParams = [upaId];
    
    if (status) {
      query += ` AND m.status = ?`;
      countQuery += ` AND m.status = ?`;
      params.push(status);
      countParams.push(status);
    }
    
    if (search) {
      query += ` AND (u.nome_completo LIKE ? OR u.email LIKE ?)`;
      countQuery += ` AND (u.nome_completo LIKE ? OR u.email LIKE ?)`;
      const searchParam = `%${search}%`;
      params.push(searchParam, searchParam);
      countParams.push(searchParam, searchParam);
    }
    
    query += ' ORDER BY u.id DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [usuarios] = await pool.execute(query, params);
    const [totalResult] = await pool.execute(countQuery, countParams);
    
    res.json({
      usuarios,
      total: totalResult[0].total,
      page,
      totalPages: Math.ceil(totalResult[0].total / limit)
    });
  } catch (error) {
    console.error('Erro ao buscar usuários da UPA:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getTurmasComCronograma = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT upa_id FROM enfermeiros WHERE id = ?',
      [enfermeiraId]
    );
    
    if (enfermeira.length === 0 || !enfermeira[0].upa_id) {
      return res.json({ turmas: [] });
    }
    
    const upaId = enfermeira[0].upa_id;
    
    const [turmas] = await pool.execute(
      `SELECT t.id, t.dia_semana, t.horario, t.vagas_totais, t.vagas_ocupadas,
              CONCAT(t.dia_semana, ' - ', t.horario) as nome
       FROM turmas t
       WHERE t.upa_id = ?
       ORDER BY FIELD(t.dia_semana, 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'),
                t.horario`,
      [upaId]
    );
    
    for (let turma of turmas) {
      const [aulas] = await pool.execute(
        `SELECT c.*, DATE_FORMAT(c.data, '%d/%m/%Y') as data_formatada
         FROM cronograma c
         WHERE c.turma_id = ?
         ORDER BY c.numero_aula ASC`,
        [turma.id]
      );
      turma.aulas = aulas;
    }
    
    res.json({ turmas });
  } catch (error) {
    console.error('Erro ao buscar turmas com cronograma:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getCronograma = async (req, res) => {
  try {
    const { matriculaId } = req.params;
    
    const [matricula] = await pool.execute(
      `SELECT m.*, u.nome_completo 
       FROM matriculas m
       JOIN usuarios u ON m.usuario_id = u.id
       WHERE m.id = ?`,
      [matriculaId]
    );
    
    if (matricula.length === 0) {
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    const [turma] = await pool.execute(
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
    
    const [aulas] = await pool.execute(
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

exports.adicionarAulaCronograma = async (req, res) => {
  try {
    const { turmaId, numeroAula, data, horario, mes } = req.body;
    
    await pool.execute(
      'INSERT INTO cronograma (turma_id, numero_aula, data, horario, mes) VALUES (?, ?, ?, ?, ?)',
      [turmaId, numeroAula, data, horario, mes]
    );
    
    res.json({ message: 'Aula adicionada com sucesso' });
  } catch (error) {
    console.error('Erro ao adicionar aula:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.deletarAulaCronograma = async (req, res) => {
  try {
    const { id } = req.params;
    
    await pool.execute('DELETE FROM cronograma WHERE id = ?', [id]);
    
    res.json({ message: 'Aula deletada com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar aula:', error);
    res.status(500).json({ error: error.message });
  }
};