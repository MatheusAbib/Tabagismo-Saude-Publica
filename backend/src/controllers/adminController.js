const pool = require('../config/database');
const bcrypt = require('bcryptjs');
const notificacaoController = require('./notificacaoController');


exports.getStats = async (req, res) => {
  try {
    const [totalUsuarios] = await pool.execute("SELECT COUNT(*) as total FROM usuarios WHERE tipo_usuario IN ('comum', 'admin')");
    const [totalEnfermeiras] = await pool.execute("SELECT COUNT(*) as total FROM enfermeiros");
    const [totalMatriculas] = await pool.execute('SELECT COUNT(*) as total FROM matriculas');
    const [totalUPAs] = await pool.execute('SELECT COUNT(*) as total FROM upas');
    const [totalRegistrosSintomas] = await pool.execute('SELECT COUNT(*) as total FROM sintomas_diarios');
    
    res.json({
      totalUsuarios: totalUsuarios[0].total,
      totalEnfermeiras: totalEnfermeiras[0].total,
      totalMatriculas: totalMatriculas[0].total,
      totalUPAs: totalUPAs[0].total,
      totalRegistrosSintomas: totalRegistrosSintomas[0].total,
    });
  } catch (error) {
    console.error('Erro ao buscar estatísticas:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUsuarioDetalhes = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [usuario] = await pool.execute(
      'SELECT id, nome_completo, sexo, data_nascimento, idade, email, cpf, telefone, score_fagestrom, stop_date, target_days, cigarros_por_dia, valor_carteira, is_admin, created_at FROM usuarios WHERE id = ?',
      [id]
    );
    
    if (usuario.length === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    
    const [sintomas] = await pool.execute(
      'SELECT data, ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar FROM sintomas_diarios WHERE usuario_id = ? ORDER BY data DESC LIMIT 30',
      [id]
    );
    
    const [matricula] = await pool.execute(
      'SELECT id, upa_nome, turma_horario, segunda_opcao_turma, status, escolaridade, score_fagestrom, medicamento, comorbidades, created_at FROM matriculas WHERE usuario_id = ? ORDER BY created_at DESC LIMIT 1',
      [id]
    );
    
    res.json({
      usuario: usuario[0],
      sintomas: sintomas,
      matricula: matricula.length > 0 ? matricula[0] : null
    });
  } catch (error) {
    console.error('Erro ao buscar detalhes do usuário:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUsuarios = async (req, res) => {
  try {
    const [usuarios] = await pool.execute(
      'SELECT id, nome_completo, email, telefone, is_admin, created_at FROM usuarios WHERE tipo_usuario IN ("comum", "admin") ORDER BY id DESC'
    );
    res.json({ usuarios });
  } catch (error) {
    console.error('Erro ao buscar usuários:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.atualizarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { nomeCompleto, sexo, email, telefone, dataNascimento, idade } = req.body;
    
    console.log('Dados recebidos:', { id, nomeCompleto, sexo, email, telefone, dataNascimento, idade });
    
    const [result] = await pool.execute(
      'UPDATE usuarios SET nome_completo = ?, sexo = ?, email = ?, telefone = ? WHERE id = ?',
      [nomeCompleto, sexo, email, telefone, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    
    res.json({ message: 'Usuário atualizado com sucesso' });
  } catch (error) {
    console.error('Erro ao atualizar usuário:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUsuariosPaginados = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    
    const offset = (page - 1) * limit;
    
    let query = 'SELECT id, nome_completo, email, telefone, is_admin, created_at FROM usuarios WHERE tipo_usuario IN ("comum", "admin")';
    let countQuery = 'SELECT COUNT(*) as total FROM usuarios WHERE tipo_usuario IN ("comum", "admin")';
    let params = [];
    let countParams = [];
    
    if (search) {
      query += ' AND (nome_completo LIKE ? OR email LIKE ?)';
      countQuery += ' AND (nome_completo LIKE ? OR email LIKE ?)';
      const searchParam = `%${search}%`;
      params = [searchParam, searchParam, limit, offset];
      countParams = [searchParam, searchParam];
    } else {
      params = [limit, offset];
    }
    
    query += ' ORDER BY id DESC LIMIT ? OFFSET ?';
    
    const [usuarios] = await pool.execute(query, params);
    const [totalResult] = await pool.execute(countQuery, countParams);
    
    res.json({
      usuarios,
      total: totalResult[0].total,
      page,
      totalPages: Math.ceil(totalResult[0].total / limit)
    });
  } catch (error) {
    console.error('Erro ao buscar usuários:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getAdminDashboardStats = async (req, res) => {
  try {
    const [totalUsuarios] = await pool.execute("SELECT COUNT(*) as total FROM usuarios");
    const [totalEnfermeiras] = await pool.execute("SELECT COUNT(*) as total FROM enfermeiros");
    const [totalMatriculas] = await pool.execute('SELECT COUNT(*) as total FROM matriculas');
    const [totalUPAs] = await pool.execute('SELECT COUNT(*) as total FROM upas');
    const [totalRegistrosSintomas] = await pool.execute('SELECT COUNT(*) as total FROM sintomas_diarios');
    
    const [maiores18] = await pool.execute('SELECT COUNT(*) as total FROM usuarios WHERE idade >= 18');
    const [menores18] = await pool.execute('SELECT COUNT(*) as total FROM usuarios WHERE idade < 18');
    
    const [usuariosComCancer] = await pool.execute('SELECT COUNT(*) as total FROM matriculas WHERE comorbidades LIKE "%cancer%" AND comorbidades NOT LIKE "%nenhum%"');
    const [usuariosComCardiovascular] = await pool.execute('SELECT COUNT(*) as total FROM matriculas WHERE comorbidades LIKE "%cardiovascular%" AND comorbidades NOT LIKE "%nenhum%"');
    
    const [mediaScoreFagestrom] = await pool.execute('SELECT AVG(score_fagestrom) as media FROM matriculas');
    
    const [distribuicaoSexo] = await pool.execute('SELECT sexo, COUNT(*) as total FROM usuarios GROUP BY sexo');
    
    const [distribuicaoEscolaridade] = await pool.execute('SELECT escolaridade, COUNT(*) as total FROM matriculas GROUP BY escolaridade');
    
    const [usuariosPorMes] = await pool.execute('SELECT DATE_FORMAT(created_at, "%Y-%m") as mes, COUNT(*) as total FROM matriculas GROUP BY DATE_FORMAT(created_at, "%Y-%m") ORDER BY mes DESC LIMIT 6');
    
    res.json({
      totalUsuarios: totalUsuarios[0].total,
      totalEnfermeiras: totalEnfermeiras[0].total,
      totalMatriculas: totalMatriculas[0].total,
      totalUPAs: totalUPAs[0].total,
      totalRegistrosSintomas: totalRegistrosSintomas[0].total,
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
    console.error('Erro ao buscar estatísticas do dashboard:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getAdminEvolucaoGeral = async (req, res) => {
  try {
    const [alunosAtivos] = await pool.execute('SELECT COUNT(DISTINCT u.id) as total FROM usuarios u INNER JOIN matriculas m ON u.id = m.usuario_id WHERE m.status = "matriculado"');
    
    const [alunosConcluidos] = await pool.execute('SELECT IFNULL(SUM(total_alunos), 0) as total FROM turmas_concluidas WHERE tipo_encerramento = "concluida"');
    
    let fumandoAtivos = 0;
    let semFumarAtivos = 0;
    
    if (alunosAtivos[0].total > 0) {
      const [fumandoResult] = await pool.execute(
        `SELECT COUNT(DISTINCT p.matricula_id) as total 
         FROM presencas p 
         INNER JOIN matriculas m ON p.matricula_id = m.id 
         WHERE m.status = "matriculado" 
         AND p.observacoes = "1- Está fumando" 
         AND p.data = (SELECT MAX(data) FROM presencas WHERE matricula_id = p.matricula_id AND observacoes IS NOT NULL)`
      );
      fumandoAtivos = fumandoResult[0].total || 0;
      
      const [semFumarResult] = await pool.execute(
        `SELECT COUNT(DISTINCT p.matricula_id) as total 
         FROM presencas p 
         INNER JOIN matriculas m ON p.matricula_id = m.id 
         WHERE m.status = "matriculado" 
         AND p.observacoes = "2- Sem fumar" 
         AND p.data = (SELECT MAX(data) FROM presencas WHERE matricula_id = p.matricula_id AND observacoes IS NOT NULL)`
      );
      semFumarAtivos = semFumarResult[0].total || 0;
    }
    
    let fumandoConcluidos = 0;
    let semFumarConcluidos = 0;
    
    if (alunosConcluidos[0].total > 0) {
      const [fumandoConcluidosResult] = await pool.execute(
        `SELECT COUNT(*) as total 
         FROM alunos_concluidos ac 
         WHERE ac.evolucao LIKE "%1- Está fumando%"`
      );
      fumandoConcluidos = fumandoConcluidosResult[0].total || 0;
      
      const [semFumarConcluidosResult] = await pool.execute(
        `SELECT COUNT(*) as total 
         FROM alunos_concluidos ac 
         WHERE ac.evolucao LIKE "%2- Sem fumar%"`
      );
      semFumarConcluidos = semFumarConcluidosResult[0].total || 0;
    }
    
    const [evolucaoMensal] = await pool.execute(
      `SELECT DATE_FORMAT(p.data, "%Y-%m") as mes, 
              SUM(CASE WHEN p.observacoes = "1- Está fumando" THEN 1 ELSE 0 END) as fumando, 
              SUM(CASE WHEN p.observacoes = "2- Sem fumar" THEN 1 ELSE 0 END) as sem_fumar 
       FROM presencas p 
       INNER JOIN matriculas m ON p.matricula_id = m.id 
       WHERE m.status = "matriculado" AND p.observacoes IS NOT NULL
       GROUP BY DATE_FORMAT(p.data, "%Y-%m") 
       ORDER BY mes ASC 
       LIMIT 12`
    );
    
    const [alunosDetalhados] = await pool.execute(
      `SELECT u.id, u.nome_completo, m.turma_horario, 
        (SELECT observacoes FROM presencas 
         WHERE matricula_id = m.id AND observacoes IS NOT NULL 
         ORDER BY data DESC LIMIT 1) as ultima_observacao,
        IFNULL((SELECT COUNT(*) FROM presencas WHERE matricula_id = m.id AND observacoes = "1- Está fumando"), 0) as semanas_fumando,
        IFNULL((SELECT COUNT(*) FROM presencas WHERE matricula_id = m.id AND observacoes = "2- Sem fumar"), 0) as semanas_sem_fumar
       FROM usuarios u 
       INNER JOIN matriculas m ON u.id = m.usuario_id 
       WHERE m.status = "matriculado" 
       ORDER BY u.nome_completo ASC`
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
      alunos_detalhados: alunosDetalhados
    });
  } catch (error) {
    console.error('Erro ao buscar evolução geral admin:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUPAs = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    
    const offset = (page - 1) * limit;
    
    let query = 'SELECT * FROM upas';
    let countQuery = 'SELECT COUNT(*) as total FROM upas';
    let params = [];
    let countParams = [];
    
    if (search) {
      query += ' WHERE nome LIKE ? OR endereco LIKE ? OR cidade LIKE ?';
      countQuery += ' WHERE nome LIKE ? OR endereco LIKE ? OR cidade LIKE ?';
      const searchParam = `%${search}%`;
      params = [searchParam, searchParam, searchParam, limit, offset];
      countParams = [searchParam, searchParam, searchParam];
    } else {
      params = [limit, offset];
    }
    
    query += ' ORDER BY id DESC LIMIT ? OFFSET ?';
    
    const [upas] = await pool.execute(query, params);
    const [totalResult] = await pool.execute(countQuery, countParams);
    
    res.json({
      upas,
      total: totalResult[0].total,
      page,
      totalPages: Math.ceil(totalResult[0].total / limit)
    });
  } catch (error) {
    console.error('Erro ao buscar UPAs:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.criarUPA = async (req, res) => {
  try {
    const { nome, endereco, cidade, telefone, horario } = req.body;
    
    const [result] = await pool.execute(
      'INSERT INTO upas (nome, endereco, cidade, telefone, horario) VALUES (?, ?, ?, ?, ?)',
      [nome, endereco, cidade, telefone, horario]
    );
    
    res.json({ message: 'UPA criada com sucesso', id: result.insertId });
  } catch (error) {
    console.error('Erro ao criar UPA:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.atualizarUPA = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, endereco, cidade, telefone, horario } = req.body;
    
    const [result] = await pool.execute(
      'UPDATE upas SET nome = ?, endereco = ?, cidade = ?, telefone = ?, horario = ? WHERE id = ?',
      [nome, endereco, cidade, telefone, horario, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'UPA não encontrada' });
    }
    
    res.json({ message: 'UPA atualizada com sucesso' });
  } catch (error) {
    console.error('Erro ao atualizar UPA:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.deletarUPA = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await pool.execute('DELETE FROM upas WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'UPA não encontrada' });
    }
    
    res.json({ message: 'UPA deletada com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar UPA:', error);
    res.status(500).json({ error: error.message });
  }
};


exports.getEnfermeiras = async (req, res) => {
  try {
    const [enfermeiras] = await pool.execute(
      `SELECT e.id, e.nome_completo, e.email, e.telefone, e.upa_id, up.nome as upa_nome, e.tipo_usuario 
       FROM enfermeiros e
       LEFT JOIN upas up ON e.upa_id = up.id 
       ORDER BY e.id DESC`
    );
    res.json({ enfermeiras });
  } catch (error) {
    console.error('Erro ao buscar enfermeiras:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.criarEnfermeira = async (req, res) => {
  try {
    const { nomeCompleto, email, senha, telefone, upaId } = req.body;
    
    console.log('Dados recebidos:', { nomeCompleto, email, senha, telefone, upaId });
    
    const hashedPassword = await bcrypt.hash(senha, 10);
    
    const [result] = await pool.execute(
      'INSERT INTO enfermeiros (nome_completo, email, senha, telefone, upa_id, tipo_usuario) VALUES (?, ?, ?, ?, ?, "enfermeira")',
      [nomeCompleto, email, hashedPassword, telefone, upaId || null]
    );
    
    res.json({ message: 'Enfermeira criada com sucesso', id: result.insertId });
  } catch (error) {
    console.error('Erro ao criar enfermeira:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.atualizarEnfermeira = async (req, res) => {
  try {
    const { id } = req.params;
    const { nomeCompleto, email, telefone, upaId } = req.body;
    
    const [result] = await pool.execute(
      'UPDATE enfermeiros SET nome_completo = ?, email = ?, telefone = ?, upa_id = ? WHERE id = ?',
      [nomeCompleto, email, telefone, upaId, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Enfermeira não encontrada' });
    }
    
    res.json({ message: 'Enfermeira atualizada com sucesso' });
  } catch (error) {
    console.error('Erro ao atualizar enfermeira:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.deletarEnfermeira = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await pool.execute('DELETE FROM enfermeiros WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Enfermeira não encontrada' });
    }
    
    res.json({ message: 'Enfermeira deletada com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar enfermeira:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getUPAsParaEnfermeira = async (req, res) => {
  try {
    const [upas] = await pool.execute('SELECT id, nome FROM upas ORDER BY nome');
    res.json({ upas });
  } catch (error) {
    console.error('Erro ao buscar UPAs:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.atualizarMatricula = async (req, res) => {
  try {
    const { matriculaId, status, turmaEscolhida } = req.body;
    
    await pool.query('START TRANSACTION');
    
    const [matricula] = await pool.query(
      'SELECT usuario_id, upa_id, upa_nome, turma_horario, segunda_opcao_turma, status as status_atual FROM matriculas WHERE id = ?',
      [matriculaId]
    );
    
    if (matricula.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    let turmaParaAlocar = matricula[0].turma_horario;
    
    // Se turmaEscolhida é 'segunda' e existe segunda opção, usa ela
    if (turmaEscolhida === 'segunda' && matricula[0].segunda_opcao_turma) {
      turmaParaAlocar = matricula[0].segunda_opcao_turma;
    }
    
    // Se veio o nome da turma diretamente
    if (turmaEscolhida !== 'primeira' && turmaEscolhida !== 'segunda' && turmaEscolhida !== null) {
      turmaParaAlocar = turmaEscolhida;
    }
    
    // SÓ atualiza vagas_ocupadas quando mudar de 'em_espera' para 'matriculado'
    if (status === 'matriculado' && matricula[0].status_atual !== 'matriculado') {
      const [turma] = await pool.query(
        `SELECT id FROM turmas 
         WHERE upa_id = ? AND CONCAT(dia_semana, ' - ', horario) = ?`,
        [matricula[0].upa_id, turmaParaAlocar]
      );
      
      if (turma.length > 0) {
        await pool.query(
          'UPDATE turmas SET vagas_ocupadas = vagas_ocupadas + 1 WHERE id = ?',
          [turma[0].id]
        );
      }
    }
    
    await pool.query(
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
    console.error('Erro ao atualizar matrícula:', error);
    res.status(500).json({ error: error.message });
  }
};