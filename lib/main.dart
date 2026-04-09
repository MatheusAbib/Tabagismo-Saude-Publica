import 'package:flutter/material.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/screens/admin_screen.dart';
import 'package:tabagismo_app/screens/enfermeira_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desfumo',
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
        final userData = snapshot.data!['user'];
        final tipoUsuario = userData['tipo_usuario'] ?? 'comum';
        final isAdmin = userData['is_admin'] == 1;
        
        if (isAdmin || tipoUsuario == 'admin') {
          return AdminScreen(userData: userData);
        } else if (tipoUsuario == 'enfermeira') {
          return EnfermeiraScreen(userData: userData);
        } else {
          return HomeScreen(userData: userData);
        }
      }
          
          return LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}