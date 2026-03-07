import 'dart:io';
import 'package:echoslice/core/notification_service.dart';
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
              
              // 1. APLICANDO MEJOR PRÁCTICA #1: Usamos un Widget separado para el título
              _TituloCentrado(goldAccent: goldAccent),
              const SizedBox(height: 30),

              // --- SELECTOR DE TIEMPO ELEGANTE ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
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
                          DropdownMenuItem(value: 20, child: Text('20 min')),
                          DropdownMenuItem(value: 30, child: Text('30 min')),
                          DropdownMenuItem(value: 60, child: Text('1 Hora')),
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

              // 2. APLICANDO MEJOR PRÁCTICA #1: Usamos un Widget separado para la IA
              _InterruptorIA(goldAccent: goldAccent, cardDark: cardDark),
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
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: goldAccent.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.audio_file_outlined, color: goldAccent, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        miAudioSeleccionado == null ? 'Cargar grabación' : 'Cambiar archivo',
                        style: TextStyle(color: goldAccent, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- LA LISTA DE CORTES ---
              if (miAudioSeleccionado != null) ...[
                Text(
                  miAudioSeleccionado!.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Duración total: ${miAudioSeleccionado!.durationInSeconds ~/ 60}m ${miAudioSeleccionado!.durationInSeconds % 60}s',
                  style: TextStyle(color: textMuted, fontSize: 14),
                ),
                const SizedBox(height: 20),

                if (estaCortando) ...[
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: goldAccent, strokeWidth: 3),
                        const SizedBox(height: 15),
                        Text(textoProgreso, style: TextStyle(color: goldAccent, fontSize: 16)),
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
      
      floatingActionButton: (miAudioSeleccionado != null && !estaCortando)
          ? FloatingActionButton(
              backgroundColor: cardDark,
              shape: CircleBorder(side: BorderSide(color: goldAccent, width: 1.5)),
              onPressed: () async {
                  setState(() { 
                    estaCortando = true; 
                    textoProgreso = "Preparando cortes...";
                  });

                  String nombreLimpio = miAudioSeleccionado!.name.split('.').first;
                  
                  // --- LA RUTA MAESTRA: AQUÍ OBLIGAMOS A QUE VAYA A /Audios/ ---
                  String rutaBase = '/storage/emulated/0/Download/EchoSlice/Audios/$nombreLimpio';
                  String carpetaDestino = rutaBase;
                  
                  int contador = 1;
                  while (await Directory(carpetaDestino).exists()) {
                    carpetaDestino = '${rutaBase}_$contador';
                    contador++;
                  }

                  // El "recursive: true" es el que hace la magia de crear "Audios" si no existe
                  await Directory(carpetaDestino).create(recursive: true);

                  int duracionPedazo = minutosSeleccionados * 60; 
                  int segundosTotales = miAudioSeleccionado!.durationInSeconds;

                  for (int i = 0; i < segundosTotales; i += duracionPedazo) {
                    int inicio = i;
                    int fin = i + duracionPedazo;
                    if (fin > segundosTotales) fin = segundosTotales;

                    int numeroDeParte = (i ~/ duracionPedazo) + 1;

                    setState(() { textoProgreso = "Procesando parte $numeroDeParte..."; });
                    await Future.delayed(const Duration(milliseconds: 500));

                    await carnicero.cortarPedazo(
                      miAudioSeleccionado!.path, inicio, fin,
                      miAudioSeleccionado!.name, numeroDeParte, carpetaDestino, 
                    );
                  }

                  setState(() { estaCortando = false; }); 
                  
                  await NotificationService.showNotification(
                    title: '¡Audio procesado! 🎧',
                    body: 'Tus cortes están listos en Descargas/EchoSlice/Audios',
                  );
              },
              child: Icon(Icons.content_cut, color: goldAccent, size: 28),
            )
          : null,
    );
  }
}

// =====================================================================
// 🧱 WIDGETS SEPARADOS (MEJOR PRÁCTICA #1: Refactorizar en Widgets)
// =====================================================================

class _TituloCentrado extends StatelessWidget {
  final Color goldAccent;
  const _TituloCentrado({required this.goldAccent});

  @override
  Widget build(BuildContext context) {
    return Center( // <--- AQUÍ ESTÁ EL TÍTULO PERFECTAMENTE CENTRADO
      child: Text(
        'EchoSlice',
        style: TextStyle(
          color: goldAccent,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontFamily: 'serif', 
        ),
      ),
    );
  }
}

class _InterruptorIA extends StatelessWidget {
  final Color goldAccent;
  final Color cardDark;
  const _InterruptorIA({required this.goldAccent, required this.cardDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: goldAccent),
              const SizedBox(width: 10),
              const Text('Generar Apuntes IA', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          Switch(
            value: false, 
            activeColor: goldAccent,
            onChanged: (bool valor) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IA en construcción 🚧')),
              );
            },
          ),
        ],
      ),
    );
  }
}