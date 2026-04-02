const pool = require('../config/database');

exports.getUsuariosEmEspera = async (req, res) => {
  try {
    const enfermeiraId = req.userId;
    
    const [enfermeira] = await pool.execute(
      'SELECT u.upa_id, up.nome as upa_nome FROM usuarios u LEFT JOIN upas up ON u.upa_id = up.id WHERE u.id = ? AND u.tipo_usuario = "enfermeira"',
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
    const { matriculaId, status } = req.body;
    
    const [result] = await pool.execute(
      'UPDATE matriculas SET status = ? WHERE id = ?',
      [status, matriculaId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Matrícula não encontrada' });
    }
    
    res.json({ message: 'Status atualizado com sucesso' });
  } catch (error) {
    console.error('Erro ao atualizar status:', error);
    res.status(500).json({ error: error.message });
  }
};