package com.roy.ecommerce.module.wishlist.model;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WishlistItem { // wishlist_items
    private Long id;
    private Long userId;
    private Long productId;
    private LocalDateTime addedAt;
}
