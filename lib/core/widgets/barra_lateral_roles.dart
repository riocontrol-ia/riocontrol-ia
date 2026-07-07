import 'package:flutter/material.dart';

import '../modelos/sesion_usuario_modelo.dart';
import '../tema/tema_rio_control.dart';
import 'componentes_rio_control.dart';

class BarraLateralRoles extends StatelessWidget {
  final List<ModuloAplicacion> modulosDisponibles;
  final ModuloAplicacion moduloSeleccionado;
  final ValueChanged<ModuloAplicacion> alSeleccionar;

  const BarraLateralRoles({
    super.key,
    required this.modulosDisponibles,
    required this.moduloSeleccionado,
    required this.alSeleccionar,
  });

  IconData _obtenerIcono(ModuloAplicacion modulo) {
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
    return Container(
      width: 268,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            child: MarcaRioControl(),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: modulosDisponibles.length,
              itemBuilder: (context, indice) {
                final modulo = modulosDisponibles[indice];
                final estaSeleccionado = modulo == moduloSeleccionado;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Material(
                    color: estaSeleccionado
                        ? ColoresRio.azulProfundo
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => alSeleccionar(modulo),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _obtenerIcono(modulo),
                              color: estaSeleccionado
                                  ? Colors.white
                                  : ColoresRio.textoSecundario,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                modulo.etiqueta,
                                style: TextStyle(
                                  fontWeight: estaSeleccionado
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: estaSeleccionado
                                      ? Colors.white
                                      : ColoresRio.texto,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColoresRio.borde,
              ),
            ),
            child: Image.asset(
              'assets/imagenes/logo_riobamba_alcaldia_ciudadana.png',
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 72,
                  child: Center(
                    child: Text(
                      'Logo institucional no disponible',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresRio.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}