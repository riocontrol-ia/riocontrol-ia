import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../datos/datos_demo.dart';
import '../servicios/servicio_proyectos.dart';
import 'controlador_sesion.dart';

class ControladorProyectos extends ChangeNotifier {
  final ControladorSesion controladorSesion;
  final ServicioProyectos _servicioProyectos = ServicioProyectos();

  StreamSubscription<List<ProyectoModelo>>? _suscripcion;

  List<ProyectoModelo> _proyectos = [];

  bool _estaCargando = true;
  bool _estaGuardando = false;
  String? _mensajeError;

  ControladorProyectos(this.controladorSesion) {
    _escucharProyectos();
  }

  List<ProyectoModelo> get proyectos {
    return List.unmodifiable(_proyectos);
  }

  List<ProyectoModelo> get todosLosProyectos {
    return List.unmodifiable(_proyectos);
  }

  bool get estaCargando => _estaCargando;

  bool get estaGuardando => _estaGuardando;

  String? get mensajeError => _mensajeError;

  void _escucharProyectos() {
    _suscripcion?.cancel();

    _estaCargando = true;
    _mensajeError = null;

    _suscripcion = _servicioProyectos
        .observarProyectos(controladorSesion)
        .listen(
      (proyectos) {
        _proyectos = proyectos;
        _estaCargando = false;
        _mensajeError = null;
        notifyListeners();
      },
      onError: (error) {
        _estaCargando = false;
        _mensajeError =
            'No fue posible cargar los proyectos desde Firestore.';
        notifyListeners();
      },
    );
  }

  Future<void> guardarProyecto(
    ProyectoModelo proyecto,
  ) async {
    _validarCadenaPresupuestaria(proyecto);

    _estaGuardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _servicioProyectos.guardarProyecto(proyecto);
    } catch (error) {
      _mensajeError = 'No fue posible guardar el proyecto.';
      rethrow;
    } finally {
      _estaGuardando = false;
      notifyListeners();
    }
  }

  Future<void> eliminarProyecto(String proyectoId) async {
    await _servicioProyectos.eliminarProyecto(proyectoId);
  }

  Future<void> cargarDatosDemostracion() async {
    _estaGuardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _servicioProyectos.sembrarDatosDemostracion(
        crearProyectosDemo(),
      );
    } catch (error) {
      _mensajeError =
          'No fue posible cargar los datos demostrativos.';
      rethrow;
    } finally {
      _estaGuardando = false;
      notifyListeners();
    }
  }

  void _validarCadenaPresupuestaria(
    ProyectoModelo proyecto,
  ) {
    final esValida = proyecto.presupuestoAsignado >= proyecto.certificado &&
        proyecto.certificado >= proyecto.comprometido &&
        proyecto.comprometido >= proyecto.devengado &&
        proyecto.devengado >= proyecto.pagado;

    if (!esValida) {
      throw Exception(
        'La cadena presupuestaria debe cumplir: '
        'presupuesto ≥ certificado ≥ comprometido ≥ devengado ≥ pagado.',
      );
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}