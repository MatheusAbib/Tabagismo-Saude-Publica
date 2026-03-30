const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  try {
    console.log('Dados recebidos:', req.body);
    const { email, cpf, telefone } = req.body;
    
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ message: 'Email já cadastrado' });
    }
    
    const userId = await User.create(req.body);
    
    res.status(201).json({ 
      message: 'Usuário cadastrado com sucesso',
      userId 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao cadastrar usuário' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, senha } = req.body;
    
    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({ message: 'Email ou senha inválidos' });
    }
    
    const validPassword = await bcrypt.compare(senha, user.senha);
    if (!validPassword) {
      return res.status(401).json({ message: 'Email ou senha inválidos' });
    }
    
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    const userData = {
      id: user.id,
      nomeCompleto: user.nome_completo,
      sexo: user.sexo,
      dataNascimento: user.data_nascimento,
      idade: user.idade,
      email: user.email
    };
    
    res.json({ 
      message: 'Login realizado com sucesso',
      token,
      user: userData
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erro ao fazer login' });
  }
};
