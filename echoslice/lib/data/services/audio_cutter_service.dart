import 'package:simple_audio_trimmer/simple_audio_trimmer.dart';

class AudioCutterService {
  
  // ¡Ahora le pedimos que reciba la 'carpetaDestino'!
  Future<String?> cortarPedazo(String rutaOriginal, int inicioSegundos, int finSegundos, String nombreOriginal, int numeroParte, String carpetaDestino) async {
    try {
      String nombreLimpio = nombreOriginal.split('.').first;
      
      // Armamos la ruta con la carpeta que el usuario eligió
      String rutaSalida = '$carpetaDestino/${nombreLimpio}_parte$numeroParte.m4a';

      await SimpleAudioTrimmer.trim(
        inputPath: rutaOriginal,
        outputPath: rutaSalida,
        start: inicioSegundos.toDouble(),
        end: finSegundos.toDouble(),
      );

      return rutaSalida; 
    } catch (e) {
      print("Error al cortar la parte $numeroParte: $e");
      return null;
    }
  }
}