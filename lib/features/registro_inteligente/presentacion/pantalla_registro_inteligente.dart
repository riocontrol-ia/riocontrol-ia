import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/controladores/controlador_sesion.dart';
import '../../../core/servicios/servicio_muni_ia.dart';
import '../../../core/tema/tema_rio_control.dart';
import '../../proyectos/dominio/modelos/proyecto_modelo.dart';
import '../../proyectos/dominio/modelos/ubicacion_proyecto_modelo.dart';
import '../dominio/borrador_proyecto_ia_modelo.dart';

class PantallaRegistroInteligente extends StatefulWidget {
  final ControladorProyectos controlador;
  final ControladorSesion controladorSesion;
  final VoidCallback alAbrirProyectos;

  const PantallaRegistroInteligente({
    super.key,
    required this.controlador,
    required this.controladorSesion,
    required this.alAbrirProyectos,
  });

  @override
  State<PantallaRegistroInteligente> createState() =>
      _PantallaRegistroInteligenteState();
}

class _PantallaRegistroInteligenteState
    extends State<PantallaRegistroInteligente> {
  final claveFormulario = GlobalKey<FormState>();
  final servicioMuniIa = ServicioMuniIa();

  int indicePestana = 0;

  final controladorNombre = TextEditingController();
  final controladorCodigoProceso = TextEditingController();
  final controladorMetaPoa = TextEditingController();
  final controladorItemPac = TextEditingController();

  final controladorPresupuesto = TextEditingController();
  final controladorCertificado = TextEditingController();
  final controladorComprometido = TextEditingController();
  final controladorDevengado = TextEditingController();
  final controladorPagado = TextEditingController();

  final controladorFormaPago = TextEditingController();
  final controladorAvanceFisico = TextEditingController(text: '0');

  final controladorReferenciaUbicacion = TextEditingController();
  final controladorCoordenadas = TextEditingController();

  final controladorDescripcionIa = TextEditingController();
  final controladorPreguntaIa = TextEditingController();

  final List<_FilaPartida> filasPartidas = [];
  final List<_FilaPago> filasPagos = [];
  final List<_MensajeChat> mensajesChat = [];

  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now().add(const Duration(days: 30));

  String etapaSeleccionada = 'Preparatoria';

  bool incluirUbicacion = false;
  TipoGeometriaProyecto tipoGeometria =
      TipoGeometriaProyecto.punto;

  PlatformFile? archivoPdfSeleccionado;

  bool estaGuardando = false;
  bool estaAnalizandoDocumento = false;
  bool estaConsultando = false;

  @override
  void initState() {
    super.initState();

    _agregarPartida(notificar: false);

    mensajesChat.add(
      _MensajeChat(
        texto:
            'Hola. Soy MuniIA. Puedo responder consultas usando únicamente '
            'los proyectos visibles para tu rol.',
        esUsuario: false,
      ),
    );

    if (!widget.controladorSesion.puedeRegistrarProyectos) {
      indicePestana = 2;
    }
  }

  @override
  void dispose() {
    controladorNombre.dispose();
    controladorCodigoProceso.dispose();
    controladorMetaPoa.dispose();
    controladorItemPac.dispose();

    controladorPresupuesto.dispose();
    controladorCertificado.dispose();
    controladorComprometido.dispose();
    controladorDevengado.dispose();
    controladorPagado.dispose();

    controladorFormaPago.dispose();
    controladorAvanceFisico.dispose();

    controladorReferenciaUbicacion.dispose();
    controladorCoordenadas.dispose();

    controladorDescripcionIa.dispose();
    controladorPreguntaIa.dispose();

    for (final fila in filasPartidas) {
      fila.dispose();
    }

    for (final fila in filasPagos) {
      fila.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puedeRegistrar =
        widget.controladorSesion.puedeRegistrarProyectos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                puedeRegistrar
                    ? 'Registro de proyecto con MuniIA'
                    : 'MuniIA institucional',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                puedeRegistrar
                    ? 'Registra proyectos manualmente o utiliza MuniIA para extraer información desde texto o PDF.'
                    : 'Consulta proyectos, alertas y ejecución usando únicamente los datos autorizados para tu rol.',
                style: const TextStyle(
                  color: ColoresRio.textoSecundario,
                ),
              ),
              const SizedBox(height: 24),
              _selectorPestanas(),
              const SizedBox(height: 20),
              _contenidoPestana(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectorPestanas() {
    final opciones = [
      (
        titulo: 'Formulario manual',
        icono: Icons.assignment_outlined,
      ),
      (
        titulo: 'Texto o PDF',
        icono: Icons.auto_awesome_outlined,
      ),
      (
        titulo: 'Consultar MuniIA',
        icono: Icons.chat_bubble_outline,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(opciones.length, (indice) {
        final opcion = opciones[indice];
        final estaSeleccionada = indicePestana == indice;

        return ChoiceChip(
          selected: estaSeleccionada,
          onSelected: (_) {
            setState(() {
              indicePestana = indice;
            });
          },
          avatar: Icon(
            opcion.icono,
            size: 18,
            color: estaSeleccionada
                ? Colors.white
                : ColoresRio.azulProfundo,
          ),
          label: Text(opcion.titulo),
          labelStyle: TextStyle(
            color: estaSeleccionada
                ? Colors.white
                : ColoresRio.texto,
            fontWeight: FontWeight.w800,
          ),
          selectedColor: ColoresRio.azulProfundo,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: estaSeleccionada
                ? ColoresRio.azulProfundo
                : ColoresRio.borde,
          ),
        );
      }),
    );
  }

  Widget _contenidoPestana() {
    switch (indicePestana) {
      case 0:
        if (!widget.controladorSesion.puedeRegistrarProyectos) {
          return _panelAccesoRestringido(
            titulo: 'Registro restringido',
            mensaje:
                'El formulario manual está disponible únicamente para Directores de Gestión.',
          );
        }

        return _formularioManual();

      case 1:
        if (!widget.controladorSesion.puedeRegistrarProyectos) {
          return _panelAccesoRestringido(
            titulo: 'Asistencia de registro restringida',
            mensaje:
                'La carga de propuestas y generación de borradores está disponible únicamente para Directores de Gestión.',
          );
        }

        return _asistirConTextoPdf();

      case 2:
      default:
        return _consultaMuniIa();
    }
  }

  Widget _panelAccesoRestringido({
    required String titulo,
    required String mensaje,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: _decoracionPanel(),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline,
            color: ColoresRio.rojo,
            size: 46,
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColoresRio.textoSecundario,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Puedes usar la pestaña “Consultar MuniIA” para analizar los datos visibles en tu alcance institucional.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColoresRio.azulProfundo,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formularioManual() {
    return Form(
      key: claveFormulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelGeneral(),
          const SizedBox(height: 18),
          _panelFinanciero(),
          const SizedBox(height: 18),
          _panelPartidas(),
          const SizedBox(height: 18),
          _panelPagos(),
          const SizedBox(height: 18),
          _panelTerritorial(),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: estaGuardando ? null : _guardarProyectoManual,
              icon: estaGuardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                estaGuardando
                    ? 'Guardando en Firestore...'
                    : 'Guardar proyecto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelGeneral() {
    return _panelSeccion(
      titulo: 'Información general',
      subtitulo:
          'La Dirección responsable se asigna automáticamente según el usuario autenticado.',
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final anchoCampo = restricciones.maxWidth >= 800
              ? (restricciones.maxWidth - 16) / 2
              : restricciones.maxWidth;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _campoTexto(
                ancho: anchoCampo,
                etiqueta: 'Nombre del proyecto',
                controlador: controladorNombre,
              ),
              _campoTexto(
                ancho: anchoCampo,
                etiqueta: 'Código del proceso',
                controlador: controladorCodigoProceso,
              ),
              _campoTexto(
                ancho: anchoCampo,
                etiqueta: 'Meta POA',
                controlador: controladorMetaPoa,
              ),
              _campoTexto(
                ancho: anchoCampo,
                etiqueta: 'Ítem PAC',
                controlador: controladorItemPac,
              ),
              SizedBox(
                width: anchoCampo,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Dirección responsable',
                  ),
                  child: Text(
                    widget.controladorSesion.direccionDirector,
                    style: const TextStyle(
                      color: ColoresRio.azulProfundo,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(
                    'etapa-$etapaSeleccionada',
                  ),
                  initialValue: etapaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Etapa contractual',
                  ),
                  items: const [
                    'Preparatoria',
                    'Precontractual',
                    'Contractual',
                    'Ejecución',
                    'Cierre',
                  ]
                      .map(
                        (etapa) => DropdownMenuItem(
                          value: etapa,
                          child: Text(etapa),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    setState(() {
                      etapaSeleccionada =
                          valor ?? 'Preparatoria';
                    });
                  },
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _campoFecha(
                  etiqueta: 'Fecha de inicio',
                  fecha: fechaInicio,
                  alSeleccionar: () {
                    _seleccionarFecha(
                      fechaActual: fechaInicio,
                      alConfirmar: (fecha) {
                        setState(() {
                          fechaInicio = fecha;
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: anchoCampo,
                child: _campoFecha(
                  etiqueta: 'Fecha de finalización',
                  fecha: fechaFin,
                  alSeleccionar: () {
                    _seleccionarFecha(
                      fechaActual: fechaFin,
                      alConfirmar: (fecha) {
                        setState(() {
                          fechaFin = fecha;
                        });
                      },
                    );
                  },
                ),
              ),
              _campoTexto(
                ancho: anchoCampo,
                etiqueta: 'Forma de pago',
                controlador: controladorFormaPago,
                ejemplo: 'Ejemplo: anticipo y pagos por avance',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _panelFinanciero() {
    return _panelSeccion(
      titulo: 'Cadena presupuestaria',
      subtitulo:
          'Debe cumplir: presupuesto ≥ certificado ≥ comprometido ≥ devengado ≥ pagado.',
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final columnas = restricciones.maxWidth >= 1050
              ? 5
              : restricciones.maxWidth >= 680
                  ? 2
                  : 1;

          final anchoCampo =
              (restricciones.maxWidth - ((columnas - 1) * 16)) /
                  columnas;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _campoMonto(
                ancho: anchoCampo,
                etiqueta: 'Presupuesto asignado',
                controlador: controladorPresupuesto,
              ),
              _campoMonto(
                ancho: anchoCampo,
                etiqueta: 'Certificado',
                controlador: controladorCertificado,
              ),
              _campoMonto(
                ancho: anchoCampo,
                etiqueta: 'Comprometido',
                controlador: controladorComprometido,
              ),
              _campoMonto(
                ancho: anchoCampo,
                etiqueta: 'Devengado',
                controlador: controladorDevengado,
              ),
              _campoMonto(
                ancho: anchoCampo,
                etiqueta: 'Pagado',
                controlador: controladorPagado,
              ),
              _campoMonto(
                ancho: anchoCampo,
                etiqueta: 'Avance físico (%)',
                controlador: controladorAvanceFisico,
                esPorcentaje: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _panelPartidas() {
    return _panelSeccion(
      titulo: 'Partidas presupuestarias',
      subtitulo:
          'La suma de las partidas debe coincidir con el presupuesto asignado.',
      child: Column(
        children: [
          ...filasPartidas.asMap().entries.map((entrada) {
            return _filaPartida(
              indice: entrada.key,
              fila: entrada.value,
            );
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _agregarPartida,
              icon: const Icon(Icons.add),
              label: const Text('Agregar partida'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaPartida({
    required int indice,
    required _FilaPartida fila,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresRio.fondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final anchoCampo = restricciones.maxWidth >= 850
              ? (restricciones.maxWidth - 48) / 3
              : restricciones.maxWidth;

          return Column(
            children: [
              Row(
                children: [
                  Text(
                    'Partida ${indice + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Eliminar partida',
                    onPressed: filasPartidas.length == 1
                        ? null
                        : () {
                            setState(() {
                              fila.dispose();
                              filasPartidas.removeAt(indice);
                            });
                          },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: ColoresRio.rojo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _campoTexto(
                    ancho: anchoCampo,
                    etiqueta: 'Código',
                    controlador: fila.controladorCodigo,
                    obligatorio: false,
                  ),
                  _campoTexto(
                    ancho: anchoCampo,
                    etiqueta: 'Denominación',
                    controlador: fila.controladorDenominacion,
                    obligatorio: false,
                  ),
                  _campoMonto(
                    ancho: anchoCampo,
                    etiqueta: 'Monto',
                    controlador: fila.controladorMonto,
                    obligatorio: false,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _panelPagos() {
    return _panelSeccion(
      titulo: 'Hitos y pagos',
      subtitulo:
          'Registra pagos planificados para generar alertas preventivas de atraso.',
      child: Column(
        children: [
          if (filasPagos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Todavía no se han agregado hitos de pago.',
                style: TextStyle(
                  color: ColoresRio.textoSecundario,
                ),
              ),
            ),
          ...filasPagos.asMap().entries.map((entrada) {
            return _filaPago(
              indice: entrada.key,
              fila: entrada.value,
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _agregarPago,
              icon: const Icon(Icons.add),
              label: const Text('Agregar hito de pago'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaPago({
    required int indice,
    required _FilaPago fila,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresRio.fondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Hito ${indice + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Eliminar hito',
                onPressed: () {
                  setState(() {
                    fila.dispose();
                    filasPagos.removeAt(indice);
                  });
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: ColoresRio.rojo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, restricciones) {
              final anchoCampo = restricciones.maxWidth >= 850
                  ? (restricciones.maxWidth - 32) / 2
                  : restricciones.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _campoTexto(
                    ancho: anchoCampo,
                    etiqueta: 'Descripción del hito',
                    controlador: fila.controladorHito,
                    obligatorio: false,
                  ),
                  _campoMonto(
                    ancho: anchoCampo,
                    etiqueta: 'Monto planificado',
                    controlador: fila.controladorMonto,
                    obligatorio: false,
                  ),
                  SizedBox(
                    width: anchoCampo,
                    child: _campoFecha(
                      etiqueta: 'Fecha prevista',
                      fecha: fila.fechaPrevista,
                      alSeleccionar: () {
                        _seleccionarFecha(
                          fechaActual: fila.fechaPrevista,
                          alConfirmar: (fecha) {
                            setState(() {
                              fila.fechaPrevista = fecha;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: anchoCampo,
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      title: const Text('Pago realizado'),
                      value: fila.estaPagado,
                      onChanged: (valor) {
                        setState(() {
                          fila.estaPagado = valor;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _panelTerritorial() {
    return _panelSeccion(
      titulo: 'Ubicación territorial',
      subtitulo:
          'Permite reflejar el proyecto en el mapa territorial del sistema.',
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Registrar ubicación en el mapa',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Activa esta opción para usar punto, línea o área.',
            ),
            value: incluirUbicacion,
            onChanged: (valor) {
              setState(() {
                incluirUbicacion = valor;
              });
            },
          ),
          if (incluirUbicacion) ...[
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, restricciones) {
                final anchoCampo = restricciones.maxWidth >= 800
                    ? (restricciones.maxWidth - 16) / 2
                    : restricciones.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _campoTexto(
                      ancho: anchoCampo,
                      etiqueta: 'Referencia de ubicación',
                      controlador: controladorReferenciaUbicacion,
                    ),
                    SizedBox(
                      width: anchoCampo,
                      child: DropdownButtonFormField<TipoGeometriaProyecto>(
                        key: ValueKey(
                          'geometria-${tipoGeometria.name}',
                        ),
                        initialValue: tipoGeometria,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de geometría',
                        ),
                        items: TipoGeometriaProyecto.values
                            .map(
                              (tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo.etiqueta),
                              ),
                            )
                            .toList(),
                        onChanged: (valor) {
                          setState(() {
                            tipoGeometria =
                                valor ?? TipoGeometriaProyecto.punto;
                          });
                        },
                      ),
                    ),
                    _campoTexto(
                      ancho: restricciones.maxWidth,
                      etiqueta: 'Coordenadas',
                      controlador: controladorCoordenadas,
                      ejemplo:
                          'Ejemplo: -1.6702,-78.6471; -1.6710,-78.6480',
                      maxLineas: 2,
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _asistirConTextoPdf() {
    return _panelSeccion(
      titulo: 'Asistir con texto o PDF',
      subtitulo:
          'MuniIA extrae un borrador. El usuario debe revisar y validar los campos antes de guardar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controladorDescripcionIa,
            minLines: 7,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Descripción o contenido de la propuesta',
              hintText:
                  'Pega aquí el texto de la propuesta, necesidad institucional o descripción de la obra.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 18),
          _panelArchivoPdf(),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: estaAnalizandoDocumento
                    ? null
                    : _analizarConMuniIa,
                icon: estaAnalizandoDocumento
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  estaAnalizandoDocumento
                      ? 'Analizando propuesta...'
                      : 'Generar borrador con MuniIA',
                ),
              ),
              OutlinedButton.icon(
                onPressed: estaAnalizandoDocumento
                    ? null
                    : _limpiarAsistencia,
                icon: const Icon(Icons.refresh),
                label: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColoresRio.naranja.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColoresRio.naranja.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF9A5B00),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Los Excel y CSV financieros se cargan desde Importación financiera. Esta pestaña es para texto o PDF de propuestas.',
                    style: TextStyle(
                      color: Color(0xFF805000),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelArchivoPdf() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresRio.fondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final informacion = archivoPdfSeleccionado == null
              ? const Text(
                  'No se ha seleccionado un PDF.',
                  style: TextStyle(
                    color: ColoresRio.textoSecundario,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      archivoPdfSeleccionado!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatearTamano(
                        archivoPdfSeleccionado!.size,
                      ),
                      style: const TextStyle(
                        color: ColoresRio.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );

          final boton = OutlinedButton.icon(
            onPressed: _seleccionarPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              archivoPdfSeleccionado == null
                  ? 'Seleccionar PDF'
                  : 'Cambiar PDF',
            ),
          );

          if (restricciones.maxWidth < 650) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                informacion,
                const SizedBox(height: 14),
                boton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: informacion),
              const SizedBox(width: 16),
              boton,
            ],
          );
        },
      ),
    );
  }

  Widget _consultaMuniIa() {
    return _panelSeccion(
      titulo: 'Consultar a MuniIA',
      subtitulo:
          'Las respuestas se basan únicamente en los proyectos visibles para el rol autenticado.',
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _preguntaRapida(
                '¿Qué proyectos tienen pagos vencidos?',
              ),
              _preguntaRapida(
                '¿Cuál tiene mayor atraso?',
              ),
              _preguntaRapida(
                '¿Cuál es la ejecución actual?',
              ),
              _preguntaRapida(
                '¿Qué proyectos están en ejecución?',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            height: 380,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColoresRio.fondo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColoresRio.borde),
            ),
            child: ListView.separated(
              itemCount: mensajesChat.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, indice) {
                final mensaje = mensajesChat[indice];

                return Align(
                  alignment: mensaje.esUsuario
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: mensaje.esUsuario
                          ? ColoresRio.azulProfundo
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: mensaje.esUsuario
                          ? null
                          : Border.all(
                              color: ColoresRio.borde,
                            ),
                    ),
                    child: Text(
                      mensaje.texto,
                      style: TextStyle(
                        color: mensaje.esUsuario
                            ? Colors.white
                            : ColoresRio.texto,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controladorPreguntaIa,
                  enabled: !estaConsultando,
                  onSubmitted: (_) => _consultarMuniIa(),
                  decoration: const InputDecoration(
                    hintText:
                        'Escribe una consulta sobre proyectos, pagos, ejecución o alertas.',
                    prefixIcon: Icon(
                      Icons.chat_bubble_outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed:
                    estaConsultando ? null : _consultarMuniIa,
                child: estaConsultando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _preguntaRapida(String texto) {
    return ActionChip(
      avatar: const Icon(
        Icons.auto_awesome,
        size: 16,
        color: ColoresRio.azulProfundo,
      ),
      label: Text(texto),
      onPressed: estaConsultando
          ? null
          : () {
              controladorPreguntaIa.text = texto;
              _consultarMuniIa();
            },
    );
  }

  Widget _panelSeccion({
    required String titulo,
    required String subtitulo,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _decoracionPanel(),
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
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _campoTexto({
    required double ancho,
    required String etiqueta,
    required TextEditingController controlador,
    String? ejemplo,
    bool obligatorio = true,
    int maxLineas = 1,
  }) {
    return SizedBox(
      width: ancho,
      child: TextFormField(
        controller: controlador,
        maxLines: maxLineas,
        validator: obligatorio
            ? (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Campo obligatorio';
                }

                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: ejemplo,
        ),
      ),
    );
  }

  Widget _campoMonto({
    required double ancho,
    required String etiqueta,
    required TextEditingController controlador,
    bool obligatorio = true,
    bool esPorcentaje = false,
  }) {
    return SizedBox(
      width: ancho,
      child: TextFormField(
        controller: controlador,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        validator: obligatorio
            ? (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Campo obligatorio';
                }

                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixText: esPorcentaje ? null : 'USD ',
          suffixText: esPorcentaje ? '%' : null,
        ),
      ),
    );
  }

  Widget _campoFecha({
    required String etiqueta,
    required DateTime fecha,
    required VoidCallback alSeleccionar,
  }) {
    return InkWell(
      onTap: alSeleccionar,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
          ),
        ),
        child: Text(
          _formatearFecha(fecha),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha({
    required DateTime fechaActual,
    required ValueChanged<DateTime> alConfirmar,
  }) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaActual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (fecha != null) {
      alConfirmar(fecha);
    }
  }

  void _agregarPartida({
    bool notificar = true,
  }) {
    final fila = _FilaPartida();

    if (notificar) {
      setState(() {
        filasPartidas.add(fila);
      });
      return;
    }

    filasPartidas.add(fila);
  }

  void _agregarPago() {
    setState(() {
      filasPagos.add(
        _FilaPago(
          fechaPrevista:
              DateTime.now().add(const Duration(days: 30)),
        ),
      );
    });
  }

  Future<void> _guardarProyectoManual() async {
    if (!claveFormulario.currentState!.validate()) {
      return;
    }

    try {
      final presupuesto = _leerMonto(
        controladorPresupuesto.text,
        'Presupuesto asignado',
      );

      final certificado = _leerMonto(
        controladorCertificado.text,
        'Certificado',
      );

      final comprometido = _leerMonto(
        controladorComprometido.text,
        'Comprometido',
      );

      final devengado = _leerMonto(
        controladorDevengado.text,
        'Devengado',
      );

      final pagado = _leerMonto(
        controladorPagado.text,
        'Pagado',
      );

      final avanceFisico = _leerMonto(
        controladorAvanceFisico.text,
        'Avance físico',
      );

      if (avanceFisico < 0 || avanceFisico > 100) {
        throw Exception(
          'El avance físico debe estar entre 0 y 100.',
        );
      }

      if (!(presupuesto >= certificado &&
          certificado >= comprometido &&
          comprometido >= devengado &&
          devengado >= pagado)) {
        throw Exception(
          'La cadena presupuestaria debe cumplir: presupuesto ≥ certificado ≥ comprometido ≥ devengado ≥ pagado.',
        );
      }

      if (fechaFin.isBefore(fechaInicio)) {
        throw Exception(
          'La fecha de finalización no puede ser anterior a la fecha de inicio.',
        );
      }

      final partidas = _crearPartidas();

      final totalPartidas = partidas.fold(
        0.0,
        (total, partida) => total + partida.monto,
      );

      if ((totalPartidas - presupuesto).abs() > 0.01) {
        throw Exception(
          'La suma de partidas debe coincidir con el presupuesto asignado.',
        );
      }

      final pagos = _crearPagos();

      final totalPagos = pagos.fold(
        0.0,
        (total, pago) => total + pago.monto,
      );

      if (totalPagos > presupuesto) {
        throw Exception(
          'La suma de pagos no puede superar el presupuesto asignado.',
        );
      }

      final ubicacion = _crearUbicacion();

      final proyecto = ProyectoModelo(
        id: 'PRY-${DateTime.now().millisecondsSinceEpoch}',
        nombre: controladorNombre.text.trim(),
        codigoProceso: controladorCodigoProceso.text.trim(),
        direccion: widget.controladorSesion.direccionDirector,
        poaMeta: controladorMetaPoa.text.trim(),
        pacItem: controladorItemPac.text.trim(),
        etapa: etapaSeleccionada,
        presupuestoAsignado: presupuesto,
        certificado: certificado,
        comprometido: comprometido,
        devengado: devengado,
        pagado: pagado,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        formaPago: controladorFormaPago.text.trim(),
        partidas: partidas,
        pagos: pagos,
        ubicacion: ubicacion,
        porcentajeAvanceFisico: avanceFisico / 100,
        fechaActualizacionFisica: DateTime.now(),
      );

      setState(() {
        estaGuardando = true;
      });

      await widget.controlador.guardarProyecto(proyecto);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Proyecto guardado correctamente en Firestore.',
          ),
        ),
      );

      widget.alAbrirProyectos();
    } catch (error) {
      if (!mounted) {
        return;
      }

      final mensaje = error
          .toString()
          .replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          estaGuardando = false;
        });
      }
    }
  }

  List<PartidaModelo> _crearPartidas() {
    final partidas = <PartidaModelo>[];

    for (final fila in filasPartidas) {
      final codigo = fila.controladorCodigo.text.trim();
      final denominacion =
          fila.controladorDenominacion.text.trim();
      final montoTexto = fila.controladorMonto.text.trim();

      if (codigo.isEmpty &&
          denominacion.isEmpty &&
          montoTexto.isEmpty) {
        continue;
      }

      if (codigo.isEmpty ||
          denominacion.isEmpty ||
          montoTexto.isEmpty) {
        throw Exception(
          'Completa código, denominación y monto de cada partida.',
        );
      }

      partidas.add(
        PartidaModelo(
          codigo: codigo,
          denominacion: denominacion,
          monto: _leerMonto(
            montoTexto,
            'Monto de partida',
          ),
        ),
      );
    }

    if (partidas.isEmpty) {
      throw Exception(
        'Debes registrar al menos una partida presupuestaria.',
      );
    }

    return partidas;
  }

  List<PagoModelo> _crearPagos() {
    final pagos = <PagoModelo>[];

    for (var indice = 0; indice < filasPagos.length; indice++) {
      final fila = filasPagos[indice];

      final hito = fila.controladorHito.text.trim();
      final montoTexto = fila.controladorMonto.text.trim();

      if (hito.isEmpty && montoTexto.isEmpty) {
        continue;
      }

      if (hito.isEmpty || montoTexto.isEmpty) {
        throw Exception(
          'Completa la descripción y monto de cada hito de pago.',
        );
      }

      pagos.add(
        PagoModelo(
          id: 'PAG-${DateTime.now().millisecondsSinceEpoch}-$indice',
          hito: hito,
          monto: _leerMonto(
            montoTexto,
            'Monto de pago',
          ),
          fechaPrevista: fila.fechaPrevista,
          estaPagado: fila.estaPagado,
        ),
      );
    }

    return pagos;
  }

  UbicacionProyectoModelo? _crearUbicacion() {
    if (!incluirUbicacion) {
      return null;
    }

    final referencia =
        controladorReferenciaUbicacion.text.trim();

    if (referencia.isEmpty) {
      throw Exception(
        'Ingresa una referencia para la ubicación territorial.',
      );
    }

    final coordenadas = _leerCoordenadas();

    final minimoRequerido = switch (tipoGeometria) {
      TipoGeometriaProyecto.punto => 1,
      TipoGeometriaProyecto.linea => 2,
      TipoGeometriaProyecto.area => 3,
    };

    if (coordenadas.length < minimoRequerido) {
      throw Exception(
        'La geometría seleccionada requiere al menos $minimoRequerido coordenada(s).',
      );
    }

    return UbicacionProyectoModelo(
      tipoGeometria: tipoGeometria,
      referenciaUbicacion: referencia,
      coordenadas: coordenadas,
    );
  }

  List<CoordenadaModelo> _leerCoordenadas() {
    final texto = controladorCoordenadas.text.trim();

    if (texto.isEmpty) {
      throw Exception(
        'Ingresa las coordenadas para ubicar el proyecto.',
      );
    }

    final coordenadas = <CoordenadaModelo>[];

    final puntos = texto.split(';');

    for (final punto in puntos) {
      final valores = punto.trim().split(',');

      if (valores.length != 2) {
        throw Exception(
          'Usa el formato: latitud,longitud; latitud,longitud',
        );
      }

      final latitud = double.tryParse(valores[0].trim());
      final longitud = double.tryParse(valores[1].trim());

      if (latitud == null || longitud == null) {
        throw Exception(
          'Las coordenadas deben contener valores numéricos válidos.',
        );
      }

      coordenadas.add(
        CoordenadaModelo(
          latitud: latitud,
          longitud: longitud,
        ),
      );
    }

    return coordenadas;
  }

  double _leerMonto(
    String texto,
    String etiqueta,
  ) {
    var limpio = texto
        .replaceAll('USD', '')
        .replaceAll('\$', '')
        .replaceAll(' ', '');

    if (limpio.contains('.') && limpio.contains(',')) {
      limpio = limpio.replaceAll('.', '').replaceAll(',', '.');
    } else {
      limpio = limpio.replaceAll(',', '.');
    }

    final valor = double.tryParse(limpio);

    if (valor == null || valor < 0) {
      throw Exception(
        '$etiqueta debe ser un número válido.',
      );
    }

    return valor;
  }

  Future<void> _seleccionarPdf() async {
    final resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) {
      return;
    }

    final archivo = resultado.files.single;

    if (archivo.bytes == null) {
      _mostrarError(
        'No fue posible leer el PDF seleccionado.',
      );
      return;
    }

    const limiteBytes = 12 * 1024 * 1024;

    if (archivo.size > limiteBytes) {
      _mostrarError(
        'El PDF debe tener un tamaño máximo de 12 MB.',
      );
      return;
    }

    setState(() {
      archivoPdfSeleccionado = archivo;
    });
  }

  Future<void> _analizarConMuniIa() async {
  final texto = controladorDescripcionIa.text.trim();

  if (texto.isEmpty && archivoPdfSeleccionado == null) {
    _mostrarError(
      'Escribe una descripción o selecciona un PDF.',
    );
    return;
  }

  final bytes = archivoPdfSeleccionado?.bytes;

  setState(() {
    estaAnalizandoDocumento = true;
  });

  try {
    final borrador = await servicioMuniIa.extraerBorradorProyecto(
      descripcion: texto,
      archivoPdf: bytes,
    );

    _aplicarBorrador(borrador);

    if (!mounted) {
      return;
    }

    setState(() {
      indicePestana = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'MuniIA generó el borrador con '
          '${borrador.partidas.length} partida(s) y '
          '${borrador.pagos.length} hito(s) de pago. '
          'Revisa la información antes de guardar.',
        ),
      ),
    );
  } catch (error) {
    if (mounted) {
      _mostrarError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        estaAnalizandoDocumento = false;
      });
    }
  }
}

  void _aplicarBorrador(
    BorradorProyectoIaModelo borrador,
  ) {
    if (borrador.nombre != null) {
      controladorNombre.text = borrador.nombre!;
    }

    if (borrador.codigoProceso != null) {
      controladorCodigoProceso.text = borrador.codigoProceso!;
    }

    if (borrador.poaMeta != null) {
      controladorMetaPoa.text = borrador.poaMeta!;
    }

    if (borrador.pacItem != null) {
      controladorItemPac.text = borrador.pacItem!;
    }

    if (borrador.etapa != null &&
        [
          'Preparatoria',
          'Precontractual',
          'Contractual',
          'Ejecución',
          'Cierre',
        ].contains(borrador.etapa)) {
      etapaSeleccionada = borrador.etapa!;
    }

    _aplicarMonto(
      controladorPresupuesto,
      borrador.presupuestoAsignado,
    );

    _aplicarMonto(
      controladorCertificado,
      borrador.certificado,
    );

    _aplicarMonto(
      controladorComprometido,
      borrador.comprometido,
    );

    _aplicarMonto(
      controladorDevengado,
      borrador.devengado,
    );

    _aplicarMonto(
      controladorPagado,
      borrador.pagado,
    );

    if (borrador.formaPago != null) {
      controladorFormaPago.text = borrador.formaPago!;
    }

    if (borrador.avanceFisico != null) {
      controladorAvanceFisico.text =
          borrador.avanceFisico!.toStringAsFixed(0);
    }

    final fechaInicioIa = _convertirFechaTexto(
      borrador.fechaInicio,
    );

    final fechaFinIa = _convertirFechaTexto(
      borrador.fechaFin,
    );

    if (fechaInicioIa != null) {
      fechaInicio = fechaInicioIa;
    }

    if (fechaFinIa != null) {
      fechaFin = fechaFinIa;
    }

    if (borrador.referenciaUbicacion != null) {
      incluirUbicacion = true;

      controladorReferenciaUbicacion.text =
          borrador.referenciaUbicacion!;
    }

    if (borrador.latitud != null &&
        borrador.longitud != null) {
      incluirUbicacion = true;

      controladorCoordenadas.text =
          '${borrador.latitud},${borrador.longitud}';
    }

    switch (borrador.tipoGeometria) {
      case 'linea':
        tipoGeometria = TipoGeometriaProyecto.linea;
        break;

      case 'area':
        tipoGeometria = TipoGeometriaProyecto.area;
        break;

      case 'punto':
      default:
        tipoGeometria = TipoGeometriaProyecto.punto;
        break;
    }

    _aplicarPartidasIa(borrador.partidas);
    _aplicarPagosIa(borrador.pagos);

    setState(() {});
  }

  void _aplicarPartidasIa(
    List<PartidaBorradorIaModelo> partidasIa,
  ) {
    for (final fila in filasPartidas) {
      fila.dispose();
    }

    filasPartidas.clear();

    if (partidasIa.isEmpty) {
      _agregarPartida(notificar: false);
      return;
    }

    for (final partida in partidasIa) {
      final fila = _FilaPartida();

      fila.controladorCodigo.text = partida.codigo ?? '';
      fila.controladorDenominacion.text =
          partida.denominacion ?? '';

      if (partida.monto != null) {
        fila.controladorMonto.text =
            partida.monto!.toStringAsFixed(2);
      }

      filasPartidas.add(fila);
    }
  }

  void _aplicarPagosIa(
    List<PagoBorradorIaModelo> pagosIa,
  ) {
    for (final fila in filasPagos) {
      fila.dispose();
    }

    filasPagos.clear();

    for (final pago in pagosIa) {
      final fechaPago = _convertirFechaTexto(
            pago.fechaPrevista,
          ) ??
          DateTime.now().add(
            const Duration(days: 30),
          );

      final fila = _FilaPago(
        fechaPrevista: fechaPago,
        estaPagado: pago.estaPagado ?? false,
      );

      fila.controladorHito.text = pago.hito ?? '';

      if (pago.monto != null) {
        fila.controladorMonto.text =
            pago.monto!.toStringAsFixed(2);
      }

      filasPagos.add(fila);
    }
  }

  void _aplicarMonto(
    TextEditingController controlador,
    double? valor,
  ) {
    if (valor == null) {
      return;
    }

    controlador.text = valor.toStringAsFixed(2);
  }

  DateTime? _convertirFechaTexto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }

    final fechaIso = DateTime.tryParse(valor);

    if (fechaIso != null) {
      return fechaIso;
    }

    final partes = valor.split('/');

    if (partes.length == 3) {
      final dia = int.tryParse(partes[0]) ?? 1;
      final mes = int.tryParse(partes[1]) ?? 1;
      final anio = int.tryParse(partes[2]);

      if (anio != null) {
        return DateTime(anio, mes, dia);
      }
    }

    return null;
  }

  void _limpiarAsistencia() {
    setState(() {
      controladorDescripcionIa.clear();
      archivoPdfSeleccionado = null;
    });
  }

  Future<void> _consultarMuniIa() async {
    final pregunta = controladorPreguntaIa.text.trim();

    if (pregunta.isEmpty) {
      return;
    }

    setState(() {
      mensajesChat.add(
        _MensajeChat(
          texto: pregunta,
          esUsuario: true,
        ),
      );

      controladorPreguntaIa.clear();
      estaConsultando = true;
    });

    final respuesta = await servicioMuniIa.responderConsulta(
      pregunta: pregunta,
      proyectosVisibles: widget.controlador.proyectos,
      alcance: widget.controladorSesion.alcanceActual,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      mensajesChat.add(
        _MensajeChat(
          texto: respuesta,
          esUsuario: false,
        ),
      );

      estaConsultando = false;
    });
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _formatearTamano(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  BoxDecoration _decoracionPanel() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: ColoresRio.borde,
      ),
    );
  }
}

class _FilaPartida {
  final controladorCodigo = TextEditingController();
  final controladorDenominacion = TextEditingController();
  final controladorMonto = TextEditingController();

  void dispose() {
    controladorCodigo.dispose();
    controladorDenominacion.dispose();
    controladorMonto.dispose();
  }
}

class _FilaPago {
  final controladorHito = TextEditingController();
  final controladorMonto = TextEditingController();

  DateTime fechaPrevista;
  bool estaPagado;

  _FilaPago({
    required this.fechaPrevista,
    this.estaPagado = false,
  });

  void dispose() {
    controladorHito.dispose();
    controladorMonto.dispose();
  }
}

class _MensajeChat {
  final String texto;
  final bool esUsuario;

  const _MensajeChat({
    required this.texto,
    required this.esUsuario,
  });
}