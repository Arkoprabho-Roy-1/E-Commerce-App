# Project Files — Purpose of Every File

This document describes what the code inside every single file in this project actually does. Organized to match the directory structure exactly.

---

## Root

**`pom.xml`**
The Maven build file. Declares all project dependencies (Spring Boot Web, Spring Boot JDBC, Spring Security, Spring Validation, PostgreSQL driver, JJWT for JWT, Lombok), the Java version, and the Spring Boot parent version. Maven reads this file to download all libraries and compile the project. Without this file, nothing builds.

**`EcommerceApplication.java`**
The entry point of the entire Spring Boot application. Contains the `main()` method with `SpringApplication.run()`. When you run this file, Spring Boot starts the embedded Tomcat server, loads all configurations, initializes all beans, and begins listening for HTTP requests on port 8080. Annotated with `@SpringBootApplication` which triggers component scanning across all packages under `com.roy.ecommerce`.

---

## `shared/config/`

**`SecurityConfig.java`**
Configures the entire Spring Security filter chain. Declares which API endpoints are public (register, login, GET product and category endpoints) and which require authentication. Declares that `/api/admin/**` endpoints require the `ROLE_ADMIN` authority. Sets session management to stateless (no HTTP sessions — JWT only). Plugs `JwtAuthFilter` into the filter chain so every request is checked for a valid token before reaching any controller. Also declares the `AuthenticationManager` bean.

**`JwtConfig.java`**
Reads `jwt.secret` and `jwt.expiration` values from `application.properties` and makes them available as injectable fields. Declares the `PasswordEncoder` bean — a `BCryptPasswordEncoder` instance — which is injected into `AuthService` for hashing and verifying passwords. BCrypt is used because it is a one-way, salted hashing algorithm designed to be slow, making brute-force attacks computationally expensive.

**`CorsConfig.java`**
Configures Cross-Origin Resource Sharing. Since the frontend (HTML files served by VS Code Live Server on port 5500) and the backend (Spring Boot on port 8080) are on different origins, browsers block all cross-origin requests by default. This file explicitly allows requests from `localhost:5500` and `127.0.0.1:5500`, permits all HTTP methods including OPTIONS (required for browser preflight requests), permits all headers (including `Authorization`), and applies this configuration to all `/api/**` routes.

**`WebMvcConfig.java`**
Implements Spring's `WebMvcConfigurer` interface. Currently a placeholder for future MVC-level configuration such as custom interceptors, message converters, or static resource handlers. Kept in the project as a clean extension point.

---

## `shared/exception/`

**`ResourceNotFoundException.java`**
A custom unchecked exception that extends `RuntimeException`. Thrown by any service when a database lookup returns no result — for example when fetching a product by an ID that does not exist. Caught by `GlobalExceptionHandler` and returned to the frontend as an HTTP 404 response with the exception message.

**`ValidationException.java`**
A custom unchecked exception for business-level rule violations. Thrown when data passes `@Valid` annotation checks but fails a business rule — for example when passwords do not match during registration, when a user tries to cancel an already-shipped order, or when a coupon code is expired. Caught by `GlobalExceptionHandler` and returned as HTTP 400.

**`UnauthorizedException.java`**
A custom unchecked exception thrown when an authenticated user attempts an action they are not permitted to perform — for example trying to delete another user's review or accessing admin-only data. Caught by `GlobalExceptionHandler` and returned as HTTP 403.

**`GlobalExceptionHandler.java`**
Annotated with `@RestControllerAdvice` — this class intercepts every exception thrown anywhere across all controllers in the application. Contains individual `@ExceptionHandler` methods for `MethodArgumentNotValidException` (returns field-level validation errors as a map), `ResourceNotFoundException` (returns 404), `ValidationException` (returns 400), `UnauthorizedException` (returns 403), and a catch-all `Exception` handler (returns 500 with a generic message). Ensures the frontend always receives a consistent `ApiResponse` JSON structure regardless of what went wrong.

---

## `shared/filter/`

**`JwtAuthFilter.java`**
Extends `OncePerRequestFilter` — runs exactly once per HTTP request, before any controller is reached. Reads the `Authorization` header from every incoming request. If the header is present and starts with `Bearer `, extracts the token, decodes the email from it using `JwtUtil`, loads the user from the database via `JwtUserDetailsService`, validates the token, and if valid, sets the authenticated user into Spring Security's `SecurityContextHolder`. This is how Spring Security knows who is making the request — enabling `@AuthenticationPrincipal` in controllers and `.hasAuthority()` checks in `SecurityConfig`.

---

## `shared/response/`

**`ApiResponse.java`**
A generic wrapper class used as the return type of every controller endpoint. Has three fields: `success` (boolean indicating pass/fail), `message` (human-readable description), and `data` (generic type T — the actual payload). Ensures every API response has the same JSON shape, making frontend error handling and success handling consistent and predictable.

**`PagedResponse.java`**
A wrapper for paginated list responses. Contains `content` (the list of items for the current page), `currentPage`, `totalPages`, `totalElements`, `pageSize`, `isFirst`, and `isLast`. Returned by all list endpoints — products, orders, reviews, users, coupons. The frontend uses `totalPages` and `isFirst`/`isLast` to render pagination controls.

---

## `shared/util/`

**`JwtUtil.java`**
The central JWT utility class. `generateToken(email, role)` builds a signed JWT containing the user's email as the subject and role as a custom claim, with an expiry timestamp. `extractEmail(token)` and `extractRole(token)` decode the token and read those values back out. `validateToken(token, email)` checks that the email in the token matches the expected email and that the token has not expired. `isTokenExpired(token)` compares the token's expiry date to the current time. Uses the JJWT library with HMAC-SHA256 signing — the signature mathematically binds the token content to the secret key, making tampering detectable.

**`SlugUtil.java`**
Converts a product or category name into a URL-friendly slug. Lowercases the input, trims whitespace, strips all characters that are not letters, digits, spaces, or hyphens, replaces spaces with hyphens, and collapses multiple consecutive hyphens into one. So `"Running Shoes Pro!!"` becomes `"running-shoes-pro"`. Used by `ProductService` and `CategoryService` when creating new records with auto-generated slugs.

**`PaginationUtil.java`**
Centralizes all pagination math. `validatePage()` ensures page numbers are never negative. `validateSize()` caps page size between 1 and 100 and applies a default of 12. `calculateOffset(page, size)` computes the SQL `OFFSET` value for a given page. `calculateTotalPages(totalElements, size)` divides and rounds up. `buildPagedResponse(content, page, size, totalElements)` assembles a complete `PagedResponse` object ready to wrap in an `ApiResponse` and return from a controller.

---

## `shared/` — Resources

**`application.properties`**
The main runtime configuration file. Contains the PostgreSQL connection URL, username, password, and driver class. Contains HikariCP connection pool settings (pool size, timeouts). Contains `jwt.secret` (the signing key) and `jwt.expiration` (token lifetime in milliseconds). Spring Boot reads this file on startup and uses these values to auto-configure the `DataSource`, `JdbcTemplate`, and all other beans.

**`application-dev.properties`**
Overrides for local development. Typically enables more verbose SQL logging, uses a local PostgreSQL URL, and may use a shorter JWT expiry for easier testing. Activated by setting `spring.profiles.active=dev`.

**`application-prod.properties`**
Overrides for a production deployment. Stricter security settings, connection pool tuning, and production database credentials. Activated by setting `spring.profiles.active=prod`.

---

## `db-schemas/`

These are plain SQL files executed manually in PostgreSQL in numeric order. They are not run automatically on startup — they are run once to set up the database schema.

**`01_users.sql`**
Creates the `users` table with columns: `id` (BIGSERIAL primary key), `user_name` (unique), `full_name`, `email` (unique), `password_hash`, `phone`, `role` (VARCHAR storing `ROLE_CUSTOMER` or `ROLE_ADMIN`), `is_banned`, `created_at`.

**`02_addresses.sql`**
Creates the `addresses` table. Foreign key `user_id` references `users(id)` with `ON DELETE CASCADE` — deleting a user also deletes all their addresses. Columns: `id`, `user_id`, `full_name`, `phone`, `street`, `city`, `state`, `pincode`, `country`, `is_default`.

