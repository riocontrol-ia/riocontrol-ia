class PartidaBorradorIaModelo {
  final String? codigo;
  final String? denominacion;
  final double? monto;

  const PartidaBorradorIaModelo({
    this.codigo,
    this.denominacion,
    this.monto,
  });

  factory PartidaBorradorIaModelo.desdeJson(
    Map<String, dynamic> datos,
  ) {
    return PartidaBorradorIaModelo(
      codigo: BorradorProyectoIaModelo.texto(datos['codigo']),
      denominacion:
          BorradorProyectoIaModelo.texto(datos['denominacion']),
      monto: BorradorProyectoIaModelo.numero(datos['monto']),
    );
  }
}

class PagoBorradorIaModelo {
  final String? hito;
  final double? monto;
  final String? fechaPrevista;
  final bool? estaPagado;

  const PagoBorradorIaModelo({
    this.hito,
    this.monto,
    this.fechaPrevista,
    this.estaPagado,
  });

  factory PagoBorradorIaModelo.desdeJson(
    Map<String, dynamic> datos,
  ) {
    return PagoBorradorIaModelo(
      hito: BorradorProyectoIaModelo.texto(datos['hito']),
      monto: BorradorProyectoIaModelo.numero(datos['monto']),
      fechaPrevista:
          BorradorProyectoIaModelo.texto(datos['fechaPrevista']),
      estaPagado:
          BorradorProyectoIaModelo.booleano(datos['estaPagado']),
    );
  }
}

class BorradorProyectoIaModelo {
  final String? nombre;
  final String? codigoProceso;
  final String? poaMeta;
  final String? pacItem;
  final String? etapa;

  final double? presupuestoAsignado;
  final double? certificado;
  final double? comprometido;
  final double? devengado;
  final double? pagado;

  final String? fechaInicio;
  final String? fechaFin;
  final String? formaPago;

  final double? avanceFisico;
  final String? referenciaUbicacion;
  final String? tipoGeometria;
  final double? latitud;
  final double? longitud;

  final List<PartidaBorradorIaModelo> partidas;
  final List<PagoBorradorIaModelo> pagos;

  const BorradorProyectoIaModelo({
    this.nombre,
    this.codigoProceso,
    this.poaMeta,
    this.pacItem,
    this.etapa,
    this.presupuestoAsignado,
    this.certificado,
    this.comprometido,
    this.devengado,
    this.pagado,
    this.fechaInicio,
    this.fechaFin,
    this.formaPago,
    this.avanceFisico,
    this.referenciaUbicacion,
    this.tipoGeometria,
    this.latitud,
    this.longitud,
    this.partidas = const [],
    this.pagos = const [],
  });

  factory BorradorProyectoIaModelo.desdeJson(
    Map<String, dynamic> datos,
  ) {
    return BorradorProyectoIaModelo(
      nombre: texto(datos['nombre']),
      codigoProceso: texto(datos['codigoProceso']),
      poaMeta: texto(datos['poaMeta']),
      pacItem: texto(datos['pacItem']),
      etapa: texto(datos['etapa']),
      presupuestoAsignado: numero(datos['presupuestoAsignado']),
      certificado: numero(datos['certificado']),
      comprometido: numero(datos['comprometido']),
      devengado: numero(datos['devengado']),
      pagado: numero(datos['pagado']),
      fechaInicio: texto(datos['fechaInicio']),
      fechaFin: texto(datos['fechaFin']),
      formaPago: texto(datos['formaPago']),
      avanceFisico: numero(datos['avanceFisico']),
      referenciaUbicacion: texto(datos['referenciaUbicacion']),
      tipoGeometria: texto(datos['tipoGeometria']),
      latitud: numero(datos['latitud']),
      longitud: numero(datos['longitud']),
      partidas: _leerPartidas(datos['partidas']),
      pagos: _leerPagos(datos['pagos']),
    );
  }

  BorradorProyectoIaModelo conListas({
    required List<PartidaBorradorIaModelo> partidas,
    required List<PagoBorradorIaModelo> pagos,
  }) {
    return BorradorProyectoIaModelo(
      nombre: nombre,
      codigoProceso: codigoProceso,
      poaMeta: poaMeta,
      pacItem: pacItem,
      etapa: etapa,
      presupuestoAsignado: presupuestoAsignado,
      certificado: certificado,
      comprometido: comprometido,
      devengado: devengado,
      pagado: pagado,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      formaPago: formaPago,
      avanceFisico: avanceFisico,
      referenciaUbicacion: referenciaUbicacion,
      tipoGeometria: tipoGeometria,
      latitud: latitud,
      longitud: longitud,
      partidas: partidas,
      pagos: pagos,
    );
  }

  static List<PartidaBorradorIaModelo> _leerPartidas(dynamic valor) {
    if (valor is! List) {
      return const [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => PartidaBorradorIaModelo.desdeJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static List<PagoBorradorIaModelo> _leerPagos(dynamic valor) {
    if (valor is! List) {
      return const [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => PagoBorradorIaModelo.desdeJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static String? texto(dynamic valor) {
    if (valor == null) {
      return null;
    }

    final resultado = valor.toString().trim();

    if (resultado.isEmpty || resultado.toLowerCase() == 'null') {
      return null;
    }

    return resultado;
  }

  static double? numero(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is num) {
      return valor.toDouble();
    }

    var textoNumero = valor.toString().trim();

    if (textoNumero.isEmpty) {
      return null;
    }

    textoNumero = textoNumero.replaceAll(
      RegExp(r'[^0-9,.\-]'),
      '',
    );

    if (textoNumero.contains('.') && textoNumero.contains(',')) {
      textoNumero = textoNumero.replaceAll('.', '').replaceAll(',', '.');
    } else {
      textoNumero = textoNumero.replaceAll(',', '.');
    }

    return double.tryParse(textoNumero);
  }

  static bool? booleano(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is bool) {
      return valor;
    }

    final textoBooleano = valor.toString().trim().toLowerCase();

    if (textoBooleano == 'true' ||
        textoBooleano == 'si' ||
        textoBooleano == 'sí' ||
        textoBooleano == 'pagado' ||
        textoBooleano == 'realizado') {
      return true;
    }

    if (textoBooleano == 'false' ||
        textoBooleano == 'no' ||
        textoBooleano == 'pendiente') {
      return false;
    }

    return null;
  }
}