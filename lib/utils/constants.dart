class Constants {
  // Para produção (servidor)
  // static const String baseUrl = '/api';

//local
  static const String baseUrl = 'http://localhost:3000/api';

    
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String updateUserEndpoint = '/user/update';
  static const String changePasswordEndpoint = '/user/change-password';
  static const String upaEndpoint = '/upa/search';
}