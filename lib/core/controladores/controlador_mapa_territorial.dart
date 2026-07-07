import 'package:flutter/material.dart';

import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../../features/proyectos/dominio/modelos/ubicacion_proyecto_modelo.dart';

class ControladorMapaTerritorial extends ChangeNotifier {
  String _textoBusqueda = '';
  String _direccionSeleccionada = 'Todas';
  String _etapaSeleccionada = 'Todas';
  String _riesgoSeleccionado = 'Todos';
  String _geometriaSeleccionada = 'Todas';
  String _avanceSeleccionado = 'Todos';
  bool _soloPagosVencidos = false;

  ProyectoModelo? _proyectoSeleccionado;
  String? _idProyectoPendienteEnfoque;

  String get textoBusqueda => _textoBusqueda;

  String get direccionSeleccionada => _direccionSeleccionada;

  String get etapaSeleccionada => _etapaSeleccionada;

  String get riesgoSeleccionado => _riesgoSeleccionado;

  String get geometriaSeleccionada => _geometriaSeleccionada;

  String get avanceSeleccionado => _avanceSeleccionado;

  bool get soloPagosVencidos => _soloPagosVencidos;

  ProyectoModelo? get proyectoSeleccionado => _proyectoSeleccionado;

  String? get idProyectoPendienteEnfoque => _idProyectoPendienteEnfoque;

  void actualizarTextoBusqueda(String valor) {
    _textoBusqueda = valor;
    notifyListeners();
  }

  void actualizarDireccion(String valor) {
    _direccionSeleccionada = valor;
    notifyListeners();
  }

  void actualizarEtapa(String valor) {
    _etapaSeleccionada = valor;
    notifyListeners();
  }

  void actualizarRiesgo(String valor) {
    _riesgoSeleccionado = valor;
    notifyListeners();
  }

  void actualizarGeometria(String valor) {
    _geometriaSeleccionada = valor;
    notifyListeners();
  }

  void actualizarAvance(String valor) {
    _avanceSeleccionado = valor;
    notifyListeners();
  }

  void cambiarSoloPagosVencidos(bool valor) {
    _soloPagosVencidos = valor;
    notifyListeners();
  }

  void limpiarFiltros() {
    _textoBusqueda = '';
    _direccionSeleccionada = 'Todas';
    _etapaSeleccionada = 'Todas';
    _riesgoSeleccionado = 'Todos';
    _geometriaSeleccionada = 'Todas';
    _avanceSeleccionado = 'Todos';
    _soloPagosVencidos = false;
    notifyListeners();
  }

  void seleccionarProyecto(
    ProyectoModelo proyecto, {
    bool solicitarEnfoque = false,
  }) {
    _proyectoSeleccionado = proyecto;

    if (solicitarEnfoque) {
      _idProyectoPendienteEnfoque = proyecto.id;
    }

    notifyListeners();
  }

  void cerrarFicha() {
    _proyectoSeleccionado = null;
    notifyListeners();
  }

  void abrirProyectoEnMapa(ProyectoModelo proyecto) {
    _textoBusqueda = '';
    _direccionSeleccionada = 'Todas';
    _etapaSeleccionada = 'Todas';
    _riesgoSeleccionado = 'Todos';
    _geometriaSeleccionada = 'Todas';
    _avanceSeleccionado = 'Todos';
    _soloPagosVencidos = false;

    _proyectoSeleccionado = proyecto;
    _idProyectoPendienteEnfoque = proyecto.id;

    notifyListeners();
  }

  void confirmarEnfoqueAplicado() {
    _idProyectoPendienteEnfoque = null;
  }

  List<ProyectoModelo> filtrarProyectos(
    List<ProyectoModelo> proyectos,
  ) {
    final texto = _textoBusqueda.trim().toLowerCase();

    final direccionesDisponibles = proyectos
        .map((proyecto) => proyecto.direccion)
        .toSet();

    final direccionFiltro = direccionesDisponibles.contains(
      _direccionSeleccionada,
    )
        ? _direccionSeleccionada
        : 'Todas';

    return proyectos.where((proyecto) {
      if (!proyecto.tieneUbicacion) {
        return false;
      }

      final coincideBusqueda = texto.isEmpty ||
          proyecto.nombre.toLowerCase().contains(texto) ||
          proyecto.codigoProceso.toLowerCase().contains(texto) ||
          proyecto.direccion.toLowerCase().contains(texto);

      final coincideDireccion =
          direccionFiltro == 'Todas' || proyecto.direccion == direccionFiltro;

      final coincideEtapa =
          _etapaSeleccionada == 'Todas' || proyecto.etapa == _etapaSeleccionada;

      final coincideRiesgo =
          _riesgoSeleccionado == 'Todos' ||
              proyecto.nivelRiesgo == _riesgoSeleccionado;

      final coincideGeometria = _geometriaSeleccionada == 'Todas' ||
          proyecto.ubicacion!.tipoGeometria.etiqueta ==
              _geometriaSeleccionada;

      final coincideAvance = _coincideAvance(proyecto);

      final coincideAlertas =
          !_soloPagosVencidos || proyecto.pagosVencidos.isNotEmpty;

      return coincideBusqueda &&
          coincideDireccion &&
          coincideEtapa &&
          coincideRiesgo &&
          coincideGeometria &&
          coincideAvance &&
          coincideAlertas;
    }).toList(growable: false);
  }

  bool _coincideAvance(ProyectoModelo proyecto) {
    final avance = proyecto.avanceFisicoNormalizado * 100;

    switch (_avanceSeleccionado) {
      case '0 - 25 %':
        return avance >= 0 && avance <= 25;
      case '26 - 50 %':
        return avance > 25 && avance <= 50;
      case '51 - 75 %':
        return avance > 50 && avance <= 75;
      case '76 - 100 %':
        return avance > 75 && avance <= 100;
      default:
        return true;
    }
  }
}