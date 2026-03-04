import 'dart:io';
import 'package:simple_audio_trimmer/simple_audio_trimmer.dart';
import 'package:path_provider/path_provider.dart';

class AudioCutterService {
  
  // Esta función recibe la ruta de tu audio original y los segundos de inicio y fin
  Future<String?> cortarPedazo(String rutaOriginal, int inicioSegundos, int finSegundos, String nombreOriginal, int numeroParte) async {
    try {
      // 1. Buscamos una carpeta segura en tu celular para guardar el pedazo
      final directorio = await getApplicationDocumentsDirectory();
      
      // 2. Limpiamos el nombre original (le quitamos el .mp3 o .m4a)
      String nombreLimpio = nombreOriginal.split('.').first;
      
      // 3. Creamos la ruta del nuevo archivo (Ej: /datos/.../clase_parte1.m4a)
      String rutaSalida = '${directorio.path}/${nombreLimpio}_parte$numeroParte.m4a';

      // 4. ¡AQUÍ METEMOS LA SIERRA! (Usamos la librería nativa)
      await SimpleAudioTrimmer.trim(
        inputPath: rutaOriginal,
        outputPath: rutaSalida,
        start: inicioSegundos.toDouble(),
        end: finSegundos.toDouble(),
      );

      return rutaSalida; // Devolvemos dónde quedó guardado
    } catch (e) {
      print("Error al cortar la parte $numeroParte: $e");
      return null;
    }
  }
}