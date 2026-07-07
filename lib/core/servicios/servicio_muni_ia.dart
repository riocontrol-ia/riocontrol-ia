import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../../features/registro_inteligente/dominio/borrador_proyecto_ia_modelo.dart';

class ServicioMuniIa {
  static const String _modeloNombre = 'gemini-3.5-flash';

  Future<BorradorProyectoIaModelo> extraerBorradorProyecto({
    required String descripcion,
    Uint8List? archivoPdf,
  }) async {
    final modelo = FirebaseAI.googleAI().generativeModel(
      model: _modeloNombre,
      generationConfig: GenerationConfig(
        temperature: 0,
        maxOutputTokens: 3500,
      ),
    );

    final instruccion = '''
Eres MuniIA, asistente institucional para registrar proyectos municipales.

Analiza únicamente el texto o PDF recibido.
Extrae solo información que esté escrita de forma explícita.
No inventes valores, códigos, fechas, partidas, pagos, porcentajes ni ubicaciones.

No uses JSON.
No uses markdown.
No agregues explicaciones antes o después de la respuesta.

Devuelve exactamente estas secciones:

[GENERAL]
NOMBRE=valor
CODIGO_PROCESO=valor
POA_META=valor
PAC_ITEM=valor
ETAPA=valor
PRESUPUESTO_ASIGNADO=valor
CERTIFICADO=valor
COMPROMETIDO=valor
DEVENGADO=valor
PAGADO=valor
FECHA_INICIO=YYYY-MM-DD
FECHA_FIN=YYYY-MM-DD
FORMA_PAGO=valor
AVANCE_FISICO=valor
REFERENCIA_UBICACION=valor
TIPO_GEOMETRIA=valor
LATITUD=valor
LONGITUD=valor

[PARTIDAS]
codigo;denominacion;monto

[PAGOS]
hito;monto;fechaPrevista;estado

Reglas:
- Si un dato no está escrito, deja vacío el valor.
- Los montos deben ser números sin símbolos monetarios.
- Las fechas deben estar en formato YYYY-MM-DD.
- El avance físico debe estar entre 0 y 100.
- ETAPA solo puede ser: Preparatoria, Precontractual, Contractual, Ejecución o Cierre.
- TIPO_GEOMETRIA solo puede ser: punto, linea o area.
- En estado de pago usa solamente SI o NO.
- En PARTIDAS incluye únicamente partidas que estén escritas explícitamente.
- En PAGOS incluye únicamente hitos que estén escritos explícitamente.
- No escribas encabezados adicionales dentro de PARTIDAS o PAGOS.

Texto adicional del usuario:
${descripcion.trim().isEmpty ? 'No se proporcionó texto adicional.' : descripcion}
''';

    try {
      final respuesta = await modelo.generateContent([
        _crearContenido(
          instruccion,
          archivoPdf,
        ),
      ]);

      final textoRespuesta = respuesta.text?.trim();

      if (textoRespuesta == null || textoRespuesta.isEmpty) {
        throw Exception(
          'MuniIA no devolvió información para generar el borrador.',
        );
      }

      final borrador = _leerBorradorDesdeTexto(textoRespuesta);

      if (!_tieneInformacion(borrador)) {
        final respuestaAlternativa = await _generarRespuestaAlternativa(
          modelo: modelo,
          descripcion: descripcion,
          archivoPdf: archivoPdf,
        );

        final borradorAlternativo =
            _leerBorradorDesdeTexto(respuestaAlternativa);

        if (_tieneInformacion(borradorAlternativo)) {
          return borradorAlternativo;
        }

        throw Exception(
          'MuniIA respondió, pero no pudo identificar datos del proyecto. '
          'Vista de respuesta: ${_resumirRespuesta(textoRespuesta)}',
        );
      }

      return borrador;
    } catch (error) {
      throw Exception(
        _obtenerMensajeError(error),
      );
    }
  }

