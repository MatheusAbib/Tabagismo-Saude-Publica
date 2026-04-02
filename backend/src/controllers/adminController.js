const pool = require('../config/database');

exports.getStats = async (req, res) => {
  try {
    const [totalUsuarios] = await pool.execute("SELECT COUNT(*) as total FROM usuarios WHERE tipo_usuario = 'comum'");
    const [totalEnfermeiras] = await pool.execute("SELECT COUNT(*) as total FROM usuarios WHERE tipo_usuario = 'enfermeira'");
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
      'SELECT id, nome_completo, email, telefone, is_admin, created_at FROM usuarios ORDER BY id DESC'
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
    
    let query = 'SELECT id, nome_completo, email, telefone, is_admin, tipo_usuario, created_at FROM usuarios WHERE tipo_usuario IN ("comum", "admin")';
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
      `SELECT u.id, u.nome_completo, u.email, u.telefone, u.upa_id, up.nome as upa_nome 
       FROM usuarios u 
       LEFT JOIN upas up ON u.upa_id = up.id 
       WHERE u.tipo_usuario = 'enfermeira' 
       ORDER BY u.id DESC`
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
    
    const bcrypt = require('bcryptjs');
    const hashedPassword = await bcrypt.hash(senha, 10);
    
    const [result] = await pool.execute(
      'INSERT INTO usuarios (nome_completo, email, senha, telefone, tipo_usuario, upa_id) VALUES (?, ?, ?, ?, "enfermeira", ?)',
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
      'UPDATE usuarios SET nome_completo = ?, email = ?, telefone = ?, upa_id = ? WHERE id = ? AND tipo_usuario = "enfermeira"',
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
    
    const [result] = await pool.execute(
      'DELETE FROM usuarios WHERE id = ? AND tipo_usuario = "enfermeira"',
      [id]
    );
    
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
    const { matriculaId, status } = req.body;
    
    console.log('Dados recebidos:', { matriculaId, status });
    
    const [result] = await pool.execute(
      'UPDATE matriculas SET status = ? WHERE id = ?',
      [status, matriculaId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    res.json({ message: 'Matrícula atualizada com sucesso' });
  } catch (error) {
    console.error('Erro ao atualizar matrícula:', error);
    res.status(500).json({ error: error.message });
  }
};