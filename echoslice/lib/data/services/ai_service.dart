import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NUEVO

class AiService {
  
  Future<String> generarApuntesDeAudio(File archivoAudio) async {
    try {
      // 1. OBTENER LA LLAVE DESDE LA MEMORIA DEL TELÉFONO
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key') ?? '';

      // Si el usuario no ha puesto su llave, detenemos todo amablemente
      if (apiKey.isEmpty) {
        return '⚠️ Error: No has configurado tu API Key de Gemini. Ve a los ajustes de la app para agregarla.';
      }

      // 2. INICIALIZAMOS EL MODELO CON LA LLAVE DEL USUARIO
      final GenerativeModel model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final bytes = await archivoAudio.readAsBytes();
      final audioPart = DataPart('audio/mp3', bytes);

      // 3. TU SÚPER PROMPT MAESTRO
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

      final response = await model.generateContent([
        Content.multi([prompt, audioPart])
      ]);

      return response.text ?? 'La IA no pudo generar el apunte.';
      
    } catch (e) {
      return 'Error al procesar con IA: $e';
    }
  }
}