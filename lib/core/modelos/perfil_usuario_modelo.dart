import 'package:cloud_firestore/cloud_firestore.dart';

import 'sesion_usuario_modelo.dart';

class PerfilUsuarioModelo {
  final String id;
  final String nombre;
  final String correo;
  final RolUsuario rol;
  final String? direccion;
  final bool activo;

  const PerfilUsuarioModelo({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
    this.direccion,
  });

  String get nombreVisible {
    if (nombre.trim().isNotEmpty) {
      return nombre;
    }

    return correo;
  }

  bool get tieneRolValido {
    return rol != RolUsuario.sinRol;
  }

  factory PerfilUsuarioModelo.desdeFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data() ?? {};

    return PerfilUsuarioModelo(
      id: documento.id,
      nombre: datos['nombre'] as String? ?? '',
      correo: datos['correo'] as String? ?? '',
      rol: _convertirRol(datos['rol'] as String? ?? ''),
      direccion: datos['direccion'] as String?,
      activo: datos['activo'] == true,
    );
  }

  static RolUsuario _convertirRol(String valor) {
    switch (valor) {
      case 'alcaldia':
        return RolUsuario.alcaldia;

      case 'direccionFinanciera':
        return RolUsuario.direccionFinanciera;

      case 'directorGestion':
        return RolUsuario.directorGestion;

      default:
        return RolUsuario.sinRol;
    }
  }
}