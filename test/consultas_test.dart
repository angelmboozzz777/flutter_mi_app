// Pruebas de US11 (usuarios) y US12 (historial global de carritos).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_app/models/carrito_registrado.dart';
import 'package:mi_app/models/producto.dart';
import 'package:mi_app/models/usuario_registrado.dart';
import 'package:mi_app/screens/carritos_globales_page.dart';
import 'package:mi_app/screens/usuarios_page.dart';
import 'package:mi_app/services/consulta_service.dart';
import 'package:mi_app/theme/game_theme.dart';
import 'package:mi_app/widgets/carritos_globales_widgets.dart';
import 'package:mi_app/widgets/home_widgets.dart';
import 'package:mi_app/widgets/usuarios_widgets.dart';

Map<String, dynamic> jsonUsuario({
  int id = 4,
  String rol = 'admin',
  Map<String, dynamic>? name,
  Map<String, dynamic>? address,
}) {
  return {
    'id': id,
    'username': 'angel',
    'email': 'angel@gamestore.com',
    'phone': '4421234567',
    'role': rol,
    'name': name ?? {'firstname': 'Angel', 'lastname': 'Ramirez'},
    'address':
        address ??
        {
          'city': 'Querétaro',
          'street': 'Av. Universidad',
          'number': '100',
          'zipcode': '76000',
        },
  };
}

Producto juego(int id, String titulo, double precio) => Producto(
  id: id,
  title: titulo,
  price: precio,
  description: 'Descripción',
  category: 'Indie',
  image: 'https://example.com/$id.jpg',
  platform: 'PC',
  stock: 10,
);

Widget enApp(Widget pantalla, {double escala = 1.0}) {
  return MaterialApp(
    theme: GameTheme.tema,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 780),
        textScaler: TextScaler.linear(escala),
      ),
      child: pantalla,
    ),
  );
}

