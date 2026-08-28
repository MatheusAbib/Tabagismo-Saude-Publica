const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  console.log('🔐 AuthMiddleware chamado');
  console.log('📨 Headers:', req.headers);
  
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    console.log('❌ Token não fornecido');
    return res.status(401).json({ message: 'Token não fornecido' });
  }
  
  console.log('📝 AuthHeader:', authHeader);
  
  const parts = authHeader.split(' ');
  
  if (parts.length !== 2) {
    console.log('❌ Token mal formatado - partes:', parts.length);
    return res.status(401).json({ message: 'Token mal formatado' });
  }
  
  const [scheme, token] = parts;
  
  if (!/^Bearer$/i.test(scheme)) {
    console.log('❌ Scheme inválido:', scheme);
    return res.status(401).json({ message: 'Token mal formatado' });
  }
  
  console.log('🔑 Token recebido:', token.substring(0, 30) + '...');
  console.log('🔐 JWT_SECRET usado:', process.env.JWT_SECRET);
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('✅ Token decodificado:', decoded);
    req.userId = decoded.id;
    req.userTipo = decoded.tipo;
    req.userEmail = decoded.email;
    req.userTable = decoded.table || 'usuarios'
    return next();
  } catch (err) {
    console.error('❌ Erro ao verificar token:', err.message);
    return res.status(401).json({ message: 'Token inválido' });
  }
};