const express = require('express');
const adminController = require('../controllers/adminController');
const upaController = require('../controllers/upaController'); 
const turmaController = require('../controllers/turmaController'); 
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

router.get('/dashboard-stats', adminController.getAdminDashboardStats);
router.get('/evolucao-geral', adminController.getAdminEvolucaoGeral);

// Rotas de turmas (adicione se tiver)
router.get('/turmas/:upaId', turmaController.getTurmasPorUPA);
router.post('/turmas', turmaController.criarTurma);
router.put('/turmas/:id', turmaController.atualizarTurma);
router.delete('/turmas/:id', turmaController.deletarTurma);

// Rotas de UPA com turmas
router.post('/upas-com-turmas', upaController.criarUPAComTurmas);
router.put('/upas-com-turmas/:id', upaController.atualizarUPAComTurmas);

module.exports = router;