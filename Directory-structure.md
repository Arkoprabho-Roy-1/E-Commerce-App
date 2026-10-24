# Directory Structure

## Overview

This is a **Modular Monolith** architecture. The backend is organized into self-contained feature modules, each owning its own Model, DTO, RowMapper, Repository Interface, Repository Implementation, Service, and Controller. There is no ORM — all database interaction is done via raw SQL using Spring's `JdbcTemplate`. The frontend is purely static HTML, CSS, and Vanilla JavaScript with no framework.

---

## Full Structure

```
ecommerce-app/
│
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/
│       │   │   └── com/roy/ecommerce/
│       │   │       │
│       │   │       ├── EcommerceApplication.java
│       │   │       │
│       │   │       ├── shared/
│       │   │       │   ├── config/
│       │   │       │   │   ├── SecurityConfig.java
│       │   │       │   │   ├── JwtConfig.java
│       │   │       │   │   ├── CorsConfig.java
│       │   │       │   │   └── WebMvcConfig.java
│       │   │       │   ├── exception/
│       │   │       │   │   ├── GlobalExceptionHandler.java
│       │   │       │   │   ├── ResourceNotFoundException.java
│       │   │       │   │   ├── UnauthorizedException.java
│       │   │       │   │   └── ValidationException.java
│       │   │       │   ├── filter/
│       │   │       │   │   └── JwtAuthFilter.java
│       │   │       │   ├── response/
│       │   │       │   │   ├── ApiResponse.java
│       │   │       │   │   └── PagedResponse.java
│       │   │       │   └── util/
│       │   │       │       ├── JwtUtil.java
│       │   │       │       ├── SlugUtil.java
│       │   │       │       └── PaginationUtil.java
│       │   │       │
│       │   │       └── module/
│       │   │           │
│       │   │           ├── user/
│       │   │           │   ├── controller/
│       │   │           │   │   ├── AuthController.java
│       │   │           │   │   └── UserController.java
│       │   │           │   ├── service/
│       │   │           │   │   ├── AuthService.java
│       │   │           │   │   ├── UserService.java
│       │   │           │   │   └── JwtUserDetailsService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── UserRepository.java
│       │   │           │   │   ├── UserRepositoryImpl.java
│       │   │           │   │   ├── AddressRepository.java
│       │   │           │   │   └── AddressRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   ├── User.java
│       │   │           │   │   ├── Role.java
│       │   │           │   │   └── Address.java
│       │   │           │   ├── mapper/
│       │   │           │   │   ├── UserRowMapper.java
│       │   │           │   │   └── AddressRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── RegisterRequest.java
│       │   │           │       ├── LoginRequest.java
│       │   │           │       ├── LoginResponse.java
│       │   │           │       ├── UserProfileDto.java
│       │   │           │       ├── UpdateProfileRequest.java
│       │   │           │       ├── ChangePasswordRequest.java
│       │   │           │       ├── AddressRequest.java
│       │   │           │       └── AddressDto.java
│       │   │           │
│       │   │           ├── catalog/
│       │   │           │   ├── controller/
│       │   │           │   │   ├── ProductController.java
│       │   │           │   │   └── CategoryController.java
│       │   │           │   ├── service/
│       │   │           │   │   ├── ProductService.java
│       │   │           │   │   └── CategoryService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── ProductRepository.java
│       │   │           │   │   ├── ProductRepositoryImpl.java
│       │   │           │   │   ├── CategoryRepository.java
│       │   │           │   │   ├── CategoryRepositoryImpl.java
│       │   │           │   │   ├── ProductImageRepository.java
│       │   │           │   │   └── ProductImageRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   ├── Product.java
│       │   │           │   │   ├── Category.java
│       │   │           │   │   └── ProductImage.java
│       │   │           │   ├── mapper/
│       │   │           │   │   ├── ProductRowMapper.java
│       │   │           │   │   ├── CategoryRowMapper.java
│       │   │           │   │   └── ProductImageRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── ProductDto.java
│       │   │           │       ├── ProductSummaryDto.java
│       │   │           │       ├── ProductCreateRequest.java
│       │   │           │       ├── ProductUpdateRequest.java
│       │   │           │       ├── CategoryDto.java
│       │   │           │       └── CategoryRequest.java
│       │   │           │
│       │   │           ├── inventory/
│       │   │           │   ├── controller/
│       │   │           │   │   └── InventoryController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── InventoryService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── InventoryRepository.java
│       │   │           │   │   └── InventoryRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   └── Inventory.java
│       │   │           │   ├── mapper/
│       │   │           │   │   └── InventoryRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── InventoryDto.java
│       │   │           │       └── AdjustStockRequest.java
│       │   │           │
│       │   │           ├── cart/
│       │   │           │   ├── controller/
│       │   │           │   │   └── CartController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── CartService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── CartRepository.java
│       │   │           │   │   ├── CartRepositoryImpl.java
│       │   │           │   │   ├── CartItemRepository.java
│       │   │           │   │   └── CartItemRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   ├── Cart.java
│       │   │           │   │   └── CartItem.java
│       │   │           │   ├── mapper/
│       │   │           │   │   ├── CartRowMapper.java
│       │   │           │   │   └── CartItemRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── CartDto.java
│       │   │           │       ├── CartItemDto.java
│       │   │           │       └── CartItemRequest.java
│       │   │           │
│       │   │           ├── order/
│       │   │           │   ├── controller/
│       │   │           │   │   └── OrderController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── OrderService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── OrderRepository.java
│       │   │           │   │   ├── OrderRepositoryImpl.java
│       │   │           │   │   ├── OrderItemRepository.java
│       │   │           │   │   └── OrderItemRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   ├── Order.java
│       │   │           │   │   ├── OrderItem.java
│       │   │           │   │   └── OrderStatus.java
│       │   │           │   ├── mapper/
│       │   │           │   │   ├── OrderRowMapper.java
│       │   │           │   │   └── OrderItemRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── OrderDto.java
│       │   │           │       ├── OrderDetailDto.java
│       │   │           │       ├── OrderItemDto.java
│       │   │           │       ├── PlaceOrderRequest.java
│       │   │           │       └── UpdateOrderStatusRequest.java
│       │   │           │
│       │   │           ├── payment/
│       │   │           │   ├── controller/
│       │   │           │   │   └── PaymentController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── PaymentService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── PaymentRepository.java
│       │   │           │   │   └── PaymentRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   ├── Payment.java
│       │   │           │   │   └── PaymentStatus.java
│       │   │           │   ├── mapper/
│       │   │           │   │   └── PaymentRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── PaymentDto.java
│       │   │           │       └── PaymentRequest.java
│       │   │           │
│       │   │           ├── review/
│       │   │           │   ├── controller/
│       │   │           │   │   └── ReviewController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── ReviewService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── ReviewRepository.java
│       │   │           │   │   └── ReviewRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   └── Review.java
│       │   │           │   ├── mapper/
│       │   │           │   │   └── ReviewRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── ReviewDto.java
│       │   │           │       └── ReviewRequest.java
│       │   │           │
│       │   │           ├── wishlist/
│       │   │           │   ├── controller/
│       │   │           │   │   └── WishlistController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── WishlistService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── WishlistItemRepository.java
│       │   │           │   │   └── WishlistItemRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   └── WishlistItem.java
│       │   │           │   ├── mapper/
│       │   │           │   │   └── WishlistItemRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── WishlistDto.java
│       │   │           │       └── WishlistItemDto.java
│       │   │           │
│       │   │           ├── discount/
│       │   │           │   ├── controller/
│       │   │           │   │   └── DiscountController.java
│       │   │           │   ├── service/
│       │   │           │   │   └── DiscountService.java
│       │   │           │   ├── repository/
│       │   │           │   │   ├── CouponRepository.java
│       │   │           │   │   └── CouponRepositoryImpl.java
│       │   │           │   ├── model/
│       │   │           │   │   ├── Coupon.java
│       │   │           │   │   └── DiscountType.java
│       │   │           │   ├── mapper/
│       │   │           │   │   └── CouponRowMapper.java
│       │   │           │   └── dto/
│       │   │           │       ├── CouponDto.java
│       │   │           │       ├── CouponRequest.java
│       │   │           │       └── ApplyCouponRequest.java
│       │   │           │
│       │   │           └── admin/
│       │   │               ├── controller/
│       │   │               │   └── AdminDashboardController.java
│       │   │               ├── service/
│       │   │               │   └── AdminService.java
│       │   │               └── dto/
│       │   │                   ├── DashboardStatsDto.java
│       │   │                   ├── SalesReportDto.java
│       │   │                   ├── LowStockAlertDto.java
│       │   │                   └── TopSellingProductDto.java
│       │   │
│       │   └── resources/
│       │       ├── application.properties
│       │       ├── application-dev.properties
│       │       ├── application-prod.properties
│       │       └── db-schemas/
│       │           ├── 01_users.sql
│       │           ├── 02_addresses.sql
│       │           ├── 03_categories.sql
│       │           ├── 04_products.sql
│       │           ├── 05_product_images.sql
│       │           ├── 06_inventory.sql
│       │           ├── 07_carts.sql
│       │           ├── 08_cart_items.sql
│       │           ├── 09_orders.sql
│       │           ├── 10_order_items.sql
│       │           ├── 11_payments.sql
│       │           ├── 12_reviews.sql
│       │           ├── 13_wishlist_items.sql
│       │           └── 14_coupons.sql
│       │
│       └── test/
│           └── java/
│               └── com/roy/ecommerce/
│                   ├── user/
│                   │   └── UserServiceTest.java
│                   ├── catalog/
│                   │   └── ProductServiceTest.java
│                   ├── order/
│                   │   └── OrderServiceTest.java
│                   └── cart/
│                       └── CartServiceTest.java
│
├── frontend/
│   ├── index.html
│   ├── assets/
│   │   ├── css/
│   │   │   ├── global.css
│   │   │   ├── components.css
│   │   │   └── pages/
|   │   │       ├── home.css
|   │   │       ├── product.css
│   │   │       ├── cart.css
│   │   │       ├── checkout.css
│   │   │       ├── auth.css
│   │   │       ├── profile.css
│   │   │       ├── orders.css
│   │   │       └── admin.css
│   │   ├── js/
│   │   │   ├── api/
│   │   │   │   ├── client.js
│   │   │   │   ├── auth.api.js
│   │   │   │   ├── product.api.js
│   │   │   │   ├── cart.api.js
│   │   │   │   ├── order.api.js
│   │   │   │   ├── payment.api.js
│   │   │   │   ├── review.api.js
│   │   │   │   ├── wishlist.api.js
│   │   │   │   └── admin.api.js
│   │   │   ├── components/
│   │   │   │   ├── navbar.js
│   │   │   │   ├── footer.js
│   │   │   │   ├── productCard.js
│   │   │   │   ├── modal.js
│   │   │   │   ├── toast.js
│   │   │   │   ├── pagination.js
│   │   │   │   └── spinner.js
│   │   │   ├── pages/
│   │   │   │   ├── home.js
│   │   │   │   ├── productList.js
│   │   │   │   ├── productDetail.js
│   │   │   │   ├── cart.js
│   │   │   │   ├── checkout.js
│   │   │   │   ├── login.js
│   │   │   │   ├── register.js
│   │   │   │   ├── profile.js
│   │   │   │   ├── orders.js
│   │   │   │   ├── orderDetail.js
│   │   │   │   ├── wishlist.js
│   │   │   │   └── admin/
│   │   │   │       ├── dashboard.js
│   │   │   │       ├── manageProducts.js
│   │   │   │       ├── manageOrders.js
│   │   │   │       ├── manageUsers.js
│   │   │   │       └── manageCoupons.js
│   │   │   └── utils/
│   │   │       ├── auth.js
│   │   │       ├── router.js
│   │   │       ├── formatter.js
│   │   │       └── validator.js
│   │   └── images/
│   │       └── placeholder.png
│   └── pages/
│       ├── product-list.html
│       ├── product-detail.html
│       ├── cart.html
│       ├── checkout.html
│       ├── login.html
│       ├── register.html
│       ├── profile.html
│       ├── orders.html
│       ├── order-detail.html
│       ├── wishlist.html
│       └── admin/
│           ├── dashboard.html
│           ├── manage-products.html
│           ├── manage-orders.html
│           ├── manage-users.html
│           └── manage-coupons.html
├── Directory-Structure.md
├── Features.md
├── Project-Files.md
└── README.md
```

