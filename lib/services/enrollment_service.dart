import 'package:tabagismo_app/services/api_service.dart';

class EnrollmentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> enroll(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/enrollment/create', data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyEnrollments() async {
    try {
      final response = await _api.get('/enrollment/my-enrollments');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStatus(int enrollmentId, String status) async {
    try {
      final response = await _api.put('/enrollment/$enrollmentId/status', {
        'status': status,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelEnrollment(int enrollmentId) async {
    try {
      final response = await _api.delete('/enrollment/$enrollmentId/cancel');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}