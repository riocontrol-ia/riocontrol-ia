enum TipoGeometriaProyecto {
  punto,
  linea,
  area,
}

extension TipoGeometriaProyectoExtension on TipoGeometriaProyecto {
  String get etiqueta {
    switch (this) {
      case TipoGeometriaProyecto.punto:
        return 'Punto';
      case TipoGeometriaProyecto.linea:
        return 'Línea';
      case TipoGeometriaProyecto.area:
        return 'Área';
    }
  }

  String get valorFirestore {
    switch (this) {
      case TipoGeometriaProyecto.punto:
        return 'punto';
      case TipoGeometriaProyecto.linea:
        return 'linea';
      case TipoGeometriaProyecto.area:
        return 'area';
    }
  }
}

TipoGeometriaProyecto tipoGeometriaDesdeTexto(String? valor) {
  switch (valor) {
    case 'linea':
      return TipoGeometriaProyecto.linea;

    case 'area':
      return TipoGeometriaProyecto.area;

    case 'punto':
    default:
      return TipoGeometriaProyecto.punto;
  }
}

class CoordenadaModelo {
  final double latitud;
  final double longitud;

  const CoordenadaModelo({
    required this.latitud,
    required this.longitud,
  });

  Map<String, dynamic> aFirestore() {
    return {
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  factory CoordenadaModelo.desdeFirestore(
    Map<String, dynamic> datos,
  ) {
    return CoordenadaModelo(
      latitud: (datos['latitud'] as num?)?.toDouble() ?? 0,
      longitud: (datos['longitud'] as num?)?.toDouble() ?? 0,
    );
  }
}

class UbicacionProyectoModelo {
  final TipoGeometriaProyecto tipoGeometria;
  final String referenciaUbicacion;
  final List<CoordenadaModelo> coordenadas;

  const UbicacionProyectoModelo({
    required this.tipoGeometria,
    required this.referenciaUbicacion,
    required this.coordenadas,
  });

  bool get esPunto => tipoGeometria == TipoGeometriaProyecto.punto;

  bool get esLinea => tipoGeometria == TipoGeometriaProyecto.linea;

  bool get esArea => tipoGeometria == TipoGeometriaProyecto.area;

  CoordenadaModelo get coordenadaCentral {
    final totalLatitud = coordenadas.fold(
      0.0,
      (total, coordenada) => total + coordenada.latitud,
    );

    final totalLongitud = coordenadas.fold(
      0.0,
      (total, coordenada) => total + coordenada.longitud,
    );

    return CoordenadaModelo(
      latitud: totalLatitud / coordenadas.length,
      longitud: totalLongitud / coordenadas.length,
    );
  }

  Map<String, dynamic> aFirestore() {
    return {
      'tipoGeometria': tipoGeometria.valorFirestore,
      'referenciaUbicacion': referenciaUbicacion,
      'coordenadas': coordenadas
          .map((coordenada) => coordenada.aFirestore())
          .toList(),
    };
  }

  factory UbicacionProyectoModelo.desdeFirestore(
    Map<String, dynamic> datos,
  ) {
    final coordenadasRaw = datos['coordenadas'] as List? ?? [];

    return UbicacionProyectoModelo(
      tipoGeometria: tipoGeometriaDesdeTexto(
        datos['tipoGeometria'] as String?,
      ),
      referenciaUbicacion:
          datos['referenciaUbicacion'] as String? ?? '',
      coordenadas: coordenadasRaw
          .whereType<Map>()
          .map(
            (coordenada) => CoordenadaModelo.desdeFirestore(
              Map<String, dynamic>.from(coordenada),
            ),
          )
          .toList(),
    );
  }
}