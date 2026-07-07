import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'ubicacion_proyecto_modelo.dart';

class PartidaModelo {
  final String codigo;
  final String denominacion;
  final double monto;

  const PartidaModelo({
    required this.codigo,
    required this.denominacion,
    required this.monto,
  });

  Map<String, dynamic> aFirestore() {
    return {
      'codigo': codigo,
      'denominacion': denominacion,
      'monto': monto,
    };
  }

  factory PartidaModelo.desdeFirestore(
    Map<String, dynamic> datos,
  ) {
    return PartidaModelo(
      codigo: datos['codigo'] as String? ?? '',
      denominacion: datos['denominacion'] as String? ?? '',
      monto: (datos['monto'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PagoModelo {
  final String id;
  final String hito;
  final double monto;
  final DateTime fechaPrevista;
  final bool estaPagado;

  const PagoModelo({
    required this.id,
    required this.hito,
    required this.monto,
    required this.fechaPrevista,
    required this.estaPagado,
  });

  bool get estaVencido {
    final ahora = DateTime.now();

    final hoy = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    );

    final fechaNormalizada = DateTime(
      fechaPrevista.year,
      fechaPrevista.month,
      fechaPrevista.day,
    );

    return !estaPagado && fechaNormalizada.isBefore(hoy);
  }

  int get diasAtraso {
    if (!estaVencido) {
      return 0;
    }

    return DateTime.now().difference(fechaPrevista).inDays;
  }

  Map<String, dynamic> aFirestore() {
    return {
      'id': id,
      'hito': hito,
      'monto': monto,
      'fechaPrevista': Timestamp.fromDate(fechaPrevista),
      'estaPagado': estaPagado,
    };
  }

  factory PagoModelo.desdeFirestore(
    Map<String, dynamic> datos,
  ) {
    return PagoModelo(
      id: datos['id'] as String? ?? '',
      hito: datos['hito'] as String? ?? '',
      monto: (datos['monto'] as num?)?.toDouble() ?? 0,
      fechaPrevista: _fechaDesdeFirestore(
        datos['fechaPrevista'],
      ),
      estaPagado: datos['estaPagado'] == true,
    );
  }
}

class ProyectoModelo {
  final String id;
  final String nombre;
  final String codigoProceso;
  final String direccion;
  final String poaMeta;
  final String pacItem;
  final String etapa;

  final double presupuestoAsignado;
  final double certificado;
  final double comprometido;
  final double devengado;
  final double pagado;

  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime? fechaCertificado;
  final DateTime? fechaComprometido;
  final DateTime? fechaDevengado;
  final DateTime? fechaPagado;

  final String formaPago;
  final List<PartidaModelo> partidas;
  final List<PagoModelo> pagos;

  final UbicacionProyectoModelo? ubicacion;
  final double porcentajeAvanceFisico;
  final DateTime? fechaActualizacionFisica;

  const ProyectoModelo({
    required this.id,
    required this.nombre,
    required this.codigoProceso,
    required this.direccion,
    required this.poaMeta,
    required this.pacItem,
    required this.etapa,
    required this.presupuestoAsignado,
    required this.certificado,
    required this.comprometido,
    required this.devengado,
    required this.pagado,
    required this.fechaInicio,
    required this.fechaFin,
    required this.formaPago,
    required this.partidas,
    required this.pagos,
    this.fechaCertificado,
    this.fechaComprometido,
    this.fechaDevengado,
    this.fechaPagado,
    this.ubicacion,
    this.porcentajeAvanceFisico = 0,
    this.fechaActualizacionFisica,
  });

  bool get tieneUbicacion {
    return ubicacion != null && ubicacion!.coordenadas.isNotEmpty;
  }

  double get porcentajeCertificado {
    return presupuestoAsignado == 0
        ? 0
        : certificado / presupuestoAsignado;
  }

  double get porcentajeComprometido {
    return presupuestoAsignado == 0
        ? 0
        : comprometido / presupuestoAsignado;
  }

  double get porcentajeEjecucion {
    return presupuestoAsignado == 0
        ? 0
        : devengado / presupuestoAsignado;
  }

  double get porcentajePagado {
    return devengado == 0 ? 0 : pagado / devengado;
  }

  double get avanceFisicoNormalizado {
    return porcentajeAvanceFisico.clamp(0.0, 1.0).toDouble();
  }

  double get saldoPorComprometer {
    return presupuestoAsignado - comprometido;
  }

  double get saldoPorPagar {
    return devengado - pagado;
  }

  List<PagoModelo> get pagosVencidos {
    return pagos.where((pago) => pago.estaVencido).toList();
  }

  int get mayorDiasAtraso {
    if (pagosVencidos.isEmpty) {
      return 0;
    }

    return pagosVencidos
        .map((pago) => pago.diasAtraso)
        .reduce(max);
  }

  int get puntajeRiesgo {
    var puntaje = 0;

    if (pagosVencidos.isNotEmpty) {
      puntaje += 45;
    }

    if (mayorDiasAtraso > 30) {
      puntaje += 25;
    }

    if (etapa == 'Ejecución' && porcentajeEjecucion < 0.35) {
      puntaje += 15;
    }

    if (saldoPorPagar > presupuestoAsignado * 0.25) {
      puntaje += 5;
    }

    return min(puntaje, 100);
  }

  String get nivelRiesgo {
    if (puntajeRiesgo >= 60) {
      return 'Alto';
    }

    if (puntajeRiesgo >= 30) {
      return 'Medio';
    }

    return 'Bajo';
  }

  ProyectoModelo copiarCon({
    String? nombre,
    String? codigoProceso,
    String? direccion,
    String? poaMeta,
    String? pacItem,
    String? etapa,
    double? presupuestoAsignado,
    double? certificado,
    double? comprometido,
    double? devengado,
    double? pagado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    DateTime? fechaCertificado,
    DateTime? fechaComprometido,
    DateTime? fechaDevengado,
    DateTime? fechaPagado,
    String? formaPago,
    List<PartidaModelo>? partidas,
    List<PagoModelo>? pagos,
    UbicacionProyectoModelo? ubicacion,
    double? porcentajeAvanceFisico,
    DateTime? fechaActualizacionFisica,
  }) {
    return ProyectoModelo(
      id: id,
      nombre: nombre ?? this.nombre,
      codigoProceso: codigoProceso ?? this.codigoProceso,
      direccion: direccion ?? this.direccion,
      poaMeta: poaMeta ?? this.poaMeta,
      pacItem: pacItem ?? this.pacItem,
      etapa: etapa ?? this.etapa,
      presupuestoAsignado:
          presupuestoAsignado ?? this.presupuestoAsignado,
      certificado: certificado ?? this.certificado,
      comprometido: comprometido ?? this.comprometido,
      devengado: devengado ?? this.devengado,
      pagado: pagado ?? this.pagado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaCertificado: fechaCertificado ?? this.fechaCertificado,
      fechaComprometido: fechaComprometido ?? this.fechaComprometido,
      fechaDevengado: fechaDevengado ?? this.fechaDevengado,
      fechaPagado: fechaPagado ?? this.fechaPagado,
      formaPago: formaPago ?? this.formaPago,
      partidas: partidas ?? this.partidas,
      pagos: pagos ?? this.pagos,
      ubicacion: ubicacion ?? this.ubicacion,
      porcentajeAvanceFisico:
          porcentajeAvanceFisico ?? this.porcentajeAvanceFisico,
      fechaActualizacionFisica:
          fechaActualizacionFisica ?? this.fechaActualizacionFisica,
    );
  }

  Map<String, dynamic> aFirestore() {
    return {
      'nombre': nombre,
      'codigoProceso': codigoProceso,
      'direccion': direccion,
      'poaMeta': poaMeta,
      'pacItem': pacItem,
      'etapa': etapa,
      'presupuestoAsignado': presupuestoAsignado,
      'certificado': certificado,
      'comprometido': comprometido,
      'devengado': devengado,
      'pagado': pagado,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'fechaCertificado': fechaCertificado == null
          ? null
          : Timestamp.fromDate(fechaCertificado!),
      'fechaComprometido': fechaComprometido == null
          ? null
          : Timestamp.fromDate(fechaComprometido!),
      'fechaDevengado': fechaDevengado == null
          ? null
          : Timestamp.fromDate(fechaDevengado!),
      'fechaPagado': fechaPagado == null
          ? null
          : Timestamp.fromDate(fechaPagado!),
      'formaPago': formaPago,
      'partidas': partidas
          .map((partida) => partida.aFirestore())
          .toList(),
      'pagos': pagos.map((pago) => pago.aFirestore()).toList(),
      'ubicacion': ubicacion?.aFirestore(),
      'porcentajeAvanceFisico': porcentajeAvanceFisico,
      'fechaActualizacionFisica':
          fechaActualizacionFisica == null
              ? null
              : Timestamp.fromDate(fechaActualizacionFisica!),
    };
  }

  factory ProyectoModelo.desdeFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data() ?? {};

    final partidasRaw = datos['partidas'] as List? ?? [];
    final pagosRaw = datos['pagos'] as List? ?? [];

    final ubicacionRaw = datos['ubicacion'];

    return ProyectoModelo(
      id: documento.id,
      nombre: datos['nombre'] as String? ?? '',
      codigoProceso: datos['codigoProceso'] as String? ?? '',
      direccion: datos['direccion'] as String? ?? '',
      poaMeta: datos['poaMeta'] as String? ?? '',
      pacItem: datos['pacItem'] as String? ?? '',
      etapa: datos['etapa'] as String? ?? 'Preparatoria',
      presupuestoAsignado:
          (datos['presupuestoAsignado'] as num?)?.toDouble() ?? 0,
      certificado: (datos['certificado'] as num?)?.toDouble() ?? 0,
      comprometido:
          (datos['comprometido'] as num?)?.toDouble() ?? 0,
      devengado: (datos['devengado'] as num?)?.toDouble() ?? 0,
      pagado: (datos['pagado'] as num?)?.toDouble() ?? 0,
      fechaInicio: _fechaDesdeFirestore(datos['fechaInicio']),
      fechaFin: _fechaDesdeFirestore(datos['fechaFin']),
      fechaCertificado:
          _fechaOpcionalDesdeFirestore(datos['fechaCertificado']),
      fechaComprometido:
          _fechaOpcionalDesdeFirestore(datos['fechaComprometido']),
      fechaDevengado:
          _fechaOpcionalDesdeFirestore(datos['fechaDevengado']),
      fechaPagado:
          _fechaOpcionalDesdeFirestore(datos['fechaPagado']),
      formaPago: datos['formaPago'] as String? ?? '',
      partidas: partidasRaw
          .whereType<Map>()
          .map(
            (partida) => PartidaModelo.desdeFirestore(
              Map<String, dynamic>.from(partida),
            ),
          )
          .toList(),
      pagos: pagosRaw
          .whereType<Map>()
          .map(
            (pago) => PagoModelo.desdeFirestore(
              Map<String, dynamic>.from(pago),
            ),
          )
          .toList(),
      ubicacion: ubicacionRaw is Map
          ? UbicacionProyectoModelo.desdeFirestore(
              Map<String, dynamic>.from(ubicacionRaw),
            )
          : null,
      porcentajeAvanceFisico:
          (datos['porcentajeAvanceFisico'] as num?)?.toDouble() ?? 0,
      fechaActualizacionFisica:
          _fechaOpcionalDesdeFirestore(
        datos['fechaActualizacionFisica'],
      ),
    );
  }
}

DateTime _fechaDesdeFirestore(dynamic valor) {
  if (valor is Timestamp) {
    return valor.toDate();
  }

  if (valor is DateTime) {
    return valor;
  }

  if (valor is String) {
    return DateTime.tryParse(valor) ?? DateTime.now();
  }

  return DateTime.now();
}

DateTime? _fechaOpcionalDesdeFirestore(dynamic valor) {
  if (valor == null) {
    return null;
  }

  if (valor is Timestamp) {
    return valor.toDate();
  }

  if (valor is DateTime) {
    return valor;
  }

  if (valor is String) {
    return DateTime.tryParse(valor);
  }

  return null;
}