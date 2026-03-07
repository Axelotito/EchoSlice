import 'package:flutter/material.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'notes_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // MEJOR PRÁCTICA #4: Guión bajo para variables privadas
  int _indiceActual = 0;

  // MEJOR PRÁCTICA #5: Usar final para colecciones que no cambian su referencia
  final List<Widget> _pantallas = [
    const HomePage(),
    const HistoryPage(),
    const NotesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Usamos el color de fondo definido en el tema
    final Color bgDark = Theme.of(context).scaffoldBackgroundColor;
    final Color goldAccent = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bgDark,
      body: _pantallas[_indiceActual], // Muestra la pantalla según el índice
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          backgroundColor: const Color(0xFF1A1A1A),
          selectedItemColor: goldAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (int nuevoIndice) {
            setState(() {
              _indiceActual = nuevoIndice;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.content_cut),
              label: 'Cortar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_special),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), // El toque de la IA
              label: 'Notas IA',
            ),
          ],
        ),
      ),
    );
  }
}