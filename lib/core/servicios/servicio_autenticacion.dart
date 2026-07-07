import 'package:firebase_auth/firebase_auth.dart';

class ServicioAutenticacion {
  final FirebaseAuth _autenticacion = FirebaseAuth.instance;

  Stream<User?> get cambiosAutenticacion {
    return _autenticacion.authStateChanges();
  }

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _autenticacion.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_obtenerMensajeError(error.code));
    }
  }

  Future<void> cerrarSesion() async {
    await _autenticacion.signOut();
  }

  String _obtenerMensajeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo electrónico no tiene un formato válido.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo electrónico o contraseña incorrectos.';
      case 'user-disabled':
        return 'Este usuario se encuentra deshabilitado.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e inténtalo otra vez.';
      default:
        return 'No fue posible iniciar sesión. Verifica tus credenciales.';
    }
  }
}