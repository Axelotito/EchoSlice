import 'dart:io';
import 'package:echoslice/data/audio_repository_impl.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/audio_class.dart';
import '../../domain/usecases/split_audio_usecase.dart';
import '../../data/services/audio_cutter_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final audioRepository = AudioRepositoryImpl();
  AudioClass? miAudioSeleccionado;
  final cerebroCortes = SplitAudioUseCase();
  List<String> pedazosCalculados = [];
  final carnicero = AudioCutterService();
  
  bool estaCortando = false; 
  String textoProgreso = ""; 
  int minutosSeleccionados = 15; 

  void _recalcularLista() {
    if (miAudioSeleccionado != null) {
      setState(() {
        pedazosCalculados = cerebroCortes.calcularFragmentos(
          miAudioSeleccionado!.durationInSeconds, 
          minutosSeleccionados
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoSlice 🎧'),
        centerTitle: true,
        elevation: 2,
      ),
      // ¡NUEVO! SafeArea protege tu app de la barra de gestos y la cámara
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Un respiro a los lados
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // Espacio arriba
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Cortar en pedazos de: ', style: TextStyle(fontSize: 16)),
                    DropdownButton<int>(
                      value: minutosSeleccionados,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5 minutos')),
                        DropdownMenuItem(value: 10, child: Text('10 minutos')),
                        DropdownMenuItem(value: 15, child: Text('15 minutos')),
                        DropdownMenuItem(value: 20, child: Text('20 minutos')),
                        DropdownMenuItem(value: 30, child: Text('30 minutos')),
                        DropdownMenuItem(value: 60, child: Text('1 Hora')),
                      ],
                      onChanged: (int? nuevoValor) {
                        if (nuevoValor != null) {
                          setState(() { minutosSeleccionados = nuevoValor; });
                          _recalcularLista(); 
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () async {
                    final audioFile = await audioRepository.pickAudioFile();
                    if (audioFile != null) {
                      setState(() { miAudioSeleccionado = audioFile; });
                      _recalcularLista();
                    }
                  },
                  icon: const Icon(Icons.folder_open, size: 28),
                  label: const Text('Seleccionar Audio', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                if (miAudioSeleccionado != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurpleAccent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.audio_file, color: Colors.deepPurpleAccent, size: 30),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200, 
                              child: Text(
                                miAudioSeleccionado!.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duración: ${miAudioSeleccionado!.durationInSeconds ~/ 60}m ${miAudioSeleccionado!.durationInSeconds % 60}s',
                              style: const TextStyle(color: Colors.greenAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                
                if (pedazosCalculados.isNotEmpty) ...[
                  
                  // --- LA MAGIA MOVIDA ARRIBA ---
                  // Si está cortando, mostramos la carga AQUÍ, bien visible
                  if (estaCortando) ...[
                    const CircularProgressIndicator(color: Colors.amber),
                    const SizedBox(height: 10),
                    Text(
                      textoProgreso, 
                      style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Si no está cortando, mostramos el título normal
                    Text('Cortes de $minutosSeleccionados minutos:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                  ],
                  // ------------------------------
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: pedazosCalculados.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          child: ListTile(
                            leading: const Icon(Icons.content_cut, color: Colors.amber),
                            title: Text(pedazosCalculados[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // Si NO está cortando, mostramos el botón
                  if (!estaCortando)
                    ElevatedButton.icon(
                        onPressed: () async {
                          setState(() { 
                            estaCortando = true; 
                            // ¡TEXTO LIMPIO! Sin advertencias
                            textoProgreso = "Creando carpeta para tu clase...";
                          });

                          String nombreLimpio = miAudioSeleccionado!.name.split('.').first;
                          String rutaBase = '/storage/emulated/0/Download/EchoSlice/$nombreLimpio';
                          String carpetaDestino = rutaBase;
                          
                          int contador = 1;
                          while (await Directory(carpetaDestino).exists()) {
                            carpetaDestino = '${rutaBase}_$contador';
                            contador++;
                          }

                          await Directory(carpetaDestino).create(recursive: true);

                          int duracionPedazo = minutosSeleccionados * 60; 
                          int segundosTotales = miAudioSeleccionado!.durationInSeconds;

                          for (int i = 0; i < segundosTotales; i += duracionPedazo) {
                            int inicio = i;
                            int fin = i + duracionPedazo;
                            if (fin > segundosTotales) fin = segundosTotales;

                            int numeroDeParte = (i ~/ duracionPedazo) + 1;

                            setState(() { 
                              // ¡TEXTO LIMPIO! Solo la información que importa
                              textoProgreso = "Cortando parte $numeroDeParte de ${pedazosCalculados.length}...";
                            });
                            
                            await Future.delayed(const Duration(milliseconds: 500));

                            await carnicero.cortarPedazo(
                              miAudioSeleccionado!.path,
                              inicio,
                              fin,
                              miAudioSeleccionado!.name,
                              numeroDeParte,
                              carpetaDestino, 
                            );
                          }

                          setState(() { estaCortando = false; }); 
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ ¡Éxito! Audios guardados en:\n$carpetaDestino'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 8),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('¡CORTAR AHORA!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                      ),
                      
                      const SizedBox(height: 20), // Un margen final para asegurar que nada pegue al borde
                  ]
                ], 
              ],
            ),
          ),
        ),
      ),
    );
  }
}