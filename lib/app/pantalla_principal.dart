import 'package:flutter/material.dart';

import '../core/controladores/controlador_mapa_territorial.dart';
import '../core/controladores/controlador_proyectos.dart';
import '../core/controladores/controlador_sesion.dart';
import '../core/modelos/perfil_usuario_modelo.dart';
import '../core/modelos/sesion_usuario_modelo.dart';
import '../core/servicios/servicio_autenticacion.dart';
import '../core/tema/tema_rio_control.dart';
import '../core/widgets/barra_lateral_roles.dart';
import '../core/widgets/componentes_rio_control.dart';
import '../features/alertas/presentacion/pantalla_alertas.dart';
import '../features/importacion_financiera/presentacion/pantalla_importacion_financiera.dart';
import '../features/mapa_territorial/presentacion/pantalla_mapa_territorial.dart';
import '../features/panel_control/presentacion/pantalla_panel_control.dart';
import '../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../features/proyectos/presentacion/pantalla_proyectos.dart';
import '../features/registro_inteligente/presentacion/pantalla_registro_inteligente.dart';
import '../features/reportes_ia/presentacion/pantalla_reportes_ia.dart';

class PantallaPrincipal extends StatefulWidget {
  final PerfilUsuarioModelo perfilUsuario;

  const PantallaPrincipal({
    super.key,
    required this.perfilUsuario,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late final ControladorSesion controladorSesion;
  late final ControladorProyectos controladorProyectos;
  late final ControladorMapaTerritorial controladorMapaTerritorial;

  ModuloAplicacion moduloSeleccionado =
      ModuloAplicacion.panelControl;

  @override
  void initState() {
    super.initState();

    controladorSesion = ControladorSesion(widget.perfilUsuario);
    controladorProyectos = ControladorProyectos(controladorSesion);
    controladorMapaTerritorial = ControladorMapaTerritorial();
  }

  @override
  void dispose() {
    controladorMapaTerritorial.dispose();
    controladorProyectos.dispose();
    controladorSesion.dispose();
    super.dispose();
  }

  void seleccionarModulo(ModuloAplicacion modulo) {
    if (!controladorSesion.puedeAccederModulo(modulo)) {
      return;
    }

    setState(() {
      moduloSeleccionado = modulo;
    });
  }

  void abrirProyectoEnMapa(ProyectoModelo proyecto) {
    controladorMapaTerritorial.abrirProyectoEnMapa(proyecto);

    seleccionarModulo(ModuloAplicacion.mapaTerritorial);
  }

  Widget obtenerContenido(ModuloAplicacion modulo) {
    switch (modulo) {
      case ModuloAplicacion.panelControl:
        return PantallaPanelControl(
          controlador: controladorProyectos,
          controladorSesion: controladorSesion,
          alAbrirReporte: () {
            seleccionarModulo(
              ModuloAplicacion.reporteEjecutivo,
            );
          },
        );

      case ModuloAplicacion.proyectos:
        return PantallaProyectos(
          controlador: controladorProyectos,
          controladorSesion: controladorSesion,
          alAbrirRegistro: controladorSesion.puedeRegistrarProyectos
              ? () {
                  seleccionarModulo(
                    ModuloAplicacion.registroMuniIa,
                  );
                }
              : null,
          alAbrirEnMapa: abrirProyectoEnMapa,
        );

      case ModuloAplicacion.alertas:
        return PantallaAlertas(
          controlador: controladorProyectos,
        );

      case ModuloAplicacion.mapaTerritorial:
        return PantallaMapaTerritorial(
          controladorProyectos: controladorProyectos,
          controladorSesion: controladorSesion,
          controladorMapa: controladorMapaTerritorial,
        );

      case ModuloAplicacion.registroMuniIa:
        return PantallaRegistroInteligente(
          controlador: controladorProyectos,
          controladorSesion: controladorSesion,
          alAbrirProyectos: () {
            seleccionarModulo(ModuloAplicacion.proyectos);
          },
        );

      case ModuloAplicacion.importacionFinanciera:
        return PantallaImportacionFinanciera(
          controladorProyectos: controladorProyectos,
          controladorSesion: controladorSesion,
        );

      case ModuloAplicacion.reporteEjecutivo:
        return PantallaReportesIa(
          controlador: controladorProyectos,
          controladorSesion: controladorSesion,
        );
    }
  }

  IconData obtenerIconoModulo(ModuloAplicacion modulo) {
    switch (modulo) {
      case ModuloAplicacion.panelControl:
        return Icons.grid_view_rounded;

      case ModuloAplicacion.proyectos:
        return Icons.account_tree_outlined;

      case ModuloAplicacion.alertas:
        return Icons.warning_amber_rounded;

      case ModuloAplicacion.mapaTerritorial:
        return Icons.map_outlined;

      case ModuloAplicacion.registroMuniIa:
        return Icons.auto_awesome_outlined;

      case ModuloAplicacion.importacionFinanciera:
        return Icons.upload_file_outlined;

      case ModuloAplicacion.reporteEjecutivo:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final modulosDisponibles = controladorSesion.modulosDisponibles;

    final moduloActivo = modulosDisponibles.contains(moduloSeleccionado)
        ? moduloSeleccionado
        : ModuloAplicacion.panelControl;

    final contenido = obtenerContenido(moduloActivo);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, restricciones) {
          final esMovil = restricciones.maxWidth < 930;

          if (esMovil) {
            return SafeArea(
              child: Column(
                children: [
                  _Cabecera(
                    titulo: moduloActivo.etiqueta,
                    perfilUsuario: widget.perfilUsuario,
                    esMovil: true,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey(moduloActivo),
                        child: contenido,
                      ),
                    ),
                  ),
                  NavigationBar(
                    selectedIndex: modulosDisponibles.indexOf(moduloActivo),
                    onDestinationSelected: (indice) {
                      seleccionarModulo(modulosDisponibles[indice]);
                    },
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                    destinations: modulosDisponibles
                        .map(
                          (modulo) => NavigationDestination(
                            icon: Icon(obtenerIconoModulo(modulo)),
                            label: modulo.etiqueta,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Row(
              children: [
                BarraLateralRoles(
                  modulosDisponibles: modulosDisponibles,
                  moduloSeleccionado: moduloActivo,
                  alSeleccionar: seleccionarModulo,
                ),
                Expanded(
                  child: Column(
                    children: [
                      _Cabecera(
                        titulo: moduloActivo.etiqueta,
                        perfilUsuario: widget.perfilUsuario,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            key: ValueKey(moduloActivo),
                            child: contenido,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final String titulo;
  final PerfilUsuarioModelo perfilUsuario;
  final bool esMovil;

  const _Cabecera({
    required this.titulo,
    required this.perfilUsuario,
    this.esMovil = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: ColoresRio.borde),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final tituloPantalla = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esMovil) ...[
                const MarcaRioControl(compacta: true),
                const SizedBox(width: 12),
              ],
              Text(
                titulo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ColoresRio.texto,
                    ),
              ),
            ],
          );

          final controles = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _menuPerfil(context),
              if (perfilUsuario.direccion != null)
                _ChipCabecera(
                  icono: Icons.account_tree_outlined,
                  texto: perfilUsuario.direccion!,
                  mostrarFlecha: false,
                ),
              const _ChipCabecera(
                icono: Icons.calendar_today_outlined,
                texto: 'Corte: hoy',
                mostrarFlecha: false,
              ),
            ],
          );

          if (restricciones.maxWidth < 900) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tituloPantalla,
                const SizedBox(height: 12),
                controles,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: tituloPantalla),
              controles,
            ],
          );
        },
      ),
    );
  }

  Widget _menuPerfil(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones de usuario',
      onSelected: (valor) async {
        if (valor == 'cerrarSesion') {
          await ServicioAutenticacion().cerrarSesion();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfilUsuario.nombreVisible,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    perfilUsuario.correo,
                    style: const TextStyle(
                      color: ColoresRio.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    perfilUsuario.rol.etiqueta,
                    style: const TextStyle(
                      color: ColoresRio.azulProfundo,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'cerrarSesion',
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: ColoresRio.rojo,
                ),
                SizedBox(width: 10),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: ColoresRio.rojo,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
      child: _ChipCabecera(
        icono: Icons.badge_outlined,
        texto: perfilUsuario.rol.etiqueta,
      ),
    );
  }
}

class _ChipCabecera extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool mostrarFlecha;

  const _ChipCabecera({
    required this.icono,
    required this.texto,
    this.mostrarFlecha = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 17,
            color: ColoresRio.azulProfundo,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColoresRio.texto,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (mostrarFlecha) ...[
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 17,
              color: ColoresRio.textoSecundario,
            ),
          ],
        ],
      ),
    );
  }
}