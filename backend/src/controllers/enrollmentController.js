const pool = require('../config/database');

exports.createEnrollment = async (req, res) => {
  try {
    const userId = req.userId;
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

    const [result] = await pool.execute(
      `INSERT INTO matriculas 
      (usuario_id, upa_id, upa_nome, turma_horario, segunda_opcao_turma, escolaridade, score_fagestrom, medicamento, comorbidades, status) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId, 
        upaId, 
        upaNome, 
        turmaHorario, 
        segundaOpcaoTurma || null,
        escolaridade, 
        scoreFagestrom, 
        medicamento, 
        JSON.stringify(comorbidades),
        'em_espera'
      ]
    );

    res.status(201).json({ 
      message: 'Matrícula realizada com sucesso! Você está na lista de espera.',
      enrollmentId: result.insertId,
      status: 'em_espera'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao realizar matrícula: ' + error.message });
  }
};

exports.getUserEnrollments = async (req, res) => {
  try {
    const userId = req.userId;
    console.log('Buscando matrículas para usuário:', userId);
    
    const [rows] = await pool.execute(
      `SELECT * FROM matriculas 
       WHERE usuario_id = ? 
       ORDER BY created_at DESC`,
      [userId]
    );
    
    console.log('Matrículas encontradas:', rows.length);
    
    res.json({ 
      success: true,
      data: rows,
      count: rows.length
    });
  } catch (error) {
    console.error('Erro ao buscar matrículas:', error);
    res.status(500).json({ 
      success: false,
      message: 'Erro ao buscar matrículas: ' + error.message 
    });
  }
};

exports.updateEnrollmentStatus = async (req, res) => {
  try {
    const { enrollmentId } = req.params;
    const { status } = req.body;
    
    const [result] = await pool.execute(
      `UPDATE matriculas SET status = ? WHERE id = ?`,
      [status, enrollmentId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Matrícula não encontrada' });
    }
    
    res.json({ message: 'Status atualizado com sucesso', status });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao atualizar status: ' + error.message });
  }
};


exports.cancelEnrollment = async (req, res) => {
  try {
    const { enrollmentId } = req.params;
    const userId = req.userId;
    
    const [enrollment] = await pool.execute(
      'SELECT * FROM matriculas WHERE id = ? AND usuario_id = ?',
      [enrollmentId, userId]
    );
    
    if (enrollment.length === 0) {
      return res.status(404).json({ message: 'Matrícula não encontrada' });
    }
    
    const [result] = await pool.execute(
      'UPDATE matriculas SET status = ? WHERE id = ?',
      ['cancelada', enrollmentId]
    );
    
    res.json({ 
      success: true,
      message: 'Matrícula cancelada com sucesso',
      status: 'cancelada'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao cancelar matrícula: ' + error.message });
  }
};
