import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';

class AlertaPago {
  final ProyectoModelo proyecto;
  final PagoModelo pago;

  const AlertaPago({
    required this.proyecto,
    required this.pago,
  });

  int get diasAtraso => pago.diasAtraso;
}

class ResumenEjecucion {
  final int totalProyectos;
  final double presupuestoAsignado;
  final double certificado;
  final double comprometido;
  final double devengado;
  final double pagado;
  final int cantidadPagosVencidos;
  final double montoPagosVencidos;
  final int proyectosRiesgoAlto;

  const ResumenEjecucion({
    required this.totalProyectos,
    required this.presupuestoAsignado,
    required this.certificado,
    required this.comprometido,
    required this.devengado,
    required this.pagado,
    required this.cantidadPagosVencidos,
    required this.montoPagosVencidos,
    required this.proyectosRiesgoAlto,
  });

  double get porcentajeEjecucion {
    return presupuestoAsignado == 0
        ? 0
        : devengado / presupuestoAsignado;
  }

  double get porcentajePagado {
    return devengado == 0 ? 0 : pagado / devengado;
  }
}

class CalculadorIndicadores {
  static ResumenEjecucion calcularResumen(
    List<ProyectoModelo> proyectos,
  ) {
    final alertas = obtenerAlertas(proyectos);

    return ResumenEjecucion(
      totalProyectos: proyectos.length,
      presupuestoAsignado: proyectos.fold(
        0.0,
        (total, proyecto) => total + proyecto.presupuestoAsignado,
      ),
      certificado: proyectos.fold(
        0.0,
        (total, proyecto) => total + proyecto.certificado,
      ),
      comprometido: proyectos.fold(
        0.0,
        (total, proyecto) => total + proyecto.comprometido,
      ),
      devengado: proyectos.fold(
        0.0,
        (total, proyecto) => total + proyecto.devengado,
      ),
      pagado: proyectos.fold(
        0.0,
        (total, proyecto) => total + proyecto.pagado,
      ),
      cantidadPagosVencidos: alertas.length,
      montoPagosVencidos: alertas.fold(
        0.0,
        (total, alerta) => total + alerta.pago.monto,
      ),
      proyectosRiesgoAlto: proyectos
          .where((proyecto) => proyecto.nivelRiesgo == 'Alto')
          .length,
    );
  }

  static List<AlertaPago> obtenerAlertas(
    List<ProyectoModelo> proyectos,
  ) {
    final alertas = <AlertaPago>[];

    for (final proyecto in proyectos) {
      for (final pago in proyecto.pagosVencidos) {
        alertas.add(
          AlertaPago(
            proyecto: proyecto,
            pago: pago,
          ),
        );
      }
    }

    alertas.sort(
      (primera, segunda) =>
          segunda.diasAtraso.compareTo(primera.diasAtraso),
    );

    return alertas;
  }

  static Map<String, double> ejecucionPorDireccion(
    List<ProyectoModelo> proyectos,
  ) {
    final resultado = <String, double>{};
    final direcciones = proyectos.map((proyecto) => proyecto.direccion).toSet();

    for (final direccion in direcciones) {
      final proyectosDireccion = proyectos
          .where((proyecto) => proyecto.direccion == direccion)
          .toList();

      resultado[direccion] =
          calcularResumen(proyectosDireccion).porcentajeEjecucion;
    }

    return resultado;
  }

  static Map<String, int> proyectosPorEtapa(
    List<ProyectoModelo> proyectos,
  ) {
    final resultado = <String, int>{};

    for (final proyecto in proyectos) {
      resultado.update(
        proyecto.etapa,
        (valorActual) => valorActual + 1,
        ifAbsent: () => 1,
      );
    }

    return resultado;
  }
}