import 'dart:ui';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false; // <-- Seguro anti-fallos

  static Future<void> init() async {
    if (_isInitialized) return; // Si ya se inicializó, no lo hacemos de nuevo

    try {
      const AndroidInitializationSettings ajustesAndroid = AndroidInitializationSettings('ic_notification');
      
      const InitializationSettings ajustesTotales = InitializationSettings(
        android: ajustesAndroid,
      );

      await _plugin.initialize(settings: ajustesTotales);

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
          
      _isInitialized = true;
      debugPrint("✅ Notificaciones inicializadas correctamente");
    } catch (e) {
      debugPrint("❌ Error al inicializar notificaciones: $e");
    }
  }

  static Future<void> showNotification({required String title, required String body}) async {
    // Si por alguna razón de MIUI no se inicializó al arrancar la app, lo forzamos aquí
    if (!_isInitialized) {
      await init();
    }

    try {
      const AndroidNotificationDetails detallesAndroid = AndroidNotificationDetails(
        'canal_echoslice_1', 
        'Avisos de Corte',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification', 
        color: Color(0xFFD4AF37),
      );

      const NotificationDetails detallesPlataforma = NotificationDetails(
        android: detallesAndroid,
      );

      await _plugin.show(
        id: DateTime.now().millisecond, // Usamos el tiempo para que no se sobreescriban si mandas varias rápido
        title: title, 
        body: body, 
        notificationDetails: detallesPlataforma,
      );
      debugPrint("✅ Notificación enviada: $title");
    } catch (e) {
      debugPrint("❌ Error al enviar notificación: $e");
    }
  }
}