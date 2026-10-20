import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_app/main.dart';
import 'package:mi_app/models/item_carrito.dart';
import 'package:mi_app/models/producto.dart';
import 'package:mi_app/theme/game_theme.dart';
import 'package:mi_app/widgets/agregar_producto_widgets.dart';
import 'package:mi_app/widgets/carrito_widgets.dart';
import 'package:mi_app/widgets/home_widgets.dart';
import 'package:mi_app/widgets/login_widgets.dart';
import 'package:mi_app/widgets/producto_detail_widgets.dart';
import 'package:mi_app/widgets/profile_widgets.dart';

Producto juego({int id = 1, double price = 249.5, int stock = 10}) {
  return Producto(
    id: id,
    title: 'Hollow Knight',
    price: price,
    description: 'Metroidvania',
    category: 'Indie',
    image: 'https://example.com/portada.jpg',
    platform: 'PC',
    stock: stock,
  );
}

void main() {
  testWidgets('La app abre en la pantalla de inicio de sesión',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  group('Producto', () {
    test('acepta id 0 al crear un producto nuevo (US06)', () {
      expect(() => juego(id: 0), returnsNormally);
    });

    test('no manda el id a la API', () {
      expect(juego().toJson().containsKey('id'), isFalse);
    });

    test('lee platform y stock del JSON', () {
      final producto = Producto.fromJson({
        'id': 3,
        'title': 'Hades',
        'price': 349,
        'description': 'Roguelike',
        'category': 'Indie',
        'image': 'https://example.com/hades.jpg',
        'platform': 'Nintendo Switch',
        'stock': 80,
      });

      expect(producto.platform, 'Nintendo Switch');
      expect(producto.stock, 80);
    });
  });

  group('Carrito', () {
    test('el subtotal es precio por cantidad con dos decimales', () {
      final item = ItemCarrito(producto: juego(price: 0.1), cantidad: 3);
      expect(item.subtotal, 0.3);
    });

    test('manda gameId y quantity a la API', () {
      final item = ItemCarrito(producto: juego(id: 7), cantidad: 2);
      expect(item.toJson(), {'gameId': 7, 'quantity': 2});
    });

    test('la cantidad no puede ser menor que 1', () {
      expect(
        () => ItemCarrito(producto: juego(), cantidad: 0),
        throwsArgumentError,
      );
    });
  });

  group('Catálogo', () {
    // Si el texto no cabe, Flutter lanza un error de "overflow" y la
    // prueba falla.
    for (final double escala in [1.0, 1.3, 1.5, 2.0]) {
      testWidgets('las tarjetas no se desbordan con letra al ${escala}x',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360 * 3, 780 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final productos = [
          for (int i = 1; i <= 4; i++)
            Producto(
              id: i,
              title: 'The Legend of Zelda: Tears of the Kingdom $i',
              price: 1399.99 * i,
              description: 'Aventura',
              category: 'Aventura y exploración',
              image: 'https://example.com/$i.jpg',
              platform: 'Nintendo Switch',
              stock: i == 2 ? 0 : 5,
            ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: GameTheme.tema,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(360, 780),
                textScaler: TextScaler.linear(escala),
              ),
              child: HomeWidgets(
                nombreUsuario: 'Demo Gamer',
                categoriaSeleccionada: 'Todos',
                categorias: const ['Aventura', 'RPG', 'Indie'],
                productos: productos,
                cargandoProductos: false,
                cargandoCategorias: false,
                errorProductos: null,
                onPerfil: () {},
                onAgregarProducto: () {},
                onRecargar: () async {},
                onCategoria: (_) {},
                onProducto: (_) {},
                esAdministrador: true,
                puedeComprar: true,
                onCarrito: () {},
                onAgregarRapido: (_) {},
                busqueda: '',
                onBuscar: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('Tears of the Kingdom'), findsWidgets);
      });
    }
  });

  group('Pantallas con letra grande', () {
    final producto = juego(price: 1399.99, stock: 5);

    final Map<String, Widget Function()> pantallas = {
      'login': () => LoginWidgets(
            usuarioController: TextEditingController(),
            passwordController: TextEditingController(),
            mostrarPassword: false,
            cargando: false,
            onLogin: () {},
            onMostrarPassword: () {},
          ),
      'detalle': () => ProductoDetailWidgets(
            producto: producto,
            esAdministrador: true,
            procesando: false,
            onEditar: () {},
            onEliminar: () {},
            puedeComprar: true,
            cantidad: 1,
            agregando: false,
            onCambiarCantidad: (_) {},
            onAgregarCarrito: () {},
            maxCantidad: 5,
          ),
      'carrito': () => CarritoWidgets(
            items: [
              ItemCarrito(producto: producto, cantidad: 12),
              ItemCarrito(producto: juego(id: 2, price: 99999.99), cantidad: 3),
            ],
            total: 316799.85,
            totalPiezas: 15,
            onCambiarCantidad: (_, _) {},
            onEliminar: (_) {},
            onPagar: () {},
            onExplorar: () {},
          ),
      'carrito vacío': () => CarritoWidgets(
            items: const [],
            total: 0,
            totalPiezas: 0,
            onCambiarCantidad: (_, _) {},
            onEliminar: (_) {},
            onPagar: () {},
            onExplorar: () {},
          ),
      'perfil': () => ProfileWidgets(
            role: 'Administrador',
            nombreCompleto: 'Angel Alejandro Martínez',
            username: 'angel',
            userId: '4',
            email: 'angel.alejandro@gamestore.com',
            phone: '4421234567',
            calle: 'Avenida Universidad',
            numero: '100',
            ciudad: 'Querétaro',
            codigoPostal: '76000',
            latitud: '0',
            longitud: '0',
            roleColor: GameColors.acento,
            roleIcon: Icons.admin_panel_settings,
            descripcion: 'Usuario con permisos administrativos',
            onCerrarSesion: () {},
          ),
      'agregar juego': () => AgregarProductoWidgets(
            tituloController: TextEditingController(),
            precioController: TextEditingController(),
            descripcionController: TextEditingController(),
            imagenController: TextEditingController(),
            categoriaController: TextEditingController(),
            plataformaController: TextEditingController(text: 'PC'),
            stockController: TextEditingController(text: '0'),
            guardando: false,
            errorTitulo: 'El título es obligatorio',
            errorPrecio: 'El precio debe ser mayor que 0',
            errorDescripcion: null,
            errorImagen: null,
            errorCategoria: null,
            errorStock: 'El stock debe ser un número entero (0 o más)',
            onGuardar: () {},
          ),
    };

    for (final entrada in pantallas.entries) {
      for (final double escala in [1.0, 2.0]) {
        testWidgets('${entrada.key} no se desborda con letra al ${escala}x',
            (WidgetTester tester) async {
          tester.view.physicalSize = const Size(360 * 3, 780 * 3);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MaterialApp(
              theme: GameTheme.tema,
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(360, 780),
                  textScaler: TextScaler.linear(escala),
                ),
                child: entrada.value(),
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('formatoPrecio', () {
    test('agrega separador de miles y dos decimales', () {
      expect(formatoPrecio(1199), '\$1,199.00');
      expect(formatoPrecio(249.5), '\$249.50');
      expect(formatoPrecio(1234567.891), '\$1,234,567.89');
    });
  });
}
