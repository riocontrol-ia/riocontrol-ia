import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/modelos/perfil_usuario_modelo.dart';
import '../core/servicios/servicio_perfiles_usuario.dart';
import '../core/tema/tema_rio_control.dart';
import '../features/autenticacion/presentacion/pantalla_inicio_sesion.dart';
import '../features/autenticacion/presentacion/pantalla_perfil_no_configurado.dart';
import 'pantalla_principal.dart';

class AplicacionRioControl extends StatelessWidget {
  const AplicacionRioControl({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RíoControl IA',
      debugShowCheckedModeBanner: false,
      theme: TemaRioControl.claro,
      home: const PuertaAutenticacion(),
    );
  }
}

class PuertaAutenticacion extends StatelessWidget {
  const PuertaAutenticacion({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, estadoAutenticacion) {
        if (estadoAutenticacion.connectionState ==
            ConnectionState.waiting) {
          return const _PantallaCarga(
            mensaje: 'Verificando sesión institucional...',
          );
        }

        final usuario = estadoAutenticacion.data;

        if (usuario == null) {
          return const PantallaInicioSesion();
        }

        return StreamBuilder<PerfilUsuarioModelo?>(
          stream: ServicioPerfilesUsuario().observarPerfil(usuario.uid),
          builder: (context, estadoPerfil) {
            if (estadoPerfil.connectionState ==
                ConnectionState.waiting) {
              return const _PantallaCarga(
                mensaje: 'Cargando permisos institucionales...',
              );
            }

            if (estadoPerfil.hasError) {
              return const PantallaPerfilNoConfigurado(
                mensaje:
                    'No fue posible validar tu perfil institucional. '
                    'Verifica la configuración de Firestore.',
              );
            }

            final perfil = estadoPerfil.data;

            if (perfil == null) {
              return const PantallaPerfilNoConfigurado(
                mensaje:
                    'Tu cuenta existe, pero todavía no tiene un perfil o rol asignado.',
              );
            }

            if (!perfil.activo) {
              return const PantallaPerfilNoConfigurado(
                mensaje:
                    'Tu perfil institucional se encuentra desactivado.',
              );
            }

            if (!perfil.tieneRolValido) {
              return const PantallaPerfilNoConfigurado(
                mensaje:
                    'Tu perfil tiene un rol no reconocido. Solicita al administrador que lo revise.',
              );
            }

            return PantallaPrincipal(
              key: ValueKey(
                '${perfil.id}-${perfil.rol.name}-${perfil.direccion}',
              ),
              perfilUsuario: perfil,
            );
          },
        );
      },
    );
  }
}

class _PantallaCarga extends StatelessWidget {
  final String mensaje;

  const _PantallaCarga({
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresRio.fondo,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: ColoresRio.azulProfundo,
            ),
            const SizedBox(height: 18),
            Text(
              mensaje,
              style: const TextStyle(
                color: ColoresRio.textoSecundario,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}