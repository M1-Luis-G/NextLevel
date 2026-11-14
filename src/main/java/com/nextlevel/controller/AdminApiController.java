package com.nextlevel.controller;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.nextlevel.dto.AdminDashboardDto;
import com.nextlevel.dto.SalesPredictionRequest;
import com.nextlevel.dto.SalesPredictionResponse;
import com.nextlevel.model.EstadoPago;
import com.nextlevel.model.EstadoPedido;
import com.nextlevel.model.Pedido;
import com.nextlevel.model.Producto;
import com.nextlevel.service.CategoriaService;
import com.nextlevel.service.PedidoService;
import com.nextlevel.service.PredictionClientService;
import com.nextlevel.service.ProductoService;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminApiController {

    private final ProductoService productoService;
    private final PedidoService pedidoService;
    private final CategoriaService categoriaService;
    private final PredictionClientService predictionClientService;

    public AdminApiController(ProductoService productoService,
                              PedidoService pedidoService,
                              CategoriaService categoriaService,
                              PredictionClientService predictionClientService) {
        this.productoService = productoService;
        this.pedidoService = pedidoService;
        this.categoriaService = categoriaService;
        this.predictionClientService = predictionClientService;
    }

    // --- DASHBOARD ---
    @GetMapping("/dashboard")
    public ResponseEntity<AdminDashboardDto> obtenerDashboard() {
        List<Producto> productos = productoService.listar();
        List<Pedido> pedidos = pedidoService.listarTodos();
        
        List<Producto> stockBajo = productoService.listarStockBajo(5).stream()
                .sorted(Comparator.comparing(Producto::getStock))
                .limit(8)
                .toList();

        Map<String, Long> categoriasResumen = productos.stream().collect(Collectors.groupingBy(
                p -> p.getCategoriaNombre() == null ? "Sin categoría" : p.getCategoriaNombre(),
                Collectors.counting()));

        BigDecimal ventasAprobadas = pedidos.stream()
                .filter(p -> p.getEstadoPago() == EstadoPago.APROBADO)
                .map(Pedido::getTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return ResponseEntity.ok(new AdminDashboardDto(
                productos.size(),
                pedidos.size(),
                stockBajo.size(),
                ventasAprobadas,
                stockBajo,
                pedidos.stream().limit(10).toList(),
                categoriasResumen
        ));
    }

    // --- GESTIÓN DE PRODUCTOS ---
    @GetMapping("/productos")
    public ResponseEntity<List<Producto>> listarProductos() {
        return ResponseEntity.ok(productoService.listar());
    }

    @PostMapping("/productos")
    public ResponseEntity<?> guardarProducto(@RequestBody Producto producto) {
        try {
            Producto guardado = productoService.guardar(producto);
            return ResponseEntity.ok(guardado);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of("error", ex.getMessage()));
        }
    }

    @DeleteMapping("/productos/{id}")
    public ResponseEntity<?> eliminarProducto(@PathVariable String id) {
        productoService.eliminar(id);
        return ResponseEntity.ok(Map.of("mensaje", "Producto eliminado correctamente"));
    }

    @GetMapping("/reportes/stock")
    public ResponseEntity<List<Producto>> reporteStockCritico() {
        return ResponseEntity.ok(productoService.listarStockBajo(5));
    }

    // --- GESTIÓN DE PEDIDOS ---
    @GetMapping("/pedidos")
    public ResponseEntity<List<Pedido>> listarPedidos() {
        return ResponseEntity.ok(pedidoService.listarTodos());
    }

    @PutMapping("/pedidos/{id}/estado")
    public ResponseEntity<Pedido> actualizarEstadoPedido(
            @PathVariable String id,
            @RequestParam EstadoPedido estado,
            @RequestParam(required = false) String trackingCode) {
        Pedido pedidoActualizado = pedidoService.actualizarSeguimiento(id, estado, trackingCode);
        return ResponseEntity.ok(pedidoActualizado);
    }

    // --- PREDICCIÓN DE VENTAS ---
    @PostMapping("/prediccion")
    public ResponseEntity<SalesPredictionResponse> predecirVentas(@RequestBody SalesPredictionRequest request) {
        return ResponseEntity.ok(predictionClientService.predict(request));
    }
}