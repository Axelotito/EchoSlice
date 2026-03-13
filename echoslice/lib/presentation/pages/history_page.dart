import 'dart:io';
import 'package:echoslice/presentation/pages/folder_details_page.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Directory>> _carpetasAudios;

  @override
  void initState() {
    super.initState();
    _carpetasAudios = _cargarHistorialAudios();
  }

  Future<List<Directory>> _cargarHistorialAudios() async {
    // LA NUEVA RUTA SEGURA:
    final directorioBase = Directory('/storage/emulated/0/Download/EchoSlice/Audios');

    if (await directorioBase.exists()) {
      final entidades = directorioBase.listSync();
      final carpetas = entidades.whereType<Directory>().toList();
      carpetas.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return carpetas;
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
        title: Text('Audios Cortados', style: TextStyle(color: goldAccent, fontFamily: 'serif', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Directory>>(
        future: _carpetasAudios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: goldAccent));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay audios aún 🎧', style: TextStyle(color: Colors.grey)));

          final carpetas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: carpetas.length,
            itemBuilder: (context, index) {
              final carpeta = carpetas[index];
              final String nombreCarpeta = carpeta.path.split('/').last;
              final DateTime fecha = carpeta.statSync().modified;
              
              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(Icons.folder_zip, color: goldAccent, size: 36),
                  title: Text(nombreCarpeta, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Cortado el: ${fecha.day}/${fecha.month}/${fecha.year}', style: const TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.arrow_forward_ios, color: goldAccent, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FolderDetailsPage(carpeta: carpeta))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}