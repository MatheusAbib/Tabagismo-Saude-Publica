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
    const [rows] = await pool.execute(`
      SELECT 
        u.id,
        u.nome_completo,
        u.sexo,
        u.data_nascimento,
        u.idade,
        u.email,
        u.senha,
        u.cpf,
        u.telefone,
        u.score_fagestrom,
        u.stop_date,
        u.target_days,
        u.cigarros_por_dia,
        u.valor_carteira,
        u.is_admin,
        u.created_at
      FROM usuarios u
      WHERE u.email = ?
    `, [email]);

    return rows[0];
  }

  static async findById(id) {
    const [rows] = await pool.execute(
      'SELECT id, nome_completo, sexo, data_nascimento, idade, email, cpf, telefone, score_fagestrom, stop_date, target_days, cigarros_por_dia, valor_carteira, is_admin, created_at FROM usuarios WHERE id = ?',
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

  static async updateTipoUsuario(id, tipoUsuario, upaId = null) {
    // Este método pode ser removido ou mantido para compatibilidade
    // Como a coluna tipo_usuario foi removida, ele não faz mais nada
    console.log('updateTipoUsuario não está mais disponível para usuarios comuns');
    return 0;
  }
}

module.exports = User;