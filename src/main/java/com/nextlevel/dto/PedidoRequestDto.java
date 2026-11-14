package com.nextlevel.dto;

import java.math.BigDecimal;
import java.util.List;
import com.nextlevel.model.CarritoItem;

public class PedidoRequestDto {
    private String direccionEnvio;
    private String ciudadEnvio;
    private String departamentoEnvio;
    private String metodoPagoId; 
    private BigDecimal costoEnvio;
    private List<CarritoItem> items;

    public String getDireccionEnvio() { return direccionEnvio; }
    public void setDireccionEnvio(String direccionEnvio) { this.direccionEnvio = direccionEnvio; }

    public String getCiudadEnvio() { return ciudadEnvio; }
    public void setCiudadEnvio(String ciudadEnvio) { this.ciudadEnvio = ciudadEnvio; }

    public String getDepartamentoEnvio() { return departamentoEnvio; }
    public void setDepartamentoEnvio(String departamentoEnvio) { this.departamentoEnvio = departamentoEnvio; }

    public String getMetodoPagoId() { return metodoPagoId; }
    public void setMetodoPagoId(String metodoPagoId) { this.metodoPagoId = metodoPagoId; }

    public BigDecimal getCostoEnvio() { return costoEnvio; }
    public void setCostoEnvio(BigDecimal costoEnvio) { this.costoEnvio = costoEnvio; }

    public List<CarritoItem> getItems() { return items; }
    public void setItems(List<CarritoItem> items) { this.items = items; }
}