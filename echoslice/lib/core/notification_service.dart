import 'dart:ui'; // Necesario para la clase Color
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // --- MAGIA DEL ÍCONO: Usamos tu silueta blanca en lugar del launcher por defecto ---
    const AndroidInitializationSettings ajustesAndroid = AndroidInitializationSettings('ic_notification');

    const InitializationSettings ajustesTotales = InitializationSettings(
      android: ajustesAndroid,
    );

    // Tu FIX 1: Parámetro nombrado 'settings'
    await _plugin.initialize(settings: ajustesTotales);

    // Tu FIX 2: Permisos correctos
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails detallesAndroid = AndroidNotificationDetails(
      'canal_echoslice_1', 
      'Avisos de Corte',
      importance: Importance.max,
      priority: Priority.high,
      // --- MAGIA VISUAL: Ícono y tu color dorado corporativo ---
      icon: 'ic_notification', 
      color: Color(0xFFD4AF37), // Pinta el gatito de dorado cuando bajas la barra
    );

    const NotificationDetails detallesPlataforma = NotificationDetails(
      android: detallesAndroid,
    );

    // Tu FIX 3: Parámetros nombrados para TODO
    await _plugin.show(
      id: 0, 
      title: title, 
      body: body, 
      notificationDetails: detallesPlataforma,
    );
  }
}