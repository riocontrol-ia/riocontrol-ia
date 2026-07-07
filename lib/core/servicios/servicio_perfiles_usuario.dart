import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/perfil_usuario_modelo.dart';

class ServicioPerfilesUsuario {
  final CollectionReference<Map<String, dynamic>> _usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  Stream<PerfilUsuarioModelo?> observarPerfil(String usuarioId) {
    return _usuarios.doc(usuarioId).snapshots().map(
      (documento) {
        if (!documento.exists) {
          return null;
        }

        return PerfilUsuarioModelo.desdeFirestore(documento);
      },
    );
  }
}