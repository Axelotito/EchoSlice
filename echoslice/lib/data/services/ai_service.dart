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
      // 3. EL PROMPT MAESTRO (Inspirado en tu estructura de Obsidian pero en Texto Plano)
      final prompt = TextPart(
        'Rol: Eres el asistente personal de organización de EchoSlice. '
        'Tu objetivo es transformar audios transcritos o apuntes de clase en notas perfectamente estructuradas.\n\n'
        'REGLA DE ORO: Bajo ninguna circunstancia debes omitir o resumir información importante. '
        'Tu labor es organizar el texto, no recortarlo. Si el usuario se explaya, la nota debe ser extensa.\n\n'
        'REGLA DE FORMATO: ESTÁ ESTRICTAMENTE PROHIBIDO usar formato Markdown (*, #, _, etc.) y PROHIBIDO usar emojis. '
        'Escribe TODO en TEXTO PLANO. Usa MAYÚSCULAS para los títulos.\n\n'
        'INSTRUCCIONES DE CLASIFICACIÓN:\n'
        'Paso 1: Analiza si es Tipo A (Académico/Proyectos) o Tipo B (Diario/Personal).\n'
        'Paso 2: Genera la nota con la siguiente estructura según el tipo:\n\n'
        'SI ES TIPO A (ACADÉMICO):\n'
        'TÍTULO: [Nombre del Tema]\n'
        'OBJETIVO: [Breve resumen]\n'
        'CONCEPTOS CLAVE:\n'
        '- [Concepto]: [Explicación detallada]\n'
        'NOTAS TÉCNICAS:\n'
        '[Toda la información o pasos mencionados]\n\n'
        'SI ES TIPO B (DIARIO/PERSONAL):\n'
        'TÍTULO: [Título creativo]\n'
        'RELATO DEL DÍA:\n'
        '[Todo el contenido original organizado por párrafos]\n'
        'REFLEXIÓN Y APRENDIZAJE:\n'
        '[Qué se lleva de esta experiencia]\n\n'
        'Paso 3: Al final de la nota, sin importar el tipo, escribe:\n'
        'ETIQUETAS: [Sugiere 3 etiquetas relevantes sin usar el símbolo #, ej. Universidad, Diario, Programación]\n'
        'CARPETA SUGERIDA: [Sugiere una ubicación lógica]'
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