**`03_categories.sql`**
Creates the `categories` table with a self-referencing foreign key: `parent_id` references `categories(id)` with `ON DELETE SET NULL`. A NULL `parent_id` means the category is a root/top-level category. Any depth of nesting is supported through this single table.

**`04_products.sql`**
Creates the `products` table. Foreign key `category_id` references `categories(id)` with `ON DELETE SET NULL`. Columns include `slug` (unique), `price` (NUMERIC), `average_rating` (NUMERIC, defaults to 0.00), `is_featured`, `is_active`, `created_at`. `is_active` defaults to TRUE.

**`05_product_images.sql`**
Creates the `product_images` table. Foreign key `product_id` references `products(id)` with `ON DELETE CASCADE` — deleting a product deletes all its images. Columns: `id`, `product_id` (NOT NULL), `image_url`, `display_order` (INT, controls render order in gallery).

**`06_inventory.sql`**
Creates the `inventory` table with a one-to-one relationship to `products` via `product_id` (NOT NULL UNIQUE). Columns: `quantity_available`, `low_stock_threshold` (defaults to 5), `last_adjusted_at`, `adjustment_note`. The UNIQUE constraint on `product_id` ensures each product has exactly one inventory record.

**`07_carts.sql`**
Creates the `carts` table. `user_id` is NOT NULL and UNIQUE — each user has exactly one cart. Foreign key references `users(id)` with `ON DELETE CASCADE`.

**`08_cart_items.sql`**
Creates the `cart_items` table. Foreign keys to both `carts(id)` and `products(id)` with `ON DELETE CASCADE`. A composite `UNIQUE(cart_id, product_id)` constraint prevents the same product from appearing as two separate rows in the same cart. Columns: `quantity`, `price_at_time_of_adding` (NUMERIC — snapshot of price when item was added).

**`09_orders.sql`**
Creates the `orders` table. Contains all shipping address fields as snapshot columns (`shipping_full_name`, `shipping_phone`, `shipping_street`, etc.) rather than a foreign key to addresses — this permanently preserves the delivery address even if the user later edits or deletes it. Also stores `total_amount`, `discount_amount`, `final_amount`, `coupon_code`, `payment_method`, `status` (defaults to `PENDING`), `created_at`.

**`10_order_items.sql`**
Creates the `order_items` table. Foreign keys to both `orders(id)` and `products(id)` with `ON DELETE CASCADE`. Contains snapshot columns `product_name`, `product_image_url`, `unit_price` — these freeze the product details at purchase time so order history is never affected by future product edits. A composite `UNIQUE(order_id, product_id)` constraint prevents duplicate line items in the same order.

**`11_payments.sql`**
Creates the `payments` table. `order_id` is NOT NULL UNIQUE — each order has exactly one payment record. Columns: `amount`, `method`, `status` (defaults to `PENDING`), `transaction_id` (nullable — COD orders have no transaction ID), `paid_at`.

**`12_reviews.sql`**
Creates the `reviews` table. Foreign keys to `users(id)` and `products(id)` both with `ON DELETE CASCADE`. A composite `UNIQUE(user_id, product_id)` constraint enforces one review per customer per product at the database level. Columns: `rating` (INT NOT NULL), `title` (NOT NULL), `body` (NOT NULL), `created_at`.

**`13_wishlist_items.sql`**
Creates the `wishlist_items` table. Foreign keys to `users(id)` and `products(id)` with `ON DELETE CASCADE`. A composite `UNIQUE(user_id, product_id)` constraint prevents duplicate wishlist entries. Columns: `id`, `user_id`, `product_id`, `added_at`.

**`14_coupons.sql`**
Creates the `coupons` table. `code` is NOT NULL UNIQUE. `discount_type` is NOT NULL (either `FLAT` or `PERCENTAGE`). `maximum_discount_cap` is nullable (only relevant for PERCENTAGE type). `expiry_date` is nullable (a null expiry means the coupon never expires). `usage_count` defaults to 0. `is_active` defaults to TRUE.

---

## `module/user/`

### `controller/`

**`AuthController.java`**
Handles two public endpoints. `POST /api/auth/register` — receives a `RegisterRequest` body, validates it with `@Valid`, delegates to `AuthService.register()`, and returns a success `ApiResponse` with no data payload. `POST /api/auth/login` — receives a `LoginRequest` body, delegates to `AuthService.login()`, and returns an `ApiResponse` wrapping a `LoginResponse` containing the JWT token and user details for the frontend to store in `localStorage`.

**`UserController.java`**
Handles all authenticated profile and address endpoints. `GET /api/users/me` returns the current user's profile. `PUT /api/users/me` updates profile fields. `PUT /api/users/me/password` changes password. `GET /api/users/me/addresses` lists all addresses. `POST /api/users/me/addresses` adds a new address. `PUT /api/users/me/addresses/{id}` updates an address. `DELETE /api/users/me/addresses/{id}` deletes an address. `PUT /api/users/me/addresses/{id}/default` sets an address as default. All endpoints extract the current user's email from the JWT via `@AuthenticationPrincipal` and pass it to `UserService`.

### `service/`

**`AuthService.java`**
Contains registration and login business logic. On register: checks passwords match, checks email and username are not already taken via repository, hashes the raw password using `BCryptPasswordEncoder`, builds a `User` model with `Role.ROLE_CUSTOMER` hardcoded (users can never self-register as admin), and saves via `UserRepository`. On login: loads user by email, checks the account is not banned, verifies the raw password against the stored hash using `passwordEncoder.matches()`, generates a JWT token via `JwtUtil`, and returns a `LoginResponse`.

**`UserService.java`**
Contains all profile and address management business logic. Fetches user profile and populates the `addresses` list by making a second query to `AddressRepository`. Updates profile fields. On password change: verifies current password before allowing the update. On add address: if the new address is marked as default, calls `addressRepository.clearDefaultAddress(userId)` first before saving. On set default: clears existing default then sets the new one. On delete address: verifies the address belongs to the requesting user before deleting.

**`JwtUserDetailsService.java`**
Implements Spring Security's `UserDetailsService` interface. Has one method: `loadUserByUsername(String email)`. Fetches the `User` from `UserRepository` by email, then constructs and returns a Spring Security `UserDetails` object containing the email, password hash, and a `GrantedAuthority` built from the user's role string (e.g. `"ROLE_ADMIN"`). This is called by `JwtAuthFilter` on every authenticated request to load the user's authorities into the security context.

### `repository/`

**`UserRepository.java`**
Interface declaring all database operations for the `users` table: `save()`, `findById()`, `findByEmail()`, `findByUserName()`, `findAll()`, `existsByEmail()`, `existsByUserName()`, `update()`, `updateBannedStatus()`, `deleteById()`.

**`UserRepositoryImpl.java`**
Concrete implementation of `UserRepository`. Annotated with `@Repository`. Injects `JdbcTemplate` and `UserRowMapper`. Each method executes a raw SQL query. `save()` runs an INSERT. `findByEmail()` runs a SELECT with a WHERE clause and uses `.stream().findFirst()` to return an `Optional<User>`. `update()` runs an UPDATE that does not include `passwordHash` or `role` — those have dedicated methods to prevent accidental privilege escalation. `updateBannedStatus()` runs a targeted UPDATE for the ban/unban feature.

**`AddressRepository.java`**
Interface declaring all database operations for the `addresses` table: `save()`, `findById()`, `findByUserId()`, `findDefaultAddressByUserId()`, `existsById()`, `update()`, `updateDefaultAddress()`, `clearDefaultAddress()`, `deleteById()`, `deleteByUserId()`.

**`AddressRepositoryImpl.java`**
Concrete implementation of `AddressRepository`. `findByUserId()` returns all addresses for a user. `findDefaultAddressByUserId()` adds `AND is_default = TRUE` to the WHERE clause. `clearDefaultAddress()` runs `UPDATE addresses SET is_default = FALSE WHERE user_id = ?` — this is called before setting a new default to ensure no two addresses are simultaneously marked as default for the same user.

### `model/`

**`User.java`**
Plain Java class (no JPA annotations) mirroring the `users` table. Fields: `id`, `userName`, `fullName`, `email`, `passwordHash`, `phone`, `banned`, `createdAt`, `role` (enum), `addresses` (List — not a DB column, populated by service layer). Annotated with Lombok `@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`.

