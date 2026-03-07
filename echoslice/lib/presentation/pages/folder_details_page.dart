import 'dart:io';
import 'package:echoslice/core/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/services/ai_service.dart';
import '../../data/services/pdf_service.dart';


class FolderDetailsPage extends StatefulWidget {
  final Directory carpeta;
  const FolderDetailsPage({super.key, required this.carpeta});

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  late Future<List<File>> _archivosFuture;
  final AudioPlayer _reproductor = AudioPlayer();
  String? _archivoSonando; 

  // --- VARIABLES PARA LA IA ---
  final AiService _aiService = AiService();
  final PdfService _pdfService = PdfService();
  bool _generandoApuntes = false;
  String _textoProgresoIa = "";

  @override
  void initState() {
    super.initState();
    _archivosFuture = _cargarArchivos();
    
    _reproductor.playerStateStream.listen((estado) {
      if (estado.processingState == ProcessingState.completed) {
        setState(() { _archivoSonando = null; });
      }
    });
  }

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

  Future<void> _tocarAudio(String rutaArchivo) async {
    try {
      if (_archivoSonando == rutaArchivo && _reproductor.playing) {
        await _reproductor.pause();
        setState(() { _archivoSonando = null; });
      } else {
        await _reproductor.setFilePath(rutaArchivo);
        setState(() { _archivoSonando = rutaArchivo; });
        _reproductor.play(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al reproducir: $e')));
    }
  }

  // =================================================================
  // 🤖 EL CEREBRO DE LA ORQUESTACIÓN (MAP-REDUCE)
  // =================================================================
  Future<void> _generarApuntesCompletos(List<File> archivos) async {
    setState(() {
      _generandoApuntes = true;
      _textoProgresoIa = "Preparando a Gemini... 🧠";
    });

    try {
      List<String> todosLosApuntes = [];
      
      // 1. MAP: Procesamos cada audio uno por uno para no saturar la IA
      // 1. MAP: Procesamos cada audio uno por uno para no saturar la IA
      for (int i = 0; i < archivos.length; i++) {
        setState(() {
          _textoProgresoIa = "Escuchando parte ${i + 1} de ${archivos.length}...\n(Gemini está tomando notas ✍️)";
        });
        
        // Mandamos el audio a la IA y esperamos el texto
        String apunte = await _aiService.generarApuntesDeAudio(archivos[i]);
        todosLosApuntes.add(apunte);

        // ¡NUEVO!: Freno de mano quitado. Solo esperamos 4 segundos gracias al modelo Flash
        if (i < archivos.length - 1) { 
           await Future.delayed(const Duration(seconds: 4));
        }
      }

      setState(() {
        _textoProgresoIa = "Armando tu PDF de estudio... 📄";
      });

      // 2. REDUCE: Juntamos todo en un PDF
      final String nombreClase = widget.carpeta.path.split('/').last;
      final String rutaPdf = await _pdfService.generarPdf(
        tituloClase: nombreClase,
        apuntesPorParte: todosLosApuntes,
        rutaCarpeta: widget.carpeta.path,
      );

      // 3. ¡AVISAMOS DEL ÉXITO!
      await NotificationService.showNotification(
        title: '¡Apuntes de $nombreClase listos! 🎓',
        body: 'Tu PDF se guardó junto a tus audios.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF guardado con éxito', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 5),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error con la IA: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Apagamos el estado de carga sin importar qué pase
      setState(() { _generandoApuntes = false; });
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
              // --- SECCIÓN MAGIA IA ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _generandoApuntes 
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: goldAccent.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: goldAccent),
                          const SizedBox(height: 15),
                          Text(
                            _textoProgresoIa, 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: goldAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _generarApuntesCompletos(archivos),
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
              
              // --- LISTA DE AUDIOS ---
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