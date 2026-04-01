const pool = require('../config/database');

class SintomaDiario {
  static async create(dados) {
    const {
      usuario_id,
      data,
      ansiedade,
      irritabilidade,
      insonia,
      fome,
      dificuldade_concentracao,
      vontade_fumar,
      observacoes
    } = dados;
    
    const [result] = await pool.execute(
      `INSERT INTO sintomas_diarios 
       (usuario_id, data, ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar, observacoes) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [usuario_id, data, ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar, observacoes]
    );
    
    return result.insertId;
  }
  
  static async findByUserAndDate(usuario_id, data) {
    const [rows] = await pool.execute(
      'SELECT * FROM sintomas_diarios WHERE usuario_id = ? AND data = ?',
      [usuario_id, data]
    );
    return rows[0];
  }
  
  static async findByUserLastDays(usuario_id, limit = 30) {
    const [rows] = await pool.execute(
      'SELECT * FROM sintomas_diarios WHERE usuario_id = ? ORDER BY data DESC LIMIT ?',
      [usuario_id, limit]
    );
    return rows;
  }
  
  static async update(id, dados) {
    const {
      ansiedade,
      irritabilidade,
      insonia,
      fome,
      dificuldade_concentracao,
      vontade_fumar,
      observacoes
    } = dados;
    
    const [result] = await pool.execute(
      `UPDATE sintomas_diarios SET 
       ansiedade = ?, irritabilidade = ?, insonia = ?, fome = ?, 
       dificuldade_concentracao = ?, vontade_fumar = ?, observacoes = ? 
       WHERE id = ?`,
      [ansiedade, irritabilidade, insonia, fome, dificuldade_concentracao, vontade_fumar, observacoes, id]
    );
    
    return result.affectedRows;
  }
  
  static async upsert(usuario_id, dados) {
    const existing = await this.findByUserAndDate(usuario_id, dados.data);
    
    if (existing) {
      await this.update(existing.id, dados);
      return existing.id;
    } else {
      return await this.create({ usuario_id, ...dados });
    }
  }
}

module.exports = SintomaDiario;