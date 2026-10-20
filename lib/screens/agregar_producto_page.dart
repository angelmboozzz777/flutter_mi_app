import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import '../widgets/agregar_producto_widgets.dart';

class AgregarProductoPage extends StatefulWidget {
  final String role;

  const AgregarProductoPage({
    super.key,
    required this.role,
  });

  @override
  State<AgregarProductoPage> createState() =>
      _AgregarProductoPageState();
}

class _AgregarProductoPageState
    extends State<AgregarProductoPage> {
  final ProductoService productoService =
      ProductoService();

  final TextEditingController tituloController =
      TextEditingController();

  final TextEditingController precioController =
      TextEditingController();

  final TextEditingController descripcionController =
      TextEditingController();

  final TextEditingController imagenController =
      TextEditingController();

  final TextEditingController categoriaController =
      TextEditingController();

  final TextEditingController plataformaController =
      TextEditingController(text: 'PC');

  final TextEditingController stockController =
      TextEditingController(text: '0');

  // Cuántos productos se crearon en esta pantalla.
  // HomePage lo usa para saber si debe recargar la lista.
  int productosCreados = 0;

  bool guardando = false;

  String? errorTitulo;
  String? errorPrecio;
  String? errorDescripcion;
  String? errorImagen;
  String? errorCategoria;
  String? errorStock;

  @override
  void initState() {
    super.initState();

    verificarAcceso();
  }

  @override
  void dispose() {
    tituloController.dispose();
    precioController.dispose();
    descripcionController.dispose();
    imagenController.dispose();
    categoriaController.dispose();
    plataformaController.dispose();
    stockController.dispose();

    super.dispose();
  }

  // Verifica que solamente el administrador
  // pueda entrar a esta pantalla.
  void verificarAcceso() {
    if (widget.role != 'Administrador') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.pop(context);
      });
    }
  }

  // Guarda el nuevo producto.
  Future<void> guardarProducto() async {
    if (widget.role != 'Administrador') {
      return;
    }

    setState(() {
      limpiarErrores();
    });

    final bool valido = validarCampos();

    if (!valido) {
      setState(() {});
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final producto = Producto(
        id: 0,
        title: tituloController.text.trim(),
        price: double.parse(
          precioController.text.trim(),
        ),
        description:
            descripcionController.text.trim(),
        category:
            categoriaController.text.trim(),
        image: imagenController.text.trim(),
        platform: plataformaController.text.trim(),
        stock: int.parse(stockController.text.trim()),
      );

      final resultado =
          await productoService.crearProducto(
        producto,
      );

      if (!mounted) return;

      setState(() {
        guardando = false;
        productosCreados++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${resultado.title}" agregado a la tienda. ID: ${resultado.id}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      limpiarFormulario();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      // Mostramos el motivo real (permiso, validación, conexión...).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Valida los campos antes de hacer el POST.
  bool validarCampos() {
    bool valido = true;

    if (tituloController.text.trim().isEmpty) {
      errorTitulo = 'El título es obligatorio';
      valido = false;
    }

    final precioTexto =
        precioController.text.trim();

    if (precioTexto.isEmpty) {
      errorPrecio = 'El precio es obligatorio';
      valido = false;
    } else if (double.tryParse(precioTexto) == null) {
      errorPrecio = 'El precio debe ser numérico';
      valido = false;
    } else if (double.parse(precioTexto) <= 0) {
      errorPrecio = 'El precio debe ser mayor que 0';
      valido = false;
    }

    if (descripcionController.text.trim().isEmpty) {
      errorDescripcion =
          'La descripción es obligatoria';
      valido = false;
    }

    final imagenTexto =
        imagenController.text.trim();

    if (imagenTexto.isEmpty) {
      errorImagen =
          'La URL de imagen es obligatoria';
      valido = false;
    } else {
      final uri = Uri.tryParse(imagenTexto);

      final bool urlValida =
          uri != null &&
          uri.hasScheme &&
          uri.hasAuthority &&
          (uri.scheme == 'http' ||
              uri.scheme == 'https');

      if (!urlValida) {
        errorImagen =
            'Ingresa una URL válida';
        valido = false;
      }
    }

    if (categoriaController.text.trim().isEmpty) {
      errorCategoria =
          'La categoría es obligatoria';
      valido = false;
    }

    final int? stock =
        int.tryParse(stockController.text.trim());

    if (stock == null || stock < 0) {
      errorStock = 'El stock debe ser un número entero (0 o más)';
      valido = false;
    }

    return valido;
  }

  void limpiarErrores() {
    errorTitulo = null;
    errorPrecio = null;
    errorDescripcion = null;
    errorImagen = null;
    errorCategoria = null;
    errorStock = null;
  }

  void limpiarFormulario() {
    tituloController.clear();
    precioController.clear();
    descripcionController.clear();
    imagenController.clear();
    categoriaController.clear();
    plataformaController.text = 'PC';
    stockController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Regresamos cuántos productos se crearon.
        Navigator.pop(context, productosCreados);
      },
      child: AgregarProductoWidgets(
      tituloController: tituloController,
      precioController: precioController,
      descripcionController:
          descripcionController,
      imagenController: imagenController,
      categoriaController:
          categoriaController,
      plataformaController: plataformaController,
      stockController: stockController,
      guardando: guardando,
      errorTitulo: errorTitulo,
      errorPrecio: errorPrecio,
      errorDescripcion: errorDescripcion,
      errorImagen: errorImagen,
      errorCategoria: errorCategoria,
      errorStock: errorStock,
      onGuardar: guardarProducto,
      ),
    );
  }
}