---

## Layer Breakdown (Backend)

| Layer | Folder | Purpose |
|---|---|---|
| Model | `module/<name>/model/` | Plain Java classes mirroring PostgreSQL tables. No JPA annotations. |
| RowMapper | `module/<name>/mapper/` | Converts raw JDBC `ResultSet` rows into Model objects. One per table. |
| Repository Interface | `module/<name>/repository/` | Java interface declaring all database operation method signatures. |
| Repository Impl | `module/<name>/repository/` | Concrete class implementing the interface using `JdbcTemplate` and raw SQL. |
| DTO | `module/<name>/dto/` | Request and Response objects at the API boundary. Never exposes Model directly. |
| Service | `module/<name>/service/` | Business logic layer. Converts Models to DTOs. Enforces all business rules. |
| Controller | `module/<name>/controller/` | HTTP layer. Receives requests, delegates to Service, returns `ApiResponse`. |
| Shared | `shared/` | Cross-cutting concerns: JWT, Security, CORS, Exception handling, Pagination. |

---

## Database Schema Execution Order

SQL files under `db-schemas/` must be run in numeric order due to foreign key dependencies:

```
01 → 02 (addresses depends on users)
03 → 04 (products depends on categories)
04 → 05, 06, 08, 10, 12, 13 (all depend on products)
07 → 08 (cart_items depends on carts)
09 → 10, 11 (order_items and payments depend on orders)
01 → 07, 09, 12, 13 (all depend on users)
```
