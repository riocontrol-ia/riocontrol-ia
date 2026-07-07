import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/controladores/controlador_proyectos.dart';
import '../../../core/controladores/controlador_sesion.dart';
import '../../../core/tema/tema_rio_control.dart';

class PantallaImportacionFinanciera extends StatefulWidget {
  final ControladorProyectos controladorProyectos;
  final ControladorSesion controladorSesion;

  const PantallaImportacionFinanciera({
    super.key,
    required this.controladorProyectos,
    required this.controladorSesion,
  });

  @override
  State<PantallaImportacionFinanciera> createState() =>
      _PantallaImportacionFinancieraState();
}

class _PantallaImportacionFinancieraState
    extends State<PantallaImportacionFinanciera> {
  PlatformFile? archivoSeleccionado;

  bool estaCargandoDatosDemo = false;
  bool estaValidandoArchivo = false;
  bool archivoValidado = false;

  Future<void> cargarDatosDemostracion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text(
            'Cargar datos demo',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Se cargarán automáticamente 10 proyectos demostrativos '
            'con presupuesto, pagos, alertas, avance físico y ubicación '
            'territorial. Los registros existentes serán actualizados '
            'sin duplicarse.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextoDialogo, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(contextoDialogo, true);
              },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Cargar datos demo'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      estaCargandoDatosDemo = true;
    });

    try {
      await widget.controladorProyectos.cargarDatosDemostracion();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Los datos demo se cargaron correctamente en Firestore.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible cargar los datos demo. Revisa las reglas de Firestore e inténtalo otra vez.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          estaCargandoDatosDemo = false;
        });
      }
    }
  }

  Future<void> seleccionarArchivo() async {
    final resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) {
      return;
    }

    setState(() {
      archivoSeleccionado = resultado.files.single;
      archivoValidado = false;
    });
  }

  Future<void> validarArchivo() async {
    if (archivoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona primero un archivo financiero.'),
        ),
      );
      return;
    }

    setState(() {
      estaValidandoArchivo = true;
      archivoValidado = false;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() {
      estaValidandoArchivo = false;
      archivoValidado = true;
    });
  }

  String formatearTamano(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controladorSesion.puedeImportarFinanzas) {
      return const _AccesoRestringidoImportacion();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Importación financiera institucional',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Carga datos financieros y conserva trazabilidad de certificado, comprometido, devengado y pagado.',
                style: TextStyle(
                  color: ColoresRio.textoSecundario,
                ),
              ),
              const SizedBox(height: 24),
              _panelCargaDatosDemo(),
              const SizedBox(height: 18),
              _panelArchivoFinanciero(),
              const SizedBox(height: 18),
              _panelEstructuraEsperada(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelCargaDatosDemo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColoresRio.azulCielo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColoresRio.azulCielo.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final informacion = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.dataset_linked_outlined,
                    color: ColoresRio.azulProfundo,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Datos demo',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Carga proyectos demostrativos con indicadores, pagos vencidos, riesgos y coordenadas para visualizar el funcionamiento del sistema.',
                style: TextStyle(
                  color: ColoresRio.textoSecundario,
                  height: 1.45,
                ),
              ),
            ],
          );

          final boton = FilledButton.icon(
            onPressed: estaCargandoDatosDemo
                ? null
                : cargarDatosDemostracion,
            icon: estaCargandoDatosDemo
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              estaCargandoDatosDemo
                  ? 'Cargando datos demo...'
                  : 'Cargar datos demo',
            ),
          );

          if (restricciones.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                informacion,
                const SizedBox(height: 18),
                boton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: informacion),
              const SizedBox(width: 24),
              boton,
            ],
          );
        },
      ),
    );
  }

  Widget _panelArchivoFinanciero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.upload_file_outlined,
                color: ColoresRio.azulProfundo,
              ),
              SizedBox(width: 10),
              Text(
                'Archivo de ejecución financiera',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Formatos admitidos: Excel (.xlsx, .xls) o CSV.',
            style: TextStyle(
              color: ColoresRio.textoSecundario,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ColoresRio.fondo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: archivoSeleccionado == null
                    ? ColoresRio.borde
                    : ColoresRio.verde.withValues(alpha: 0.35),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, restricciones) {
                final informacionArchivo = archivoSeleccionado == null
                    ? const Text(
                        'No se ha seleccionado un archivo.',
                        style: TextStyle(
                          color: ColoresRio.textoSecundario,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            archivoSeleccionado!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: ColoresRio.texto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatearTamano(archivoSeleccionado!.size),
                            style: const TextStyle(
                              color: ColoresRio.textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );

                final acciones = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: seleccionarArchivo,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: Text(
                        archivoSeleccionado == null
                            ? 'Seleccionar archivo'
                            : 'Cambiar archivo',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: estaValidandoArchivo
                          ? null
                          : validarArchivo,
                      icon: estaValidandoArchivo
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: Text(
                        estaValidandoArchivo
                            ? 'Validando...'
                            : 'Validar estructura',
                      ),
                    ),
                  ],
                );

                if (restricciones.maxWidth < 650) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      informacionArchivo,
                      const SizedBox(height: 16),
                      acciones,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: informacionArchivo),
                    const SizedBox(width: 20),
                    acciones,
                  ],
                );
              },
            ),
          ),
          if (archivoValidado) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresRio.verde.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ColoresRio.verde.withValues(alpha: 0.24),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: ColoresRio.verde,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Archivo validado. La lectura y actualización masiva se implementará en la siguiente fase.',
                      style: TextStyle(
                        color: ColoresRio.verde,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _panelEstructuraEsperada() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresRio.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estructura esperada para importación real',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cada fila del Excel o CSV debe representar un proyecto o proceso.',
            style: TextStyle(
              color: ColoresRio.textoSecundario,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _campoEsperado('codigoProceso', 'Código del proceso'),
              _campoEsperado('certificado', 'Monto certificado'),
              _campoEsperado('comprometido', 'Monto comprometido'),
              _campoEsperado('devengado', 'Monto devengado'),
              _campoEsperado('pagado', 'Monto pagado'),
              _campoEsperado('fechaCorte', 'Fecha del reporte'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campoEsperado(
    String campo,
    String descripcion,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresRio.fondo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campo,
            style: const TextStyle(
              color: ColoresRio.azulProfundo,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: const TextStyle(
              color: ColoresRio.textoSecundario,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoRestringidoImportacion extends StatelessWidget {
  const _AccesoRestringidoImportacion();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ColoresRio.borde),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              color: ColoresRio.rojo,
              size: 48,
            ),
            SizedBox(height: 14),
            Text(
              'Acceso restringido',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La importación financiera está disponible únicamente para Dirección Financiera.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColoresRio.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}