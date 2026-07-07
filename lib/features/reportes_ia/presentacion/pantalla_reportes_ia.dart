import 'package:flutter/material.dart';

import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/controladores/controlador_sesion.dart';
import '../../../core/tema/tema_rio_control.dart';
import '../../../core/utilidades/calculador_indicadores.dart';
import '../../../core/utilidades/formateadores.dart';
import '../../proyectos/dominio/modelos/proyecto_modelo.dart';

class PantallaReportesIa extends StatefulWidget {
  final ControladorProyectos controlador;
  final ControladorSesion controladorSesion;

  const PantallaReportesIa({
    super.key,
    required this.controlador,
    required this.controladorSesion,
  });

  @override
  State<PantallaReportesIa> createState() => _PantallaReportesIaState();
}

class _PantallaReportesIaState extends State<PantallaReportesIa> {
  String alcanceSeleccionado = 'Global';
  bool reporteGenerado = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.controladorSesion.puedeGenerarReporteEjecutivo) {
      return const _AccesoRestringidoReporte();
    }

    return AnimatedBuilder(
      animation: widget.controlador,
      builder: (context, _) {
        final proyectos = widget.controlador.proyectos;

        final direcciones = [
          'Global',
          ...proyectos.map((proyecto) => proyecto.direccion).toSet(),
        ];

        final alcanceValido = direcciones.contains(alcanceSeleccionado)
            ? alcanceSeleccionado
            : 'Global';

        final proyectosSeleccionados = alcanceValido == 'Global'
            ? proyectos
            : proyectos
                .where(
                  (proyecto) => proyecto.direccion == alcanceValido,
                )
                .toList();

        final resumen =
            CalculadorIndicadores.calcularResumen(proyectosSeleccionados);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporte ejecutivo MuniIA',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Convierte indicadores financieros y alertas en información clara para toma de decisiones.',
                    style: TextStyle(
                      color: ColoresRio.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _panelConfiguracion(direcciones, alcanceValido),
                  const SizedBox(height: 20),
                  _panelResumen(resumen),
                  const SizedBox(height: 20),
                  if (reporteGenerado)
                    _panelReporte(
                      proyectosSeleccionados,
                      alcanceValido,
                    )
                  else
                    _estadoInicial(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _panelConfiguracion(
    List<String> direcciones,
    String alcanceValido,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _decoracionPanel(),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final selector = SizedBox(
            width: 290,
            child: DropdownButtonFormField<String>(
              initialValue: alcanceValido,
              decoration: const InputDecoration(
                labelText: 'Alcance del reporte',
              ),
              items: direcciones
                  .map(
                    (direccion) => DropdownMenuItem(
                      value: direccion,
                      child: Text(direccion),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  alcanceSeleccionado = valor ?? 'Global';
                  reporteGenerado = false;
                });
              },
            ),
          );

          final boton = FilledButton.icon(
            onPressed: () {
              setState(() {
                reporteGenerado = true;
              });
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generar reporte'),
          );

          if (restricciones.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selector,
                const SizedBox(height: 14),
                boton,
              ],
            );
          }

          return Row(
            children: [
              selector,
              const Spacer(),
              boton,
            ],
          );
        },
      ),
    );
  }

  Widget _panelResumen(ResumenEjecucion resumen) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _decoracionPanel(),
      child: Wrap(
        spacing: 28,
        runSpacing: 18,
        children: [
          _dato(
            'Ejecución',
            Formateadores.porcentaje(resumen.porcentajeEjecucion),
          ),
          _dato(
            'Comprometido',
            Formateadores.moneda(resumen.comprometido),
          ),
          _dato(
            'Pagado',
            Formateadores.moneda(resumen.pagado),
          ),
          _dato(
            'Pagos vencidos',
            '${resumen.cantidadPagosVencidos}',
          ),
        ],
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            color: ColoresRio.textoSecundario,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            color: ColoresRio.texto,
          ),
        ),
      ],
    );
  }

  Widget _panelReporte(
    List<ProyectoModelo> proyectos,
    String alcance,
  ) {
    final texto = _construirReporte(proyectos, alcance);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColoresRio.azulMedio.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: ColoresRio.azulProfundo,
              ),
              SizedBox(width: 10),
              Text(
                'Informe ejecutivo generado',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: ColoresRio.texto,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Trazabilidad: las cifras del informe se calculan desde los datos registrados en el sistema.',
            style: TextStyle(
              color: ColoresRio.textoSecundario,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _construirReporte(
    List<ProyectoModelo> proyectos,
    String alcance,
  ) {
    final resumen = CalculadorIndicadores.calcularResumen(proyectos);
    final alertas = CalculadorIndicadores.obtenerAlertas(proyectos);

    final entidad = alcance == 'Global'
        ? 'el GADMR'
        : 'la Dirección de $alcance';

    final introduccion =
        'Al corte de hoy, $entidad registra una ejecución presupuestaria de '
        '${Formateadores.porcentaje(resumen.porcentajeEjecucion)}. '
        'De un presupuesto asignado de ${Formateadores.moneda(resumen.presupuestoAsignado)}, '
        '${Formateadores.moneda(resumen.comprometido)} se encuentra comprometido y '
        '${Formateadores.moneda(resumen.devengado)} ha sido devengado.';

    if (alertas.isEmpty) {
      return '$introduccion '
          'No se identifican pagos vencidos en el alcance analizado. '
          'Se recomienda mantener el monitoreo periódico.';
    }

    final alertaPrincipal = alertas.first;

    return '$introduccion '
        'Se identifican ${alertas.length} pago(s) vencido(s) por un monto acumulado de '
        '${Formateadores.moneda(resumen.montoPagosVencidos)}. '
        'La alerta prioritaria corresponde al proyecto "${alertaPrincipal.proyecto.nombre}", '
        'con ${alertaPrincipal.diasAtraso} días de atraso. '
        'Se recomienda priorizar la revisión financiera y contractual.';
  }

  Widget _estadoInicial() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(38),
      decoration: _decoracionPanel(),
      child: const Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 54,
            color: ColoresRio.azulProfundo,
          ),
          SizedBox(height: 14),
          Text(
            'Selecciona el alcance y genera el reporte ejecutivo.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoracionPanel() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ColoresRio.borde),
    );
  }
}

class _AccesoRestringidoReporte extends StatelessWidget {
  const _AccesoRestringidoReporte();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ColoresRio.borde),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              color: ColoresRio.rojo,
              size: 48,
            ),
            SizedBox(height: 14),
            Text(
              'Acceso restringido',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'El reporte ejecutivo está disponible para Alcaldía y Dirección Financiera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColoresRio.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}