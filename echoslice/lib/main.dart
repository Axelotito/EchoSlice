import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- MEJOR PRÁCTICA: TEMA GLOBAL DEFINIDO AQUÍ ---
    return MaterialApp(
      title: 'EchoSlice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Fondo carbón
        primaryColor: const Color(0xFFE5C158), // Acento dorado
        cardColor: const Color(0xFF262626), // Color de tarjetas
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}