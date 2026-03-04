import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart'; // <--- NUEVA HERRAMIENTA IMPORTADA
import '../../domain/entities/audio_class.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  @override
  Future<AudioClass?> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, 
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      
      // --- LA MAGIA DEL CRONÓMETRO EMPIEZA AQUÍ ---
      final player = AudioPlayer(); // Creamos un lector invisible
      Duration? duration = Duration.zero;
      
      try {
        // Le pedimos que lea el archivo y nos diga cuánto dura
        duration = await player.setFilePath(path);
      } catch (e) {
        print("Error al leer el tiempo del audio: $e");
      }
      
      await player.dispose(); // Destruimos el lector para no gastar memoria RAM
      
      // Convertimos el tiempo a segundos totales (si falla, ponemos 0)
      final int segundosReales = duration?.inSeconds ?? 0;
      // ---------------------------------------------

      return AudioClass(
        path: path, 
        name: name, 
        durationInSeconds: segundosReales // ¡Adiós al cero, ahora es real!
      ); 
    }
    
    return null;
  }
}