  Future<String> _generarRespuestaAlternativa({
    required GenerativeModel modelo,
    required String descripcion,
    required Uint8List? archivoPdf,
  }) async {
    final instruccion = '''
Analiza el texto o PDF recibido y extrae únicamente los datos del proyecto.

No uses JSON.
No uses tablas.
No uses markdown.

Devuelve cada dato en una línea con el formato CAMPO: VALOR.

Usa solamente estos campos:

NOMBRE:
CODIGO_PROCESO:
POA_META:
PAC_ITEM:
ETAPA:
PRESUPUESTO_ASIGNADO:
CERTIFICADO:
COMPROMETIDO:
DEVENGADO:
PAGADO:
FECHA_INICIO:
FECHA_FIN:
FORMA_PAGO:
AVANCE_FISICO:
REFERENCIA_UBICACION:
TIPO_GEOMETRIA:
LATITUD:
LONGITUD:

Después añade, solo si existen datos:

PARTIDA: codigo | denominacion | monto
PAGO: hito | monto | fecha | SI o NO

No inventes datos.

Texto adicional:
${descripcion.trim().isEmpty ? 'No se proporcionó texto adicional.' : descripcion}
''';

    final respuesta = await modelo.generateContent([
      _crearContenido(
        instruccion,
        archivoPdf,
      ),
    ]);

    return respuesta.text?.trim() ?? '';
  }

  Content _crearContenido(
    String instruccion,
    Uint8List? archivoPdf,
  ) {
    if (archivoPdf == null) {
      return Content.text(instruccion);
    }

    return Content.multi([
      TextPart(instruccion),
      InlineDataPart(
        'application/pdf',
        archivoPdf,
      ),
    ]);
  }

  BorradorProyectoIaModelo _leerBorradorDesdeTexto(
    String respuesta,
  ) {
    final generales = <String, String>{};
    final partidas = <PartidaBorradorIaModelo>[];
    final pagos = <PagoBorradorIaModelo>[];

    var seccionActual = '';

    final lineas = respuesta
        .replaceAll('```', '')
        .replaceAll('\r', '')
        .split('\n');

    for (final lineaOriginal in lineas) {
      var linea = lineaOriginal.trim();

      if (linea.isEmpty) {
        continue;
      }

      linea = linea
          .replaceAll('**', '')
          .replaceAll('`', '')
          .replaceFirst(
            RegExp(r'^[-*•]\s*'),
            '',
          )
          .trim();

      final encabezado = _normalizarTexto(linea);

      if (encabezado == 'GENERAL' ||
          encabezado == 'DATOSGENERALES') {
        seccionActual = 'general';
        continue;
      }

      if (encabezado == 'PARTIDAS' ||
          encabezado == 'PARTIDASPRESUPUESTARIAS') {
        seccionActual = 'partidas';
        continue;
      }

      if (encabezado == 'PAGOS' ||
          encabezado == 'HITOSYPAGOS' ||
          encabezado == 'CRONOGRAMAPAGOS') {
        seccionActual = 'pagos';
        continue;
      }

      if (linea.toUpperCase().startsWith('PARTIDA:')) {
        final contenido = linea.substring('PARTIDA:'.length).trim();

        _agregarPartidaDesdeLinea(
          contenido,
          partidas,
        );

        continue;
      }

      if (linea.toUpperCase().startsWith('PAGO:')) {
        final contenido = linea.substring('PAGO:'.length).trim();

        _agregarPagoDesdeLinea(
          contenido,
          pagos,
        );

        continue;
      }

      if (seccionActual == 'partidas') {
        final fueAgregada = _agregarPartidaDesdeLinea(
          linea,
          partidas,
        );

        if (fueAgregada) {
          continue;
        }
      }

      if (seccionActual == 'pagos') {
        final fueAgregado = _agregarPagoDesdeLinea(
          linea,
          pagos,
        );

        if (fueAgregado) {
          continue;
        }
      }

      final campoValor = _leerCampoValor(linea);

      if (campoValor == null) {
        continue;
      }

      final campoCanonico = _obtenerCampoCanonico(
        campoValor.campo,
      );

      if (campoCanonico == null || campoValor.valor.isEmpty) {
        continue;
      }

      generales[campoCanonico] = campoValor.valor;
    }

    final datos = <String, dynamic>{
      ...generales,
      'partidas': partidas
          .map(
            (partida) => {
              'codigo': partida.codigo,
              'denominacion': partida.denominacion,
              'monto': partida.monto,
            },
          )
          .toList(),
      'pagos': pagos
          .map(
            (pago) => {
              'hito': pago.hito,
              'monto': pago.monto,
              'fechaPrevista': pago.fechaPrevista,
              'estaPagado': pago.estaPagado,
            },
          )
          .toList(),
    };

    return BorradorProyectoIaModelo.desdeJson(datos);
  }

