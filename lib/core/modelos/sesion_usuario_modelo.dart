enum RolUsuario {
  sinRol,
  alcaldia,
  direccionFinanciera,
  directorGestion,
}

enum ModuloAplicacion {
  panelControl,
  proyectos,
  alertas,
  mapaTerritorial,
  registroMuniIa,
  importacionFinanciera,
  reporteEjecutivo,
}

extension RolUsuarioExtension on RolUsuario {
  String get etiqueta {
    switch (this) {
      case RolUsuario.alcaldia:
        return 'Alcaldía';

      case RolUsuario.direccionFinanciera:
        return 'Dirección Financiera';

      case RolUsuario.directorGestion:
        return 'Director/a de Gestión';

      case RolUsuario.sinRol:
        return 'Sin rol asignado';
    }
  }

  String get descripcion {
    switch (this) {
      case RolUsuario.alcaldia:
        return 'Vista estratégica global e informes ejecutivos';

      case RolUsuario.direccionFinanciera:
        return 'Seguimiento presupuestario y financiero municipal';

      case RolUsuario.directorGestion:
        return 'Gestión de proyectos de su Dirección';

      case RolUsuario.sinRol:
        return 'Acceso pendiente de configuración';
    }
  }
}

extension ModuloAplicacionExtension on ModuloAplicacion {
  String get etiqueta {
    switch (this) {
      case ModuloAplicacion.panelControl:
        return 'Panel de control';

      case ModuloAplicacion.proyectos:
        return 'Proyectos';

      case ModuloAplicacion.alertas:
        return 'Alertas';

      case ModuloAplicacion.mapaTerritorial:
        return 'Mapa territorial';

      case ModuloAplicacion.registroMuniIa:
        return 'MuniIA';

      case ModuloAplicacion.importacionFinanciera:
        return 'Importación financiera';

      case ModuloAplicacion.reporteEjecutivo:
        return 'Reporte ejecutivo';
    }
  }
}