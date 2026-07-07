import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/proyectos/dominio/modelos/proyecto_modelo.dart';
import '../tema/tema_rio_control.dart';
import '../utilidades/formateadores.dart';

class ElementoNavegacion {
  final String titulo;
  final IconData icono;

  const ElementoNavegacion({
    required this.titulo,
    required this.icono,
  });
}

const elementosNavegacion = [
  ElementoNavegacion(
    titulo: 'Panel de control',
    icono: Icons.grid_view_rounded,
  ),
  ElementoNavegacion(
    titulo: 'Proyectos',
    icono: Icons.account_tree_outlined,
  ),
  ElementoNavegacion(
    titulo: 'Alertas',
    icono: Icons.warning_amber_rounded,
  ),
  ElementoNavegacion(
    titulo: 'Mapa territorial',
    icono: Icons.map_outlined,
  ),
  ElementoNavegacion(
    titulo: 'Registro MuniIA',
    icono: Icons.auto_awesome_outlined,
  ),
  ElementoNavegacion(
    titulo: 'Reporte ejecutivo',
    icono: Icons.description_outlined,
  ),
];

class MarcaRioControl extends StatelessWidget {
  final bool compacta;

  const MarcaRioControl({
    super.key,
    this.compacta = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compacta ? 38 : 44,
          height: compacta ? 38 : 44,
          decoration: BoxDecoration(
            color: ColoresRio.azulProfundo,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.account_balance_rounded,
                color: Colors.white,
                size: 23,
              ),
              Positioned(
                right: 5,
                bottom: 5,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: ColoresRio.naranja,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!compacta) ...[
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RíoControl IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ColoresRio.texto,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'POA · PAC · Pagos',
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresRio.textoSecundario,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class BarraLateral extends StatelessWidget {
  final int indiceSeleccionado;
  final ValueChanged<int> alSeleccionar;

  const BarraLateral({
    super.key,
    required this.indiceSeleccionado,
    required this.alSeleccionar,
  });

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
              itemCount: elementosNavegacion.length,
              itemBuilder: (context, indice) {
                final elemento = elementosNavegacion[indice];
                final estaSeleccionado = indice == indiceSeleccionado;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Material(
                    color: estaSeleccionado
                        ? ColoresRio.azulProfundo
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => alSeleccionar(indice),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              elemento.icono,
                              color: estaSeleccionado
                                  ? Colors.white
                                  : ColoresRio.textoSecundario,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              elemento.titulo,
                              style: TextStyle(
                                fontWeight: estaSeleccionado
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: estaSeleccionado
                                    ? Colors.white
                                    : ColoresRio.texto,
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

          // Logo institucional al final de la barra lateral.
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
            ),
          ),
        ],
      ),
    );
  }
}

class EtiquetaEstado extends StatelessWidget {
  final String texto;

  const EtiquetaEstado({
    super.key,
    required this.texto,
  });

