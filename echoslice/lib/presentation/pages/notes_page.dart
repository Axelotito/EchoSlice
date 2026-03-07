import 'dart:io';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<File>> _archivosPdfs;

  @override
  void initState() {
    super.initState();
    _archivosPdfs = _cargarHistorialPdfs();
  }

  Future<List<File>> _cargarHistorialPdfs() async {
    final directorioNotas = Directory('/storage/emulated/0/Download/EchoSlice/Apuntes');
    if (await directorioNotas.exists()) {
      final entidades = directorioNotas.listSync();
      final pdfs = entidades.whereType<File>().where((file) => file.path.endsWith('.pdf')).toList();
      pdfs.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return pdfs;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final Color goldAccent = Theme.of(context).primaryColor;
    final Color bgDark = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text('Apuntes Inteligentes', style: TextStyle(color: goldAccent, fontFamily: 'serif', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<File>>(
        future: _archivosPdfs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: goldAccent));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Aún no has generado apuntes 📄', style: TextStyle(color: Colors.grey)));

          final pdfs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final archivoPdf = pdfs[index];
              final String nombreArchivo = archivoPdf.path.split('/').last;
              final DateTime fecha = archivoPdf.statSync().modified;

              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 36),
                  title: Text(nombreArchivo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Generado el: ${fecha.day}/${fecha.month}/${fecha.year}', style: const TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.open_in_new, color: goldAccent, size: 20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ruta: ${archivoPdf.path}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}