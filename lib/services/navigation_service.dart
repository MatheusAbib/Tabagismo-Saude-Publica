import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> push<T>(Widget page, {String? routeName}) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushReplacement<T>(Widget page) {
    return navigatorKey.currentState!.pushReplacement<T, T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}