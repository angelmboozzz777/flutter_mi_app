import 'package:flutter/material.dart';

// ==========================================================
// TEMA DE LA APP (oscuro sobrio, estilo tienda de videojuegos)
// Todos los colores salen de aquí.
// ==========================================================

class GameColors {
  static const Color fondo = Color(0xFF12151C);
  static const Color superficie = Color(0xFF1A1F2B);
  static const Color superficieAlta = Color(0xFF232A38);
  static const Color borde = Color(0xFF2C3444);

  static const Color acento = Color(0xFF3B82F6);
  static const Color acentoOscuro = Color(0xFF2563EB);

  static const Color texto = Color(0xFFE6E9EF);
  static const Color textoSecundario = Color(0xFF9AA3B2);
  static const Color textoTenue = Color(0xFF6B7385);

  static const Color exito = Color(0xFF22C55E);
  static const Color advertencia = Color(0xFFF59E0B);
  static const Color peligro = Color(0xFFEF4444);
}

class GameTheme {
  static ThemeData get tema {
    final OutlineInputBorder bordeBase = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: GameColors.borde),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GameColors.fondo,
      colorScheme: const ColorScheme.dark(
        primary: GameColors.acento,
        onPrimary: Colors.white,
        secondary: GameColors.acento,
        onSecondary: Colors.white,
        surface: GameColors.superficie,
        onSurface: GameColors.texto,
        error: GameColors.peligro,
      ),
      dividerColor: GameColors.borde,
      dividerTheme: const DividerThemeData(
        color: GameColors.borde,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GameColors.fondo,
        foregroundColor: GameColors.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: GameColors.texto,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GameColors.superficie,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: GameColors.textoSecundario),
        floatingLabelStyle: const TextStyle(color: GameColors.acento),
        hintStyle: const TextStyle(color: GameColors.textoTenue),
        prefixIconColor: GameColors.textoSecundario,
        suffixIconColor: GameColors.textoSecundario,
        border: bordeBase,
        enabledBorder: bordeBase,
        disabledBorder: bordeBase,
        focusedBorder: bordeBase.copyWith(
          borderSide: const BorderSide(
            color: GameColors.acento,
            width: 1.5,
          ),
        ),
        errorBorder: bordeBase.copyWith(
          borderSide: const BorderSide(color: GameColors.peligro),
        ),
        focusedErrorBorder: bordeBase.copyWith(
          borderSide: const BorderSide(
            color: GameColors.peligro,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GameColors.acento,
          foregroundColor: Colors.white,
          disabledBackgroundColor: GameColors.superficieAlta,
          disabledForegroundColor: GameColors.textoTenue,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GameColors.texto,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: GameColors.borde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GameColors.textoSecundario,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GameColors.acento,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GameColors.superficie,
        selectedColor: GameColors.acento,
        side: const BorderSide(color: GameColors.borde),
        labelStyle: const TextStyle(
          color: GameColors.textoSecundario,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GameColors.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: const TextStyle(
          color: GameColors.texto,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: GameColors.textoSecundario,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GameColors.superficieAlta,
        contentTextStyle: const TextStyle(
          color: GameColors.texto,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: GameColors.acento,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GameColors.acento,
      ),
    );
  }
}

// ==========================================================
// WIDGETS REUTILIZABLES
// ==========================================================

// Botón principal: azul, con indicador de carga opcional.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback? onPressed;
  final bool cargando;
  final Color? color;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.cargando = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle? estilo = color == null
        ? null
        : FilledButton.styleFrom(backgroundColor: color);

    final Widget contenido = cargando
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icono != null) ...[
                  Icon(icono, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(texto),
              ],
            ),
          );

    return FilledButton(
      // Mientras carga se ve activo pero no responde.
      onPressed: cargando ? () {} : onPressed,
      style: estilo,
      child: contenido,
    );
  }
}

// Etiqueta discreta (categoría, plataforma, rol...).
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icono;

  const Etiqueta({
    super.key,
    required this.texto,
    this.color = GameColors.textoSecundario,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Título de sección.
class TituloSeccion extends StatelessWidget {
  final String texto;
  final Widget? accion;

  const TituloSeccion(this.texto, {super.key, this.accion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: GameColors.texto,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ?accion, // solo se agrega si no es null
      ],
    );
  }
}

// Contenedor con fondo de tarjeta.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: GameColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.borde),
      ),
      child: child,
    );
  }
}

// Precio con formato $1,199.00
String formatoPrecio(double valor) {
  final String fijo = valor.toStringAsFixed(2);
  final List<String> partes = fijo.split('.');
  final String entero = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$entero.${partes[1]}';
}

// Imagen de portada con un marcador de posición si no carga.
class PortadaJuego extends StatelessWidget {
  final String url;
  final double iconoSize;
  final BoxFit fit;

  const PortadaJuego({
    super.key,
    required this.url,
    this.iconoSize = 36,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        return Container(color: GameColors.superficieAlta);
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: GameColors.superficieAlta,
          alignment: Alignment.center,
          child: Icon(
            Icons.videogame_asset_outlined,
            size: iconoSize,
            color: GameColors.textoTenue,
          ),
        );
      },
    );
  }
}
