package com.roy.ecommerce.module.cart.model;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
 
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CartItem { // cart_items table
    private Long id;
    private Long cartId;
    private Long productId;
    private int quantity;
    private BigDecimal priceAtTimeOfAdding;
}
