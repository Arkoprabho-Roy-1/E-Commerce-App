package com.roy.ecommerce.module.cart.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cart { // carts table
    private Long id;
    private Long userId;
    private List<CartItem> cartItems;
}
 
