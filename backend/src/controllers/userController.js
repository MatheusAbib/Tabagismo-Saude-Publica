const pool = require('../config/database');
const User = require('../models/User');
const notificacaoController = require('./notificacaoController');
const bcrypt = require('bcryptjs');

exports.getUserData = async (req, res) => {
  try {
    const userId = req.userId;
    const user = await User.findById(userId);
    
    console.log('USER DO BANCO:', user);
    console.log('stop_date raw:', user.stop_date);
    
    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }
    
    let stopDateFormatted = null;
    if (user.stop_date) {
      const dateStr = new Date(user.stop_date).toISOString().split('T')[0];
      stopDateFormatted = dateStr;
    }
    
    console.log('stopDateFormatted:', stopDateFormatted);
    
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
        stop_date: stopDateFormatted,
        target_days: user.target_days || null,
        cigarros_por_dia: user.cigarros_por_dia || null,
        valor_carteira: user.valor_carteira || null,
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
    
    let updated;
    
    if (scoreFagestrom !== undefined && scoreFagestrom !== null) {
      const [result] = await pool.execute(
        'UPDATE usuarios SET score_fagestrom = ? WHERE id = ?',
        [scoreFagestrom, userId]
      );
      updated = result.affectedRows;
      
      let nivel = '';
      if (scoreFagestrom <= 2) nivel = 'Muito Baixa';
      else if (scoreFagestrom <= 4) nivel = 'Baixa';
      else if (scoreFagestrom == 5) nivel = 'Média';
      else if (scoreFagestrom <= 7) nivel = 'Elevada';
      else nivel = 'Muito Elevada';
      
        await notificacaoController.criarNotificacao(
          userId,
          'Teste de Fagerström',
          'Resultado do seu teste:\n\n'
          + `Nível de dependência: ${nivel}\n`
          + `Pontuação: ${scoreFagestrom} pontos\n\n`
          + 'Continue acompanhando sua evolução.',
          'fagerstrom',
          '/fagerstrom-test'
        );
    } else {
      const [result] = await pool.execute(
        'UPDATE usuarios SET nome_completo = ?, sexo = ?, email = ?, telefone = ? WHERE id = ?',
        [nomeCompleto, sexo, email, telefone, userId]
      );
      updated = result.affectedRows;
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