  bool _agregarPartidaDesdeLinea(
    String linea,
    List<PartidaBorradorIaModelo> partidas,
  ) {
    final valores = _separarColumnas(linea);

    if (valores.length < 3) {
      return false;
    }

    final codigo = valores[0];
    final denominacion = valores[1];
    final monto = BorradorProyectoIaModelo.numero(
      valores[2],
    );

    final encabezadoCodigo = _normalizarTexto(codigo);

    if (encabezadoCodigo == 'CODIGO' ||
        encabezadoCodigo == 'PARTIDA' ||
        monto == null ||
        codigo.isEmpty ||
        denominacion.isEmpty) {
      return false;
    }

    partidas.add(
      PartidaBorradorIaModelo(
        codigo: codigo,
        denominacion: denominacion,
        monto: monto,
      ),
    );

    return true;
  }

  bool _agregarPagoDesdeLinea(
    String linea,
    List<PagoBorradorIaModelo> pagos,
  ) {
    final valores = _separarColumnas(linea);

    if (valores.length < 4) {
      return false;
    }

    final hito = valores[0];
    final monto = BorradorProyectoIaModelo.numero(
      valores[1],
    );
    final fecha = valores[2];
    final estado = valores[3];

    final encabezadoHito = _normalizarTexto(hito);

    if (encabezadoHito == 'HITO' ||
        encabezadoHito == 'PAGO' ||
        monto == null ||
        hito.isEmpty ||
        fecha.isEmpty) {
      return false;
    }

    pagos.add(
      PagoBorradorIaModelo(
        hito: hito,
        monto: monto,
        fechaPrevista: fecha,
        estaPagado: BorradorProyectoIaModelo.booleano(
              estado,
            ) ??
            false,
      ),
    );

    return true;
  }

  List<String> _separarColumnas(String linea) {
    String separador = '';

    if (linea.contains(';')) {
      separador = ';';
    } else if (linea.contains('|')) {
      separador = '|';
    } else if (linea.contains('\t')) {
      separador = '\t';
    }

    if (separador.isEmpty) {
      return const [];
    }

    return linea
        .split(separador)
        .map((valor) => valor.trim())
        .where((valor) => valor.isNotEmpty)
        .toList();
  }

  _CampoValor? _leerCampoValor(String linea) {
    final separadores = ['=', ':', '|'];

    for (final separador in separadores) {
      final posicion = linea.indexOf(separador);

      if (posicion <= 0) {
        continue;
      }

      final campo = linea.substring(0, posicion).trim();
      final valor = linea.substring(posicion + 1).trim();

      if (campo.isNotEmpty) {
        return _CampoValor(
          campo: campo,
          valor: valor,
        );
      }
    }

    return null;
  }

  String? _obtenerCampoCanonico(String campo) {
    final normalizado = _normalizarTexto(campo);

    const equivalencias = {
      'NOMBRE': 'nombre',
      'PROYECTO': 'nombre',
      'NOMBREDELPROYECTO': 'nombre',

      'CODIGO': 'codigoProceso',
      'CODIGOPROCESO': 'codigoProceso',
      'CODIGODELPROCESO': 'codigoProceso',

      'POAMETA': 'poaMeta',
      'METAPOA': 'poaMeta',
      'METADELPOA': 'poaMeta',

      'PACITEM': 'pacItem',
      'ITEMPAC': 'pacItem',
      'ITEMDELPAC': 'pacItem',

      'ETAPA': 'etapa',
      'ETAPACONTRACTUAL': 'etapa',

      'PRESUPUESTO': 'presupuestoAsignado',
      'PRESUPUESTOASIGNADO': 'presupuestoAsignado',

      'CERTIFICADO': 'certificado',
      'COMPROMETIDO': 'comprometido',
      'DEVENGADO': 'devengado',
      'PAGADO': 'pagado',

      'FECHAINICIO': 'fechaInicio',
      'FECHADEINICIO': 'fechaInicio',

      'FECHAFIN': 'fechaFin',
      'FECHAFINALIZACION': 'fechaFin',
      'FECHADEFINALIZACION': 'fechaFin',

      'FORMAPAGO': 'formaPago',
      'FORMADEPAGO': 'formaPago',

      'AVANCEFISICO': 'avanceFisico',
      'PORCENTAJEAVANCE': 'avanceFisico',

      'REFERENCIAUBICACION': 'referenciaUbicacion',
      'UBICACION': 'referenciaUbicacion',
      'REFERENCIA': 'referenciaUbicacion',

      'TIPOGEOMETRIA': 'tipoGeometria',
      'GEOMETRIA': 'tipoGeometria',

      'LATITUD': 'latitud',
      'LONGITUD': 'longitud',
    };

    return equivalencias[normalizado];
  }

