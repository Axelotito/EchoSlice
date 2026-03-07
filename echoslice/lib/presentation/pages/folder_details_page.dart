import 'dart:io';
import 'package:flutter/material.dart';
// ¡NUEVO! Importamos el motor de audio
import 'package:just_audio/just_audio.dart';

class FolderDetailsPage extends StatefulWidget {
  final Directory carpeta;
  const FolderDetailsPage({super.key, required this.carpeta});

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  late Future<List<File>> _archivosFuture;
  
  // --- MEJOR PRÁCTICA: Variables de estado del Reproductor ---
  final AudioPlayer _reproductor = AudioPlayer();
  String? _archivoSonando; // Guarda la ruta del archivo que está sonando actualmente

  @override
  void initState() {
    super.initState();
    _archivosFuture = _cargarArchivos();
    
    // Escuchamos cuando el audio termina por completo para apagar el ícono de "Pause"
    _reproductor.playerStateStream.listen((estado) {
      if (estado.processingState == ProcessingState.completed) {
        setState(() {
          _archivoSonando = null;
        });
      }
    });
  }

  // MEJOR PRÁCTICA: Siempre hay que "destruir" el reproductor al salir de la pantalla
  // para que la música no siga sonando como fantasma en el fondo.
  @override
  void dispose() {
    _reproductor.dispose();
    super.dispose();
  }

  Future<List<File>> _cargarArchivos() async {
    if (await widget.carpeta.exists()) {
      final entidades = widget.carpeta.listSync();
      final archivos = entidades.whereType<File>().where((file) {
        final ext = file.path.toLowerCase();
        return ext.endsWith('.m4a') || ext.endsWith('.mp3') || ext.endsWith('.wav');
      }).toList();
      archivos.sort((a, b) => a.path.compareTo(b.path));
      return archivos;
    }
    return [];
  }

  // --- FUNCIÓN DEL CEREBRO DE REPRODUCCIÓN ---
  // --- FUNCIÓN DEL CEREBRO DE REPRODUCCIÓN (CORREGIDA) ---
  Future<void> _tocarAudio(String rutaArchivo) async {
    try {
      // Si tocas el mismo que ya está sonando, se pausa.
      if (_archivoSonando == rutaArchivo && _reproductor.playing) {
        await _reproductor.pause();
        setState(() { _archivoSonando = null; });
      } else {

        await _reproductor.setFilePath(rutaArchivo);
 
        setState(() { _archivoSonando = rutaArchivo; });
        
        _reproductor.play(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir: $e')),
      );
    }
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
        title: Text(nombreCarpeta, style: TextStyle(color: goldAccent, fontFamily: 'serif', fontSize: 18)),
        iconTheme: IconThemeData(color: goldAccent),
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: archivos.length,
                  itemBuilder: (context, index) {
                    final archivo = archivos[index];
                    final estaSonando = _archivoSonando == archivo.path;

                    return _ArchivoItemCard(
                      archivo: archivo,
                      goldAccent: goldAccent,
                      estaSonando: estaSonando,
                      alPresionarPlay: () => _tocarAudio(archivo.path),
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
// 🧱 WIDGET SEPARADO
// =====================================================================
class _ArchivoItemCard extends StatelessWidget {
  final File archivo;
  final Color goldAccent;
  final bool estaSonando;
  final VoidCallback alPresionarPlay;

  const _ArchivoItemCard({
    required this.archivo, 
    required this.goldAccent,
    required this.estaSonando,
    required this.alPresionarPlay,
  });

  @override
  Widget build(BuildContext context) {
    final String nombreArchivo = archivo.path.split('/').last;
    
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Si está sonando, le ponemos un borde dorado para que resalte
        side: estaSonando ? BorderSide(color: goldAccent, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          estaSonando ? Icons.graphic_eq : Icons.audiotrack, 
          color: goldAccent
        ),
        title: Text(
          nombreArchivo, 
          style: TextStyle(
            color: estaSonando ? goldAccent : Colors.white70,
            fontWeight: estaSonando ? FontWeight.bold : FontWeight.normal,
          )
        ),
        trailing: IconButton(
          // Cambia dinámicamente el ícono de Play a Pause
          icon: Icon(
            estaSonando ? Icons.pause_circle_filled : Icons.play_circle_fill, 
            color: estaSonando ? goldAccent : Colors.white38, 
            size: 34
          ),
          onPressed: alPresionarPlay,
        ),
      ),
    );
  }
}