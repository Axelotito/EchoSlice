class SplitAudioUsecase {
  static const int segmentDuration = 15; 

  //Con esta funcion checare cuantos fragmentos se necesitan 
  List <Map<String, Duration>> calculateSegments (Duration totalDuration) 
  {
    List<Map<String, Duration>> segment  = [];
    int startMinutes = 0;

    while(startMinutes < totalDuration.inMinutes)
    {
      int endMinutes = startMinutes + segmentDuration;

      if (endMinutes > totalDuration.inMinutes) 
      {
        endMinutes = totalDuration.inMinutes;
      }

      segment.add({
        'start': Duration(minutes: startMinutes),
        'end': Duration(minutes: endMinutes)
      });

      startMinutes = endMinutes;
    }
    return segment;
  } 
}