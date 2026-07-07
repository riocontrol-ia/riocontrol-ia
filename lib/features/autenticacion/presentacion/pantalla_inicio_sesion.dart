import 'package:flutter/material.dart';

import '../../../core/servicios/servicio_autenticacion.dart';
import '../../../core/tema/tema_rio_control.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() =>
      _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final claveFormulario = GlobalKey<FormState>();

  final controladorCorreo = TextEditingController();
  final controladorContrasena = TextEditingController();

  final servicioAutenticacion = ServicioAutenticacion();

  bool ocultarContrasena = true;
  bool estaCargando = false;
  String? mensajeError;

  @override
  void dispose() {
    controladorCorreo.dispose();
    controladorContrasena.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (!claveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      estaCargando = true;
      mensajeError = null;
    });

    try {
      await servicioAutenticacion.iniciarSesion(
        correo: controladorCorreo.text,
        contrasena: controladorContrasena.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        mensajeError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          estaCargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresRio.fondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final esPantallaAmplia = restricciones.maxWidth >= 900;

            if (esPantallaAmplia) {
              return Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: _panelInstitucional(),
                  ),
                  Expanded(
                    flex: 5,
                    child: _panelFormulario(),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _panelInstitucional(compacto: true),
                  _panelFormulario(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _panelInstitucional({
    bool compacto = false,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: compacto ? 260 : double.infinity,
      ),
      padding: const EdgeInsets.all(42),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColoresRio.azulProfundo,
            ColoresRio.azulMedio,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compacto ? 220 : 390,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Image.asset(
                  'assets/imagenes/logo_riobamba_alcaldia_ciudadana.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 34),
              Text(
                'RíoControl IA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compacto ? 30 : 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sistema inteligente de seguimiento de ejecución, pagos y proyectos del GADMR.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              if (!compacto) ...[
                const SizedBox(height: 44),
                _beneficio(
                  Icons.account_balance_wallet_outlined,
                  'Control presupuestario y financiero',
                ),
                const SizedBox(height: 14),
                _beneficio(
                  Icons.map_outlined,
                  'Seguimiento territorial de obras',
                ),
                const SizedBox(height: 14),
                _beneficio(
                  Icons.auto_awesome_outlined,
                  'Reporte ejecutivo generado con IA',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _beneficio(
    IconData icono,
    String texto,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icono,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _panelFormulario() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Form(
            key: claveFormulario,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acceso institucional',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: ColoresRio.texto,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingresa con las credenciales asignadas por la administración del sistema.',
                  style: TextStyle(
                    color: ColoresRio.textoSecundario,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: controladorCorreo,
                  keyboardType: TextInputType.emailAddress,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa tu correo institucional';
                    }

                    if (!valor.contains('@')) {
                      return 'Ingresa un correo válido';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Correo institucional',
                    prefixIcon: Icon(Icons.alternate_email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controladorContrasena,
                  obscureText: ocultarContrasena,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => iniciarSesion(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: ocultarContrasena
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () {
                        setState(() {
                          ocultarContrasena = !ocultarContrasena;
                        });
                      },
                      icon: Icon(
                        ocultarContrasena
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (mensajeError != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ColoresRio.rojo.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ColoresRio.rojo.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: ColoresRio.rojo,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            mensajeError!,
                            style: const TextStyle(
                              color: ColoresRio.rojo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: estaCargando ? null : iniciarSesion,
                    icon: estaCargando
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(
                      estaCargando
                          ? 'Verificando acceso...'
                          : 'Iniciar sesión',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'RíoControl IA · Acceso restringido',
                    style: TextStyle(
                      color: ColoresRio.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}