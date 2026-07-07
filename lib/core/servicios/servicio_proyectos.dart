import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../controladores/controlador_sesion.dart';
import '../datos/datos_demo.dart';

class ServicioProyectos {
  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('proyectos');

  Stream<List<ProyectoModelo>> observarProyectos(
    ControladorSesion controladorSesion,
  ) {
    Query<Map<String, dynamic>> consulta = _coleccion;

    if (controladorSesion.esDirectorGestion) {
      consulta = consulta.where(
        'direccion',
        isEqualTo: controladorSesion.direccionDirector,
      );
    }

    return consulta.snapshots().map((resultado) {
      final proyectos = resultado.docs
          .map(ProyectoModelo.desdeFirestore)
          .toList();

      proyectos.sort(
        (primero, segundo) =>
            primero.nombre.compareTo(segundo.nombre),
      );

      return proyectos;
    });
  }

  Future<void> guardarProyecto(
    ProyectoModelo proyecto,
  ) async {
    final datos = proyecto.aFirestore();

    datos['actualizadoEn'] = FieldValue.serverTimestamp();
    datos['origenRegistro'] = 'registroManual';

    // No se realiza get() antes de guardar.
    // Así un Director puede crear un proyecto nuevo de su Dirección.
    await _coleccion.doc(proyecto.id).set(
          datos,
          SetOptions(merge: true),
        );
  }

  Future<void> eliminarProyecto(String proyectoId) async {
    await _coleccion.doc(proyectoId).delete();
  }

  Future<void> sembrarDatosDemostracion(
    List<ProyectoModelo> proyectos,
  ) async {
    final lote = FirebaseFirestore.instance.batch();

    for (final proyecto in proyectos) {
      final referencia = _coleccion.doc(proyecto.id);

      final datos = proyecto.aFirestore();
      datos['creadoEn'] = FieldValue.serverTimestamp();
      datos['actualizadoEn'] = FieldValue.serverTimestamp();
      datos['origenRegistro'] = 'datosDemo';

      lote.set(
        referencia,
        datos,
        SetOptions(merge: true),
      );
    }

    await lote.commit();
  }

  Future<void> cargarDatosDemo() async {
    await sembrarDatosDemostracion(
      crearProyectosDemo(),
    );
  }
}