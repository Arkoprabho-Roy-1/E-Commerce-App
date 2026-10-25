package com.roy.ecommerce.module.catalog.model;
  
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder 
@NoArgsConstructor 
@AllArgsConstructor
public class Category { // categories table
    
    private Long id;
    private String name;
    private String slug;
    private String description;
    private Long parentId;
}
