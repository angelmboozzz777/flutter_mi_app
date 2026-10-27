import 'package:flutter/material.dart';

import '../models/carrito_registrado.dart';
import '../services/consulta_service.dart';
import '../widgets/carritos_globales_widgets.dart';
import '../widgets/consulta_widgets.dart';

// ==========================================================
// US12 - Visualizar histórico de carritos globales
// Solo Administrador y Auditor. Pantalla de solo lectura:
// no hay ningún botón para modificar o borrar carritos.
// ==========================================================

class CarritosGlobalesPage extends StatefulWidget {
  final String role;

  const CarritosGlobalesPage({super.key, required this.role});

  @override
  State<CarritosGlobalesPage> createState() => _CarritosGlobalesPageState();
}

class _CarritosGlobalesPageState extends State<CarritosGlobalesPage> {
  final ConsultaService consultaService = ConsultaService();

  List<CarritoDetallado> carritos = [];
  bool cargando = true;
  String? error;

  String busqueda = '';
  String filtro = 'todos'; // todos | con_articulos | vacios

  // Escenario 2: un Cliente nunca ve historiales ajenos.
  bool get permitido => Permisos.puedeConsultarTodo(widget.role);

  @override
  void initState() {
    super.initState();

    if (permitido) {
      cargarCarritos();
    }
  }

  // ==========================================================
  // CARGA (carritos + catálogo + usuarios, cruzados)
  // ==========================================================

  Future<void> cargarCarritos() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await consultaService.obtenerCarritosDetallados();

      if (!mounted) return;

      // Los más recientes primero.
      resultado.sort((a, b) {
        final fechaA = a.carrito.fecha ?? DateTime(1970);
        final fechaB = b.carrito.fecha ?? DateTime(1970);
        final porFecha = fechaB.compareTo(fechaA);
        return porFecha != 0 ? porFecha : b.carrito.id.compareTo(a.carrito.id);
      });

      setState(() {
        carritos = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      final mensaje = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        cargando = false;
        error = mensaje;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            persist: false,
            action: SnackBarAction(
              label: 'REINTENTAR',
              textColor: Colors.white,
              onPressed: cargarCarritos,
            ),
          ),
        );
    }
  }

  // ==========================================================
  // FILTROS Y RESUMEN
  // ==========================================================

  List<CarritoDetallado> get carritosVisibles {
    return carritos.where((detallado) {
      final bool vacio = detallado.carrito.articulos.isEmpty;
      final bool filtroOk =
          filtro == 'todos' ||
          (filtro == 'con_articulos' && !vacio) ||
          (filtro == 'vacios' && vacio);
      final bool textoOk = busqueda.isEmpty || detallado.coincideCon(busqueda);
      return filtroOk && textoOk;
    }).toList();
  }

  ResumenCarritos get resumen {
    final visibles = carritosVisibles;
    return ResumenCarritos(
      carritos: visibles.length,
      piezas: visibles.fold(0, (suma, c) => suma + c.carrito.totalPiezas),
      monto: double.parse(
        visibles
            .fold<double>(0, (suma, c) => suma + c.total)
            .toStringAsFixed(2),
      ),
      clientes: visibles.map((c) => c.carrito.userId).toSet().length,
    );
  }

  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (!permitido) {
      return const AccesoDenegado(titulo: 'Historial de carritos');
    }

    return CarritosGlobalesWidgets(
      carritos: carritosVisibles,
      totalCarritos: carritos.length,
      resumen: resumen,
      cargando: cargando,
      error: error,
      busqueda: busqueda,
      filtro: filtro,
      onBuscar: (texto) => setState(() => busqueda = texto.trim()),
      onFiltro: (valor) => setState(() => filtro = valor),
      onRecargar: cargarCarritos,
    );
  }
}
