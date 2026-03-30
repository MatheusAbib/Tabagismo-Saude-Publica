const express = require('express');
const userController = require('../controllers/userController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.get('/me', userController.getUserData);
router.put('/update', userController.updateUser);
router.put('/change-password', userController.changePassword);

module.exports = router;