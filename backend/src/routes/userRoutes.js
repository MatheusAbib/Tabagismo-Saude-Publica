const express = require('express');
const userController = require('../controllers/userController');
const sintomaController = require('../controllers/sintomaController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.get('/me', userController.getUserData);
router.put('/update', userController.updateUser);
router.put('/change-password', userController.changePassword);
router.put('/goal', userController.updateGoal);
router.post('/sintomas', sintomaController.registrarSintoma);
router.get('/sintomas', sintomaController.getSintomasUsuario);
router.get('/sintomas/hoje', sintomaController.getSintomaHoje);

module.exports = router;