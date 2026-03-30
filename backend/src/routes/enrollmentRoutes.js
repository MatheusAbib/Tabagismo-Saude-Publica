const express = require('express');
const enrollmentController = require('../controllers/enrollmentController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(authMiddleware);
router.post('/create', enrollmentController.createEnrollment);
router.get('/my-enrollments', enrollmentController.getUserEnrollments);
router.put('/:enrollmentId/status', enrollmentController.updateEnrollmentStatus);
router.delete('/:enrollmentId/cancel', enrollmentController.cancelEnrollment); 

module.exports = router;