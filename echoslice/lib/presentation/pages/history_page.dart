import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color goldAccent = Theme.of(context).primaryColor;
    return Center(
      child: Text('📂 Próximamente: Tu Historial de Audios', 
        style: TextStyle(color: goldAccent, fontSize: 18)),
    );
  }
}