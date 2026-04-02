const express = require('express');
const enfermeiraController = require('../controllers/enfermeiraController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);
router.get('/usuarios-espera', enfermeiraController.getUsuariosEmEspera);
router.put('/matricula-status', enfermeiraController.atualizarStatusMatricula);

module.exports = router;