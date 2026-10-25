package com.roy.ecommerce.module.catalog.model;
  
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
  
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Product { //products table
    
    private Long id;
    private String name;
    private String slug;
    private String description;
    private BigDecimal price;
    private Long categoryId;
    private double averageRating;
    private boolean featured;
    private boolean active;
    private List<ProductImage> productImages;
    private LocalDateTime createdAt;
}
