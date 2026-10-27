import 'package:flutter/material.dart';

import '../models/usuario_registrado.dart';
import '../theme/game_theme.dart';
import 'consulta_widgets.dart';

class UsuariosWidgets extends StatelessWidget {
  final List<UsuarioRegistrado> usuarios;
  final int totalUsuarios;
  final Map<String, int> conteoPorRol;

  final bool cargando;
  final String? error;

  final String busqueda;
  final String filtroRol;

  final Function(String) onBuscar;
  final Function(String) onFiltroRol;
  final Future<void> Function() onRecargar;

  const UsuariosWidgets({
    super.key,
    required this.usuarios,
    required this.totalUsuarios,
    required this.conteoPorRol,
    required this.cargando,
    required this.error,
    required this.busqueda,
    required this.filtroRol,
    required this.onBuscar,
    required this.onFiltroRol,
    required this.onRecargar,
  });

  static const Map<String, String> nombresFiltro = {
    'todos': 'Todos',
    'admin': 'Administradores',
    'auditor': 'Auditores',
    'user': 'Clientes',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            onPressed: cargando ? null : onRecargar,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    // Primera carga: indicador visual (Escenario 3).
    if (cargando && totalUsuarios == 0) {
      return const EstadoCargando(mensaje: 'Cargando usuarios...');
    }

    // Falló y no hay nada que mostrar: reintentar (Escenario 3).
    if (error != null && totalUsuarios == 0) {
      return EstadoError(mensaje: error!, onReintentar: onRecargar);
    }

    return RefreshIndicator(
      onRefresh: onRecargar,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _encabezado()),
          SliverToBoxAdapter(child: _filtros()),
          if (cargando)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (usuarios.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _sinResultados())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList.separated(
                itemCount: usuarios.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return TarjetaUsuario(usuario: usuarios[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Directorio de cuentas',
                  style: TextStyle(
                    color: GameColors.texto,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const InsigniaSoloLectura(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$totalUsuarios ${totalUsuarios == 1 ? 'cuenta registrada' : 'cuentas registradas'}',
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Indicador(
                  valor: '${conteoPorRol['admin'] ?? 0}',
                  etiqueta: 'Admins',
                  icono: Icons.admin_panel_settings_outlined,
                  color: colorDeRol('admin'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Indicador(
                  valor: '${conteoPorRol['auditor'] ?? 0}',
                  etiqueta: 'Auditores',
                  icono: Icons.fact_check_outlined,
                  color: colorDeRol('auditor'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Indicador(
                  valor: '${conteoPorRol['user'] ?? 0}',
                  etiqueta: 'Clientes',
                  icono: Icons.sports_esports_outlined,
                  color: colorDeRol('user'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onBuscar,
            style: const TextStyle(color: GameColors.texto),
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre, usuario o correo...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: nombresFiltro.entries.map((entrada) {
          final bool elegido = filtroRol == entrada.key;
          final int cantidad = conteoPorRol[entrada.key] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${entrada.value} ($cantidad)'),
              selected: elegido,
              onSelected: (_) => onFiltroRol(entrada.key),
              side: BorderSide(
                color: elegido ? GameColors.acento : GameColors.borde,
              ),
              labelStyle: TextStyle(
                color: elegido ? Colors.white : GameColors.textoSecundario,
                fontWeight: elegido ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sinResultados() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 44,
            color: GameColors.textoTenue,
          ),
          const SizedBox(height: 12),
          Text(
            busqueda.isEmpty
                ? 'No hay usuarios con este rol.'
                : 'Ningún usuario coincide con "$busqueda".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameColors.textoSecundario,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// Tarjeta de un usuario: muestra nombre, usuario, correo y
// teléfono; al tocarla se despliega la dirección (solo lectura).
// ==========================================================

class TarjetaUsuario extends StatefulWidget {
  final UsuarioRegistrado usuario;

  const TarjetaUsuario({super.key, required this.usuario});

  @override
  State<TarjetaUsuario> createState() => _TarjetaUsuarioState();
}

class _TarjetaUsuarioState extends State<TarjetaUsuario> {
  bool abierta = false;

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;
    final Color color = colorDeRol(usuario.rol);

    return Material(
      color: GameColors.superficie,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => abierta = !abierta),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: abierta ? color.withValues(alpha: 0.5) : GameColors.borde,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.16),
                    child: Text(
                      usuario.iniciales,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nombreVisible,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: GameColors.texto,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${usuario.usuario}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: GameColors.textoSecundario,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pegada a la derecha; con letra grande se corta con "...".
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Etiqueta(texto: usuario.rolVisible, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _dato(Icons.email_outlined, usuario.correo),
              const SizedBox(height: 6),
              _dato(
                Icons.phone_outlined,
                usuario.telefono.isEmpty ? 'Sin teléfono' : usuario.telefono,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: abierta ? _detalle(usuario) : const SizedBox.shrink(),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextoDesplegar(
                  abierta: abierta,
                  textoAbrir: 'Ver detalles',
                  textoCerrar: 'Ocultar detalles',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dato(IconData icono, String texto) {
    return Row(
      children: [
        Icon(icono, size: 16, color: GameColors.textoTenue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GameColors.texto, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _detalle(UsuarioRegistrado usuario) {
    final direccion = usuario.direccion;
    final geo = direccion.geolocalizacion;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GameColors.superficieAlta,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renglon('ID de usuario', '${usuario.id}'),
            _renglon(
              'Dirección',
              direccion.estaVacia
                  ? 'Sin dirección registrada'
                  : direccion.completa,
            ),
            if (geo.tieneDatos)
              _renglon('Coordenadas', '${geo.latitud}, ${geo.longitud}'),
          ],
        ),
      ),
    );
  }

  Widget _renglon(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: GameColors.textoTenue, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(color: GameColors.texto, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