  Color get color {
    final valor = texto.toLowerCase();

    if (valor.contains('alto') || valor.contains('vencido')) {
      return ColoresRio.rojo;
    }

    if (valor.contains('medio') ||
        valor.contains('preparatoria') ||
        valor.contains('precontractual')) {
      return ColoresRio.naranja;
    }

    if (valor.contains('bajo') ||
        valor.contains('cierre') ||
        valor.contains('pagado')) {
      return ColoresRio.verde;
    }

    if (valor.contains('ejecución')) {
      return ColoresRio.azulCielo;
    }

    return ColoresRio.violeta;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class TarjetaIndicador extends StatelessWidget {
  final String titulo;
  final String valor;
  final String detalle;
  final IconData icono;
  final Color color;
  final bool destacada;

  const TarjetaIndicador({
    super.key,
    required this.titulo,
    required this.valor,
    required this.detalle,
    required this.icono,
    required this.color,
    this.destacada = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = destacada ? Colors.white : ColoresRio.texto;

    final colorDetalle = destacada
        ? Colors.white.withOpacity(0.75)
        : ColoresRio.textoSecundario;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: destacada ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: destacada ? null : Border.all(color: ColoresRio.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: destacada
                  ? Colors.white.withOpacity(0.16)
                  : color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icono,
              color: destacada ? Colors.white : color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: colorDetalle,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor,
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detalle,
                  style: TextStyle(
                    color: colorDetalle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TarjetaProyecto extends StatelessWidget {
  final ProyectoModelo proyecto;
  final VoidCallback? alPresionar;

  const TarjetaProyecto({
    super.key,
    required this.proyecto,
    this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    final porcentaje =
        proyecto.porcentajeEjecucion.clamp(0.0, 1.0).toDouble();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColoresRio.borde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      proyecto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: ColoresRio.texto,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  EtiquetaEstado(texto: proyecto.nivelRiesgo),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${proyecto.codigoProceso} · ${proyecto.direccion}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ColoresRio.textoSecundario,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 9,
                runSpacing: 8,
                children: [
                  EtiquetaEstado(texto: proyecto.etapa),
                  Text(
                    Formateadores.moneda(proyecto.presupuestoAsignado),
                    style: const TextStyle(
                      color: ColoresRio.azulProfundo,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ejecución presupuestaria',
                      style: TextStyle(
                        color: ColoresRio.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    Formateadores.porcentaje(
                      proyecto.porcentajeEjecucion,
                    ),
                    style: const TextStyle(
                      color: ColoresRio.azulProfundo,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  minHeight: 9,
                  color: ColoresRio.azulCielo,
                  backgroundColor: const Color(0xFFE8EDF4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    proyecto.pagosVencidos.isEmpty
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    size: 18,
                    color: proyecto.pagosVencidos.isEmpty
                        ? ColoresRio.verde
                        : ColoresRio.rojo,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    proyecto.pagosVencidos.isEmpty
                        ? 'Sin pagos vencidos'
                        : '${proyecto.pagosVencidos.length} pago(s) vencido(s)',
                    style: const TextStyle(
                      color: ColoresRio.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraficoBarrasDirecciones extends StatelessWidget {
  final Map<String, double> datos;

  const GraficoBarrasDirecciones({
    super.key,
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    final entradas = datos.entries.toList();

    return Column(
      children: entradas.asMap().entries.map((entrada) {
        final indice = entrada.key;
        final direccion = entrada.value.key;
        final porcentaje =
            entrada.value.value.clamp(0.0, 1.0).toDouble();

        final colores = [
          ColoresRio.azulMedio,
          ColoresRio.azulCielo,
          ColoresRio.naranja,
          ColoresRio.violeta,
          ColoresRio.verde,
        ];

        final color = colores[indice % colores.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 19),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      direccion,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ColoresRio.texto,
                      ),
                    ),
                  ),
                  Text(
                    Formateadores.porcentaje(porcentaje),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  minHeight: 12,
                  color: color,
                  backgroundColor: const Color(0xFFE9EDF4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class GraficoDonaEtapas extends StatelessWidget {
  final Map<String, int> datos;

  const GraficoDonaEtapas({
    super.key,
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    final entradas = datos.entries.toList();

    final colores = [
      ColoresRio.azulMedio,
      ColoresRio.naranja,
      ColoresRio.azulCielo,
      ColoresRio.violeta,
      ColoresRio.verde,
    ];

    final total = datos.values.fold(
      0,
      (suma, valor) => suma + valor,
    );

    return Row(
      children: [
        SizedBox(
          width: 158,
          height: 158,
          child: CustomPaint(
            painter: PintorDona(
              valores: entradas.map((entrada) => entrada.value).toList(),
              colores: colores,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ColoresRio.texto,
                    ),
                  ),
                  const Text(
                    'proyectos',
                    style: TextStyle(
                      color: ColoresRio.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: entradas.asMap().entries.map((entrada) {
              final indice = entrada.key;
              final valor = entrada.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colores[indice % colores.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        valor.key,
                        style: const TextStyle(
                          color: ColoresRio.textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '${valor.value}',
                      style: const TextStyle(
                        color: ColoresRio.texto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class PintorDona extends CustomPainter {
  final List<int> valores;
  final List<Color> colores;

  PintorDona({
    required this.valores,
    required this.colores,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = valores.fold(
      0,
      (suma, valor) => suma + valor,
    );

    if (total == 0) {
      return;
    }

    final centro = Offset(size.width / 2, size.height / 2);
    final radio = math.min(size.width, size.height) / 2;

    final rectangulo = Rect.fromCircle(
      center: centro,
      radius: radio - 8,
    );

    final pintura = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    var anguloInicio = -math.pi / 2;

    for (var indice = 0; indice < valores.length; indice++) {
      final angulo = (valores[indice] / total) * (math.pi * 2);

      pintura.color = colores[indice % colores.length];

      canvas.drawArc(
        rectangulo,
        anguloInicio,
        angulo - 0.06,
        false,
        pintura,
      );

      anguloInicio += angulo;
    }
  }

  @override
  bool shouldRepaint(covariant PintorDona anterior) {
    return true;
  }
}