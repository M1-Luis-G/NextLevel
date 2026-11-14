package com.nextlevel.controller.api;

import com.nextlevel.model.Producto;
import com.nextlevel.repository.ProductoRepository;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Collections;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin(origins = "*")
public class ProductoApiController {

    private final ProductoRepository productoRepository;

    public ProductoApiController(ProductoRepository productoRepository) {
        this.productoRepository = productoRepository;
    }

    @GetMapping
    public ResponseEntity<Page<Producto>> listarProductos(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "6") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(productoRepository.findAll(pageable));
    }

    @GetMapping("/imagen/{nombreArchivo:.+}")
    public ResponseEntity<byte[]> obtenerImagen(@PathVariable String nombreArchivo) {
        try {
            Path rutaTarget = Paths.get("target/classes/static/images", nombreArchivo);
            Path rutaSrc = Paths.get("src/main/resources/static/images", nombreArchivo);
            byte[] bytes;

            if (Files.exists(rutaTarget)) {
                bytes = Files.readAllBytes(rutaTarget);
            } else if (Files.exists(rutaSrc)) {
                bytes = Files.readAllBytes(rutaSrc);
            } else {
                Resource imgFile = new ClassPathResource("static/images/" + nombreArchivo);
                if (!imgFile.exists()) {
                    imgFile = new ClassPathResource("static/images/prod1.png");
                }
                bytes = StreamUtils.copyToByteArray(imgFile.getInputStream());
            }

            MediaType mediaType = MediaType.IMAGE_JPEG;
            if (bytes.length > 4 && bytes[0] == (byte) 0x89 && bytes[1] == (byte) 0x50) {
                mediaType = MediaType.IMAGE_PNG;
            }
            return ResponseEntity.ok()
                    .contentType(mediaType)
                    .body(bytes);
        } catch (IOException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/subir-imagen")
    public ResponseEntity<Map<String, String>> subirImagen(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Archivo vacio"));
        }
        try {
            String original = file.getOriginalFilename() != null ? file.getOriginalFilename() : "img.png";
            String limpio = original.replaceAll("[^a-zA-Z0-9._-]", "_");
            String nombreFinal = UUID.randomUUID().toString().substring(0, 8) + "_" + limpio;

            Path dirSrc = Paths.get("src/main/resources/static/images");
            Path dirTarget = Paths.get("target/classes/static/images");
            Files.createDirectories(dirSrc);
            Files.createDirectories(dirTarget);

            Path destinoSrc = dirSrc.resolve(nombreFinal);
            Path destinoTarget = dirTarget.resolve(nombreFinal);

            Files.copy(file.getInputStream(), destinoSrc, StandardCopyOption.REPLACE_EXISTING);
            Files.copy(destinoSrc, destinoTarget, StandardCopyOption.REPLACE_EXISTING);

            return ResponseEntity.ok(Collections.singletonMap("ruta", "/images/" + nombreFinal));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("error", "No se pudo guardar la imagen"));
        }
    }

    @PostMapping
    public ResponseEntity<Producto> crearProducto(@RequestBody Producto producto) {
        if (producto.getImagen() == null || producto.getImagen().trim().isEmpty()) {
            producto.setImagen("/images/prod1.png");
        }
        if (producto.getPrecio() == null) {
            producto.setPrecio(BigDecimal.ZERO);
        }
        if (producto.getStock() == null) {
            producto.setStock(1);
        }
        Producto guardado = productoRepository.save(producto);
        return ResponseEntity.status(HttpStatus.CREATED).body(guardado);
    }
}