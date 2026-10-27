import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

// ==========================================================
// Piezas comunes de las pantallas de consulta (US11 y US12)
// ==========================================================

// Color de cada rol de la API (admin | auditor | user).
Color colorDeRol(String rol) {
  switch (rol) {
    case 'admin':
      return GameColors.acento;
    case 'auditor':
      return GameColors.advertencia;
    default:
      return GameColors.exito;
  }
}

// Escenario 3: indicador visual mientras se descarga.
class EstadoCargando extends StatelessWidget {
  final String mensaje;

  const EstadoCargando({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GameColors.texto,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Si el servidor estaba dormido puede tardar hasta un minuto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: GameColors.textoTenue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Escenario 3: si falla la red, mensaje y botón para reintentar.
class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const EstadoError({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameColors.peligro.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 36,
                color: GameColors.peligro,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar',
              style: TextStyle(
                color: GameColors.texto,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GameColors.textoSecundario,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            BotonPrincipal(
              texto: 'Reintentar',
              icono: Icons.refresh,
              onPressed: onReintentar,
            ),
          ],
        ),
      ),
    );
  }
}

// Escenario 2: si un Cliente llega a la pantalla por cualquier vía.
class AccesoDenegado extends StatelessWidget {
  final String titulo;

  const AccesoDenegado({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: GameColors.textoTenue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Acceso restringido',
                style: TextStyle(
                  color: GameColors.texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Esta sección es solo para el Administrador y el Auditor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: GameColors.textoSecundario),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Insignia que recuerda que la pantalla es de consulta.
class InsigniaSoloLectura extends StatelessWidget {
  const InsigniaSoloLectura({super.key});

  @override
  Widget build(BuildContext context) {
    return const Etiqueta(
      texto: 'Solo lectura',
      icono: Icons.visibility_outlined,
      color: GameColors.advertencia,
    );
  }
}

// Tarjeta de resumen: un número grande con su descripción.
class Indicador extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final IconData icono;
  final Color color;

  const Indicador({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.icono,
    this.color = GameColors.acento,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                color: GameColors.texto,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Fecha legible sin paquetes extra: "20 oct 2026".
String fechaCorta(DateTime? fecha) {
  if (fecha == null) return 'Sin fecha';
  const meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
}

// "Ver detalles ⌄" / "Ocultar ⌃". Es un solo texto con el icono
// adentro, así con letra grande baja de renglón en vez de desbordarse.
class TextoDesplegar extends StatelessWidget {
  final bool abierta;
  final String textoAbrir;
  final String textoCerrar;

  const TextoDesplegar({
    super.key,
    required this.abierta,
    required this.textoAbrir,
    required this.textoCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: abierta ? textoCerrar : textoAbrir,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              abierta ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: GameColors.acento,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.end,
      style: const TextStyle(
        color: GameColors.acento,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
