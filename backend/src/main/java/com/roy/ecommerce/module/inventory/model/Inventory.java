package com.roy.ecommerce.module.inventory.model;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
 
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Inventory {
    private Long id;
    private Long productId;
    private int quantityAvailable;
    private int lowStockThreshold;
    private LocalDateTime lastAdjustedAt;
    private String adjustmentNote;
}
