package com.roy.ecommerce.module.review.model;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
 
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Review { // reviews table
    private Long id;
    private Long userId;
    private Long productId;
    private int rating;
    private String title;
    private String body;
    private LocalDateTime createdAt;
}
