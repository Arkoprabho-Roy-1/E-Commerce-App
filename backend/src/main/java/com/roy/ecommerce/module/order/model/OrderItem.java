package com.roy.ecommerce.module.order.model;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderItem { // order_items table
    private Long id;
    private Long orderId;
    private Long productId;
    private String productName;
    private String productImageUrl;
    private BigDecimal unitPrice;
    private int quantity;
    private BigDecimal lineTotal;   // line total is unitPrice × quantity 
}
