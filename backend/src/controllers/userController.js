const pool = require('../config/database');
const User = require('../models/User');
const notificacaoController = require('./notificacaoController');
const bcrypt = require('bcryptjs');

exports.getUserData = async (req, res) => {
  try {
    const userId = req.userId;
    const userTable = req.userTable || 'usuarios';
    
    let user;
    
    if (userTable === 'enfermeiros') {
      const [rows] = await pool.execute(
        'SELECT id, nome_completo, email, telefone, cpf, upa_id, tipo_usuario, created_at FROM enfermeiros WHERE id = ?',
        [userId]
      );
      user = rows[0];
      
      if (!user) {
        return res.status(404).json({ message: 'Enfermeira não encontrada' });
      }
      
      return res.json({ 
        success: true,
        user: {
          id: user.id,
          nomeCompleto: user.nome_completo || '',
          sexo: '',
          dataNascimento: null,
          idade: null,
          email: user.email || '',
          cpf: user.cpf || '',
          telefone: user.telefone || '',
          scoreFagestrom: null,
          stop_date: null,
          target_days: null,
          cigarros_por_dia: null,
          valor_carteira: null,
          is_admin: 0,
          tipo_usuario: user.tipo_usuario || 'enfermeira',
          upa_id: user.upa_id || null,
        }
      });
    }
    
    user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }
    
    let stopDateFormatted = null;
    if (user.stop_date) {
      const dateStr = new Date(user.stop_date).toISOString().split('T')[0];
      stopDateFormatted = dateStr;
    }
    
    res.json({ 
      success: true,
      user: {
        id: user.id,
        nomeCompleto: user.nome_completo || '',
        sexo: user.sexo || '',
        dataNascimento: user.data_nascimento || null,
        idade: user.idade || 0,
        email: user.email || '',
        cpf: user.cpf || '',
        telefone: user.telefone || '',
        scoreFagestrom: user.score_fagestrom || null,
        stop_date: stopDateFormatted,
        target_days: user.target_days || null,
        cigarros_por_dia: user.cigarros_por_dia || null,
        valor_carteira: user.valor_carteira || null,
        is_admin: user.is_admin || 0,
        tipo_usuario: user.tipo_usuario || 'comum',
        upa_id: user.upa_id || null,
      }
    });
  } catch (error) {
    console.error('Erro em getUserData:', error);
    res.status(500).json({ message: 'Erro ao buscar dados do usuário: ' + error.message });
  }
};

exports.updateUser = async (req, res) => {
  try {
    const userId = req.userId;
    const userTable = req.userTable || 'usuarios';
    const { nomeCompleto, sexo, email, telefone, scoreFagestrom } = req.body;
    
    let updated;
    
    if (userTable === 'enfermeiros') {
      const [result] = await pool.execute(
        'UPDATE enfermeiros SET nome_completo = ?, email = ?, telefone = ? WHERE id = ?',
        [nomeCompleto, email, telefone, userId]
      );
      updated = result.affectedRows;
    } else {
      if (scoreFagestrom !== undefined && scoreFagestrom !== null) {
        const [result] = await pool.execute(
          'UPDATE usuarios SET score_fagestrom = ? WHERE id = ?',
          [scoreFagestrom, userId]
        );
        updated = result.affectedRows;
      } else {
        const [result] = await pool.execute(
          'UPDATE usuarios SET nome_completo = ?, sexo = ?, email = ?, telefone = ? WHERE id = ?',
          [nomeCompleto, sexo, email, telefone, userId]
        );
        updated = result.affectedRows;
      }
    }
    
    if (updated === 0) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }
    
    res.json({ 
      success: true,
      message: 'Dados atualizados com sucesso' 
    });
  } catch (error) {
    console.error('Erro no updateUser:', error);
    res.status(500).json({ message: 'Erro ao atualizar dados: ' + error.message });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const userId = req.userId;
    const userTable = req.userTable || 'usuarios';
    const { currentPassword, newPassword } = req.body;
    
    const bcrypt = require('bcryptjs');
    const pool = require('../config/database');
    
    let users;
    
    if (userTable === 'enfermeiros') {
      [users] = await pool.query('SELECT * FROM enfermeiros WHERE id = ?', [userId]);
    } else {
      [users] = await pool.query('SELECT * FROM usuarios WHERE id = ?', [userId]);
    }
    
    if (users.length === 0) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    
    const user = users[0];
    
    const isValid = await bcrypt.compare(currentPassword, user.senha);
    if (!isValid) {
      return res.status(401).json({ error: 'Senha atual incorreta' });
    }
    
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    if (userTable === 'enfermeiros') {
      await pool.query('UPDATE enfermeiros SET senha = ? WHERE id = ?', [hashedPassword, userId]);
    } else {
      await pool.query('UPDATE usuarios SET senha = ? WHERE id = ?', [hashedPassword, userId]);
    }
    
    res.json({ message: 'Senha alterada com sucesso' });
  } catch (error) {
    console.error('Erro ao alterar senha:', error);
    res.status(500).json({ error: error.message });
  }
};
exports.updateGoal = async (req, res) => {
  const userId = req.userId;
  let { stopDate, targetDays, cigarrosPorDia, valorCarteira } = req.body;
  
  try {
    if (stopDate) {
      stopDate = stopDate.split('T')[0];
    }
    
    const query = 'UPDATE usuarios SET stop_date = ?, target_days = ?, cigarros_por_dia = ?, valor_carteira = ? WHERE id = ?';
    await pool.execute(query, [stopDate, targetDays, cigarrosPorDia, valorCarteira, userId]);
    res.json({ message: 'Meta atualizada com sucesso' });
  } catch (error) {
    console.error('Erro em updateGoal:', error);
    res.status(500).json({ error: error.message });
  }
};