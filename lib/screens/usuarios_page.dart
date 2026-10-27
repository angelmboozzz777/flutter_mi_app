import 'package:flutter/material.dart';

import '../models/usuario_registrado.dart';
import '../services/consulta_service.dart';
import '../widgets/consulta_widgets.dart';
import '../widgets/usuarios_widgets.dart';

// ==========================================================
// US11 - Listar todos los usuarios registrados
// Solo Administrador y Auditor. Pantalla de solo lectura.
// ==========================================================

class UsuariosPage extends StatefulWidget {
  final String role;

  const UsuariosPage({super.key, required this.role});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final ConsultaService consultaService = ConsultaService();

  List<UsuarioRegistrado> usuarios = [];
  bool cargando = true;
  String? error;

  String busqueda = '';
  String filtroRol = 'todos'; // todos | admin | auditor | user

  // Escenario 2: aunque alguien llegue aquí "a la fuerza",
  // un Cliente no ve nada ni se hace la petición.
  bool get permitido => Permisos.puedeConsultarTodo(widget.role);

  @override
  void initState() {
    super.initState();

    if (permitido) {
      cargarUsuarios();
    }
  }

  // ==========================================================
  // CARGA (Escenario 1 y 3)
  // ==========================================================

  Future<void> cargarUsuarios() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await consultaService.obtenerUsuarios();

      if (!mounted) return;

      resultado.sort((a, b) => a.id.compareTo(b.id));

      setState(() {
        usuarios = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      final mensaje = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        cargando = false;
        error = mensaje;
      });

      // Alerta con opción de reintentar.
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
              onPressed: cargarUsuarios,
            ),
          ),
        );
    }
  }

  // ==========================================================
  // FILTROS
  // ==========================================================

  List<UsuarioRegistrado> get usuariosVisibles {
    return usuarios.where((usuario) {
      final bool rolOk = filtroRol == 'todos' || usuario.rol == filtroRol;
      final bool textoOk = busqueda.isEmpty || usuario.coincideCon(busqueda);
      return rolOk && textoOk;
    }).toList();
  }

  Map<String, int> get conteoPorRol {
    final conteo = {
      'todos': usuarios.length,
      'admin': 0,
      'auditor': 0,
      'user': 0,
    };
    for (final usuario in usuarios) {
      conteo[usuario.rol] = (conteo[usuario.rol] ?? 0) + 1;
    }
    return conteo;
  }

  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (!permitido) {
      return const AccesoDenegado(titulo: 'Usuarios');
    }

    return UsuariosWidgets(
      usuarios: usuariosVisibles,
      totalUsuarios: usuarios.length,
      conteoPorRol: conteoPorRol,
      cargando: cargando,
      error: error,
      busqueda: busqueda,
      filtroRol: filtroRol,
      onBuscar: (texto) => setState(() => busqueda = texto.trim()),
      onFiltroRol: (rol) => setState(() => filtroRol = rol),
      onRecargar: cargarUsuarios,
    );
  }
}
