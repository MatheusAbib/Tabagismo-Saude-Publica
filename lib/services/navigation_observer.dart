import 'package:flutter/material.dart';
import 'package:tabagismo_app/services/loader_service.dart';

class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _showLoader(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _hideLoader();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _showLoader(newRoute);
    }
  }

  void _showLoader(Route route) {
    final context = route.navigator?.context;
    if (context != null && context.mounted) {
      if (!LoaderService.isShowing) {
        LoaderService.show(context, message: 'Carregando...');
        Future.delayed(const Duration(milliseconds: 600), () {
          if (LoaderService.isShowing) {
            LoaderService.hide();
          }
        });
      }
    }
  }

  void _hideLoader() {
    if (LoaderService.isShowing) {
      LoaderService.hide();
    }
  }
}