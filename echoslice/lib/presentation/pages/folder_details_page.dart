import 'dart:io';
import 'package:flutter/material.dart';

class FolderDetailsPage extends StatefulWidget {
  // MEJOR PRÁCTICA #5: Usamos final para la variable que recibe la pantalla
  final Directory carpeta;
  
  const FolderDetailsPage({super.key, required this.carpeta});

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  late Future<List<File>> _archivosFuture;

  @override
  void initState() {
    super.initState();
    // Cargamos los archivos de esta carpeta específica al abrir la pantalla
    _archivosFuture = _cargarArchivos();
  }

  Future<List<File>> _cargarArchivos() async {
    if (await widget.carpeta.exists()) {
      final entidades = widget.carpeta.listSync();
      
      // Filtramos solo los archivos de audio
      final archivos = entidades.whereType<File>().where((file) {
        final extension = file.path.toLowerCase();
        return extension.endsWith('.m4a') || extension.endsWith('.mp3') || extension.endsWith('.wav');
      }).toList();
      
      // Los ordenamos por nombre (Parte 1, Parte 2, etc.)
      archivos.sort((a, b) => a.path.compareTo(b.path));
      return archivos;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final Color goldAccent = Theme.of(context).primaryColor;
    final Color bgDark = Theme.of(context).scaffoldBackgroundColor;
    final String nombreCarpeta = widget.carpeta.path.split('/').last;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text(
          nombreCarpeta,
          style: TextStyle(color: goldAccent, fontFamily: 'serif', fontSize: 18),
        ),
        iconTheme: IconThemeData(color: goldAccent), // Color de la flecha de regreso
      ),
      body: FutureBuilder<List<File>>(
        future: _archivosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: goldAccent));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('La carpeta está vacía 👻', style: TextStyle(color: Colors.grey)));
          }

          final archivos = snapshot.data!;

          return Column(
            children: [
              // --- EL BOTÓN DE IA PARA TODA LA CLASE ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generando apuntes de toda la clase... 🚧')),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, color: Colors.black),
                  label: const Text('Generar Apuntes Completos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const Divider(color: Colors.white24, indent: 20, endIndent: 20),
              
              // --- LISTA DE AUDIOS CORTADOS ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: archivos.length,
                  itemBuilder: (context, index) {
                    return _ArchivoItemCard(
                      archivo: archivos[index],
                      goldAccent: goldAccent,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =====================================================================
// 🧱 WIDGET SEPARADO (Mejor Práctica #1)
// =====================================================================
class _ArchivoItemCard extends StatelessWidget {
  final File archivo;
  final Color goldAccent;

  const _ArchivoItemCard({required this.archivo, required this.goldAccent});

  @override
  Widget build(BuildContext context) {
    final String nombreArchivo = archivo.path.split('/').last;
    
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.audiotrack, color: goldAccent),
        title: Text(nombreArchivo, style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_fill, color: Colors.white38, size: 30),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reproductor en construcción 🚧')),
            );
          },
        ),
      ),
    );
  }
}