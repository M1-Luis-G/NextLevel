import 'package:material_ui/material_ui.dart';

import '../models/producto.dart';
import '../services/productoservice.dart';

class ProductoViewModel extends ChangeNotifier {
  final ProductoService _productoService = ProductoService();

  List<Producto> _productos = [];
  List<Producto> get productos => _productos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _categoriaSeleccionada = 'Todas';
  String get categoriaSeleccionada => _categoriaSeleccionada;

  int _paginaActual = 0;
  int _tamanoPagina =
      6; // Se actualiza dinámicamente según el tamaño de la pantalla
  bool _hayMasPaginas = true;
  bool get hayMasPaginas => _hayMasPaginas;

  List<Producto> get productosFiltrados {
    if (_categoriaSeleccionada == 'Todas') return _productos;
    return _productos
        .where(
          (p) =>
              p.categoria.toLowerCase() == _categoriaSeleccionada.toLowerCase(),
        )
        .toList();
  }

  List<String> get categoriasDisponibles {
    final cats = _productos.map((p) => p.categoria).toSet().toList();
    return ['Todas', ...cats];
  }

  // Ajusta cuántos productos pedir por lote según lo que quepa en la pantalla actual
  void actualizarTamanoPagina(int nuevoTamano) {
    if (nuevoTamano > 0 && _tamanoPagina != nuevoTamano) {
      _tamanoPagina = nuevoTamano;
      if (_productos.isEmpty && !_isLoading) {
        cargarProductos();
      }
    }
  }

  Future<void> cargarProductos({int? sizeInicial}) async {
    if (sizeInicial != null && sizeInicial > 0) {
      _tamanoPagina = sizeInicial;
    }

    _isLoading = true;
    _errorMessage = '';
    _paginaActual = 0;
    _hayMasPaginas = true;
    notifyListeners();

    try {
      final nuevos = await _productoService.obtenerProductos(
        page: _paginaActual,
        size: _tamanoPagina,
      );
      _productos = nuevos;
      if (nuevos.length < _tamanoPagina) {
        _hayMasPaginas = false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarMasProductos() async {
    if (_isLoading || _isLoadingMore || !_hayMasPaginas) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final siguientePagina = _paginaActual + 1;
      final nuevos = await _productoService.obtenerProductos(
        page: siguientePagina,
        size: _tamanoPagina,
      );

      if (nuevos.isEmpty) {
        _hayMasPaginas = false;
      } else {
        _paginaActual = siguientePagina;
        _productos.addAll(nuevos);
        if (nuevos.length < _tamanoPagina) {
          _hayMasPaginas = false;
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> agregarProducto(Producto producto) async {
    try {
      final exito = await _productoService.crearProducto(producto);
      if (exito) {
        await cargarProductos();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void seleccionarCategoria(String categoria) {
    _categoriaSeleccionada = categoria;
    notifyListeners();
  }
}
