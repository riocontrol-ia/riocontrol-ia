import 'package:flutter/material.dart';

import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/controladores/controlador_sesion.dart';
import '../../../core/tema/tema_rio_control.dart';
import '../../../core/utilidades/calculador_indicadores.dart';
import '../../../core/utilidades/formateadores.dart';
import '../../../core/widgets/componentes_rio_control.dart';

class PantallaPanelControl extends StatelessWidget {
  final ControladorProyectos controlador;
  final ControladorSesion controladorSesion;
  final VoidCallback alAbrirReporte;

  const PantallaPanelControl({
    super.key,
    required this.controlador,
    required this.controladorSesion,
    required this.alAbrirReporte,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (context, _) {
        final proyectos = controlador.proyectos;
        final resumen = CalculadorIndicadores.calcularResumen(proyectos);
        final alertas = CalculadorIndicadores.obtenerAlertas(proyectos);
        final ejecucion =
            CalculadorIndicadores.ejecucionPorDireccion(proyectos);
        final etapas =
            CalculadorIndicadores.proyectosPorEtapa(proyectos);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(context),
                  const SizedBox(height: 25),
                  _indicadores(context, resumen),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, restricciones) {
                      if (restricciones.maxWidth < 950) {
                        return Column(
                          children: [
                            _panelEjecucion(ejecucion),
                            const SizedBox(height: 18),
                            _panelEtapas(etapas),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _panelEjecucion(ejecucion),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 2,
                            child: _panelEtapas(etapas),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _panelAlertas(alertas),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _encabezado(BuildContext context) {
    final texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controladorSesion.esDirectorGestion
              ? 'Panorama de ejecución de su Dirección'
              : 'Panorama de ejecución municipal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 7),
        Text(
          controladorSesion.esDirectorGestion
              ? 'Indicadores, alertas y seguimiento de los proyectos asignados.'
              : 'Indicadores, alertas y análisis preventivo de POA, PAC y pagos.',
          style: const TextStyle(
            color: ColoresRio.textoSecundario,
          ),
        ),
      ],
    );

    final accion = controladorSesion.puedeGenerarReporteEjecutivo
        ? FilledButton.icon(
            onPressed: alAbrirReporte,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generar informe MuniIA'),
          )
        : Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: ColoresRio.azulCielo.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: ColoresRio.azulMedio,
                ),
                SizedBox(width: 8),
                Text(
                  'Vista operativa',
                  style: TextStyle(
                    color: ColoresRio.azulProfundo,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              texto,
              const SizedBox(height: 16),
              accion,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: texto),
            accion,
          ],
        );
      },
    );
  }

  Widget _indicadores(
    BuildContext context,
    ResumenEjecucion resumen,
  ) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final columnas = restricciones.maxWidth >= 1200
            ? 4
            : restricciones.maxWidth >= 700
                ? 2
                : 1;

        final ancho =
            (restricciones.maxWidth - ((columnas - 1) * 16)) / columnas;

        final tarjetas = [
          TarjetaIndicador(
            titulo: 'Ejecución global',
            valor: Formateadores.porcentaje(resumen.porcentajeEjecucion),
            detalle: '${resumen.totalProyectos} procesos registrados',
            icono: Icons.trending_up_rounded,
            color: ColoresRio.azulProfundo,
            destacada: true,
          ),
          TarjetaIndicador(
            titulo: 'Total comprometido',
            valor: Formateadores.moneda(resumen.comprometido),
            detalle: 'Recursos reservados',
            icono: Icons.account_balance_wallet_outlined,
            color: ColoresRio.violeta,
          ),
          TarjetaIndicador(
            titulo: 'Total pagado',
            valor: Formateadores.moneda(resumen.pagado),
            detalle: 'Desembolsos efectivos',
            icono: Icons.payments_outlined,
            color: ColoresRio.verde,
          ),
          TarjetaIndicador(
            titulo: 'Pagos vencidos',
            valor: '${resumen.cantidadPagosVencidos}',
            detalle: Formateadores.moneda(resumen.montoPagosVencidos),
            icono: Icons.warning_amber_rounded,
            color: ColoresRio.rojo,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: tarjetas
              .map(
                (tarjeta) => SizedBox(
                  width: ancho,
                  child: tarjeta,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _panelEjecucion(Map<String, double> ejecucion) {
    return _Panel(
      titulo: 'Ejecución por Dirección de Gestión',
      subtitulo:
          'Porcentaje devengado frente al presupuesto asignado.',
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: GraficoBarrasDirecciones(datos: ejecucion),
      ),
    );
  }

  Widget _panelEtapas(Map<String, int> etapas) {
    return _Panel(
      titulo: 'Estado de los procesos',
      subtitulo: 'Distribución por etapa de contratación.',
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: GraficoDonaEtapas(datos: etapas),
      ),
    );
  }

  Widget _panelAlertas(List<AlertaPago> alertas) {
    return _Panel(
      titulo: 'Alertas que requieren atención',
      subtitulo: 'Pagos vencidos priorizados por días de atraso.',
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: alertas.isEmpty
            ? const Text('No existen pagos vencidos.')
            : Column(
                children: alertas.take(4).map((alerta) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 11),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColoresRio.rojo.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: ColoresRio.rojo.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: ColoresRio.rojo,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alerta.proyecto.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${alerta.pago.hito} · ${alerta.proyecto.direccion}',
                                style: const TextStyle(
                                  color: ColoresRio.textoSecundario,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formateadores.moneda(alerta.pago.monto),
                              style: const TextStyle(
                                color: ColoresRio.rojo,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${alerta.diasAtraso} días',
                              style: const TextStyle(
                                color: ColoresRio.textoSecundario,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget child;

  const _Panel({
    required this.titulo,
    required this.subtitulo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ColoresRio.texto,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitulo,
            style: const TextStyle(
              color: ColoresRio.textoSecundario,
              fontSize: 13,
            ),
          ),
          child,
        ],
      ),
    );
  }
}