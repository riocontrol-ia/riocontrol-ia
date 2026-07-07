import 'package:flutter/material.dart';

class ColoresRio {
  static const azulProfundo = Color(0xFF173A70);
  static const azulMedio = Color(0xFF1E5AA8);
  static const azulCielo = Color(0xFF29A8DE);

  static const naranja = Color(0xFFFFA91F);
  static const rojo = Color(0xFFE84C3D);
  static const verde = Color(0xFF1E9C6A);
  static const violeta = Color(0xFF7657D8);

  static const fondo = Color(0xFFF4F6FA);
  static const superficie = Colors.white;
  static const texto = Color(0xFF1B2735);
  static const textoSecundario = Color(0xFF718096);
  static const borde = Color(0xFFE3E8EF);
}

class TemaRioControl {
  static ThemeData get claro {
    final esquemaColor = ColorScheme.fromSeed(
      seedColor: ColoresRio.azulProfundo,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquemaColor.copyWith(
        primary: ColoresRio.azulProfundo,
        secondary: ColoresRio.naranja,
        surface: ColoresRio.superficie,
      ),
      scaffoldBackgroundColor: ColoresRio.fondo,
      dividerColor: ColoresRio.borde,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ColoresRio.texto,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresRio.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresRio.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColoresRio.azulMedio,
            width: 1.6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColoresRio.azulProfundo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}