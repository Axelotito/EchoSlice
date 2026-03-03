import '../entities/audio_class.dart';

// es abstracto para un molde
abstract class AudioRepository {
  //Habra una clase Future
  //nos dara  un AudioClass 
  Future<AudioClass?> pickAudioFile();
}