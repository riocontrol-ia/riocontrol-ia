import 'package:flutter/material.dart';

import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/tema/tema_rio_control.dart';
import '../../../core/utilidades/calculador_indicadores.dart';
import '../../../core/utilidades/formateadores.dart';

class PantallaAlertas extends StatefulWidget {
  final ControladorProyectos controlador;

  const PantallaAlertas({
    super.key,
    required this.controlador,
  });

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  String direccionSeleccionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controlador,
      builder: (context, _) {
        final proyectos = widget.controlador.proyectos;

        final direcciones = [
          'Todas',
          ...proyectos.map((proyecto) => proyecto.direccion).toSet(),
        ];

        final alertas = CalculadorIndicadores.obtenerAlertas(proyectos)
            .where(
              (alerta) =>
                  direccionSeleccionada == 'Todas' ||
                  alerta.proyecto.direccion == direccionSeleccionada,
            )
            .toList();

        final montoTotal = alertas.fold(
          0.0,
          (total, alerta) => total + alerta.pago.monto,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alertas preventivas de pagos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Obligaciones vencidas priorizadas para atención financiera y contractual.',
                    style: TextStyle(color: ColoresRio.textoSecundario),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, restricciones) {
                      final filtro = SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: direccionSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por Dirección',
                          ),
                          items: direcciones
                              .map(
                                (direccion) => DropdownMenuItem(
                                  value: direccion,
                                  child: Text(direccion, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              )
                              .toList(),
                          onChanged: (valor) {
                            setState(() {
                              direccionSeleccionada = valor ?? 'Todas';
                            });
                          },
                        ),
                      );

                      final resumen = Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _resumen(
                            'Pagos vencidos',
                            '${alertas.length}',
                            Icons.warning_amber_rounded,
                            ColoresRio.rojo,
                          ),
                          _resumen(
                            'Monto en riesgo',
                            Formateadores.moneda(montoTotal),
                            Icons.payments_outlined,
                            ColoresRio.naranja,
                          ),
                        ],
                      );

                      if (restricciones.maxWidth < 720) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            filtro,
                            const SizedBox(height: 14),
                            resumen,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          filtro,
                          const SizedBox(width: 16),
                          Expanded(child: resumen),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  if (alertas.isEmpty)
                    _sinAlertas()
                  else
                    ...alertas.map(_tarjetaAlerta),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resumen(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresRio.textoSecundario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ColoresRio.texto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaAlerta(AlertaPago alerta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColoresRio.rojo.withOpacity(0.22),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final contenido = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alerta.proyecto.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${alerta.proyecto.direccion} · ${alerta.proyecto.codigoProceso}',
                style: const TextStyle(
                  color: ColoresRio.textoSecundario,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hito pendiente: ${alerta.pago.hito}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          );

          final valor = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formateadores.moneda(alerta.pago.monto),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ColoresRio.rojo,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${alerta.diasAtraso} días de atraso',
                style: const TextStyle(
                  color: ColoresRio.rojo,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

          if (restricciones.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: ColoresRio.rojo,
                  size: 32,
                ),
                const SizedBox(height: 12),
                contenido,
                const SizedBox(height: 16),
                valor,
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: ColoresRio.rojo,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(child: contenido),
              const SizedBox(width: 16),
              valor,
            ],
          );
        },
      ),
    );
  }

  Widget _sinAlertas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: ColoresRio.verde,
            size: 50,
          ),
          SizedBox(height: 12),
          Text(
            'No existen pagos vencidos para los filtros seleccionados.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}