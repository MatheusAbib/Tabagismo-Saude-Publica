const express = require('express');
const upaController = require('../controllers/upaController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);
router.get('/search', upaController.searchUPA);

module.exports = router;
