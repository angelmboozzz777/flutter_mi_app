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

  bool guardando = false;

  String? errorTitulo;
  String? errorPrecio;
  String? errorDescripcion;
  String? errorImagen;
  String? errorCategoria;

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
      );

      final resultado =
          await productoService.crearProducto(
        producto,
      );

      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Producto creado correctamente. ID: ${resultado.id}',
          ),
        ),
      );

      limpiarFormulario();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo crear el producto.',
          ),
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

    return valido;
  }

  void limpiarErrores() {
    errorTitulo = null;
    errorPrecio = null;
    errorDescripcion = null;
    errorImagen = null;
    errorCategoria = null;
  }

  void limpiarFormulario() {
    tituloController.clear();
    precioController.clear();
    descripcionController.clear();
    imagenController.clear();
    categoriaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AgregarProductoWidgets(
      tituloController: tituloController,
      precioController: precioController,
      descripcionController:
          descripcionController,
      imagenController: imagenController,
      categoriaController:
          categoriaController,
      guardando: guardando,
      errorTitulo: errorTitulo,
      errorPrecio: errorPrecio,
      errorDescripcion: errorDescripcion,
      errorImagen: errorImagen,
      errorCategoria: errorCategoria,
      onGuardar: guardarProducto,
    );
  }
}