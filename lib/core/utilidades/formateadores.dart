class Formateadores {
  static String moneda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');

    final entero = partes.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (coincidencia) => '.',
    );

    return 'USD $entero,${partes.last}';
  }

  static String porcentaje(double valor) {
    return '${(valor * 100).toStringAsFixed(0)} %';
  }

  static String fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}