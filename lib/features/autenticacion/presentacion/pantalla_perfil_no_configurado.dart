import 'package:flutter/material.dart';

import '../../../core/servicios/servicio_autenticacion.dart';
import '../../../core/tema/tema_rio_control.dart';

class PantallaPerfilNoConfigurado extends StatelessWidget {
  final String mensaje;

  const PantallaPerfilNoConfigurado({
    super.key,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresRio.fondo,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColoresRio.borde),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: ColoresRio.naranja.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: ColoresRio.naranja,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Perfil institucional pendiente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColoresRio.textoSecundario,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    ServicioAutenticacion().cerrarSesion();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}