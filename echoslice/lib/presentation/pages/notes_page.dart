import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color goldAccent = Theme.of(context).primaryColor;
    return Center(
      child: Text('🤖 Próximamente: Tus Apuntes con IA', 
        style: TextStyle(color: goldAccent, fontSize: 18)),
    );
  }
}