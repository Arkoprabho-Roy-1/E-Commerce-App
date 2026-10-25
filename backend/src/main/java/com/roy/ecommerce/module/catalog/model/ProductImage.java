package com.roy.ecommerce.module.catalog.model;
  
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductImage {
    private Long id;
    private Long productId;
    private String imageUrl;
    private int displayOrder;
}
 
