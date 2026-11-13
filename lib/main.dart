
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
  const MyApp({super.key});

  static const Color _primary = Color(0xFF426E8C);
  static const Color _primaryDark = Color(0xFF355C78);
  static const Color _primaryLight = Color(0xFFE1EDF6);
  static const Color _background = Color(0xFFFFFDF9);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceSecondary = Color(0xFFFAF8F3);
  static const Color _border = Color(0xFFE6E5DF);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF667078);
  static const Color _error = Color(0xFFC65D47);

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      primaryContainer: _primaryLight,
      onPrimaryContainer: _primaryDark,
      secondary: _primaryDark,
      onSecondary: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
      error: _error,
      onError: Colors.white,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
    );

    final textTheme = baseTheme.textTheme.apply(
      bodyColor: _textPrimary,
      displayColor: _textPrimary,
      fontFamily: 'Inter',
    );

    return baseTheme.copyWith(
      primaryColor: _primary,
      dividerColor: _border,
      disabledColor: _textSecondary.withValues(alpha: 0.45),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(
        color: _primary,
        size: 22,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: _primaryLight,
        circularTrackColor: _primaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: _primary,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: _border,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'DMSerifDisplay',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: _textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.5,
          color: _textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: _border,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _textSecondary,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _primary,
        ),
        prefixIconColor: _primary,
        suffixIconColor: _textSecondary,
        errorStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: _error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _error,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _border,
          disabledForegroundColor: _textSecondary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(
            color: _border,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _primary,
          highlightColor: _primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _primary,
        unselectedLabelColor: _textSecondary,
        indicatorColor: _primary,
        dividerColor: _border,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: _border,
          ),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _textPrimary,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(_surface),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: _border,
              ),
            ),
          ),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _textPrimary,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(
          color: _border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary;
          }
          return _textSecondary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary;
          }
          return _border;
        }),
        trackOutlineColor: WidgetStateProperty.all(
          Colors.transparent,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _primaryLight,
        thumbColor: _primary,
        overlayColor: Color(0x22426E8C),
        valueIndicatorColor: _primaryDark,
        valueIndicatorTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _primary,
        headerForegroundColor: Colors.white,
        todayForegroundColor: WidgetStateProperty.all(_primary),
        dayForegroundColor: WidgetStateProperty.all(_textPrimary),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: _border,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surface,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: _textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: _border,
          ),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          _primary.withValues(alpha: 0.55),
        ),
        trackColor: WidgetStateProperty.all(_primaryLight),
        thickness: WidgetStateProperty.all(4),
        radius: const Radius.circular(8),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desfumo - Apoio ao Tabagismo',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: _buildTheme(),
      home: FutureBuilder(
        future: AuthService().getSavedUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: _primary,
                  strokeWidth: 3,
                ),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final fullData =
                Map<String, dynamic>.from(snapshot.data!);

            final userData =
                Map<String, dynamic>.from(fullData['user']);

            final token = fullData['token']?.toString() ?? '';

            if (token.isNotEmpty) {
              userData['token'] = token;

              final tipoUsuario =
                  userData['tipo_usuario']?.toString() ?? 'comum';

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
    );
  }
}
