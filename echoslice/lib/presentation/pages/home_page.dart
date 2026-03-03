import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoSlice'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: (){
            // aca va la logica que ya hice
            print("Boton Presionado: Abriendo galería...");
          },
          icon: const Icon(Icons.folder_open, size: 28),
          label: const Text(
            'Seleccionar Audio',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            )
          ),
        ),
      )
    );
  }
}