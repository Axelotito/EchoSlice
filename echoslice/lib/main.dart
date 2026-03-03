import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';

void main (){
  runApp(const EchoSliceApp());
}

class EchoSliceApp extends StatelessWidget{
  const EchoSliceApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'EchoSlice',
      debugShowCheckedModeBanner: false, // no mostrara la linea de modo debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness : Brightness.dark, //Modo oscuro god
        ),
        useMaterial3: true,
      ),
      home: const HomePage(), // se llama la pantalla principal.
    );
  }
}