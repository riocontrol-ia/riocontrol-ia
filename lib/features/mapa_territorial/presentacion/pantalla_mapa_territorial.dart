import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/controladores/controlador_mapa_territorial.dart';
import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/controladores/controlador_sesion.dart';
import '../../../core/tema/tema_rio_control.dart';
import '../../../core/utilidades/formateadores.dart';
import '../../../core/widgets/componentes_rio_control.dart';
import '../../proyectos/dominio/modelos/proyecto_modelo.dart';

class PantallaMapaTerritorial extends StatefulWidget {
  final ControladorProyectos controladorProyectos;
  final ControladorSesion controladorSesion;
  final ControladorMapaTerritorial controladorMapa;

  const PantallaMapaTerritorial({
    super.key,
    required this.controladorProyectos,
    required this.controladorSesion,
    required this.controladorMapa,
  });

  @override
  State<PantallaMapaTerritorial> createState() =>
      _PantallaMapaTerritorialState();
}

class _PantallaMapaTerritorialState
    extends State<PantallaMapaTerritorial> {
  final controladorVistaMapa = MapController();
  final controladorBusqueda = TextEditingController();

  late final VoidCallback escuchadorFiltros;
  String? idEnfoqueProgramado;

  @override
  void initState() {
    super.initState();

    controladorBusqueda.text = widget.controladorMapa.textoBusqueda;

    escuchadorFiltros = () {
      final nuevoTexto = widget.controladorMapa.textoBusqueda;

      if (controladorBusqueda.text != nuevoTexto) {
        controladorBusqueda.value = TextEditingValue(
          text: nuevoTexto,
          selection: TextSelection.collapsed(
            offset: nuevoTexto.length,
          ),
        );
      }
    };

    widget.controladorMapa.addListener(escuchadorFiltros);
  }

  @override
  void dispose() {
    widget.controladorMapa.removeListener(escuchadorFiltros);
    controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controladorProyectos,
        widget.controladorSesion,
        widget.controladorMapa,
      ]),
      builder: (context, _) {
        final proyectosPermitidos = widget.controladorProyectos.proyectos;

        final proyectosMapa = widget.controladorMapa.filtrarProyectos(
          proyectosPermitidos,
        );

        _procesarEnfoquePendiente(proyectosMapa);

        final proyectoSeleccionado =
            _proyectoSeleccionadoVisible(proyectosMapa);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(context, proyectosMapa.length),
                  const SizedBox(height: 18),
                  _panelFiltros(
                    context,
                    proyectosPermitidos,
                  ),
                  const SizedBox(height: 18),
                  _leyenda(),
                  const SizedBox(height: 18),
                  _mapa(
                    context,
                    proyectosMapa,
                    proyectoSeleccionado,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ProyectoModelo? _proyectoSeleccionadoVisible(
    List<ProyectoModelo> proyectosMapa,
  ) {
    final seleccionado = widget.controladorMapa.proyectoSeleccionado;

    if (seleccionado == null) {
      return null;
    }

    final existe = proyectosMapa.any(
      (proyecto) => proyecto.id == seleccionado.id,
    );

    return existe ? seleccionado : null;
  }

  void _procesarEnfoquePendiente(
    List<ProyectoModelo> proyectosMapa,
  ) {
    final idPendiente = widget.controladorMapa.idProyectoPendienteEnfoque;

    if (idPendiente == null || idEnfoqueProgramado == idPendiente) {
      return;
    }

    idEnfoqueProgramado = idPendiente;

    ProyectoModelo? proyectoPendiente;

    for (final proyecto in proyectosMapa) {
      if (proyecto.id == idPendiente) {
        proyectoPendiente = proyecto;
        break;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (proyectoPendiente != null) {
        _centrarProyecto(proyectoPendiente!);
      }

      widget.controladorMapa.confirmarEnfoqueAplicado();
      idEnfoqueProgramado = null;
    });
  }

  Widget _encabezado(
    BuildContext context,
    int cantidadProyectos,
  ) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final texto = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RíoMapa de Ejecución',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              '${widget.controladorSesion.alcanceActual}. '
              '$cantidadProyectos proyecto(s) visibles en el mapa.',
              style: const TextStyle(
                color: ColoresRio.textoSecundario,
              ),
            ),
          ],
        );

        final botonLimpiar = OutlinedButton.icon(
          onPressed: () {
            controladorBusqueda.clear();
            widget.controladorMapa.limpiarFiltros();
          },
          icon: const Icon(Icons.filter_alt_off_outlined),
          label: const Text('Limpiar filtros'),
        );

        if (restricciones.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              texto,
              const SizedBox(height: 14),
              botonLimpiar,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: texto),
            botonLimpiar,
          ],
        );
      },
    );
  }

  Widget _panelFiltros(
    BuildContext context,
    List<ProyectoModelo> proyectosPermitidos,
  ) {
    final direcciones = [
      'Todas',
      ...proyectosPermitidos.map((proyecto) => proyecto.direccion).toSet(),
    ];

    final direccionActiva = direcciones.contains(
      widget.controladorMapa.direccionSeleccionada,
    )
        ? widget.controladorMapa.direccionSeleccionada
        : 'Todas';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final anchoDisponible = restricciones.maxWidth;

          final anchoBusqueda = anchoDisponible < 620
              ? anchoDisponible
              : anchoDisponible < 980
                  ? anchoDisponible
                  : 350.0;

          final anchoCampo = anchoDisponible < 620
              ? anchoDisponible
              : anchoDisponible < 980
                  ? (anchoDisponible - 12) / 2
                  : 210.0;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: anchoBusqueda,
                child: TextField(
                  controller: controladorBusqueda,
                  onChanged: widget.controladorMapa.actualizarTextoBusqueda,
                  decoration: const InputDecoration(
                    hintText: 'Buscar proyecto, código o Dirección',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _filtroDesplegable(
                  etiqueta: 'Dirección',
                  valor: direccionActiva,
                  opciones: direcciones,
                  alCambiar: widget.controladorMapa.actualizarDireccion,
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _filtroDesplegable(
                  etiqueta: 'Etapa',
                  valor: widget.controladorMapa.etapaSeleccionada,
                  opciones: const [
                    'Todas',
                    'Preparatoria',
                    'Precontractual',
                    'Contractual',
                    'Ejecución',
                    'Cierre',
                  ],
                  alCambiar: widget.controladorMapa.actualizarEtapa,
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _filtroDesplegable(
                  etiqueta: 'Riesgo',
                  valor: widget.controladorMapa.riesgoSeleccionado,
                  opciones: const [
                    'Todos',
                    'Alto',
                    'Medio',
                    'Bajo',
                  ],
                  alCambiar: widget.controladorMapa.actualizarRiesgo,
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _filtroDesplegable(
                  etiqueta: 'Tipo de ubicación',
                  valor: widget.controladorMapa.geometriaSeleccionada,
                  opciones: const [
                    'Todas',
                    'Punto',
                    'Línea',
                    'Área',
                  ],
                  alCambiar: widget.controladorMapa.actualizarGeometria,
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _filtroDesplegable(
                  etiqueta: 'Avance físico',
                  valor: widget.controladorMapa.avanceSeleccionado,
                  opciones: const [
                    'Todos',
                    '0 - 25 %',
                    '26 - 50 %',
                    '51 - 75 %',
                    '76 - 100 %',
                  ],
                  alCambiar: widget.controladorMapa.actualizarAvance,
                ),
              ),
              FilterChip(
                selected: widget.controladorMapa.soloPagosVencidos,
                showCheckmark: true,
                selectedColor: ColoresRio.rojo.withOpacity(0.14),
                avatar: const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                ),
                label: const Text('Solo pagos vencidos'),
                onSelected: widget.controladorMapa.cambiarSoloPagosVencidos,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filtroDesplegable({
    required String etiqueta,
    required String valor,
    required List<String> opciones,
    required ValueChanged<String> alCambiar,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: valor,
      decoration: InputDecoration(labelText: etiqueta),
      items: opciones
          .map(
            (opcion) => DropdownMenuItem<String>(
              value: opcion,
              child: Text(
                opcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (valorSeleccionado) {
        alCambiar(valorSeleccionado ?? opciones.first);
      },
    );
  }

  Widget _leyenda() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _itemLeyenda(
          color: ColoresRio.azulMedio,
          texto: 'Avance inicial',
        ),
        _itemLeyenda(
          color: ColoresRio.azulCielo,
          texto: 'Avance en ejecución',
        ),
        _itemLeyenda(
          color: ColoresRio.verde,
          texto: 'Cerca de finalizar',
        ),
        _itemLeyenda(
          color: ColoresRio.naranja,
          texto: 'Riesgo medio',
        ),
        _itemLeyenda(
          color: ColoresRio.rojo,
          texto: 'Riesgo alto / pago vencido',
        ),
      ],
    );
  }

  Widget _itemLeyenda({
    required Color color,
    required String texto,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          texto,
          style: const TextStyle(
            color: ColoresRio.textoSecundario,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _mapa(
    BuildContext context,
    List<ProyectoModelo> proyectos,
    ProyectoModelo? proyectoSeleccionado,
  ) {
    return Container(
      height: 650,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColoresRio.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: controladorVistaMapa,
            options: const MapOptions(
              initialCenter: LatLng(-1.6640, -78.6540),
              initialZoom: 13.1,
              minZoom: 11,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ec.edu.unach.rio_control_ia',
                maxNativeZoom: 19,
              ),
              PolygonLayer(
                polygons: _poligonosProyectos(proyectos),
              ),
              PolylineLayer(
                polylines: [
                  ..._lineasBase(proyectos),
                  ..._lineasAvance(proyectos),
                ],
              ),
              MarkerLayer(
                markers: _marcadoresProyectos(proyectos),
              ),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap contributors'),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 17,
                    color: ColoresRio.azulProfundo,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Ubicaciones referenciales de demostración',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (proyectos.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ColoresRio.borde),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: ColoresRio.azulProfundo,
                          size: 42,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No existen proyectos para los filtros seleccionados.',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (proyectoSeleccionado != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Align(
                alignment: Alignment.bottomRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 410),
                  child: _fichaFlotante(proyectoSeleccionado),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Polygon> _poligonosProyectos(
    List<ProyectoModelo> proyectos,
  ) {
    return proyectos
        .where((proyecto) => proyecto.ubicacion?.esArea ?? false)
        .map(
          (proyecto) {
            final color = _colorTerritorial(proyecto);

            return Polygon(
              points: _obtenerCoordenadasLatLng(proyecto),
              color: color.withOpacity(0.26),
              borderColor: color,
              borderStrokeWidth: 3,
            );
          },
        )
        .toList();
  }

  List<Polyline> _lineasBase(
    List<ProyectoModelo> proyectos,
  ) {
    return proyectos
        .where((proyecto) => proyecto.ubicacion?.esLinea ?? false)
        .map(
          (proyecto) => Polyline(
            points: _obtenerCoordenadasLatLng(proyecto),
            color: const Color(0xFFB8C3D1),
            strokeWidth: 11,
            borderColor: Colors.white,
            borderStrokeWidth: 2,
          ),
        )
        .toList();
  }

  List<Polyline> _lineasAvance(
    List<ProyectoModelo> proyectos,
  ) {
    return proyectos
        .where(
          (proyecto) =>
              (proyecto.ubicacion?.esLinea ?? false) &&
              proyecto.avanceFisicoNormalizado > 0,
        )
        .map(
          (proyecto) => Polyline(
            points: _obtenerTramoAvanzado(
              _obtenerCoordenadasLatLng(proyecto),
              proyecto.avanceFisicoNormalizado,
            ),
            color: _colorTerritorial(proyecto),
            strokeWidth: 8,
          ),
        )
        .toList();
  }

  List<Marker> _marcadoresProyectos(
    List<ProyectoModelo> proyectos,
  ) {
    return proyectos.map((proyecto) {
      final ubicacion = proyecto.ubicacion!;
      final puntoCentral = ubicacion.coordenadaCentral;
      final color = _colorTerritorial(proyecto);

      return Marker(
        point: LatLng(
          puntoCentral.latitud,
          puntoCentral.longitud,
        ),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => _seleccionarProyecto(proyecto),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              ubicacion.esLinea
                  ? Icons.route_rounded
                  : ubicacion.esArea
                      ? Icons.park_outlined
                      : Icons.location_on_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _seleccionarProyecto(ProyectoModelo proyecto) {
    widget.controladorMapa.seleccionarProyecto(proyecto);
    _centrarProyecto(proyecto);
  }

  void _centrarProyecto(ProyectoModelo proyecto) {
    final puntoCentral = proyecto.ubicacion!.coordenadaCentral;

    controladorVistaMapa.move(
      LatLng(
        puntoCentral.latitud,
        puntoCentral.longitud,
      ),
      15.5,
    );
  }

  Widget _fichaFlotante(ProyectoModelo proyecto) {
    final color = _colorTerritorial(proyecto);

    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.26),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    proyecto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar detalle',
                  onPressed: widget.controladorMapa.cerrarFicha,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              proyecto.ubicacion!.referenciaUbicacion,
              style: const TextStyle(
                color: ColoresRio.textoSecundario,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EtiquetaEstado(texto: proyecto.etapa),
                EtiquetaEstado(
                  texto: 'Riesgo ${proyecto.nivelRiesgo}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _filaDato(
              icono: Icons.account_balance_wallet_outlined,
              etiqueta: 'Presupuesto',
              valor: Formateadores.moneda(
                proyecto.presupuestoAsignado,
              ),
            ),
            _filaDato(
              icono: Icons.trending_up_rounded,
              etiqueta: 'Ejecución financiera',
              valor: Formateadores.porcentaje(
                proyecto.porcentajeEjecucion,
              ),
            ),
            _filaDato(
              icono: Icons.engineering_outlined,
              etiqueta: 'Avance físico',
              valor: Formateadores.porcentaje(
                proyecto.avanceFisicoNormalizado,
              ),
            ),
            _filaDato(
              icono: Icons.warning_amber_rounded,
              etiqueta: 'Pagos vencidos',
              valor: proyecto.pagosVencidos.isEmpty
                  ? 'Sin alertas'
                  : '${proyecto.pagosVencidos.length} pendiente(s)',
              color: proyecto.pagosVencidos.isEmpty
                  ? ColoresRio.verde
                  : ColoresRio.rojo,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _mostrarFichaCompleta(proyecto),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Ver ficha completa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDato({
    required IconData icono,
    required String etiqueta,
    required String valor,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(
            icono,
            size: 18,
            color: color ?? ColoresRio.azulMedio,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: ColoresRio.textoSecundario,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: color ?? ColoresRio.texto,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarFichaCompleta(ProyectoModelo proyecto) {
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
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filaDetalle(
                    'Dirección',
                    proyecto.direccion,
                  ),
                  _filaDetalle(
                    'Etapa',
                    proyecto.etapa,
                  ),
                  _filaDetalle(
                    'Ubicación',
                    proyecto.ubicacion!.referenciaUbicacion,
                  ),
                  _filaDetalle(
                    'Presupuesto',
                    Formateadores.moneda(
                      proyecto.presupuestoAsignado,
                    ),
                  ),
                  _filaDetalle(
                    'Ejecución financiera',
                    Formateadores.porcentaje(
                      proyecto.porcentajeEjecucion,
                    ),
                  ),
                  _filaDetalle(
                    'Avance físico',
                    Formateadores.porcentaje(
                      proyecto.avanceFisicoNormalizado,
                    ),
                  ),
                  _filaDetalle(
                    'Pagos vencidos',
                    proyecto.pagosVencidos.isEmpty
                        ? 'Sin pagos vencidos'
                        : '${proyecto.pagosVencidos.length} pago(s) pendiente(s)',
                  ),
                  _filaDetalle(
                    'Nivel de riesgo',
                    proyecto.nivelRiesgo,
                  ),
                ],
              ),
            ),
          ),
          actions: [
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
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 165,
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

  Color _colorTerritorial(ProyectoModelo proyecto) {
    if (proyecto.nivelRiesgo == 'Alto') {
      return ColoresRio.rojo;
    }

    if (proyecto.nivelRiesgo == 'Medio') {
      return ColoresRio.naranja;
    }

    if (proyecto.avanceFisicoNormalizado >= 0.85) {
      return ColoresRio.verde;
    }

    if (proyecto.avanceFisicoNormalizado >= 0.40) {
      return ColoresRio.azulCielo;
    }

    if (proyecto.avanceFisicoNormalizado > 0) {
      return ColoresRio.azulMedio;
    }

    return const Color(0xFF94A3B8);
  }

  List<LatLng> _obtenerCoordenadasLatLng(
    ProyectoModelo proyecto,
  ) {
    return proyecto.ubicacion!.coordenadas
        .map(
          (coordenada) => LatLng(
            coordenada.latitud,
            coordenada.longitud,
          ),
        )
        .toList();
  }

  List<LatLng> _obtenerTramoAvanzado(
    List<LatLng> puntos,
    double avance,
  ) {
    if (puntos.length < 2 || avance <= 0) {
      return puntos;
    }

    if (avance >= 1) {
      return puntos;
    }

    final distanciaTotal = _distanciaTotal(puntos);
    final distanciaObjetivo = distanciaTotal * avance;

    final resultado = <LatLng>[puntos.first];
    var distanciaAcumulada = 0.0;

    for (var indice = 0; indice < puntos.length - 1; indice++) {
      final inicio = puntos[indice];
      final fin = puntos[indice + 1];

      final distanciaSegmento = _distanciaEntre(inicio, fin);

      if (distanciaAcumulada + distanciaSegmento <= distanciaObjetivo) {
        resultado.add(fin);
        distanciaAcumulada += distanciaSegmento;
        continue;
      }

      final restante = distanciaObjetivo - distanciaAcumulada;
      final proporcion = restante / distanciaSegmento;

      resultado.add(
        LatLng(
          inicio.latitude + ((fin.latitude - inicio.latitude) * proporcion),
          inicio.longitude +
              ((fin.longitude - inicio.longitude) * proporcion),
        ),
      );

      break;
    }

    return resultado;
  }

  double _distanciaTotal(List<LatLng> puntos) {
    var total = 0.0;

    for (var indice = 0; indice < puntos.length - 1; indice++) {
      total += _distanciaEntre(
        puntos[indice],
        puntos[indice + 1],
      );
    }

    return total;
  }

  double _distanciaEntre(
    LatLng primero,
    LatLng segundo,
  ) {
    final diferenciaLatitud = segundo.latitude - primero.latitude;
    final diferenciaLongitud = segundo.longitude - primero.longitude;

    return math.sqrt(
      (diferenciaLatitud * diferenciaLatitud) +
          (diferenciaLongitud * diferenciaLongitud),
    );
  }
}