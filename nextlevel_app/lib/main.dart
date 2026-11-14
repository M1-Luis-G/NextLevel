import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'viewmodels/authviewmodel.dart';
import 'viewmodels/productoviewmodel.dart'; // <-- 1. NUEVO IMPORT
import 'views/loginview.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => ProductoViewModel(),
        ), // <-- 2. NUEVO PROVIDER
      ],
      child: const NextLevelAdminApp(),
    ),
  );
}

class NextLevelAdminApp extends StatelessWidget {
  const NextLevelAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextLevel Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF5C317A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C317A),
          primary: const Color(0xFF85679A),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF85679A),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF85679A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const LoginView(),
    );
  }
}
