const SintomaDiario = require('../models/SintomaDiario');

exports.registrarSintoma = async (req, res) => {
  try {
    const userId = req.userId;
    const { data, ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar, observacoes } = req.body;
    
    const sintomaId = await SintomaDiario.upsert(userId, {
      data,
      ansiedade,
      irritabilidade,
      insonia,
      fome,
      dificuldade_concentracao,
      vontade_fumar,
      observacoes
    });
    
    res.json({ success: true, message: 'Sintoma registrado com sucesso', id: sintomaId });
  } catch (error) {
    console.error('Erro ao registrar sintoma:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.getSintomasUsuario = async (req, res) => {
  try {
    const userId = req.userId;
    const { limit = 30 } = req.query;
    
    const sintomas = await SintomaDiario.findByUserLastDays(userId, parseInt(limit));
    
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
    
    const sintoma = await SintomaDiario.findByUserAndDate(userId, hoje);
    
    res.json({ success: true, sintoma });
  } catch (error) {
    console.error('Erro ao buscar sintoma de hoje:', error);
    res.status(500).json({ error: error.message });
  }
};