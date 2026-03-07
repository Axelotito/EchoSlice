import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<String> generarPdf({
    required String tituloClase,
    required List<String> apuntesPorParte,
    required String rutaCarpeta,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 100, // <--- ¡EL TRUCO MÁGICO! Le damos permiso de hacer hasta 100 hojas
        build: (pw.Context context) {
          
          // 1. Armamos la lista de elementos (Portada)
          List<pw.Widget> elementos = [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Apuntes con IA: $tituloClase',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generado automáticamente por EchoSlice',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
          ];

          // 2. Agregamos los apuntes (Ahora cortados en párrafos pequeños)
          for (int i = 0; i < apuntesPorParte.length; i++) {
            elementos.add(
              pw.Text(
                'Parte ${i + 1}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
            );
            elementos.add(pw.SizedBox(height: 10));

            // --- ¡NUEVA MAGIA ANTI-DESBORDAMIENTO! ---
            // Cortamos el texto gigante de la IA cada vez que hay un salto de línea (\n)
            final parrafos = apuntesPorParte[i].split('\n');
            
            for (var parrafo in parrafos) {
              if (parrafo.trim().isNotEmpty) {
                elementos.add(
                  pw.Paragraph( // Usamos Paragraph en lugar de Text para que lo maneje mejor
                    text: parrafo,
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                  ),
                );
              }
            }
            // ------------------------------------------
            
            elementos.add(pw.SizedBox(height: 30));
          }

          return elementos;
        },
      ),
    );
    // --- 1. CREAMOS LA CARPETA EXCLUSIVA PARA LOS PDFs ---
    final directorioNotas = Directory('/storage/emulated/0/Download/EchoSlice/Apuntes');
    
    if (!await directorioNotas.exists()) {
      await directorioNotas.create(recursive: true);
    }

    // --- 2. LIMPIAMOS EL NOMBRE ---
    final nombreLimpio = tituloClase.replaceAll(RegExp(r'[^\w\s]+'), '');
    String rutaBase = '${directorioNotas.path}/Apuntes_$nombreLimpio';
    String rutaFinal = '$rutaBase.pdf';
    
    // --- 3. LÓGICA ANTI-SOBREESCRITURA (Tu idea del _1, _2) ---
    int contador = 1;
    while (await File(rutaFinal).exists()) {
      rutaFinal = '${rutaBase}_$contador.pdf';
      contador++;
    }

    // --- 4. GUARDAMOS EL ARCHIVO ---
    final file = File(rutaFinal);
    await file.writeAsBytes(await pdf.save());

    return rutaFinal;
  }
}