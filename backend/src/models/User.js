const pool = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
static async create(userData) {
  const { nomeCompleto, sexo, dataNascimento, idade, email, senha, cpf, telefone } = userData;
  const hashedPassword = await bcrypt.hash(senha, 10);
  
  const [result] = await pool.execute(
    'INSERT INTO usuarios (nome_completo, sexo, data_nascimento, idade, email, senha, cpf, telefone) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [nomeCompleto, sexo, dataNascimento, idade, email, hashedPassword, cpf, telefone]
  );
  
  return result.insertId;
}
  static async findByEmail(email) {
    const [rows] = await pool.execute(
      'SELECT * FROM usuarios WHERE email = ?',
      [email]
    );
    
    return rows[0];
  }

static async findById(id) {
  const [rows] = await pool.execute(
    'SELECT id, nome_completo, sexo, data_nascimento, idade, email, cpf, telefone, score_fagestrom FROM usuarios WHERE id = ?',
    [id]
  );
  
  return rows[0];
}

static async update(id, userData) {
  const { nomeCompleto, sexo, email, telefone } = userData;
  const [result] = await pool.execute(
    'UPDATE usuarios SET nome_completo = ?, sexo = ?, email = ?, telefone = ? WHERE id = ?',
    [nomeCompleto, sexo, email, telefone, id]
  );
  
  return result.affectedRows;
}

  static async updatePassword(id, newPassword) {
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    const [result] = await pool.execute(
      'UPDATE usuarios SET senha = ? WHERE id = ?',
      [hashedPassword, id]
    );
    
    return result.affectedRows;
  }
}

module.exports = User;
