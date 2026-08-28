import 'package:flutter/material.dart';
import 'package:tabagismo_app/widgets/loading_overlay.dart';

class LoaderManager extends StatefulWidget {
  final Widget child;

  const LoaderManager({super.key, required this.child});

  @override
  State<LoaderManager> createState() => _LoaderManagerState();

  static _LoaderManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_LoaderManagerState>();
  }
}

class _LoaderManagerState extends State<LoaderManager> {
  bool _isLoading = false;
  String _message = 'Carregando...';

  void show({String message = 'Carregando...'}) {
    setState(() {
      _isLoading = true;
      _message = message;
    });
  }

  void hide() {
    setState(() {
      _isLoading = false;
    });
  }

  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: _message,
      child: widget.child,
    );
  }
}