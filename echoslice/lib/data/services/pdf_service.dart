import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  Future<String> generarPdf({
    required String tituloClase,
    required List<String> apuntesPorParte,
    String? rutaCarpeta, // Ahora es opcional
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 100,
        build: (pw.Context context) {
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

          for (int i = 0; i < apuntesPorParte.length; i++) {
            elementos.add(
              pw.Text(
                'Parte ${i + 1}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
            );
            elementos.add(pw.SizedBox(height: 10));

            final parrafos = apuntesPorParte[i].split('\n');
            for (var parrafo in parrafos) {
              if (parrafo.trim().isNotEmpty) {
                elementos.add(
                  pw.Paragraph(
                    text: parrafo,
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                  ),
                );
              }
            }
            elementos.add(pw.SizedBox(height: 30));
          }

          return elementos;
        },
      ),
    );

    // --- LA NUEVA RUTA SEGURA PARA ANDROID 11+ ---
    final directorioPrincipal = await getExternalStorageDirectory();
    final directorioNotas = Directory('${directorioPrincipal!.path}/EchoSlice/Apuntes');

    if (!await directorioNotas.exists()) {
      await directorioNotas.create(recursive: true);
    }

    final nombreLimpio = tituloClase.replaceAll(RegExp(r'[^\w\s]+'), '');
    String rutaBase = '${directorioNotas.path}/Apuntes_$nombreLimpio';
    String rutaFinal = '$rutaBase.pdf';
    
    int contador = 1;
    while (await File(rutaFinal).exists()) {
      rutaFinal = '${rutaBase}_$contador.pdf';
      contador++;
    }

    final file = File(rutaFinal);
    await file.writeAsBytes(await pdf.save());

    return rutaFinal;
  }
}