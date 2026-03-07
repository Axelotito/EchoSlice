import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../api_config.dart';

class AiService {
  // MEJOR PRÁCTICA: Usamos final y variables privadas. 
  // Instanciamos el modelo gemini-1.5-flash porque es rapidísimo y puede "escuchar" audios.
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash', // <--- ¡AQUÍ ESTÁ LA MAGIA!
    apiKey: ApiConfig.geminiKey,
  );

  /// Toma un archivo de audio cortado y le pide a Gemini que haga los apuntes.
  Future<String> generarApuntesDeAudio(File archivoAudio) async {
    try {
      // 1. Leemos el archivo de audio nativo de tu celular
      final bytes = await archivoAudio.readAsBytes();

      // 2. Empaquetamos el audio en un formato que la IA entienda
      // Nota: Le ponemos 'audio/mp3' genérico, Gemini es lo bastante listo para entender m4a/wav/mp3
      final audioPart = DataPart('audio/mp3', bytes);

      // 3. EL PROMPT MAESTRO (Hackeado: Sin Markdown y SIN Emojis)
      final prompt = TextPart(
        'Eres un estudiante universitario de excelencia. '
        'Escucha este fragmento de audio y crea apuntes estructurados. '
        'REGLAS ESTRICTAS: '
        '1. Escribe TODO en TEXTO PLANO. PROHIBIDO usar formato Markdown (*, #, _, etc.). '
        '2. ESTÁ ESTRICTAMENTE PROHIBIDO USAR EMOJIS. No incluyas ninguna carita, símbolo gráfico ni emojis, solo letras y números estándar. '
        'Para los títulos usa MAYÚSCULAS. Para las listas usa guiones normales (-). '
        'Mantén un formato limpio y espaciado.'
      );

      // 4. Mandamos el paquete (Texto + Audio) a la nube de Google
      final response = await _model.generateContent([
        Content.multi([prompt, audioPart])
      ]);

      // 5. Devolvemos el texto generado, o un mensaje de error si la IA se quedó muda
      return response.text ?? 'La IA no pudo generar el apunte. Tal vez el audio era puro silencio.';
      
    } catch (e) {
      return 'Error al procesar con IA: $e';
    }
  }
}