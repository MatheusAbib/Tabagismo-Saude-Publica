const pool = require('../config/database');

exports.searchUPA = async (req, res) => {
  try {
    const { bairro } = req.query;
    
    let query = 'SELECT * FROM upas';
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