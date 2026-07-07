import 'package:flutter/material.dart';

import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/controladores/controlador_sesion.dart';
import '../../../core/tema/tema_rio_control.dart';
import '../../../core/utilidades/formateadores.dart';
import '../../../core/widgets/componentes_rio_control.dart';
import '../dominio/modelos/proyecto_modelo.dart';

class PantallaProyectos extends StatefulWidget {
  final ControladorProyectos controlador;
  final ControladorSesion controladorSesion;
  final VoidCallback? alAbrirRegistro;
  final ValueChanged<ProyectoModelo> alAbrirEnMapa;

  const PantallaProyectos({
    super.key,
    required this.controlador,
    required this.controladorSesion,
    required this.alAbrirRegistro,
    required this.alAbrirEnMapa,
  });

  @override
  State<PantallaProyectos> createState() => _PantallaProyectosState();
}

class _PantallaProyectosState extends State<PantallaProyectos> {
  final controladorBusqueda = TextEditingController();

  String direccionSeleccionada = 'Todas';
  String etapaSeleccionada = 'Todas';

  @override
  void dispose() {
    controladorBusqueda.dispose();
    super.dispose();
  }

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

        final proyectosFiltrados = proyectos.where((proyecto) {
          final textoBusqueda =
              controladorBusqueda.text.trim().toLowerCase();

          final coincideDireccion = direccionSeleccionada == 'Todas' ||
              proyecto.direccion == direccionSeleccionada;

          final coincideEtapa = etapaSeleccionada == 'Todas' ||
              proyecto.etapa == etapaSeleccionada;

          final coincideBusqueda = textoBusqueda.isEmpty ||
              proyecto.nombre.toLowerCase().contains(textoBusqueda) ||
              proyecto.codigoProceso.toLowerCase().contains(textoBusqueda);

          return coincideDireccion && coincideEtapa && coincideBusqueda;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(context),
                  const SizedBox(height: 24),
                  _seccionFiltros(context, direcciones),
                  const SizedBox(height: 22),
                  Text(
                    '${proyectosFiltrados.length} proyecto(s) encontrado(s)',
                    style: const TextStyle(
                      color: ColoresRio.textoSecundario,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _listaProyectos(context, proyectosFiltrados),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _obtenerDescripcion() {
    if (widget.controladorSesion.esAlcaldia) {
      return 'Consulta estratégica de proyectos, ejecución y alertas institucionales.';
    }

    if (widget.controladorSesion.esDireccionFinanciera) {
      return 'Consulta de presupuesto, pagos, ejecución y alertas financieras.';
    }

    return 'Gestión de proyectos, avances y alertas de su Dirección.';
  }

  Widget _encabezado(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final texto = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proyectos y procesos de contratación',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              _obtenerDescripcion(),
              style: const TextStyle(
                color: ColoresRio.textoSecundario,
              ),
            ),
          ],
        );

        final botonRegistro = widget.alAbrirRegistro == null
            ? null
            : FilledButton.icon(
                onPressed: widget.alAbrirRegistro,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Registrar con MuniIA'),
              );

        if (restricciones.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              texto,
              if (botonRegistro != null) ...[
                const SizedBox(height: 16),
                botonRegistro,
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: texto),
            if (botonRegistro != null) botonRegistro,
          ],
        );
      },
    );
  }

  Widget _seccionFiltros(
    BuildContext context,
    List<String> direcciones,
  ) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final buscador = TextField(
          controller: controladorBusqueda,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Buscar por proyecto o código',
            prefixIcon: Icon(Icons.search),
          ),
        );

        final filtroDireccion = DropdownButtonFormField<String>(
          isExpanded: true,
          value: direccionSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Dirección',
          ),
          items: direcciones
              .map(
                (direccion) => DropdownMenuItem<String>(
                  value: direccion,
                  child: Text(
                    direccion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (valor) {
            setState(() {
              direccionSeleccionada = valor ?? 'Todas';
            });
          },
        );

        final filtroEtapa = DropdownButtonFormField<String>(
          isExpanded: true,
          value: etapaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Etapa',
          ),
          items: const [
            'Todas',
            'Preparatoria',
            'Precontractual',
            'Contractual',
            'Ejecución',
            'Cierre',
          ]
              .map(
                (etapa) => DropdownMenuItem<String>(
                  value: etapa,
                  child: Text(
                    etapa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (valor) {
            setState(() {
              etapaSeleccionada = valor ?? 'Todas';
            });
          },
        );

        if (restricciones.maxWidth >= 1100) {
          return Row(
            children: [
              Expanded(child: buscador),
              const SizedBox(width: 16),
              SizedBox(
                width: 250,
                child: filtroDireccion,
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 190,
                child: filtroEtapa,
              ),
            ],
          );
        }

        if (restricciones.maxWidth >= 680) {
          return Column(
            children: [
              buscador,
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: filtroDireccion),
                  const SizedBox(width: 14),
                  Expanded(child: filtroEtapa),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            buscador,
            const SizedBox(height: 14),
            filtroDireccion,
            const SizedBox(height: 14),
            filtroEtapa,
          ],
        );
      },
    );
  }

  Widget _listaProyectos(
    BuildContext context,
    List<ProyectoModelo> proyectos,
  ) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final columnas = restricciones.maxWidth >= 1150
            ? 3
            : restricciones.maxWidth >= 700
                ? 2
                : 1;

        final ancho =
            (restricciones.maxWidth - ((columnas - 1) * 16)) / columnas;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: proyectos
              .map(
                (proyecto) => SizedBox(
                  width: ancho,
                  child: TarjetaProyecto(
                    proyecto: proyecto,
                    alPresionar: () =>
                        mostrarDetalle(context, proyecto),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  void mostrarDetalle(
    BuildContext context,
    ProyectoModelo proyecto,
  ) {
    showDialog(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: Text(
            proyecto.nombre,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      EtiquetaEstado(texto: proyecto.etapa),
                      EtiquetaEstado(
                        texto: 'Riesgo ${proyecto.nivelRiesgo}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _filaDetalle(
                    'Código del proceso',
                    proyecto.codigoProceso,
                  ),
                  _filaDetalle(
                    'Dirección',
                    proyecto.direccion,
                  ),
                  _filaDetalle(
                    'Presupuesto asignado',
                    Formateadores.moneda(
                      proyecto.presupuestoAsignado,
                    ),
                  ),
                  _filaDetalle(
                    'Certificado',
                    Formateadores.moneda(proyecto.certificado),
                  ),
                  _filaDetalle(
                    'Comprometido',
                    Formateadores.moneda(proyecto.comprometido),
                  ),
                  _filaDetalle(
                    'Devengado',
                    Formateadores.moneda(proyecto.devengado),
                  ),
                  _filaDetalle(
                    'Pagado',
                    Formateadores.moneda(proyecto.pagado),
                  ),
                  _filaDetalle(
                    'Saldo por pagar',
                    Formateadores.moneda(proyecto.saldoPorPagar),
                  ),
                  if (proyecto.tieneUbicacion) ...[
                    const Divider(height: 30),
                    const Text(
                      'Información territorial',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _filaDetalle(
                      'Ubicación',
                      proyecto.ubicacion!.referenciaUbicacion,
                    ),
                    _filaDetalle(
                      'Avance físico',
                      Formateadores.porcentaje(
                        proyecto.avanceFisicoNormalizado,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (proyecto.tieneUbicacion)
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(contextoDialogo);
                  widget.alAbrirEnMapa(proyecto);
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ver en mapa'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _filaDetalle(
    String etiqueta,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: ColoresRio.textoSecundario,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}