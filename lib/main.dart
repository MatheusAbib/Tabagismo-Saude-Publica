import 'package:flutter/material.dart';
import 'package:tabagismo_app/screens/login_screen.dart';
import 'package:tabagismo_app/screens/home_screen.dart';
import 'package:tabagismo_app/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabagismo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: AuthService().getSavedUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(userData: snapshot.data!['user']);
          }
          
          return LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}