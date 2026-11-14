import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';
import '../services/productoservice.dart';
import '../viewmodels/productoviewmodel.dart';
import '../viewmodels/authviewmodel.dart';
import 'loginview.dart';

class CatalogoView extends StatefulWidget {
  const CatalogoView({super.key});

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  int _indiceNavegacion = 1;
  bool _esAdmin = false;

  final ScrollController _scrollController = ScrollController();
  final ProductoService _imagenService = ProductoService();
  final ImagePicker _picker = ImagePicker();
  int _ultimoTamanoCalculado = 0;

  @override
  void initState() {
    super.initState();
    _verificarRolUsuario();
    _scrollController.addListener(_detectarScrollAlFinal);
  }

  void _detectarScrollAlFinal() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      Provider.of<ProductoViewModel>(
        context,
        listen: false,
      ).cargarMasProductos();
    }
  }

  Future<void> _verificarRolUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final roles = prefs.getStringList('user_roles') ?? [];
    if (mounted) {
      setState(() {
        _esAdmin = roles.contains('ROLE_ADMIN');
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_detectarScrollAlFinal);
    _scrollController.dispose();
    super.dispose();
  }

  void _mostrarDialogoAyuda() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF5C317A)),
            SizedBox(width: 8),
            Text('Ayuda - Nextlevel Store'),
          ],
        ),
        content: const Text(
          '• En Inicio se cargan automáticamente los productos que caben en tu pantalla y más al bajar.\n'
          '• En Indicadores puedes revisar el resumen del inventario.\n'
          '• En Categoría puedes filtrar los productos por tipo.\n'
          '• Usa el botón (+) en la esquina inferior derecha para registrar nuevos productos y subir imágenes desde tu PC.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    await authVM.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  void _mostrarFormularioAgregarProducto() {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final categoriaCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    Uint8List? bytesArchivoSeleccionado;
    String? nombreArchivoSeleccionado;
    bool guardando = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (stfContext, setDialogState) {
                return Container(
                  width: 390,
                  margin: const EdgeInsets.only(
                    left: 16,
                    top: 24,
                    bottom: 24,
                    right: 16,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C317A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white38, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 16,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Registrar Producto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nombreCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Nombre del producto',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: precioCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Precio (ej. 45000)',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: categoriaCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Categoría (ej. Consolas, Juegos)',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Stock disponible',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Descripción del producto',
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            final XFile? archivo = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (archivo != null) {
                              final bytes = await archivo.readAsBytes();
                              setDialogState(() {
                                bytesArchivoSeleccionado = bytes;
                                nombreArchivoSeleccionado = archivo.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            nombreArchivoSeleccionado ??
                                'Subir imagen desde mi computadora',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (bytesArchivoSeleccionado != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 120,
                              child: Image.memory(
                                bytesArchivoSeleccionado!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        guardando
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  if (nombreCtrl.text.trim().isEmpty ||
                                      precioCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Completa al menos el nombre y el precio',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    guardando = true;
                                  });

                                  String rutaImagenFinal = '/images/prod1.png';

                                  if (bytesArchivoSeleccionado != null &&
                                      nombreArchivoSeleccionado != null) {
                                    final rutaSubida = await _imagenService
                                        .subirImagenBytes(
                                          bytesArchivoSeleccionado!,
                                          nombreArchivoSeleccionado!,
                                        );
                                    if (rutaSubida != null) {
                                      rutaImagenFinal = rutaSubida;
                                    }
                                  }

                                  final nuevo = Producto(
                                    nombre: nombreCtrl.text.trim(),
                                    precio:
                                        double.tryParse(
                                          precioCtrl.text.trim(),
                                        ) ??
                                        0.0,
                                    categoria: categoriaCtrl.text.trim().isEmpty
                                        ? 'General'
                                        : categoriaCtrl.text.trim(),
                                    stock:
                                        int.tryParse(stockCtrl.text.trim()) ??
                                        1,
                                    descripcion: descCtrl.text.trim(),
                                    imagenUrl: rutaImagenFinal,
                                  );

                                  if (!dialogContext.mounted) return;
                                  final prodVM = Provider.of<ProductoViewModel>(
                                    dialogContext,
                                    listen: false,
                                  );
                                  final exito = await prodVM.agregarProducto(
                                    nuevo,
                                  );

                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        exito
                                            ? '¡Producto e imagen guardados en la base de datos!'
                                            : prodVM.errorMessage,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Guardar Producto'),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prodVM = Provider.of<ProductoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C317A),
        elevation: 0,
        centerTitle: true,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onSelected: (valor) {
            if (valor == 'ayuda') _mostrarDialogoAyuda();
            if (valor == 'salir') _cerrarSesion();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ayuda',
              child: ListTile(
                leading: Icon(Icons.help_outline, color: Color(0xFF5C317A)),
                title: Text('Ayuda'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'salir',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.redAccent),
                title: Text('Salir'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        title: const Text(
          'Nextlevel store',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Times New Roman',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                tooltip: _esAdmin ? 'Rol: Administrador' : 'Rol: Cliente',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _esAdmin
                            ? 'Sesión activa: Administrador'
                            : 'Sesión activa: Cliente',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: _construirVistaActual(prodVM),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _esAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5C317A),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.black87, width: 2),
              ),
              onPressed: _mostrarFormularioAgregarProducto,
              child: const Icon(Icons.add, size: 32),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF4A2563),
        indicatorColor: const Color(0xFF85679A),
        selectedIndex: _indiceNavegacion,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _indiceNavegacion = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.bar_chart, color: Colors.white),
            label: 'Indicadores',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.category, color: Colors.white),
            label: 'Categoría',
          ),
        ],
      ),
    );
  }

  Widget _construirVistaActual(ProductoViewModel prodVM) {
    if (prodVM.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_indiceNavegacion == 0) {
      return _construirVistaIndicadores(prodVM);
    } else if (_indiceNavegacion == 2) {
      return _construirVistaCategorias(prodVM);
    }
    return _construirCuadriculaProductos(prodVM.productosFiltrados);
  }

  Widget _construirCuadriculaProductos(List<Producto> listaProductos) {
    final prodVM = Provider.of<ProductoViewModel>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double anchoMaximoTarjeta = 210.0;
        const double relacionAspecto = 0.78;

        final int columnas = (constraints.maxWidth / anchoMaximoTarjeta)
            .ceil()
            .clamp(2, 8);
        final double anchoRealTarjeta = constraints.maxWidth / columnas;
        final double altoRealTarjeta = anchoRealTarjeta / relacionAspecto;

        final int filasVisibles =
            (constraints.maxHeight / altoRealTarjeta).ceil() + 1;
        final int productosQueCaben = (columnas * filasVisibles).clamp(6, 30);

        if (_ultimoTamanoCalculado != productosQueCaben) {
          _ultimoTamanoCalculado = productosQueCaben;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (prodVM.productos.isEmpty &&
                !prodVM.isLoading &&
                prodVM.errorMessage.isEmpty) {
              prodVM.cargarProductos(sizeInicial: productosQueCaben);
            } else {
              prodVM.actualizarTamanoPagina(productosQueCaben);
            }
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients &&
              _scrollController.position.maxScrollExtent == 0 &&
              prodVM.hayMasPaginas &&
              !prodVM.isLoadingMore &&
              listaProductos.isNotEmpty) {
            prodVM.cargarMasProductos();
          }
        });

        if (listaProductos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white70,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay productos registrados aún',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if (prodVM.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      prodVM.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 45),
                    ),
                    onPressed: () =>
                        prodVM.cargarProductos(sizeInicial: productosQueCaben),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recargar'),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: listaProductos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: relacionAspecto,
                  ),
                  itemBuilder: (context, index) {
                    final prod = listaProductos[index];
                    final inicial = prod.nombre.isNotEmpty
                        ? prod.nombre[0].toUpperCase()
                        : 'P';

                    return Card(
                      color: Colors.white.withValues(alpha: 0.92),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF85679A),
                                  child: Text(
                                    inicial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prod.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        '\$${prod.precio.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5C317A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Expanded(
                              child: Center(
                                child:
                                    prod.imagenUrl != null &&
                                        prod.imagenUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _ImagenProductoApi(
                                          url: prod.imagenUrl!,
                                          servicio: _imagenService,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.widgets_rounded,
                                        size: 64,
                                        color: Colors.black26,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              prod.descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    prod.categoria,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                Text(
                                  'Stock: ${prod.stock}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (prodVM.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirVistaIndicadores(ProductoViewModel prodVM) {
    final totalProductos = prodVM.productos.length;
    final stockTotal = prodVM.productos.fold<int>(0, (sum, p) => sum + p.stock);
    final valorInventario = prodVM.productos.fold<double>(
      0,
      (sum, p) => sum + (p.precio * p.stock),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Indicadores de Tienda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF5C317A),
              child: Icon(Icons.inventory, color: Colors.white),
            ),
            title: const Text('Productos Cargados en Vista'),
            trailing: Text(
              '$totalProductos',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF5C317A),
              child: Icon(Icons.layers, color: Colors.white),
            ),
            title: const Text('Unidades en Stock'),
            trailing: Text(
              '$stockTotal',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF5C317A),
              child: Icon(Icons.attach_money, color: Colors.white),
            ),
            title: const Text('Valor del Inventario Cargado'),
            trailing: Text(
              '\$${valorInventario.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirVistaCategorias(ProductoViewModel prodVM) {
    final categorias = prodVM.categoriasDisponibles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Filtrar por Categoría',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            children: categorias.map((cat) {
              final seleccionada = prodVM.categoriaSeleccionada == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: seleccionada,
                onSelected: (_) {
                  prodVM.seleccionarCategoria(cat);
                  setState(() {
                    _indiceNavegacion = 1;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ImagenProductoApi extends StatefulWidget {
  final String url;
  final ProductoService servicio;

  const _ImagenProductoApi({required this.url, required this.servicio});

  @override
  State<_ImagenProductoApi> createState() => _ImagenProductoApiState();
}

class _ImagenProductoApiState extends State<_ImagenProductoApi> {
  late Future<Uint8List?> _futureBytes;

  @override
  void initState() {
    super.initState();
    _futureBytes = widget.servicio.obtenerBytesImagen(widget.url);
  }

  @override
  void didUpdateWidget(covariant _ImagenProductoApi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _futureBytes = widget.servicio.obtenerBytesImagen(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _futureBytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            cacheWidth: 300,
            errorBuilder: (_, _, _) => const Icon(
              Icons.widgets_rounded,
              size: 56,
              color: Colors.black26,
            ),
          );
        }
        return const Icon(
          Icons.widgets_rounded,
          size: 56,
          color: Colors.black26,
        );
      },
    );
  }
}
