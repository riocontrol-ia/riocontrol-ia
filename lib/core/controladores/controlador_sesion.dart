import 'package:flutter/material.dart';

import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../modelos/perfil_usuario_modelo.dart';
import '../modelos/sesion_usuario_modelo.dart';

class ControladorSesion extends ChangeNotifier {
  final PerfilUsuarioModelo perfilUsuario;

  ControladorSesion(this.perfilUsuario);

  RolUsuario get rolActual {
    return perfilUsuario.rol;
  }

  String get direccionDirector {
    return perfilUsuario.direccion ?? '';
  }

  bool get esAlcaldia {
    return rolActual == RolUsuario.alcaldia;
  }

  bool get esDireccionFinanciera {
    return rolActual == RolUsuario.direccionFinanciera;
  }

  bool get esDirectorGestion {
    return rolActual == RolUsuario.directorGestion;
  }

  bool get puedeRegistrarProyectos {
    return esDirectorGestion;
  }

  bool get puedeImportarFinanzas {
    return esDireccionFinanciera;
  }

  bool get puedeGenerarReporteEjecutivo {
    return esAlcaldia || esDireccionFinanciera;
  }

  bool get puedeConsultarMuniIa {
    return esAlcaldia || esDireccionFinanciera || esDirectorGestion;
  }

  String get alcanceActual {
    if (esDirectorGestion) {
      return 'Proyectos de $direccionDirector';
    }

    if (esDireccionFinanciera) {
      return 'Vista financiera global';
    }

    if (esAlcaldia) {
      return 'Vista estratégica global';
    }

    return 'Sin permisos asignados';
  }

  List<ModuloAplicacion> get modulosDisponibles {
    if (esAlcaldia) {
      return const [
        ModuloAplicacion.panelControl,
        ModuloAplicacion.proyectos,
        ModuloAplicacion.alertas,
        ModuloAplicacion.mapaTerritorial,
        ModuloAplicacion.registroMuniIa,
        ModuloAplicacion.reporteEjecutivo,
      ];
    }

    if (esDireccionFinanciera) {
      return const [
        ModuloAplicacion.panelControl,
        ModuloAplicacion.proyectos,
        ModuloAplicacion.alertas,
        ModuloAplicacion.mapaTerritorial,
        ModuloAplicacion.registroMuniIa,
        ModuloAplicacion.importacionFinanciera,
        ModuloAplicacion.reporteEjecutivo,
      ];
    }

    if (esDirectorGestion) {
      return const [
        ModuloAplicacion.panelControl,
        ModuloAplicacion.proyectos,
        ModuloAplicacion.alertas,
        ModuloAplicacion.mapaTerritorial,
        ModuloAplicacion.registroMuniIa,
      ];
    }

    return const [];
  }

  bool puedeAccederModulo(ModuloAplicacion modulo) {
    return modulosDisponibles.contains(modulo);
  }

  List<ProyectoModelo> filtrarProyectos(
    List<ProyectoModelo> proyectos,
  ) {
    if (!esDirectorGestion) {
      return List.unmodifiable(proyectos);
    }

    return proyectos
        .where(
          (proyecto) => proyecto.direccion == direccionDirector,
        )
        .toList(growable: false);
  }
}