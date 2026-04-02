const pool = require('../config/database');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

exports.getUserData = async (req, res) => {
  try {
    const userId = req.userId;
    const user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }
    
    res.json({ 
      success: true,
      user: {
        id: user.id,
        nomeCompleto: user.nome_completo,
        sexo: user.sexo,
        dataNascimento: user.data_nascimento,
        idade: user.idade,
        email: user.email,
        cpf: user.cpf || '',
        telefone: user.telefone || '',
        scoreFagestrom: user.score_fagestrom,
        stop_date: user.stop_date,
        target_days: user.target_days,
        cigarros_por_dia: user.cigarros_por_dia,
        valor_carteira: user.valor_carteira,
        is_admin: user.is_admin || 0,
        tipo_usuario: user.tipo_usuario || 'comum',
        upa_id: user.upa_id,
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
    const { nomeCompleto, sexo, email, telefone, scoreFagestrom } = req.body;
    
    console.log('=== DEBUG updateUser ===');
    console.log('userId:', userId);
    console.log('Dados recebidos:', req.body);
    console.log('scoreFagestrom:', scoreFagestrom);
    console.log('Tipo do score:', typeof scoreFagestrom);
    
    let updated;
    
    if (scoreFagestrom !== undefined && scoreFagestrom !== null) {
      // Atualizar apenas o score
      console.log('Atualizando score para:', scoreFagestrom);
      const [result] = await pool.execute(
        'UPDATE usuarios SET score_fagestrom = ? WHERE id = ?',
        [scoreFagestrom, userId]
      );
      updated = result.affectedRows;
      console.log('Resultado da atualização do score:', result);
    } else {
      // Atualizar dados completos
      console.log('Atualizando dados completos');
      const [result] = await pool.execute(
        'UPDATE usuarios SET nome_completo = ?, sexo = ?, email = ?, telefone = ? WHERE id = ?',
        [nomeCompleto, sexo, email, telefone, userId]
      );
      updated = result.affectedRows;
      console.log('Resultado da atualização completa:', result);
    }
    
    if (updated === 0) {
      console.log('Nenhuma linha foi atualizada');
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }
    
    console.log('Atualização bem sucedida!');
    res.json({ 
      success: true,
      message: 'Dados atualizados com sucesso' 
    });
  } catch (error) {
    console.error('Erro no updateUser:', error);
    console.error('Stack trace:', error.stack);
    res.status(500).json({ message: 'Erro ao atualizar dados: ' + error.message });
  }
};


exports.updateGoal = async (req, res) => {
  const userId = req.userId;
  const { stopDate, targetDays, cigarrosPorDia, valorCarteira } = req.body;
  
  try {
    const query = 'UPDATE usuarios SET stop_date = ?, target_days = ?, cigarros_por_dia = ?, valor_carteira = ? WHERE id = ?';
    await pool.execute(query, [stopDate, targetDays, cigarrosPorDia, valorCarteira, userId]);
    res.json({ message: 'Meta atualizada com sucesso' });
  } catch (error) {
    console.error('Erro em updateGoal:', error);
    res.status(500).json({ error: error.message });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const userId = req.userId;
    const { oldPassword, newPassword } = req.body;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }
    
    const userWithPassword = await User.findByEmail(user.email);
    const validPassword = await bcrypt.compare(oldPassword, userWithPassword.senha);
    
    if (!validPassword) {
      return res.status(401).json({ message: 'Senha atual incorreta' });
    }
    
    await User.updatePassword(userId, newPassword);
    
    res.json({ 
      success: true,
      message: 'Senha alterada com sucesso' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao alterar senha' });
  }
};