void main() {
  // ----------------------------------------------------------
  // Modelos: el JSON anidado nunca debe tumbar la app
  // ----------------------------------------------------------
  group('US11 - UsuarioRegistrado', () {
    test('lee nombre, dirección y rol', () {
      final usuario = UsuarioRegistrado.fromJson(jsonUsuario());
      expect(usuario.nombreVisible, 'Angel Ramirez');
      expect(usuario.rolVisible, 'Administrador');
      expect(usuario.iniciales, 'AR');
      expect(
        usuario.direccion.completa,
        'Av. Universidad #100, Querétaro, C.P. 76000',
      );
    });

    test('no falla si name, address o geolocation vienen nulos', () {
      final usuario = UsuarioRegistrado.fromJson({
        'id': '7',
        'username': 'cayemango',
        'email': null,
        'phone': null,
        'name': null,
        'address': {'geolocation': null},
      });
      expect(usuario.id, 7);
      expect(usuario.nombreVisible, 'cayemango');
      expect(usuario.correo, '');
      expect(usuario.rolVisible, 'Cliente');
      expect(usuario.direccion.estaVacia, isTrue);
      expect(usuario.direccion.geolocalizacion.tieneDatos, isFalse);
    });

    test('lee coordenadas si la API las manda (estilo Fake Store)', () {
      final usuario = UsuarioRegistrado.fromJson(
        jsonUsuario(
          address: {
            'city': 'kilcoole',
            'geolocation': {'lat': '-37.3159', 'long': '81.1496'},
          },
        ),
      );
      expect(
        usuario.direccion.geolocalizacion.latitud,
        closeTo(-37.3159, 0.0001),
      );
    });

    test('el buscador encuentra por nombre, usuario o correo', () {
      final usuario = UsuarioRegistrado.fromJson(jsonUsuario());
      expect(usuario.coincideCon('ramirez'), isTrue);
      expect(usuario.coincideCon('ANGEL'), isTrue);
      expect(usuario.coincideCon('gamestore.com'), isTrue);
      expect(usuario.coincideCon('damiani'), isFalse);
    });
  });

  group('US12 - CarritoRegistrado y cruce de datos', () {
    test('lee id, dueño, fecha y artículos', () {
      final carrito = CarritoRegistrado.fromJson({
        'id': 3,
        'userId': 4,
        'date': '2026-10-20',
        'products': [
          {'gameId': 1, 'quantity': 2},
          {'gameId': 5, 'quantity': 1},
        ],
      });
      expect(carrito.id, 3);
      expect(carrito.userId, 4);
      expect(carrito.fecha, DateTime(2026, 10, 20));
      expect(carrito.totalPiezas, 3);
    });

    test('acepta productId (Fake Store) y products nulo', () {
      final fake = CarritoRegistrado.fromJson({
        'id': 1,
        'userId': 1,
        'date': 'no es fecha',
        'products': [
          {'productId': 9, 'quantity': 4},
        ],
      });
      expect(fake.articulos.single.gameId, 9);
      expect(fake.fecha, isNull);

      final vacio = CarritoRegistrado.fromJson({
        'id': 2,
        'userId': 1,
        'products': null,
      });
      expect(vacio.articulos, isEmpty);
    });

    test(
      'cruza ids con el catálogo para mostrar el título real y el total',
      () {
        final carrito = CarritoRegistrado.fromJson({
          'id': 3,
          'userId': 4,
          'date': '2026-10-20',
          'products': [
            {'gameId': 1, 'quantity': 2},
            {'gameId': 99, 'quantity': 1}, // juego que ya se borró
          ],
        });
        final detallado = CarritoDetallado.cruzar(
          carrito,
          {1: juego(1, 'Hollow Knight', 249.5)},
          {4: UsuarioRegistrado.fromJson(jsonUsuario())},
        );

        expect(detallado.articulos[0].titulo, 'Hollow Knight');
        expect(detallado.articulos[0].subtotal, 499.0);
        expect(detallado.articulos[1].titulo, 'Juego #99');
        expect(detallado.articulos[1].existe, isFalse);
        expect(detallado.total, 499.0);
        expect(detallado.nombreDueno, 'Angel Ramirez');
        expect(detallado.coincideCon('#3'), isTrue);
        expect(detallado.coincideCon('angel'), isTrue);
      },
    );
  });

  // ----------------------------------------------------------
  // Permisos (Escenario 2 de ambas historias)
  // ----------------------------------------------------------
  group('Permisos por rol', () {
    test('solo Administrador y Auditor pueden consultar todo', () {
      expect(Permisos.puedeConsultarTodo('Administrador'), isTrue);
      expect(Permisos.puedeConsultarTodo('Auditor'), isTrue);
      expect(Permisos.puedeConsultarTodo('Cliente'), isFalse);
      expect(Permisos.puedeConsultarTodo(''), isFalse);
    });

    testWidgets('un Cliente que llega a Usuarios ve acceso restringido', (
      tester,
    ) async {
      await tester.pumpWidget(enApp(const UsuariosPage(role: 'Cliente')));
      await tester.pump();
      expect(find.text('Acceso restringido'), findsOneWidget);
      expect(find.byType(TarjetaUsuario), findsNothing);
    });

    testWidgets('un Cliente que llega al historial ve acceso restringido', (
      tester,
    ) async {
      await tester.pumpWidget(
        enApp(const CarritosGlobalesPage(role: 'Cliente')),
      );
      await tester.pump();
      expect(find.text('Acceso restringido'), findsOneWidget);
      expect(find.byType(TarjetaCarritoGlobal), findsNothing);
    });

    for (final puede in [true, false]) {
      testWidgets('el botón del panel ${puede ? 'sí' : 'no'} aparece', (
        tester,
      ) async {
        await tester.pumpWidget(
          enApp(
            HomeWidgets(
              nombreUsuario: 'Demo',
              categoriaSeleccionada: 'Todos',
              categorias: const [],
              productos: const [],
              cargandoProductos: false,
              cargandoCategorias: false,
              errorProductos: null,
              onPerfil: () {},
              onAgregarProducto: () {},
              onRecargar: () async {},
              onCategoria: (_) {},
              onProducto: (_) {},
              esAdministrador: false,
              puedeComprar: !puede,
              onCarrito: () {},
              onAgregarRapido: (_) {},
              busqueda: '',
              onBuscar: (_) {},
              puedeConsultar: puede,
              onUsuarios: () {},
              onCarritosGlobales: () {},
            ),
          ),
        );
        expect(
          find.byTooltip('Panel de consulta'),
          puede ? findsOneWidget : findsNothing,
        );
      });
    }
  });

  // ----------------------------------------------------------
  // Pantallas: estados y letra grande
  // ----------------------------------------------------------
  group('Pantallas de consulta', () {
    final usuarios = [
      UsuarioRegistrado.fromJson(jsonUsuario()),
      UsuarioRegistrado.fromJson(
        jsonUsuario(
          id: 5,
          rol: 'auditor',
          name: {
            'firstname': 'Damiani Alejandra',
            'lastname': 'Torres de la Fuente',
          },
        ),
      ),
      UsuarioRegistrado.fromJson({'id': 7, 'username': 'sin_datos'}),
    ];

    final detallados = [
      CarritoDetallado.cruzar(
        CarritoRegistrado.fromJson({
          'id': 12,
          'userId': 4,
          'date': '2026-10-20',
          'products': [
            {'gameId': 1, 'quantity': 3},
            {'gameId': 2, 'quantity': 1},
            {'gameId': 99, 'quantity': 2},
          ],
        }),
        {
          1: juego(
            1,
            'Call of Duty: Modern Warfare III Edición Definitiva',
            1499.0,
          ),
          2: juego(2, 'Hades', 349.0),
        },
        {4: usuarios[0]},
      ),
      CarritoDetallado.cruzar(
        CarritoRegistrado.fromJson({
          'id': 13,
          'userId': 77,
          'date': '2026-10-21',
          'products': [],
        }),
        {},
        {},
      ),
    ];

    Widget pantallaUsuarios({
      bool cargando = false,
      String? error,
      List<UsuarioRegistrado>? lista,
    }) {
      final datos = lista ?? usuarios;
      return UsuariosWidgets(
        usuarios: datos,
        totalUsuarios: datos.length,
        conteoPorRol: const {'todos': 3, 'admin': 1, 'auditor': 1, 'user': 1},
        cargando: cargando,
        error: error,
        busqueda: '',
        filtroRol: 'todos',
        onBuscar: (_) {},
        onFiltroRol: (_) {},
        onRecargar: () async {},
      );
    }

    Widget pantallaCarritos({
      bool cargando = false,
      String? error,
      List<CarritoDetallado>? lista,
    }) {
      final datos = lista ?? detallados;
      return CarritosGlobalesWidgets(
        carritos: datos,
        totalCarritos: datos.length,
        resumen: const ResumenCarritos(
          carritos: 2,
          piezas: 6,
          monto: 4846.0,
          clientes: 2,
        ),
        cargando: cargando,
        error: error,
        busqueda: '',
        filtro: 'todos',
        onBuscar: (_) {},
        onFiltro: (_) {},
        onRecargar: () async {},
      );
    }

    testWidgets('US11 muestra nombre, correo, teléfono y usuario', (
      tester,
    ) async {
      await tester.pumpWidget(enApp(pantallaUsuarios()));
      expect(find.text('Angel Ramirez'), findsOneWidget);
      expect(find.text('@angel'), findsWidgets);
      expect(find.text('angel@gamestore.com'), findsWidgets);
      expect(find.text('4421234567'), findsWidgets);
      expect(find.text('Solo lectura'), findsOneWidget);
    });

    testWidgets('US11 al tocar una tarjeta se ve la dirección', (tester) async {
      await tester.pumpWidget(enApp(pantallaUsuarios()));
      expect(
        find.text('Av. Universidad #100, Querétaro, C.P. 76000'),
        findsNothing,
      );
      await tester.tap(find.text('Angel Ramirez'));
      await tester.pumpAndSettle();
      expect(
        find.text('Av. Universidad #100, Querétaro, C.P. 76000'),
        findsOneWidget,
      );
    });

    testWidgets('US11 indicador de carga y error con reintentar', (
      tester,
    ) async {
      await tester.pumpWidget(
        enApp(pantallaUsuarios(cargando: true, lista: const [])),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        enApp(pantallaUsuarios(error: 'Sin conexión', lista: const [])),
      );
      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('US12 muestra id, fecha y dueño del carrito', (tester) async {
      await tester.pumpWidget(enApp(pantallaCarritos()));
      expect(find.text('Carrito #12'), findsOneWidget);
      expect(find.text('20 oct 2026'), findsOneWidget);
      expect(find.textContaining('ID 4'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Usuario ID 77'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Usuario ID 77'), findsOneWidget);
    });

    testWidgets('US12 al expandir se ven los títulos reales y cantidades', (
      tester,
    ) async {
      await tester.pumpWidget(enApp(pantallaCarritos()));
      expect(find.text('Hades'), findsNothing);
      await tester.tap(find.text('Carrito #12'));
      await tester.pumpAndSettle();
      expect(find.text('Hades'), findsOneWidget);
      expect(find.textContaining('ID 2 · 1 ×'), findsOneWidget);
      expect(find.text('Juego #99'), findsOneWidget);
    });

    testWidgets('US12 es solo lectura: no hay botones de editar o borrar', (
      tester,
    ) async {
      await tester.pumpWidget(enApp(pantallaCarritos()));
      await tester.tap(find.text('Carrito #12'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.remove), findsNothing);
    });

    for (final escala in [1.0, 2.0]) {
      testWidgets('US11 no se desborda con letra al ${escala}x', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360 * 3, 780 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(enApp(pantallaUsuarios(), escala: escala));
        await tester.scrollUntilVisible(
          find.text('Angel Ramirez'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Angel Ramirez'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('US12 no se desborda con letra al ${escala}x', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360 * 3, 780 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(enApp(pantallaCarritos(), escala: escala));
        await tester.scrollUntilVisible(
          find.text('Carrito #12'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Carrito #12'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
