package com.roy.ecommerce.module.payment.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor; 

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
    private Long id;
    private Long orderId;
    private BigDecimal amount;
    private String method;
    private PaymentStatus status;
    private String transactionId;
    private LocalDateTime paidAt;
}
