package com.roy.ecommerce.module.user.model;

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
public class User {
    private Long id;
    private String userName;
    private String fullName;
    private String email;
    private String passwordHash;
    private String phone;
    private boolean banned;
    private LocalDateTime createdAt;
    private Role role;
    private List<Address> addresses;
}
