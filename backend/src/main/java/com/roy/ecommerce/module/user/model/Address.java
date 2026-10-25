package com.roy.ecommerce.module.user.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
 
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Address {
    private Long id;
    private Long userId;
    private String fullName;
    private String phone;
    private String street;
    private String city;
    private String state;
    private String pincode;
    private String country;
    private boolean defaultAddress;    
}
