const pool = require('../config/database');

exports.searchUPA = async (req, res) => {
  try {
    const { bairro } = req.query;
    
    let query = 'SELECT id, nome, endereco, cidade, telefone, horario FROM upas';
    let params = [];
    
    if (bairro && bairro.trim() !== '') {
      query += ' WHERE endereco LIKE ? OR nome LIKE ?';
      params.push(`%${bairro}%`, `%${bairro}%`);
    }
    
    const [rows] = await pool.execute(query, params);
    
    res.json({ data: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao buscar UPAs' });
  }
};

exports.getUPAs = async (req, res) => {
  try {
    const { page = 1, limit = 10, search = '' } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    
    let query = 'SELECT id, nome, endereco, cidade, telefone, horario FROM upas';
    let countQuery = 'SELECT COUNT(*) as total FROM upas';
    let params = [];
    
    if (search && search.trim() !== '') {
      const whereClause = ' WHERE nome LIKE ? OR endereco LIKE ? OR cidade LIKE ?';
      query += whereClause;
      countQuery += whereClause;
      const searchParam = `%${search}%`;
      params = [searchParam, searchParam, searchParam];
    }
    
    query += ' ORDER BY nome LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);
    
    const [rows] = await pool.execute(query, params);
    
    let total = 0;
    if (search && search.trim() !== '') {
      const [countResult] = await pool.execute(countQuery, params.slice(0, 3));
      total = countResult[0].total;
    } else {
      const [countResult] = await pool.execute('SELECT COUNT(*) as total FROM upas');
      total = countResult[0].total;
    }
    
    res.json({
      upas: rows,
      total: total,
      totalPages: Math.ceil(total / parseInt(limit)),
      currentPage: parseInt(page)
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao buscar UPAs' });
  }
};

exports.criarUPAComTurmas = async (req, res) => {
  try {
    const { nome, endereco, cidade, telefone, horario, turmas } = req.body;
    
    console.log('Dados recebidos:', { nome, endereco, cidade, telefone, horario });
    console.log('Turmas:', turmas);
    
    const [result] = await pool.execute(
      'INSERT INTO upas (nome, endereco, cidade, telefone, horario) VALUES (?, ?, ?, ?, ?)',
      [nome, endereco, cidade, telefone || null, horario || null]
    );
    
    const upaId = result.insertId;
    
    if (turmas && turmas.length > 0) {
      for (const turma of turmas) {
        console.log('Inserindo turma:', turma);
        await pool.execute(
          'INSERT INTO turmas (upa_id, dia_semana, horario, vagas_totais) VALUES (?, ?, ?, ?)',
          [upaId, turma.dia_semana, turma.horario, turma.vagas_totais || 4]
        );
      }
    }
    
    res.status(201).json({ message: 'UPA criada com sucesso', id: upaId });
  } catch (error) {
    console.error('Erro detalhado:', error);
    res.status(500).json({ message: 'Erro ao criar UPA', error: error.message });
  }
};

exports.atualizarUPAComTurmas = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, endereco, cidade, telefone, horario, turmas } = req.body;
    
    console.log('Atualizando UPA:', { id, nome, endereco, cidade, telefone, horario, turmas });
    
    await pool.execute('START TRANSACTION');
    
    await pool.execute(
      'UPDATE upas SET nome = ?, endereco = ?, cidade = ?, telefone = ?, horario = ? WHERE id = ?',
      [nome, endereco, cidade, telefone || null, horario || null, id]
    );
    
    // Deletar apenas as turmas que não estão mais selecionadas
    if (turmas && turmas.length > 0) {
      // Deletar todas e recriar (mais simples)
      await pool.execute('DELETE FROM turmas WHERE upa_id = ?', [id]);
      
      for (const turma of turmas) {
        await pool.execute(
          'INSERT INTO turmas (upa_id, dia_semana, horario, vagas_totais, vagas_ocupadas) VALUES (?, ?, ?, ?, 0)',
          [id, turma.dia_semana, turma.horario, turma.vagas_totais || 4]
        );
      }
    }
    
    await pool.execute('COMMIT');
    
    res.json({ message: 'UPA atualizada com sucesso' });
  } catch (error) {
    await pool.execute('ROLLBACK');
    console.error('Erro detalhado:', error);
    res.status(500).json({ message: 'Erro ao atualizar UPA', error: error.message });
  }
};


exports.getUPAsLista = async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT id, nome FROM upas ORDER BY nome');
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao buscar lista de UPAs' });
  }
};

exports.getUPAById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(
      'SELECT id, nome, endereco, cidade, telefone, horario FROM upas WHERE id = ?',
      [id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ message: 'UPA não encontrada' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao buscar UPA' });
  }
};

exports.criarUPA = async (req, res) => {
  try {
    const { nome, endereco, cidade, telefone, horario } = req.body;
    
    if (!nome || !endereco || !cidade) {
      return res.status(400).json({ message: 'Nome, endereço e cidade são obrigatórios' });
    }
    
    const [result] = await pool.execute(
      'INSERT INTO upas (nome, endereco, cidade, telefone, horario) VALUES (?, ?, ?, ?, ?)',
      [nome, endereco, cidade, telefone || null, horario || null]
    );
    
    res.status(201).json({ 
      message: 'UPA criada com sucesso', 
      id: result.insertId 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao criar UPA' });
  }
};

exports.atualizarUPA = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, endereco, cidade, telefone, horario } = req.body;
    
    if (!nome || !endereco || !cidade) {
      return res.status(400).json({ message: 'Nome, endereço e cidade são obrigatórios' });
    }
    
    const [result] = await pool.execute(
      'UPDATE upas SET nome = ?, endereco = ?, cidade = ?, telefone = ?, horario = ? WHERE id = ?',
      [nome, endereco, cidade, telefone || null, horario || null, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'UPA não encontrada' });
    }
    
    res.json({ message: 'UPA atualizada com sucesso' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao atualizar UPA' });
  }
};

exports.deletarUPA = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await pool.execute('DELETE FROM upas WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'UPA não encontrada' });
    }
    
    res.json({ message: 'UPA deletada com sucesso' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao deletar UPA' });
  }
};