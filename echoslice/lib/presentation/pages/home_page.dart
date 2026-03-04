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
  
  // Aquí guardaremos el audio temporalmente en la memoria de la pantalla
  AudioClass? miAudioSeleccionado;
  final cerebroCortes = SplitAudioUseCase();
  List<String> pedazosCalculados = [];
  final carnicero = AudioCutterService();
  bool estaCortando = false; // Para mostrar una ruedita de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoSlice 🎧'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final audioFile = await audioRepository.pickAudioFile();

                if (audioFile != null) {
                  setState(() {
                    miAudioSeleccionado = audioFile;
                    // Le mandamos el tiempo al cerebro y nos devuelve la lista
                    pedazosCalculados = cerebroCortes.calcularFragmentos(audioFile.durationInSeconds);
                  });
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
            
            // Un espacio invisible para separar
            const SizedBox(height: 40),

            // Si ya seleccionamos un audio, mostramos esta tarjeta en la pantalla
            if (miAudioSeleccionado != null) ...[
              const Text(
                'Clase lista para procesar:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              
              // --- INICIO DE LA CAJA MORADA ---
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
                        // Aquí hacemos las matemáticas rápidas para que se vea como "45m 20s"
                        Text(
                          'Duración: ${miAudioSeleccionado!.durationInSeconds ~/ 60}m ${miAudioSeleccionado!.durationInSeconds % 60}s',
                          style: const TextStyle(color: Colors.greenAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // --- FIN DE LA CAJA MORADA ---
              
              const SizedBox(height: 20),
            
              // Si hay pedazos calculados, los mostramos DEBAJO de la caja morada
              // Si hay pedazos calculados, los mostramos
            if (pedazosCalculados.isNotEmpty) ...[
              const Text('Cortes de 15 minutos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // ¡Arreglo visual! Expanded hace que tome el espacio necesario sin cortarse
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

              // EL GRAN BOTÓN DE CORTE
              estaCortando 
                ? const CircularProgressIndicator() // Si está cortando, mostramos la ruedita
                : ElevatedButton.icon(
                    onPressed: () async {
                      setState(() { estaCortando = true; }); // Encendemos la ruedita

                      int duracionPedazo = 15 * 60; // 15 minutos en segundos
                      int segundosTotales = miAudioSeleccionado!.durationInSeconds;

                      // Ciclo for para cortar cada pedazo
                      for (int i = 0; i < segundosTotales; i += duracionPedazo) {
                        int inicio = i;
                        int fin = i + duracionPedazo;
                        if (fin > segundosTotales) fin = segundosTotales;

                        int numeroDeParte = (i ~/ duracionPedazo) + 1;

                        // Mandamos a llamar al Carnicero
                        await carnicero.cortarPedazo(
                          miAudioSeleccionado!.path,
                          inicio,
                          fin,
                          miAudioSeleccionado!.name,
                          numeroDeParte,
                        );
                      }

                      setState(() { estaCortando = false; }); // Apagamos la ruedita
                      
                      // ¡Avisamos que terminó!
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ ¡Audio rebanado con éxito! Revisa tus documentos.'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
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
                  const SizedBox(height: 20),
              ]
            ], // Fin del bloque "if (miAudioSeleccionado != null)"
          ],
        ),
      ),
    );
  }
}