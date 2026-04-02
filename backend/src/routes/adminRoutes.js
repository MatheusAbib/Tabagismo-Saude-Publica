const express = require('express');
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.get('/stats', adminController.getStats);
router.get('/usuarios', adminController.getUsuarios);
router.get('/usuarios/paginados', adminController.getUsuariosPaginados);
router.get('/usuarios/:id', adminController.getUsuarioDetalhes);
router.put('/usuarios/:id', adminController.atualizarUsuario);
router.put('/matricula', adminController.atualizarMatricula);

router.get('/upas', adminController.getUPAs);
router.post('/upas', adminController.criarUPA);
router.put('/upas/:id', adminController.atualizarUPA);
router.delete('/upas/:id', adminController.deletarUPA);

router.get('/enfermeiras', adminController.getEnfermeiras);
router.post('/enfermeiras', adminController.criarEnfermeira);
router.put('/enfermeiras/:id', adminController.atualizarEnfermeira);
router.delete('/enfermeiras/:id', adminController.deletarEnfermeira);
router.get('/upas-lista', adminController.getUPAsParaEnfermeira);

module.exports = router;