**`Role.java`**
Enum with two values: `ROLE_CUSTOMER` and `ROLE_ADMIN`. The `ROLE_` prefix is required by Spring Security's `hasAuthority()` mechanism. Stored as a VARCHAR string in the `users` table via `role.name()` and converted back to enum via `Role.valueOf()` in `UserRowMapper`.

**`Address.java`**
Plain Java class mirroring the `addresses` table. Fields: `id`, `userId`, `fullName`, `phone`, `street`, `city`, `state`, `pincode`, `country`, `defaultAddress`. The field is named `defaultAddress` rather than `isDefault` to avoid Lombok's builder method naming conflict with the `is` prefix convention.

### `mapper/`

**`UserRowMapper.java`**
Implements `RowMapper<User>`. The `mapRow()` method reads each column from the SQL `ResultSet` using the exact column names from the `users` table (`user_name`, `full_name`, `password_hash`, `is_banned`, `created_at`) and maps them to the corresponding `User` fields. Converts the role VARCHAR back to a `Role` enum using `Role.valueOf()`. Does not populate the `addresses` list — that is done in the service layer.

**`AddressRowMapper.java`**
Implements `RowMapper<Address>`. Maps each column from the `addresses` table `ResultSet` to the corresponding `Address` field, including `is_default` mapped to `defaultAddress`.

### `dto/`

**`RegisterRequest.java`**
Incoming JSON body for `POST /api/auth/register`. Fields: `username`, `fullName`, `email`, `password`, `confirmPassword`, `phone`. Annotated with `@NotBlank`, `@Email`, `@Size` constraints that are activated by `@Valid` in `AuthController`.

**`LoginRequest.java`**
Incoming JSON body for `POST /api/auth/login`. Fields: `email`, `password`. Both annotated with `@NotBlank`.

**`LoginResponse.java`**
Outgoing data returned after a successful login. Fields: `token` (the JWT string), `tokenType` (always `"Bearer"`), `userId`, `fullName`, `userName`, `role`. The frontend stores all of these in `localStorage` to maintain session state.

**`UserProfileDto.java`**
Outgoing data for `GET /api/users/me`. Contains all user fields safe to expose — no `passwordHash`. Fields: `id`, `userName`, `fullName`, `email`, `phone`, `role`, `List<AddressDto> addresses`.

**`UpdateProfileRequest.java`**
Incoming body for `PUT /api/users/me`. Fields: `userName`, `fullName`, `phone`, `email`. All fields are validated with `@NotBlank` and `@Size`.

**`ChangePasswordRequest.java`**
Incoming body for `PUT /api/users/me/password`. Fields: `oldPassword`, `newPassword`, `confirmNewPassword`. The service verifies `oldPassword` against the stored hash before allowing the change, and checks `newPassword` equals `confirmNewPassword`.

**`AddressRequest.java`**
Incoming body for creating or updating an address. Fields: `fullName`, `phone`, `street`, `city`, `state`, `pincode`, `country`, `defaultAddress`. All string fields are `@NotBlank`.

**`AddressDto.java`**
Outgoing representation of an address. Fields: `id`, `fullName`, `phone`, `street`, `city`, `state`, `pincode`, `country`, `defaultAddress`. The `id` field is essential for the frontend to identify which address to edit or delete.

---

## `module/catalog/`

### `controller/`

**`ProductController.java`**
Public endpoints: `GET /api/products` (paginated list with filter and sort query params), `GET /api/products/{id}` (single product detail), `GET /api/products/search?q=` (keyword search). Admin-only endpoints: `POST /api/products` (create), `PUT /api/products/{id}` (update), `DELETE /api/products/{id}` (soft delete — sets `is_active = false`). All list endpoints return `PagedResponse<ProductSummaryDto>` wrapped in `ApiResponse`. The detail endpoint returns `ProductDto`.

**`CategoryController.java`**
Public endpoints: `GET /api/categories` (list all), `GET /api/categories/{id}` (single), `GET /api/categories/roots` (top-level only), `GET /api/categories/{id}/children` (sub-categories of a parent). Admin-only: `POST /api/categories`, `PUT /api/categories/{id}`, `DELETE /api/categories/{id}`.

### `service/`

**`ProductService.java`**
Business logic for all product operations. On create: auto-generates slug from name using `SlugUtil` if no slug is provided, checks slug uniqueness, saves product, saves each image URL as a `ProductImage` row, saves an `Inventory` record with the provided initial stock quantity. On fetch single product: retrieves product, fetches its images from `ProductImageRepository`, fetches category name from `CategoryRepository`, assembles and returns a `ProductDto`. On fetch list: applies pagination via `PaginationUtil`. On soft delete: calls `productRepository.updateActiveStatus(id, false)` rather than deleting the row, preserving order history. After any review is submitted or deleted, `ProductService.recalculateAverageRating()` is called which runs the aggregate SQL query and updates the product's `average_rating`.

**`CategoryService.java`**
Business logic for category operations. On delete: checks whether any products are assigned to this category via `ProductRepository` before deleting — if products exist, throws a `ValidationException` with an informative message instead of proceeding. On create: checks for slug uniqueness. On fetch all: returns the full flat list of categories; the frontend or a DTO can use `parentId` to construct a tree if needed.

### `repository/`

**`ProductRepository.java`**
Interface declaring: `save()`, `findById()`, `findBySlug()`, `findAll()`, `findByCategory()`, `findFeatured()`, `findActive()`, `findByKeyword()`, `existsBySlug()`, `existsById()`, `update()`, `updateAverageRating()`, `updateActiveStatus()`, `deleteById()`.

**`ProductRepositoryImpl.java`**
Implements `ProductRepository` using `JdbcTemplate` and `ProductRowMapper`. `findByKeyword()` uses PostgreSQL's `ILIKE` operator for case-insensitive pattern matching: `WHERE name ILIKE ? OR description ILIKE ?` with a `%keyword%` pattern. `updateAverageRating()` runs a targeted UPDATE only on the `average_rating` column. `save()` returns the generated `id` using `RETURNING id` so the service can immediately create related inventory and image records.

**`CategoryRepository.java`**
Interface declaring: `save()`, `findById()`, `findBySlug()`, `findAll()`, `findByParentId()`, `findRootCategories()`, `existsByName()`, `existsBySlug()`, `existsById()`, `update()`, `deleteById()`.

**`CategoryRepositoryImpl.java`**
Implements `CategoryRepository`. `findRootCategories()` runs `SELECT * FROM categories WHERE parent_id IS NULL`. `findByParentId()` runs `SELECT * FROM categories WHERE parent_id = ?`. Both are used to support the self-referencing category tree.

**`ProductImageRepository.java`**
Interface declaring: `save()`, `saveAll()`, `findById()`, `findByProductId()`, `existsById()`, `deleteById()`, `deleteByProductId()`.

**`ProductImageRepositoryImpl.java`**
Implements `ProductImageRepository`. `saveAll()` iterates over a list and calls `save()` for each. `findByProductId()` orders results by `display_order ASC` so images are returned in the intended gallery sequence. `deleteByProductId()` is called when a product's images are fully replaced during an update.

### `model/`

**`Product.java`**
Plain Java class mirroring the `products` table. Fields: `id`, `name`, `slug`, `description`, `price` (BigDecimal), `categoryId` (Long), `averageRating` (double), `featured` (boolean), `active` (boolean), `productImages` (List — populated by service), `createdAt`. No JPA annotations.

**`Category.java`**
Plain Java class mirroring the `categories` table. Fields: `id`, `name`, `slug`, `description`, `parentId` (Long, nullable). The `parentId` being nullable is what enables the self-referencing tree — null means root level.

**`ProductImage.java`**
Plain Java class mirroring the `product_images` table. Fields: `id`, `productId`, `imageUrl`, `displayOrder` (int).

### `mapper/`

**`ProductRowMapper.java`**
Maps a `products` ResultSet row to a `Product` object. Uses `rs.getObject("category_id", Long.class)` instead of `rs.getLong()` for the nullable `category_id` column — `getLong()` returns 0 for NULL while `getObject()` correctly returns null.

