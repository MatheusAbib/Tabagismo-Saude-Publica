const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const upaRoutes = require('./routes/upaRoutes');
const enrollmentRoutes = require('./routes/enrollmentRoutes');
const adminRoutes = require('./routes/adminRoutes');
const enfermeiraRoutes = require('./routes/enfermeiraRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/upa', upaRoutes);
app.use('/api/enrollment', enrollmentRoutes);
app.use('/api/admin', adminRoutes);

app.use('/api/enfermeira', enfermeiraRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'API Tabagismo App' });
});

module.exports = app;