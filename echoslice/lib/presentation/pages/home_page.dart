import 'dart:io';
import 'package:echoslice/core/notification_service.dart';
import 'package:echoslice/data/audio_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // Escudo Anti-Sueño

import '../../domain/entities/audio_class.dart';
import '../../domain/usecases/split_audio_usecase.dart';
import '../../data/services/audio_cutter_service.dart';

// Importamos el cerebro y el PDF
import '../../data/services/ai_service.dart';
import '../../data/services/pdf_service.dart';

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
  
  // Servicios de IA
  final AiService _aiService = AiService();
  final PdfService _pdfService = PdfService();
  
  bool estaCortando = false; 
  String textoProgreso = ""; 
  int minutosSeleccionados = 15; 
  
  // ¡NUEVO! Variable del Switch
  bool _autoGenerarIA = false; 

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

  // =========================================================
  // 🤖 PIPELINE AUTOMÁTICO: CORTAR -> IA -> PDF
  // =========================================================
  Future<void> _iniciarProcesoMaestro() async {
    setState(() { 
      estaCortando = true; 
      textoProgreso = "Preparando cortes...";
    });

    // 1. ACTIVAMOS EL WAKELOCK (Para que Android no mate la app)
    WakelockPlus.enable();

    try {
      // --- FASE 1: CORTAR AUDIO ---
      String nombreLimpio = miAudioSeleccionado!.name.split('.').first;
      String rutaBase = '/storage/emulated/0/Download/EchoSlice/Audios/$nombreLimpio';
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

        setState(() { textoProgreso = "✂️ Cortando parte $numeroDeParte..."; });
        await Future.delayed(const Duration(milliseconds: 500));

        await carnicero.cortarPedazo(
          miAudioSeleccionado!.path, inicio, fin,
          miAudioSeleccionado!.name, numeroDeParte, carpetaDestino, 
        );
      }

      // --- FASE 2: IA AUTOMÁTICA (Si el switch está encendido) ---
      if (_autoGenerarIA) {
        setState(() { textoProgreso = "Cortes listos. Despertando a Gemini... 🧠"; });
        
        final directorio = Directory(carpetaDestino);
        final archivos = directorio.listSync().whereType<File>().toList();
        archivos.sort((a, b) => a.path.compareTo(b.path));

        List<String> todosLosApuntes = [];
        for (int i = 0; i < archivos.length; i++) {
          
          bool exito = false;
          String apunte = "";
          
          // --- BUCLE DE REINTENTO INTELIGENTE ---
          while (!exito) {
            setState(() { textoProgreso = "✍️ IA analizando parte ${i + 1} de ${archivos.length}..."; });
            
            apunte = await _aiService.generarApuntesDeAudio(archivos[i]);
            
            // Si Google nos bloquea temporalmente por rapidez (Quota exceeded / 429)
            if (apunte.contains('Quota exceeded') || apunte.contains('retry in')) {
              setState(() { textoProgreso = "Google pide pausa. Esperando 60s para continuar... ⏳"; });
              await Future.delayed(const Duration(seconds: 60)); // Esperamos 1 minuto y el while lo vuelve a intentar
            } else {
              exito = true; // Si no hay error, salimos del bucle de reintento
            }
          }
          
          todosLosApuntes.add(apunte);

          // Pausa normal entre archivos para evitar enojar a Google
          if (i < archivos.length - 1) { 
             setState(() { textoProgreso = "⏳ Enfriando motores (evitando límites)..."; });
             await Future.delayed(const Duration(seconds: 25)); // Lo subimos a 25s por seguridad
          }
        }
        setState(() { textoProgreso = "Armando tu PDF de estudio... 📄"; });
        await _pdfService.generarPdf(
          tituloClase: nombreLimpio,
          apuntesPorParte: todosLosApuntes,
          rutaCarpeta: 'dummy_path', // El PdfService ya sabe dónde guardarlo internamente
        );
        
        await NotificationService.showNotification(
          title: '¡Operación Completa! 🎓',
          body: 'Tus audios y tu PDF inteligente están listos.',
        );
      } else {
        // Si el switch estaba apagado, solo avisamos del corte
        await NotificationService.showNotification(
          title: '¡Audios cortados! 🎧',
          body: 'Tus fragmentos están listos en tu biblioteca.',
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      // APAGAMOS EL WAKELOCK AL TERMINAR (Para dejar descansar la batería)
      WakelockPlus.disable();
      setState(() { estaCortando = false; }); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color goldAccent = Theme.of(context).primaryColor;
    final Color cardDark = Theme.of(context).cardColor;
    final Color textMuted = const Color(0xFFA0A0A0);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  'EchoSlice',
                  style: TextStyle(color: goldAccent, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontFamily: 'serif'),
                ),
              ),
              const SizedBox(height: 30),

              // --- SELECTOR DE TIEMPO ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Segmentos de corte:', style: TextStyle(color: textMuted, fontSize: 16)),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: minutosSeleccionados,
                        dropdownColor: cardDark,
                        icon: Icon(Icons.keyboard_arrow_down, color: goldAccent),
                        style: TextStyle(color: goldAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 min')),
                          DropdownMenuItem(value: 10, child: Text('10 min')),
                          DropdownMenuItem(value: 15, child: Text('15 min')),
                        ],
                        onChanged: (int? nuevoValor) {
                          if (nuevoValor != null) {
                            setState(() { minutosSeleccionados = nuevoValor; });
                            _recalcularLista(); 
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- INTERRUPTOR DE IA (¡AHORA SÍ FUNCIONA!) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _autoGenerarIA ? goldAccent : goldAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: _autoGenerarIA ? goldAccent : Colors.grey),
                        const SizedBox(width: 10),
                        const Text('Generar Apuntes IA', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                    Switch(
                      value: _autoGenerarIA, 
                      activeColor: goldAccent,
                      onChanged: (bool valor) {
                        setState(() { _autoGenerarIA = valor; });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- BOTÓN DE SELECCIONAR AUDIO ---
              GestureDetector(
                onTap: () async {
                  final audioFile = await audioRepository.pickAudioFile();
                  if (audioFile != null) {
                    setState(() { miAudioSeleccionado = audioFile; });
                    _recalcularLista();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldAccent.withValues(alpha: 0.3))),
                  child: Column(
                    children: [
                      Icon(Icons.audio_file_outlined, color: goldAccent, size: 40),
                      const SizedBox(height: 10),
                      Text(miAudioSeleccionado == null ? 'Cargar grabación' : 'Cambiar archivo', style: TextStyle(color: goldAccent, fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- LA LISTA DE CORTES Y ESTADO ---
              if (miAudioSeleccionado != null) ...[
                Text(miAudioSeleccionado!.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 20),

                if (estaCortando) ...[
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: goldAccent, strokeWidth: 3),
                        const SizedBox(height: 15),
                        Text(textoProgreso, textAlign: TextAlign.center, style: TextStyle(color: goldAccent, fontSize: 16)),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: pedazosCalculados.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Icon(Icons.graphic_eq, color: goldAccent, size: 24),
                              const SizedBox(width: 15),
                              Text(pedazosCalculados[index], style: const TextStyle(color: Colors.white70, fontSize: 15)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      
      // --- BOTÓN DE INICIO MAESTRO ---
      floatingActionButton: (miAudioSeleccionado != null && !estaCortando)
          ? FloatingActionButton(
              backgroundColor: cardDark,
              shape: CircleBorder(side: BorderSide(color: goldAccent, width: 1.5)),
              onPressed: _iniciarProcesoMaestro, // <--- LLAMA A LA NUEVA FUNCIÓN AUTOMÁTICA
              child: Icon(Icons.content_cut, color: goldAccent, size: 28),
            )
          : null,
    );
  }
}