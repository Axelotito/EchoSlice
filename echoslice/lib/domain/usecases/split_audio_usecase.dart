class SplitAudioUseCase {
  
  List<String> calcularFragmentos(int segundosTotales, int minutosPorCorte) {
    List<String> fragmentos = [];
    
    // Multiplicamos los minutos elegidos por 60 para saber los segundos reales
    int duracionPedazo = minutosPorCorte * 60; 

    for (int i = 0; i < segundosTotales; i += duracionPedazo) {
      int inicio = i;
      int fin = i + duracionPedazo;
      
      if (fin > segundosTotales) {
        fin = segundosTotales;
      }

      String textoInicio = '${inicio ~/ 60}m ${inicio % 60}s';
      String textoFin = '${fin ~/ 60}m ${fin % 60}s';
      
      fragmentos.add('Parte ${fragmentos.length + 1}: $textoInicio ➡️ $textoFin');
    }
    
    return fragmentos;
  }
}