**`CategoryRowMapper.java`**
Maps a `categories` ResultSet row to a `Category` object. Uses `rs.getObject("parent_id", Long.class)` for the nullable `parent_id` column.

**`ProductImageRowMapper.java`**
Maps a `product_images` ResultSet row to a `ProductImage` object. All columns are NOT NULL so no special null handling is needed.

### `dto/`

**`ProductDto.java`**
Full product detail response used on the product detail page. Fields: `id`, `name`, `slug`, `description`, `price`, `categoryId`, `categoryName`, `averageRating`, `featured`, `active`, `imageUrls` (List of strings), `createdAt`. `categoryName` is populated by the service from a separate category lookup. `imageUrls` is a flat list of strings extracted from `ProductImage` objects — the frontend does not need the full image object.

**`ProductSummaryDto.java`**
Lightweight product response used for product cards on listing pages. Fields: `id`, `name`, `slug`, `description`, `price`, `categoryName`, `averageRating`, `featured`, `active`, `thumbnailUrl`. Only the first image URL is included as `thumbnailUrl` — sending all images for every card in a 100-product list would be wasteful.

**`ProductCreateRequest.java`**
Incoming body for creating a product. Fields: `name` (required), `slug` (optional — auto-generated if blank), `description`, `price` (required, positive), `categoryId` (required), `stockQuantity` (required, zero or positive), `imageUrls` (list), `isFeatured`, `isActive`. Uses `@NotBlank`, `@NotNull`, `@Positive`, `@PositiveOrZero`, `@Size`.

**`ProductUpdateRequest.java`**
Incoming body for updating a product. All fields are optional (`@Size` without `@NotBlank`, `@Positive` without `@NotNull`) using wrapper types (`Integer`, `Boolean`, `BigDecimal`) instead of primitives so that null means "not provided" rather than "set to zero/false".

**`CategoryDto.java`**
Outgoing category data. Fields: `id`, `name`, `slug`, `description`, `parentId`. `parentId` being null indicates a root category; a non-null value tells the frontend which category is this one's parent.

**`CategoryRequest.java`**
Incoming body for creating or updating a category. Fields: `name` (required), `slug` (required), `description` (optional), `parentId` (optional). Uses `@NotBlank` and `@Size`.

---

## `module/inventory/`

### `controller/`

**`InventoryController.java`**
Admin-only endpoints. `GET /api/admin/inventory` returns a paginated list of all inventory records with their current stock levels. `PUT /api/admin/inventory/{productId}` accepts an `AdjustStockRequest` and manually sets the stock quantity with an adjustment note. All endpoints are protected by `ROLE_ADMIN` via `SecurityConfig`.

### `service/`

**`InventoryService.java`**
Business logic for stock management. `adjustStock(productId, request)` — validates the product exists, updates `quantity_available` and records the `adjustment_note`. `decrementStock(productId, quantity)` — called by `OrderService` when an order is placed; validates that available stock is sufficient before decrementing, throwing a `ValidationException` if not. `incrementStock(productId, quantity)` — called by `OrderService` when an order is cancelled, restoring the units. `getLowStockItems()` — used by `AdminService` to populate the dashboard alert list, returns all inventory rows where `quantity_available <= low_stock_threshold`.

### `repository/`

**`InventoryRepository.java`**
Interface declaring: `save()`, `findById()`, `findByProductId()`, `findAll()`, `findLowStockItems()`, `existsByProductId()`, `update()`, `incrementStock()`, `decrementStock()`, `deleteById()`, `deleteByProductId()`.

**`InventoryRepositoryImpl.java`**
Implements `InventoryRepository`. `incrementStock()` runs `UPDATE inventory SET quantity_available = quantity_available + ? WHERE product_id = ?`. `decrementStock()` runs the same with subtraction. `findLowStockItems()` runs `WHERE quantity_available <= low_stock_threshold`. Both increment and decrement use atomic SQL arithmetic to avoid race conditions.

### `model/`

**`Inventory.java`**
Plain Java class mirroring the `inventory` table. Fields: `id`, `productId`, `quantityAvailable`, `lowStockThreshold`, `lastAdjustedAt`, `adjustmentNote`.

### `mapper/`

**`InventoryRowMapper.java`**
Maps an `inventory` ResultSet row to an `Inventory` object.

### `dto/`

**`InventoryDto.java`**
Outgoing inventory data for admin views. Fields: `id`, `productId`, `productName` (joined from products table in service), `quantityAvailable`, `lowStockThreshold`, `lastAdjustedAt`, `adjustmentNote`.

**`AdjustStockRequest.java`**
Incoming body for manual stock adjustment. Fields: `quantityAvailable` (Integer, required, zero or positive), `adjustmentNote` (String, required). `Integer` wrapper is used instead of primitive `int` so null is distinguishable from zero.

---

## `module/cart/`

### `controller/`

**`CartController.java`**
All endpoints require authentication. `GET /api/cart` fetches the current user's cart. `POST /api/cart/items` adds a product to the cart. `PUT /api/cart/items/{itemId}` updates item quantity. `DELETE /api/cart/items/{itemId}` removes a single item. `DELETE /api/cart` clears the entire cart. The authenticated user's identity is extracted from JWT via `@AuthenticationPrincipal` and passed to `CartService`.

### `service/`

**`CartService.java`**
Business logic for cart operations. On get cart: fetches the `Cart` record, fetches all `CartItem` rows for that cart, for each item fetches the product name and thumbnail from `ProductRepository`, assembles `CartItemDto` objects including the computed `lineTotal` (quantity × price), sums up the `subtotal`, and returns a `CartDto`. On add item: checks if the user's cart exists — if not, creates one. Checks if the product is already in the cart — if so, increments quantity instead of inserting a new row. Validates that the requested quantity does not exceed available stock. On update quantity: validates stock before updating. On clear cart: calls `CartItemRepository.deleteByCartId()`.

### `repository/`

**`CartRepository.java`**
Interface declaring: `save()`, `findById()`, `findByUserId()`, `existsByUserId()`, `deleteById()`, `deleteByUserId()`.

**`CartRepositoryImpl.java`**
Implements `CartRepository`. `save()` inserts only `user_id` — the cart table has no other columns. `findByUserId()` is the primary lookup — each user has exactly one cart due to the UNIQUE constraint.

**`CartItemRepository.java`**
Interface declaring: `save()`, `findById()`, `findByCartId()`, `findByCartIdAndProductId()`, `existsByCartIdAndProductId()`, `getTotalItemCount()`, `update()`, `updateQuantity()`, `deleteById()`, `deleteByCartId()`.

**`CartItemRepositoryImpl.java`**
Implements `CartItemRepository`. `findByCartIdAndProductId()` is used to check if a product is already in the cart before deciding whether to insert or update. `getTotalItemCount()` uses `COALESCE(SUM(quantity), 0)` to return 0 instead of NULL when the cart is empty. `deleteByCartId()` is called after a successful order placement to clear the cart.

### `model/`

**`Cart.java`**
Plain Java class mirroring the `carts` table. Fields: `id`, `userId`, `cartItems` (List — populated by service).

**`CartItem.java`**
Plain Java class mirroring the `cart_items` table. Fields: `id`, `cartId`, `productId`, `quantity` (int), `priceAtTimeOfAdding` (BigDecimal).

### `mapper/`

**`CartRowMapper.java`**
Maps a `carts` ResultSet row to a `Cart` object. Only maps `id` and `user_id` — `cartItems` is left null, populated later by `CartService`.

**`CartItemRowMapper.java`**
Maps a `cart_items` ResultSet row to a `CartItem` object, including `price_at_time_of_adding` as BigDecimal.

### `dto/`

**`CartDto.java`**
Outgoing cart data. Fields: `id`, `userId`, `cartItems` (List of CartItemDto), `subtotal` (BigDecimal — sum of all line totals), `totalItemCount` (int — sum of all quantities). Assembled entirely by `CartService` — no single SQL query produces this shape.

**`CartItemDto.java`**
Outgoing representation of a single cart line item. Fields: `id`, `productId`, `productName`, `productThumbnailUrl`, `unitPrice`, `quantity`, `lineTotal`. `productName` and `productThumbnailUrl` are fetched from the products table by the service — they are not stored in `cart_items`.

