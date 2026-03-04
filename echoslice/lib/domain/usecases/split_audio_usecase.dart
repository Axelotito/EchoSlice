class SplitAudioUseCase {
  List<String> calcularFragmentos(int segundosTotales) {
    List<String> fragmentos = [];
    int duracionPedazo = 15 * 60; // 15 minutos en segundos (900)

    for (int i = 0; i < segundosTotales; i += duracionPedazo) {
      int inicio = i;
      int fin = i + duracionPedazo;
      
      // Si el último pedazo es más corto de 15 minutos, lo ajustamos al final real
      if (fin > segundosTotales) {
        fin = segundosTotales;
      }

      // Convertimos los segundos a texto bonito
      String textoInicio = '${inicio ~/ 60}m ${inicio % 60}s';
      String textoFin = '${fin ~/ 60}m ${fin % 60}s';
      
      fragmentos.add('Parte ${fragmentos.length + 1}: $textoInicio ➡️ $textoFin');
    }
    
    return fragmentos;
  }
}