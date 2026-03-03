import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/audio_class.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository 
{
  @override
  Future<AudioClass?> pickAudioFile() async
  {
    // 1. abrimos el explorador de archivos del celular
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // Esto hara que no puedas Escoger otra cosa que no sea un archivo de audio
    );

    //2. Si el usuario no es stupid uwu y no cancelo el proceso
    if (result != null  && result.files.single.path != null) {

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

    }
  }

}