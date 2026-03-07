import 'dart:io';
import 'package:flutter/material.dart';
import 'folder_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // MEJOR PRÁCTICA #4 y #2: Variable privada para almacenar la búsqueda.
  // Al guardarlo aquí, evitamos que Android busque los archivos cada vez que mueves la pantalla.
  late Future<List<Directory>> _carpetasFuture;

  @override
  void initState() {
    super.initState();
    // Arrancamos la búsqueda de archivos solo UNA vez cuando se abre esta pestaña
    _carpetasFuture = _cargarHistorial();
  }

  // Función privada que va a la memoria del teléfono
  Future<List<Directory>> _cargarHistorial() async {
    final directorioBase = Directory('/storage/emulated/0/Download/EchoSlice');
    
    if (await directorioBase.exists()) {
      final entidades = directorioBase.listSync();
      
      // Filtramos solo las carpetas y las ordenamos de la más nueva a la más vieja
      final carpetas = entidades.whereType<Directory>().toList();
      carpetas.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return carpetas;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final Color goldAccent = Theme.of(context).primaryColor;
    final Color bgDark = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text(
          'Tus Clases Cortadas',
          style: TextStyle(color: goldAccent, fontFamily: 'serif', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // FutureBuilder es un widget mágico que muestra un estado de carga mientras espera los archivos
      body: FutureBuilder<List<Directory>>(
        future: _carpetasFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: goldAccent));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar historial 😔', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay audios cortados 🎧',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final carpetas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: carpetas.length,
            itemBuilder: (context, index) {
              final carpeta = carpetas[index];
              // MEJOR PRÁCTICA #1: Llamamos a un Widget separado para mantener el código limpio
              return _CarpetaHistorialCard(
                carpeta: carpeta,
                goldAccent: goldAccent,
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================================
// 🧱 WIDGET SEPARADO (Mejor Práctica #1)
// =====================================================================

class _CarpetaHistorialCard extends StatelessWidget {
  final Directory carpeta;
  final Color goldAccent;

  const _CarpetaHistorialCard({
    required this.carpeta,
    required this.goldAccent,
  });

  @override
  Widget build(BuildContext context) {
    // Sacamos el nombre de la carpeta de la ruta completa
    final String nombreCarpeta = carpeta.path.split('/').last;
    
    // Obtenemos la fecha en la que cortaste el audio
    final DateTime fechaModificacion = carpeta.statSync().modified;
    final String fechaLimpia = "${fechaModificacion.day}/${fechaModificacion.month}/${fechaModificacion.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldAccent.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(Icons.folder_zip, color: goldAccent, size: 36),
        title: Text(
          nombreCarpeta,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Cortado el: $fechaLimpia',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: goldAccent, size: 16),
        onTap: () {
          // --- NUEVA NAVEGACIÓN ---
          // Ponemos la carta de detalles encima de la baraja
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderDetailsPage(carpeta: carpeta),
            ),
          );
        },
      ),
    );
  }
}