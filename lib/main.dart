import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/screens/admin_screen.dart';
import 'package:tabagismo_app/screens/enfermeira_screen.dart';
import 'package:tabagismo_app/screens/sobre_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/polling_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PollingService()..startPolling(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desfumo - Apoio ao Tabagismo',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2C7DA0),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: FutureBuilder(
        future: AuthService().getSavedUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            final fullData = Map<String, dynamic>.from(snapshot.data!);
            final userData = Map<String, dynamic>.from(fullData['user']);
            final token = fullData['token']?.toString() ?? '';
            
            if (token.isNotEmpty) {
              userData['token'] = token;
              
              final tipoUsuario = userData['tipo_usuario']?.toString() ?? 'comum';
              final isAdmin = userData['is_admin'] == 1;
              
              if (isAdmin || tipoUsuario == 'admin') {
                return AdminScreen(userData: userData);
              } else if (tipoUsuario == 'enfermeira') {
                return EnfermeiraScreen(userData: userData);
              } else {
                return HomeScreen(userData: userData);
              }
            }
          }
          
          return const SobreScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}