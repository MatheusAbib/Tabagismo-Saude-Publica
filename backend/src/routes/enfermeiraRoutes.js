const express = require('express');
const enfermeiraController = require('../controllers/enfermeiraController');
const turmaController = require('../controllers/turmaController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);
router.get('/usuarios-espera', enfermeiraController.getUsuariosEmEspera);
router.put('/matricula-status', enfermeiraController.atualizarStatusMatricula);
router.get('/usuarios', enfermeiraController.getUsuariosDaUPA);
router.get('/dashboard-stats', enfermeiraController.getDashboardStats);

router.post('/presenca', enfermeiraController.registrarPresenca);
router.get('/presencas/:matriculaId', enfermeiraController.getPresencasPorMatricula);
router.get('/presencas', enfermeiraController.getPresencasDaUPA);
router.get('/presencas/estatisticas/:matriculaId', enfermeiraController.getEstatisticasPresenca);

router.get('/lista-presenca', enfermeiraController.getUsuariosMatriculadosComPresencas);
router.post('/presencas-lote', enfermeiraController.salvarPresencasEmLote);
router.get('/historico-presencas', enfermeiraController.getHistoricoPresencas);
router.get('/historico-usuarios', enfermeiraController.getHistoricoPorUsuario);
router.get('/historico-detalhado', enfermeiraController.getHistoricoDetalhado);

router.post('/encerrar-turma', enfermeiraController.encerrarTurma);
router.get('/evolucao-geral', enfermeiraController.getEvolucaoGeral);

router.get('/turmas/:upaId', turmaController.getTurmasPorUPA);

module.exports = router;