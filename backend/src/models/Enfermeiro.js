const pool = require('../config/database');
const bcrypt = require('bcryptjs');

class Enfermeiro {
  static async create(userData) {
    const { nomeCompleto, email, senha, telefone, cpf, upaId, tipoUsuario = 'enfermeira' } = userData;
    
    if (cpf) {
      const [existing] = await pool.execute(
        'SELECT id FROM enfermeiros WHERE cpf = ?',
        [cpf]
      );
      if (existing.length > 0) {
        throw new Error('CPF já cadastrado');
      }
    }
    
    const [emailExists] = await pool.execute(
      'SELECT id FROM enfermeiros WHERE email = ?',
      [email]
    );
    if (emailExists.length > 0) {
      throw new Error('Email já cadastrado');
    }
    
    const hashedPassword = await bcrypt.hash(senha, 10);
    
    const [result] = await pool.execute(
      'INSERT INTO enfermeiros (nome_completo, email, senha, telefone, cpf, upa_id, tipo_usuario) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [nomeCompleto, email, hashedPassword, telefone, cpf, upaId, tipoUsuario]
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
      'SELECT id, nome_completo, email, telefone, cpf, tipo_usuario, upa_id, created_at FROM enfermeiros WHERE id = ?',
      [id]
    );
    return rows[0];
  }

  static async update(id, userData) {
    const { nomeCompleto, email, telefone, cpf } = userData;
    
    if (cpf) {
      const [existing] = await pool.execute(
        'SELECT id FROM enfermeiros WHERE cpf = ? AND id != ?',
        [cpf, id]
      );
      if (existing.length > 0) {
        throw new Error('CPF já cadastrado para outra enfermeira');
      }
    }
    
    const [emailExists] = await pool.execute(
      'SELECT id FROM enfermeiros WHERE email = ? AND id != ?',
      [email, id]
    );
    if (emailExists.length > 0) {
      throw new Error('Email já cadastrado para outra enfermeira');
    }
    
    const [result] = await pool.execute(
      'UPDATE enfermeiros SET nome_completo = ?, email = ?, telefone = ?, cpf = ? WHERE id = ?',
      [nomeCompleto, email, telefone, cpf, id]
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