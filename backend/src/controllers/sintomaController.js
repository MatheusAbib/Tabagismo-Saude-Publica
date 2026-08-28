const pool = require('../config/database');
const notificacaoController = require('./notificacaoController');

exports.registrarSintoma = async (req, res) => {
  try {
    const usuarioId = req.userId;
    const { data, ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar, observacoes } = req.body;
    
    console.log('📦 Body recebido:', req.body);
    console.log('📦 Valores extraídos:', {
      usuarioId,
      data,
      ansiedade,
      irritabilidade,
      insonia,
      fome,
      dificuldade_concentracao,
      vontade_fumar,
      observacoes
    });
    
    const ansiedadeVal = ansiedade !== undefined ? ansiedade : null;
    const irritabilidadeVal = irritabilidade !== undefined ? irritabilidade : null;
    const insoniaVal = insonia !== undefined ? insonia : null;
    const fomeVal = fome !== undefined ? fome : null;
    const dificuldadeConcentracaoVal = dificuldade_concentracao !== undefined ? dificuldade_concentracao : null;
    const vontadeFumarVal = vontade_fumar !== undefined ? vontade_fumar : null;
    const observacoesVal = observacoes !== undefined && observacoes !== '' ? observacoes : null;
    
    console.log('📦 Valores processados:', {
      ansiedadeVal,
      irritabilidadeVal,
      insoniaVal,
      fomeVal,
      dificuldadeConcentracaoVal,
      vontadeFumarVal,
      observacoesVal
    });
    
    const [existing] = await pool.execute(
      'SELECT id FROM sintomas_diarios WHERE usuario_id = ? AND data = ?',
      [usuarioId, data]
    );
    
    let result;
    if (existing.length > 0) {
      result = await pool.execute(
        `UPDATE sintomas_diarios 
         SET ansiedade = ?, irritabilidade = ?, insonia = ?, fome = ?, 
             dificuldade_concentracao = ?, vontade_fumar = ?, observacoes = ?
         WHERE usuario_id = ? AND data = ?`,
        [ansiedadeVal, irritabilidadeVal, insoniaVal, fomeVal, dificuldadeConcentracaoVal, vontadeFumarVal, observacoesVal, usuarioId, data]
      );
      console.log('✅ UPDATE realizado');
    } else {
      result = await pool.execute(
        `INSERT INTO sintomas_diarios 
         (usuario_id, data, ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar, observacoes)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [usuarioId, data, ansiedadeVal, irritabilidadeVal, insoniaVal, fomeVal, dificuldadeConcentracaoVal, vontadeFumarVal, observacoesVal]
      );
      console.log('✅ INSERT realizado');
    }
    
    await notificacaoController.criarNotificacao(
      usuarioId,
      'Diário Registrado',
      'Registro de hoje salvo!\n\nAcesse o gráfico para acompanhar sua evolução\nContinue assim!',
      'sintoma',
      '/home?tab=grafico'
    );
    
    res.json({ message: 'Sintomas registrados com sucesso' });
  } catch (error) {
    console.error('❌ Erro detalhado ao registrar sintomas:', error);
    console.error('❌ Stack:', error.stack);
    res.status(500).json({ error: error.message, stack: error.stack });
  }
};

exports.getSintomasUsuario = async (req, res) => {
  try {
    const userId = req.userId;
    const { limit = 30 } = req.query;
    
    const [sintomas] = await pool.execute(
      `SELECT * FROM sintomas_diarios 
       WHERE usuario_id = ? 
       ORDER BY data DESC 
       LIMIT ?`,
      [userId, parseInt(limit)]
    );
    
    res.json({ success: true, sintomas });
  } catch (error) {
    console.error('Erro ao buscar sintomas:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getSintomaHoje = async (req, res) => {
  try {
    const userId = req.userId;
    const hoje = new Date().toISOString().split('T')[0];
    
    const [sintomas] = await pool.execute(
      'SELECT * FROM sintomas_diarios WHERE usuario_id = ? AND data = ?',
      [userId, hoje]
    );
    
    const sintoma = sintomas.length > 0 ? sintomas[0] : null;
    
    res.json({ success: true, sintoma });
  } catch (error) {
    console.error('Erro ao buscar sintoma de hoje:', error);
    res.status(500).json({ error: error.message });
  }
};