**`CartItemRequest.java`**
Incoming body for adding or updating a cart item. Fields: `productId` (required), `quantity` (required, positive Integer).

---

## `module/order/`

### `controller/`

**`OrderController.java`**
Customer endpoints: `POST /api/orders` (place order), `GET /api/orders` (list own orders, paginated), `GET /api/orders/{id}` (own order detail), `PUT /api/orders/{id}/cancel` (cancel if PENDING). Admin endpoints: `GET /api/admin/orders` (list all orders with filters — status, date range), `GET /api/admin/orders/{id}` (full detail of any order), `PUT /api/admin/orders/{id}/status` (update status). Customer endpoints verify that the requested order belongs to the authenticated user before returning data.

### `service/`

**`OrderService.java`**
The most complex service in the project. `placeOrder(email, request)` — fetches the user, fetches their cart, validates the cart is not empty, fetches each product and its inventory, validates no item's requested quantity exceeds available stock (throws `ValidationException` per failing item), fetches the selected address and copies its fields as shipping snapshot fields, applies the coupon if provided (via `DiscountService`), calculates `totalAmount`, `discountAmount`, and `finalAmount`, saves the `Order` record (using `RETURNING id` to get the generated order ID), saves each `OrderItem` with product name and image snapshots, calls `InventoryService.decrementStock()` for each item, calls `PaymentService.createPayment()`, calls `CartService.clearCart()` — all within a single `@Transactional` block so any failure rolls back the entire operation. `cancelOrder(email, orderId)` — verifies the order belongs to the user, verifies status is PENDING, calls `InventoryService.incrementStock()` for each item, updates status to CANCELLED. `updateOrderStatus(orderId, newStatus)` — admin only, enforces sequential status transitions server-side.

### `repository/`

**`OrderRepository.java`**
Interface declaring: `save()` (returns Long — the generated order ID), `findById()`, `findByIdAndUserId()`, `findByUserId()`, `findAll()`, `findByStatus()`, `existsById()`, `countOrdersToday()`, `updateStatus()`, `deleteById()`.

**`OrderRepositoryImpl.java`**
Implements `OrderRepository`. `save()` uses `RETURNING id` and `queryForObject()` to capture the auto-generated primary key immediately after INSERT — this ID is needed to create related `OrderItem` records. `findByIdAndUserId()` adds `AND user_id = ?` so customers can only retrieve their own orders. `countOrdersToday()` uses `WHERE DATE(created_at) = CURRENT_DATE` for the admin dashboard stat.

**`OrderItemRepository.java`**
Interface declaring: `save()`, `saveAll()`, `findById()`, `findByOrderId()`, `existsByOrderIdAndProductId()`, `deleteById()`, `deleteByOrderId()`.

**`OrderItemRepositoryImpl.java`**
Implements `OrderItemRepository`. `saveAll()` iterates and calls `save()` for each item. `findByOrderId()` returns all line items for a given order, used to populate the `orderItems` list in `OrderDetailDto`.

### `model/`

**`Order.java`**
Plain Java class mirroring the `orders` table. Contains all shipping snapshot fields (`shippingFullName`, `shippingPhone`, `shippingStreet`, `shippingCity`, `shippingState`, `shippingPincode`, `shippingCountry`), financial fields (`totalAmount`, `discountAmount`, `finalAmount`), `couponCode`, `paymentMethod`, `status` (OrderStatus enum), `orderItems` (List — populated by service), `createdAt`.

**`OrderItem.java`**
Plain Java class mirroring the `order_items` table. Contains product snapshot fields (`productName`, `productImageUrl`, `unitPrice`) so order history is immutable regardless of future product changes. Fields: `id`, `orderId`, `productId`, `productName`, `productImageUrl`, `unitPrice`, `quantity`, `lineTotal` (BigDecimal).

**`OrderStatus.java`**
Enum with values: `PENDING`, `PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`. Stored as VARCHAR in the database. The service enforces that status transitions follow the defined sequence.

### `mapper/`

**`OrderRowMapper.java`**
Maps an `orders` ResultSet row to an `Order` object. Converts the `status` VARCHAR back to `OrderStatus` enum via `OrderStatus.valueOf()`. Does not populate `orderItems` — that is done in the service layer.

**`OrderItemRowMapper.java`**
Maps an `order_items` ResultSet row to an `OrderItem` object including all snapshot columns.

### `dto/`

**`OrderDto.java`**
Lightweight order data for the My Orders list page. Fields: `id`, `userId`, `totalAmount`, `discountAmount`, `finalAmount`, `couponCode`, `paymentMethod`, `status`, `createdAt`, `totalItemCount`. Does not include the full item list — that is only in `OrderDetailDto`.

**`OrderDetailDto.java`**
Full order data for the Order Detail page. All fields from `OrderDto` plus all shipping address snapshot fields and `List<OrderItemDto> orderItems`.

**`OrderItemDto.java`**
Outgoing representation of a single order line item for display. Fields: `id`, `productId`, `productName`, `productImageUrl`, `unitPrice`, `quantity`, `lineTotal`.

