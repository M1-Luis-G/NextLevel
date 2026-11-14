package com.nextlevel.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import com.nextlevel.model.Pedido;
import com.nextlevel.model.Producto;

public class AdminDashboardDto {
    private int totalProductos;
    private int totalPedidos;
    private int stockCritico;
    private BigDecimal ventasAprobadas;
    private List<Producto> stockBajo;
    private List<Pedido> pedidosRecientes;
    private Map<String, Long> categoriasResumen;

    public AdminDashboardDto() {}

    public AdminDashboardDto(int totalProductos, int totalPedidos, int stockCritico,
                             BigDecimal ventasAprobadas, List<Producto> stockBajo,
                             List<Pedido> pedidosRecientes, Map<String, Long> categoriasResumen) {
        this.totalProductos = totalProductos;
        this.totalPedidos = totalPedidos;
        this.stockCritico = stockCritico;
        this.ventasAprobadas = ventasAprobadas;
        this.stockBajo = stockBajo;
        this.pedidosRecientes = pedidosRecientes;
        this.categoriasResumen = categoriasResumen;
    }

    public int getTotalProductos() { return totalProductos; }
    public void setTotalProductos(int totalProductos) { this.totalProductos = totalProductos; }
    
    public int getTotalPedidos() { return totalPedidos; }
    public void setTotalPedidos(int totalPedidos) { this.totalPedidos = totalPedidos; }
    
    public int getStockCritico() { return stockCritico; }
    public void setStockCritico(int stockCritico) { this.stockCritico = stockCritico; }
    
    public BigDecimal getVentasAprobadas() { return ventasAprobadas; }
    public void setVentasAprobadas(BigDecimal ventasAprobadas) { this.ventasAprobadas = ventasAprobadas; }
    
    public List<Producto> getStockBajo() { return stockBajo; }
    public void setStockBajo(List<Producto> stockBajo) { this.stockBajo = stockBajo; }
    
    public List<Pedido> getPedidosRecientes() { return pedidosRecientes; }
    public void setPedidosRecientes(List<Pedido> pedidosRecientes) { this.pedidosRecientes = pedidosRecientes; }
    
    public Map<String, Long> getCategoriasResumen() { return categoriasResumen; }
    public void setCategoriasResumen(Map<String, Long> categoriasResumen) { this.categoriasResumen = categoriasResumen; }
}