  String _normalizarTexto(String texto) {
    return texto
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll('Ñ', 'N')
        .replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
  }

  bool _tieneInformacion(
    BorradorProyectoIaModelo borrador,
  ) {
    return borrador.nombre != null ||
        borrador.codigoProceso != null ||
        borrador.presupuestoAsignado != null ||
        borrador.fechaInicio != null ||
        borrador.fechaFin != null ||
        borrador.partidas.isNotEmpty ||
        borrador.pagos.isNotEmpty;
  }

  String _resumirRespuesta(String respuesta) {
    final texto = respuesta.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    if (texto.length <= 280) {
      return texto;
    }

    return '${texto.substring(0, 280)}...';
  }

  Future<String> responderConsulta({
    required String pregunta,
    required List<ProyectoModelo> proyectosVisibles,
    required String alcance,
  }) async {
    if (proyectosVisibles.isEmpty) {
      return 'No existen proyectos visibles dentro del alcance actual.';
    }

    final modelo = FirebaseAI.googleAI().generativeModel(
      model: _modeloNombre,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: 700,
      ),
    );

    final contexto = _crearContextoProyectos(
      proyectosVisibles,
    );

    final instruccion = '''
Eres MuniIA, asistente institucional de análisis municipal.

Responde solamente con base en los datos proporcionados.
No inventes cifras, fechas, proyectos, riesgos, pagos ni responsables.

Si no existe la información, responde exactamente:
No dispongo de esa información en los proyectos visibles.

Alcance autorizado:
$alcance

Proyectos visibles:
$contexto

Pregunta:
$pregunta

Responde en español, de forma breve, clara y profesional.
''';

    try {
      final respuesta = await modelo.generateContent([
        Content.text(instruccion),
      ]);

      final texto = respuesta.text?.trim();

      if (texto == null || texto.isEmpty) {
        return 'MuniIA no pudo generar una respuesta.';
      }

      return texto;
    } catch (error) {
      return _obtenerMensajeError(error);
    }
  }

  String _obtenerMensajeError(Object error) {
    final detalle = error
        .toString()
        .replaceFirst('Exception: ', '');

    if (detalle.toLowerCase().contains('quota')) {
      return 'Se alcanzó temporalmente el límite de consultas de MuniIA. Intenta nuevamente en unos minutos.';
    }

    if (detalle.toLowerCase().contains('permission')) {
      return 'Firebase AI Logic rechazó la solicitud por permisos: $detalle';
    }

    if (detalle.toLowerCase().contains('api key')) {
      return 'No fue posible validar Firebase AI Logic: $detalle';
    }

    return 'Error técnico de MuniIA: $detalle';
  }

  String _crearContextoProyectos(
    List<ProyectoModelo> proyectos,
  ) {
    return proyectos.map((proyecto) {
      final montoVencido = proyecto.pagosVencidos.fold(
        0.0,
        (total, pago) => total + pago.monto,
      );

      return '''
Proyecto: ${proyecto.nombre}
Código: ${proyecto.codigoProceso}
Dirección: ${proyecto.direccion}
Etapa: ${proyecto.etapa}
Presupuesto: USD ${proyecto.presupuestoAsignado.toStringAsFixed(2)}
Certificado: USD ${proyecto.certificado.toStringAsFixed(2)}
Comprometido: USD ${proyecto.comprometido.toStringAsFixed(2)}
Devengado: USD ${proyecto.devengado.toStringAsFixed(2)}
Pagado: USD ${proyecto.pagado.toStringAsFixed(2)}
Avance físico: ${(proyecto.avanceFisicoNormalizado * 100).toStringAsFixed(0)} %
Riesgo: ${proyecto.nivelRiesgo}
Pagos vencidos: ${proyecto.pagosVencidos.length}
Monto vencido: USD ${montoVencido.toStringAsFixed(2)}
Mayor atraso: ${proyecto.mayorDiasAtraso} días
''';
    }).join('\n-----------------------------\n');
  }
}

class _CampoValor {
  final String campo;
  final String valor;

  const _CampoValor({
    required this.campo,
    required this.valor,
  });
}