**`PlaceOrderRequest.java`**
Incoming body for placing an order. Fields: `addressId` (required — the user's saved address to ship to), `paymentMethod` (required), `couponCode` (optional). The service fetches the address by ID and copies its fields as snapshots.

**`UpdateOrderStatusRequest.java`**
Incoming body for admin status updates. Field: `status` (String, required). The service parses this to `OrderStatus` enum and validates the transition is sequential.

---

## `module/payment/`

### `controller/`

**`PaymentController.java`**
`GET /api/payments/order/{orderId}` — returns the payment details for a given order. Used on the Order Detail page to show payment method, transaction ID, and payment status. Payment creation is not triggered directly by the frontend — it happens internally within `OrderService.placeOrder()`.

### `service/`

**`PaymentService.java`**
`createPayment(orderId, amount, method)` — called internally by `OrderService` during order placement. For `MOCK_CARD` method: sets status to `COMPLETED` and generates a random UUID as the `transactionId`. For `COD` method: sets status to `PENDING` (payment is not received until delivery) and leaves `transactionId` null. Saves the `Payment` record via `PaymentRepository`. `getPaymentByOrderId(orderId)` — returns payment details for display.

### `repository/`

**`PaymentRepository.java`**
Interface declaring: `save()`, `findById()`, `findByOrderId()`, `findAll()`, `existsByOrderId()`, `updateStatus()`, `deleteById()`.

**`PaymentRepositoryImpl.java`**
Implements `PaymentRepository`. `save()` uses `NOW()` for `paid_at` directly in SQL. `findByOrderId()` is the primary lookup since payments are always retrieved in context of an order.

### `model/`

**`Payment.java`**
Plain Java class mirroring the `payments` table. Fields: `id`, `orderId`, `amount` (BigDecimal), `method`, `status` (PaymentStatus enum), `transactionId` (String, nullable), `paidAt`.

**`PaymentStatus.java`**
Enum with values: `PENDING`, `COMPLETED`, `FAILED`, `REFUNDED`. Stored as VARCHAR in the database.

### `mapper/`

**`PaymentRowMapper.java`**
Maps a `payments` ResultSet row to a `Payment` object. Converts `status` VARCHAR to `PaymentStatus` enum. Handles nullable `transaction_id` column safely.

### `dto/`

**`PaymentDto.java`**
Outgoing payment data for display. Fields: `id`, `orderId`, `amount`, `method`, `status`, `transactionId`, `paidAt`.

**`PaymentRequest.java`**
Incoming body if payment is initiated separately. Fields: `orderId`, `method`, `mockCardNumber`, `mockCardExpiry`, `mockCardCvv`. The mock card fields are accepted but not validated or processed — the backend simply marks the payment as completed.

---

## `module/review/`

### `controller/`

**`ReviewController.java`**
Public: `GET /api/products/{productId}/reviews` (paginated review list for a product). Authenticated: `POST /api/products/{productId}/reviews` (submit or edit a review — service determines which based on existing record), `DELETE /api/reviews/{id}` (customer deletes own review, admin can delete any review).

### `service/`

**`ReviewService.java`**
`submitReview(email, productId, request)` — verifies the user has a DELIVERED order containing this product by querying the `order_items` and `orders` tables. If not, throws `UnauthorizedException`. Checks if a review already exists for this user+product combination — if yes, updates the existing record (edit mode). If no, inserts a new record. After save, calls `ProductService.recalculateAverageRating(productId)` which recomputes and updates the `average_rating` on the product. `deleteReview(email, reviewId)` — for customers, verifies the review belongs to them before deleting. For admins, deletes without ownership check. After delete, triggers average rating recalculation.

### `repository/`

**`ReviewRepository.java`**
Interface declaring: `save()`, `findById()`, `findByProductId()`, `findByUserId()`, `findByUserIdAndProductId()`, `existsByUserIdAndProductId()`, `calculateAverageRatingByProductId()`, `update()`, `deleteById()`, `deleteByProductId()`.

**`ReviewRepositoryImpl.java`**
Implements `ReviewRepository`. `calculateAverageRatingByProductId()` runs `SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE product_id = ?` — `COALESCE` ensures 0.0 is returned instead of NULL when there are no reviews. `findByUserIdAndProductId()` is used to check for existing reviews before deciding insert vs update.

### `model/`

**`Review.java`**
Plain Java class mirroring the `reviews` table. Fields: `id`, `userId`, `productId`, `rating` (int), `title`, `body`, `createdAt`.

### `mapper/`

**`ReviewRowMapper.java`**
Maps a `reviews` ResultSet row to a `Review` object.

### `dto/`

**`ReviewDto.java`**
Outgoing review data for public display. Fields: `id`, `userId`, `reviewerName` (fetched from users table by service — not stored in reviews table), `productId`, `rating`, `title`, `body`, `createdAt`.

**`ReviewRequest.java`**
Incoming body for submitting or editing a review. Fields: `rating` (Integer, required, min 1 max 5), `title` (required, max 200), `body` (required, max 200).

---

## `module/wishlist/`

### `controller/`

**`WishlistController.java`**
All endpoints require authentication. `GET /api/wishlist` fetches the current user's wishlist. `POST /api/wishlist/{productId}` adds a product. `DELETE /api/wishlist/{productId}` removes a product. `POST /api/wishlist/{productId}/move-to-cart` adds the product to cart and removes it from wishlist in one operation.

### `service/`

**`WishlistService.java`**
`getWishlist(email)` — fetches all `WishlistItem` records for the user, then for each item fetches the product details from `ProductRepository` and the inventory from `InventoryRepository` to determine `isInStock`. Assembles `WishlistItemDto` objects including the `isInStock` flag so the frontend can show "Unavailable" for out-of-stock items. `addToWishlist(email, productId)` — checks if item already exists, if so returns without error (idempotent). `moveToCart(email, productId)` — calls `CartService.addItem()` then calls `deleteByUserIdAndProductId()`.

### `repository/`

**`WishlistItemRepository.java`**
Interface declaring: `save()`, `findById()`, `findByUserId()`, `findByUserIdAndProductId()`, `existsByUserIdAndProductId()`, `countByUserId()`, `deleteById()`, `deleteByUserId()`, `deleteByUserIdAndProductId()`.

**`WishlistItemRepositoryImpl.java`**
Implements `WishlistItemRepository`. `findByUserId()` orders by `added_at DESC` so the most recently added items appear first. `deleteByUserIdAndProductId()` is used for both remove and move-to-cart operations.

### `model/`

**`WishlistItem.java`**
Plain Java class mirroring the `wishlist_items` table. Fields: `id`, `userId`, `productId`, `addedAt`.

### `mapper/`

**`WishlistItemRowMapper.java`**
Maps a `wishlist_items` ResultSet row to a `WishlistItem` object.

### `dto/`

**`WishlistDto.java`**
Outgoing full wishlist data. Fields: `userId`, `items` (List of WishlistItemDto), `totalItemCount`.

**`WishlistItemDto.java`**
Outgoing representation of a single wishlist entry. Fields: `id`, `productId`, `productName`, `productThumbnailUrl`, `price`, `isInStock`, `addedAt`. `isInStock` is computed by checking `inventory.quantity_available > 0` in the service layer.

---

## `module/discount/`

### `controller/`

**`DiscountController.java`**
Authenticated customer endpoint: `POST /api/discount/validate` — validates a coupon code against the cart subtotal and returns the discount amount or an error. Admin-only endpoints: `GET /api/admin/coupons` (list all), `POST /api/admin/coupons` (create), `PUT /api/admin/coupons/{id}` (update), `DELETE /api/admin/coupons/{id}` (delete), `PUT /api/admin/coupons/{id}/status` (activate/deactivate).

### `service/`

**`DiscountService.java`**
`validateAndCalculateDiscount(couponCode, cartSubtotal)` — fetches the coupon by code, throws `ResourceNotFoundException` if not found. Validates in order: is active, not expired (`expiryDate == null || expiryDate.isAfter(LocalDate.now())`), usage count below limit (`usageLimit == null || usageCount < usageLimit`), cart subtotal meets minimum order value. Calculates discount: for `FLAT` type, discount = `discountValue`. For `PERCENTAGE` type, discount = `cartSubtotal × (discountValue / 100)`, then applies `maximumDiscountCap` if set. Returns the final discount amount. `incrementCouponUsage(couponId)` — called by `OrderService` after a successful order placement to increment the coupon's `usage_count`.

### `repository/`

**`CouponRepository.java`**
Interface declaring: `save()`, `findById()`, `findByCode()`, `findAll()`, `findActive()`, `existsByCode()`, `existsById()`, `update()`, `incrementUsageCount()`, `updateActiveStatus()`, `deleteById()`.

**`CouponRepositoryImpl.java`**
Implements `CouponRepository`. `findActive()` runs `WHERE is_active = TRUE AND (expiry_date IS NULL OR expiry_date >= CURRENT_DATE)`. `incrementUsageCount()` runs `UPDATE coupons SET usage_count = usage_count + 1 WHERE id = ?` — atomic SQL increment, no race condition.

### `model/`

**`Coupon.java`**
Plain Java class mirroring the `coupons` table. Fields: `id`, `code`, `discountType` (DiscountType enum), `discountValue` (BigDecimal), `minimumOrderValue` (BigDecimal), `maximumDiscountCap` (BigDecimal, nullable), `expiryDate` (LocalDate, nullable), `usageLimit` (int, nullable), `usageCount` (int), `active` (boolean).

**`DiscountType.java`**
Enum with two values: `FLAT` and `PERCENTAGE`. Stored as VARCHAR in the `coupons` table.

### `mapper/`

**`CouponRowMapper.java`**
Maps a `coupons` ResultSet row to a `Coupon` object. Handles nullable `expiry_date` using a null check before calling `.toLocalDate()`. Handles nullable `maximum_discount_cap` using `rs.getBigDecimal()` which returns null for SQL NULL automatically.

### `dto/`

**`CouponDto.java`**
Outgoing coupon data for admin management views. All coupon fields including `usageCount` so admin can see how many times a coupon has been used.

**`CouponRequest.java`**
Incoming body for creating or updating a coupon. Fields: `code` (required, unique), `discountType` (required), `discountValue` (required, positive), `minimumOrderValue` (required), `maximumDiscountCap` (optional), `expiryDate` (optional), `usageLimit` (optional), `isActive` (optional Boolean wrapper).

**`ApplyCouponRequest.java`**
Incoming body for the validate coupon endpoint. Fields: `couponCode` (required), `cartSubtotal` (required BigDecimal). The service uses `cartSubtotal` to check the minimum order value without having to re-fetch the cart.

---

## `module/admin/`

### `controller/`

**`AdminDashboardController.java`**
Admin-only endpoints. `GET /api/admin/dashboard/stats` — returns summary card data for the dashboard overview. `GET /api/admin/dashboard/sales-report?startDate=&endDate=` — returns revenue and best-seller data for the given date range. Both endpoints are protected by `ROLE_ADMIN`.

### `service/`

**`AdminService.java`**
Aggregates data from multiple repositories to build admin views. `getDashboardStats()` — calls `OrderRepository.countOrdersToday()`, queries total revenue via a `SUM(final_amount)` SQL aggregation, calls `ProductRepository` for active product count, calls `UserRepository` for total user count, calls `OrderRepository.findByStatus(PENDING)` for pending count, calls `InventoryRepository.findLowStockItems()` for the alert list. Assembles and returns `DashboardStatsDto`. `getSalesReport(startDate, endDate)` — runs aggregation queries against the `orders` and `order_items` tables filtered by the date range to compute total orders, total revenue, average order value, and a ranked list of top-selling products by units sold.

### `dto/`

**`DashboardStatsDto.java`**
Outgoing data for the admin dashboard overview. Fields: `totalRevenue` (BigDecimal), `ordersToday` (int), `activeProductCount` (int), `totalUserCount` (int), `pendingOrderCount` (int), `lowStockProducts` (List of LowStockAlertDto).

**`SalesReportDto.java`**
Outgoing data for the admin sales report. Fields: `startDate`, `endDate`, `totalOrders` (int), `totalRevenue` (BigDecimal), `averageOrderValue` (BigDecimal), `topSellingProducts` (List of TopSellingProductDto).

**`LowStockAlertDto.java`**
Lightweight outgoing data for a single low-stock alert entry. Fields: `productId`, `productName`, `quantityAvailable`, `lowStockThreshold`. Used in the dashboard alert list.

**`TopSellingProductDto.java`**
Outgoing data for a single entry in the best-sellers report. Fields: `productId`, `productName`, `totalUnitsSold` (int), `totalRevenue` (BigDecimal). Populated by aggregating `order_items` grouped by `product_id` within the report date range.

---

## `test/`

**`UserServiceTest.java`**
Unit tests for `AuthService` and `UserService`. Tests covered: registration with a duplicate email throws `ValidationException`, registration with mismatched passwords throws `ValidationException`, login with a wrong password throws `ValidationException`, login for a banned user throws `ValidationException`, profile update persists correct fields, password change with incorrect current password is rejected.

**`ProductServiceTest.java`**
Unit tests for `ProductService`. Tests covered: product creation with an auto-generated slug, product creation with a duplicate slug throws `ValidationException`, soft delete sets `is_active = false` rather than removing the row, keyword search returns only active products, average rating recalculation after a review is submitted.

**`OrderServiceTest.java`**
Unit tests for `OrderService`. Tests covered: successful order placement decrements inventory and clears cart, placing an order with an empty cart throws `ValidationException`, placing an order where a cart item exceeds stock throws `ValidationException`, order cancellation from non-PENDING status throws `ValidationException`, successful cancellation increments inventory back.

**`CartServiceTest.java`**
Unit tests for `CartService`. Tests covered: adding a new item inserts a `CartItem` row, adding an item already in the cart increments quantity instead of inserting a duplicate, updating quantity beyond available stock throws `ValidationException`, removing an item calls the correct repository method, clearing the cart deletes all items for that cart ID.

---

## Frontend

---

## `index.html`

The home page shell. Contains the hero banner structure, placeholder containers for featured products, new arrivals, and category tiles. Loads `global.css`, `components.css`, `home.css`, `navbar.js`, `footer.js`, and `home.js`. All dynamic content is injected by `home.js` at runtime.

---

## `assets/css/`

**`global.css`**
CSS reset, root CSS custom properties (color palette, font sizes, spacing scale, border radii), and base styles applied to every page — body font, link defaults, button base styles, and utility classes like `.hidden`, `.flex`, `.container`.

**`components.css`**
Styles for reusable UI components shared across all pages: product card grid item, navbar layout and links, footer, modal overlay and dialog, toast notification animations, loading spinner, and pagination control buttons.

**`pages/home.css`**
Styles specific to the home page: hero banner layout and background, featured products section grid, new arrivals section grid, category tile grid and hover effects.

**`pages/product.css`**
Styles for both the product listing page (filter sidebar layout, sort bar, product grid) and the product detail page (image gallery with thumbnail strip, info panel layout, review list and star display).

**`pages/cart.css`**
Styles for the cart page: line item row layout, quantity control button group, remove button, and the summary panel positioning and totals display.

**`pages/checkout.css`**
Styles for the multi-step checkout: step indicator bar showing current progress, address card selection layout, order review table, coupon input and applied badge, payment method radio card layout, and confirmation page layout.

**`pages/auth.css`**
Styles for the login and register pages: centered card layout, form input fields, validation error message display below inputs, and submit button.

**`pages/profile.css`**
Styles for the profile page: section tab navigation, address book grid with card layout, default badge on address cards, and inline edit forms.

**`pages/orders.css`**
Styles for the orders list and order detail pages: order summary card layout, status badge colors (one color per status), and the order status timeline indicator on the detail page.

**`pages/admin.css`**
Styles specific to the admin panel: dashboard stat card grid, data table with alternating row colors, action button groups, and the admin sidebar navigation layout.

---

## `assets/js/api/`

**`client.js`**
The base HTTP client used by every other API file. Wraps the native `fetch()` API. Automatically reads the JWT token from `localStorage` and adds `Authorization: Bearer <token>` to every request header. On a 401 response, clears the token from `localStorage` and redirects the user to the login page. On a 500 response, triggers a generic error toast. Returns the parsed JSON response body. All other API files call through this instead of calling `fetch()` directly.

**`auth.api.js`**
Functions: `register(data)` calling `POST /api/auth/register` and `login(data)` calling `POST /api/auth/login`.

**`product.api.js`**
Functions: `getProducts(filters)`, `getProductById(id)`, `searchProducts(query)`, `createProduct(data)`, `updateProduct(id, data)`, `deleteProduct(id)`, `getCategories()`, `getCategoryById(id)`.

**`cart.api.js`**
Functions: `getCart()`, `addToCart(productId, quantity)`, `updateCartItem(itemId, quantity)`, `removeCartItem(itemId)`, `clearCart()`.

**`order.api.js`**
Functions: `placeOrder(data)`, `getMyOrders(page, size)`, `getOrderById(id)`, `cancelOrder(id)`, `getAllOrders(filters)`, `updateOrderStatus(id, status)`.

**`payment.api.js`**
Functions: `getPaymentByOrderId(orderId)`.

**`review.api.js`**
Functions: `getReviewsByProduct(productId, page)`, `submitReview(productId, data)`, `deleteReview(reviewId)`.

**`wishlist.api.js`**
Functions: `getWishlist()`, `addToWishlist(productId)`, `removeFromWishlist(productId)`, `moveToCart(productId)`.

**`admin.api.js`**
Functions: `getDashboardStats()`, `getSalesReport(startDate, endDate)`, `getUsers(filters)`, `banUser(userId)`, `unbanUser(userId)`, `getInventory()`, `adjustStock(productId, data)`, `getCoupons()`, `createCoupon(data)`, `updateCoupon(id, data)`, `deleteCoupon(id)`, `getAllReviews(filters)`, `deleteReview(id)`.

---

## `assets/js/components/`

**`navbar.js`**
Dynamically renders the navbar into every page by injecting HTML into a designated `<nav>` element. Calls `auth.js` to check login state — if logged in, replaces Login/Register links with the user's name and a Logout button. If the user is ADMIN, adds an "Admin Panel" link. Fetches the cart item count from `cart.api.js` and displays it as a badge on the cart icon.

**`footer.js`**
Injects the footer HTML into every page. Static content — copyright notice and navigation links.

**`productCard.js`**
A function that accepts a `ProductSummaryDto` object and returns an HTML string representing a product card. Used by `home.js` and `productList.js` to render product grids consistently without duplicating HTML across multiple files.

**`modal.js`**
A reusable modal component. Exposes `openModal(title, bodyHTML)` and `closeModal()`. Manages the overlay, the dialog box, a title, injectable body content, and a close button. Used by admin pages for create/edit forms and by checkout for the new address form.

**`toast.js`**
Exposes `showToast(message, type)` where type is `success`, `error`, or `info`. Creates a notification element, appends it to the page, applies a CSS animation, and auto-removes it after a few seconds. Used everywhere — after adding to cart, on API errors, on successful order placement.

**`pagination.js`**
A function that takes `currentPage`, `totalPages`, and a callback function, then renders pagination controls (Previous button, numbered page buttons, Next button). When a page button is clicked, calls the callback with the new page number so the parent page script can re-fetch with the updated page.

**`spinner.js`**
Exposes `showSpinner()` and `hideSpinner()`. Displays a full-page or inline loading overlay while async API calls are in flight so the user knows the application is working.

---

## `assets/js/pages/`

**`home.js`**
On page load: calls `getProducts({ featured: true })` and injects results into the featured section using `productCard.js`. Calls `getProducts({ sort: 'newest', limit: 8 })` for new arrivals. Calls `getCategories()` and renders category tiles. Each category tile, when clicked, navigates to the product list page with the category filter pre-applied in the URL.

**`productList.js`**
Reads query parameters from the URL (category, minPrice, maxPrice, rating, sort, page, size). Calls `getProducts(filters)` with those parameters. Renders the product grid using `productCard.js`. Wires filter/sort input change events to rebuild the query parameters and re-fetch. Renders pagination controls using `pagination.js`.

**`productDetail.js`**
Reads the product ID from the URL. Calls `getProductById(id)` and renders the full detail view: image gallery with thumbnail switcher, all product fields, stock status display. Calls `getReviewsByProduct(id)` and renders the review list with pagination. If the user is logged in, renders the review submission form. If a review already exists for this user, pre-fills the form and shows "Edit Review" mode.

**`cart.js`**
Calls `getCart()` on load and renders the cart page. Wires quantity increment/decrement buttons to call `updateCartItem()`. Wires remove buttons to call `removeCartItem()`. After every change, recalculates and re-renders the subtotal display. Wires "Proceed to Checkout" to navigate to `checkout.html`.

**`checkout.js`**
Manages the multi-step checkout UI. Step 1: calls user addresses API and renders selectable address cards; includes a form to add a new address inline. Step 2: renders cart contents and a coupon input — on apply calls `validateCoupon` endpoint and updates the displayed total. Step 3: renders payment method radio buttons. On final submit: calls `placeOrder(data)` — on success renders the confirmation step with the returned order ID and details.

**`login.js`**
Wires the login form. On submit, calls `login(data)` from `auth.api.js`. On success, calls `auth.js` to store the JWT token and user data in `localStorage`, then redirects to the home page or the previously attempted protected page.

**`register.js`**
Wires the register form with client-side validation using `validator.js` (password match check, email format, minimum lengths). On submit, calls `register(data)`. On success, redirects to the login page with a success toast.

**`profile.js`**
Fetches and renders the user's profile on load. Wires the edit profile form to call `updateProfile()`. Wires the change password form to call `changePassword()`. Renders the address book list and wires add, edit, delete, and set-default buttons to their respective API calls.

**`orders.js`**
Fetches and renders the list of the current user's orders with pagination. Each order card shows ID, date, status badge (color-coded via `formatter.js`), total, and a "View Details" link.

**`orderDetail.js`**
Reads the order ID from the URL. Fetches the order by ID and renders the full detail view: all line items, shipping address, payment details, and status badge. Shows a Cancel button only if status is `PENDING`.

**`wishlist.js`**
Fetches and renders the wishlist on load. For each item renders the product thumbnail, name, price, and an `isInStock` indicator. "Move to Cart" button is disabled for out-of-stock items. "Remove" button calls `removeFromWishlist()`.

**`admin/dashboard.js`**
Calls `getDashboardStats()` and populates the summary stat cards. Renders the recent orders table. Renders the low stock alert list. All data is injected dynamically into placeholder elements in `dashboard.html`.

**`admin/manageProducts.js`**
Fetches and renders the product management table with search and filter controls. "Add Product" button opens a modal with the create form via `modal.js`. Each row's "Edit" button opens the same modal pre-filled with existing data. "Deactivate" button calls `deleteProduct()` (soft delete). Handles image URL list management in the form.

**`admin/manageOrders.js`**
Fetches all orders with admin filter controls (status dropdown, date range inputs). Renders the orders table. Each row has a status update dropdown — on change calls `updateOrderStatus()`.

**`admin/manageUsers.js`**
Fetches and renders all users with a search input. Each row shows name, email, role, banned status, and a Ban/Unban toggle button. Clicking calls `banUser()` or `unbanUser()`.

**`admin/manageCoupons.js`**
Fetches and renders all coupons with usage counts. "Add Coupon" opens a modal form. "Edit" pre-fills the modal. "Deactivate" calls the status update endpoint.

---

## `assets/js/utils/`

**`auth.js`**
The single source of truth for authentication state on the frontend. Functions: `saveToken(token)` writes to `localStorage`, `getToken()` reads it, `removeToken()` clears it. `saveUser(user)` stores user data (id, name, role), `getUser()` retrieves it. `isLoggedIn()` returns `true` if a token exists. `getRole()` returns the stored role string. `isAdmin()` returns `true` if role is `ROLE_ADMIN`. Every other script imports from here instead of accessing `localStorage` directly — centralizing auth state in one place.

**`router.js`**
A minimal hash-based client-side router. Reads `window.location.hash` on page load and navigation events. Maps hash paths like `#/products/42` to the correct page script and passes the ID as a parameter. Enables navigating between views without full page reloads on applicable pages. Also used to pass query parameters like category filters between pages via the hash.

**`formatter.js`**
Utility functions for consistent data display. `formatCurrency(amount)` formats a number as `₹1,299.00`. `formatDate(dateString)` converts an ISO timestamp to a human-readable format like `12 Jan 2025`. `formatStatus(status)` converts an enum string like `PROCESSING` to a display label `Processing` and returns the corresponding CSS badge class name for color coding.

**`validator.js`**
Reusable form validation functions for client-side checks before making API calls. `isValidEmail(str)` checks format. `isValidPhone(str)` checks length and numeric format. `isNotEmpty(str)` checks not blank. `minLength(str, n)` checks minimum character count. `passwordsMatch(p1, p2)` compares two password fields. Used by `login.js`, `register.js`, `profile.js`, and `checkout.js`. Server-side validation in Spring still runs independently — these are a UX convenience, not a security measure.

---

## HTML Pages

Each HTML file is a static shell. It contains the page's structural layout with empty placeholder elements, loads the relevant CSS files, loads `navbar.js` and `footer.js` as shared components, and loads the page-specific JavaScript file which makes API calls and injects all dynamic content into the DOM. None of the HTML files contain hardcoded product data, user data, or any data that comes from the backend.

**`pages/product-list.html`** — Shell with a filter sidebar panel, sort bar, and an empty product grid container. `productList.js` fills the grid.

**`pages/product-detail.html`** — Shell with placeholders for the image gallery, product info panel, and review section. `productDetail.js` populates all three.

**`pages/cart.html`** — Shell with an empty cart items container and a summary panel with placeholder totals. `cart.js` renders the items and totals.

**`pages/checkout.html`** — Shell with four step containers (address, review, payment, confirmation) where only one is visible at a time. `checkout.js` controls which step is shown.

**`pages/login.html`** — Static login form. `login.js` wires the submit event.

**`pages/register.html`** — Static registration form. `register.js` wires validation and submit.

**`pages/profile.html`** — Shell with tab sections for profile info, change password, and address book. `profile.js` fetches and renders all content.

**`pages/orders.html`** — Shell with an empty orders list container. `orders.js` fetches and renders the list.

**`pages/order-detail.html`** — Shell with placeholder sections for order summary, items table, shipping info, and payment info. `orderDetail.js` populates all sections.

**`pages/wishlist.html`** — Shell with an empty wishlist grid container. `wishlist.js` renders the items.

**`pages/admin/dashboard.html`** — Shell with empty stat card containers, a recent orders table body, and a low stock alert list container. `dashboard.js` populates all of them.

**`pages/admin/manage-products.html`** — Shell with a search input, filter controls, and an empty product data table. `manageProducts.js` populates the table and wires all controls.

**`pages/admin/manage-orders.html`** — Shell with status and date filter controls and an empty orders table. `manageOrders.js` populates and wires it.

**`pages/admin/manage-users.html`** — Shell with a search input and an empty users table. `manageUsers.js` populates and wires the ban/unban buttons.

**`pages/admin/manage-coupons.html`** — Shell with an "Add Coupon" button and an empty coupons table. `manageCoupons.js` populates the table and manages the modal form.

**`assets/images/placeholder.png`** — A static placeholder image displayed on product cards when a product has no image URL or when an image fails to load. Referenced in `productCard.js` as the fallback `src`.
