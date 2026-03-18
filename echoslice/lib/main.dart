import 'package:echoslice/core/notification_service.dart';
import 'package:echoslice/presentation/pages/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  // 1. Aseguramos que el motor de Flutter arranque
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. ¡DIBUJAMOS LA APP INMEDIATAMENTE! (Adiós pantalla negra)
  runApp(const MyApp());
  
  // 3. Arrancamos las notificaciones en el fondo para que MIUI no se congele
  NotificationService.init().catchError((error) {
    debugPrint("MIUI bloqueó las notificaciones iniciales: $error");
  });
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
      home: MainScreen(),
    );
  }
}