import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings ajustesAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings ajustesTotales = InitializationSettings(
      android: ajustesAndroid,
    );

    // FIX 1: Ahora exige que le pongamos la etiqueta "settings:"
    await _plugin.initialize(settings: ajustesTotales);

    // FIX 2: Regresamos al nombre correcto para Android
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
    );

    const NotificationDetails detallesPlataforma = NotificationDetails(
      android: detallesAndroid,
    );

    // FIX 3: Ahora exige que etiquetemos ABSOLUTAMENTE TODO (id:, title:, body:, etc.)
    await _plugin.show(
      id: 0, 
      title: title, 
      body: body, 
      notificationDetails: detallesPlataforma,
    );
  }
}