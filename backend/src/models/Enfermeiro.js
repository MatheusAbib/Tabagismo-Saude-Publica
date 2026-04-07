// backend/src/models/Enfermeiro.js
const pool = require('../config/database');
const bcrypt = require('bcryptjs');

class Enfermeiro {
  static async create(userData) {
    const { nomeCompleto, email, senha, telefone, upaId, tipoUsuario = 'enfermeira' } = userData;
    const hashedPassword = await bcrypt.hash(senha, 10);
    
    const [result] = await pool.execute(
      'INSERT INTO enfermeiros (nome_completo, email, senha, telefone, upa_id, tipo_usuario) VALUES (?, ?, ?, ?, ?, ?)',
      [nomeCompleto, email, hashedPassword, telefone, upaId, tipoUsuario]
    );
    
    return result.insertId;
  }

  static async findByEmail(email) {
    const [rows] = await pool.execute(`
      SELECT 
        e.*,
        up.nome AS upa_nome
      FROM enfermeiros e
      LEFT JOIN upas up ON up.id = e.upa_id
      WHERE e.email = ?
    `, [email]);
    
    return rows[0];
  }

  static async findById(id) {
    const [rows] = await pool.execute(
      'SELECT id, nome_completo, email, telefone, tipo_usuario, upa_id, created_at FROM enfermeiros WHERE id = ?',
      [id]
    );
    return rows[0];
  }

  static async update(id, userData) {
    const { nomeCompleto, email, telefone } = userData;
    const [result] = await pool.execute(
      'UPDATE enfermeiros SET nome_completo = ?, email = ?, telefone = ? WHERE id = ?',
      [nomeCompleto, email, telefone, id]
    );
    
    return result.affectedRows;
  }

  static async updatePassword(id, newPassword) {
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    const [result] = await pool.execute(
      'UPDATE enfermeiros SET senha = ? WHERE id = ?',
      [hashedPassword, id]
    );
    
    return result.affectedRows;
  }
}

module.exports = Enfermeiro;