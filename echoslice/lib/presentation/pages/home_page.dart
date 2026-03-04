import 'package:echoslice/data/audio_repository_impl.dart';
import 'package:flutter/material.dart';
// Importamos a nuestro trabajador de la Capa de Datos


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Instanciamos a nuestro trabajador (El que sabe usar file_picker)
    final audioRepository = AudioRepositoryImpl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoSlice 🎧'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            // 2. Cuando presionas el botón, le pasamos la estafeta al trabajador
            print("Llamando al trabajador para abrir la galería...");
            
            // La palabra 'await' le dice a la app: "Espérate aquí congelada hasta que el usuario elija su archivo"
            final audioFile = await audioRepository.pickAudioFile();

            // 3. Revisamos qué nos trajo el trabajador
            if (audioFile != null) {
              print("¡Éxito! Archivo seleccionado: ${audioFile.name}");
              
              // Si estamos en Flutter, podemos usar este mensajito flotante bonito
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Audio cargado: ${audioFile.name}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              print("El usuario se arrepintió y canceló.");
            }
          },
          icon: const Icon(Icons.folder_open, size: 28),
          label: const Text(
            'Seleccionar Audio', 
            style: TextStyle(fontSize: 18)
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}