const pool = require('../config/database');

exports.criarNotificacao = async (usuarioId, titulo, mensagem, tipo, acaoUrl) => {
  try {
    await pool.execute(
      'INSERT INTO notificacoes (usuario_id, titulo, mensagem, tipo, acao_url) VALUES (?, ?, ?, ?, ?)',
      [usuarioId, titulo, mensagem, tipo, acaoUrl]
    );
  } catch (error) {
    console.error('Erro ao criar notificação:', error);
  }
};

exports.getNotificacoes = async (req, res) => {
  try {
    const usuarioId = req.userId;
    
    const [notificacoes] = await pool.execute(
      'SELECT * FROM notificacoes WHERE usuario_id = ? ORDER BY data_criacao DESC LIMIT 50',
      [usuarioId]
    );
    
    const [naoLidas] = await pool.execute(
      'SELECT COUNT(*) as total FROM notificacoes WHERE usuario_id = ? AND lida = 0',
      [usuarioId]
    );
    
    res.json({
      notificacoes,
      naoLidas: naoLidas[0].total
    });
  } catch (error) {
    console.error('Erro ao buscar notificações:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.marcarComoLida = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.userId;
    
    await pool.execute(
      'UPDATE notificacoes SET lida = 1 WHERE id = ? AND usuario_id = ?',
      [id, usuarioId]
    );
    
    res.json({ message: 'Notificação marcada como lida' });
  } catch (error) {
    console.error('Erro ao marcar notificação:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.marcarTodasComoLidas = async (req, res) => {
  try {
    const usuarioId = req.userId;
    
    await pool.execute(
      'UPDATE notificacoes SET lida = 1 WHERE usuario_id = ? AND lida = 0',
      [usuarioId]
    );
    
    res.json({ message: 'Todas notificações marcadas como lidas' });
  } catch (error) {
    console.error('Erro ao marcar notificações:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.limparTodasNotificacoes = async (req, res) => {
  try {
    const usuarioId = req.userId;
    
    const [result] = await pool.execute(
      'DELETE FROM notificacoes WHERE usuario_id = ?',
      [usuarioId]
    );
    
    res.json({ 
      message: 'Todas as notificações foram removidas',
      removidas: result.affectedRows 
    });
  } catch (error) {
    console.error('Erro ao limpar notificações:', error);
    res.status(500).json({ error: error.message });
  }
};