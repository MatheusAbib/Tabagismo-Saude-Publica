const pool = require('../config/database');

exports.getTurmasPorUPA = async (req, res) => {
  try {
    const { upaId } = req.params;
    const [rows] = await pool.execute(
      `SELECT t.*, 
              (t.vagas_totais - t.vagas_ocupadas) as vagas_disponiveis,
              CASE 
                WHEN (t.vagas_totais - t.vagas_ocupadas) > 0 THEN 'disponivel'
                ELSE 'lotado'
              END as status
       FROM turmas t 
       WHERE t.upa_id = ? 
       ORDER BY FIELD(t.dia_semana, 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'),
                t.horario`,
      [upaId]
    );
    
    res.json({ turmas: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao buscar turmas' });
  }
};

exports.atualizarVagas = async (req, res) => {
  try {
    const { turmaId, operacao } = req.body;
    
    if (operacao === 'increment') {
      await pool.execute(
        'UPDATE turmas SET vagas_ocupadas = vagas_ocupadas + 1 WHERE id = ? AND vagas_ocupadas < vagas_totais',
        [turmaId]
      );
    } else if (operacao === 'decrement') {
      await pool.execute(
        'UPDATE turmas SET vagas_ocupadas = vagas_ocupadas - 1 WHERE id = ? AND vagas_ocupadas > 0',
        [turmaId]
      );
    }
    
    res.json({ message: 'Vagas atualizadas com sucesso' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao atualizar vagas' });
  }
};

exports.criarTurma = async (req, res) => {
  try {
    const { upaId, diaSemana, horario, vagasTotais } = req.body;
    
    const [result] = await pool.execute(
      'INSERT INTO turmas (upa_id, dia_semana, horario, vagas_totais) VALUES (?, ?, ?, ?)',
      [upaId, diaSemana, horario, vagasTotais || 4]
    );
    
    res.status(201).json({ message: 'Turma criada com sucesso', id: result.insertId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao criar turma' });
  }
};

exports.atualizarTurma = async (req, res) => {
  try {
    const { id } = req.params;
    const { diaSemana, horario, vagasTotais } = req.body;
    
    await pool.execute(
      'UPDATE turmas SET dia_semana = ?, horario = ?, vagas_totais = ? WHERE id = ?',
      [diaSemana, horario, vagasTotais, id]
    );
    
    res.json({ message: 'Turma atualizada com sucesso' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao atualizar turma' });
  }
};

exports.deletarTurma = async (req, res) => {
  try {
    const { id } = req.params;
    
    await pool.execute('DELETE FROM turmas WHERE id = ?', [id]);
    
    res.json({ message: 'Turma deletada com sucesso' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao deletar turma' });
  }
};