import 'package:cloud_firestore/cloud_firestore.dart';

class PartidaCatalogoModelo {
  final String id;
  final String codigo;
  final String detalle;
  final String grupo;
  final int lineasPresupuestarias;

  const PartidaCatalogoModelo({
    required this.id,
    required this.codigo,
    required this.detalle,
    required this.grupo,
    required this.lineasPresupuestarias,
  });

  String get etiquetaCompleta {
    return '$codigo · $detalle';
  }

  Map<String, dynamic> aFirestore() {
    return {
      'codigo': codigo,
      'detalle': detalle,
      'grupo': grupo,
      'lineasPresupuestarias': lineasPresupuestarias,
    };
  }

  factory PartidaCatalogoModelo.desdeFirestore(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data() ?? {};

    return PartidaCatalogoModelo(
      id: documento.id,
      codigo: datos['codigo'] as String? ?? '',
      detalle: datos['detalle'] as String? ?? '',
      grupo: datos['grupo'] as String? ?? '',
      lineasPresupuestarias:
          (datos['lineasPresupuestarias'] as num?)?.toInt() ?? 0,
    );
  }
}