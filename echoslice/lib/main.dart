import 'package:echoslice/core/notification_service.dart';
import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';


void main() async {
  // 3. Nos aseguramos de que los motores de Flutter estén encendidos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. ¡Despertamos al cartero y pedimos permiso!
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoSlice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, 
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}