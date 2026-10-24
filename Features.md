# Features

This document describes every feature available in the E-Commerce application, organized by user role. There are three roles: **Guest**, **Customer** (authenticated user), and **Admin**.

---

## Role 1 — Guest

Guests are unauthenticated visitors. They can browse the store but cannot transact.

---

### 1. Home Page

- Displays a static hero banner section
- Shows a **Featured Products** section — products flagged as featured by admin
- Shows a **New Arrivals** section — products sorted by creation date descending, limited to the latest 8–12
- Shows product categories as clickable tiles that navigate to filtered product listings
- Navbar shows links to: Home, Products, Login, Register

---

### 2. Product Listing Page

- Fetches all active products with server-side pagination (12 per page)
- **Filtering options:**
  - By category
  - By price range (min/max)
  - By average rating (e.g. 4 stars and above)
  - By availability (in stock only toggle)
- **Sorting options:** Price low to high, Price high to low, Newest first, Highest rated
- Each product card shows: thumbnail image, name, price, average rating, and a View button
- Keyword search against product name and description with paginated results

---

### 3. Product Detail Page

- Shows full product info: name, description, image gallery, price, category, average rating, total review count, stock availability
- If out of stock, the Add to Cart button is disabled and "Out of Stock" is displayed
- Shows all customer reviews with star ratings, reviewer name, and review text — paginated
- Guests cannot submit a review — a prompt to login is shown instead
- "Add to Wishlist" button is shown but redirects to login if clicked

---

### 4. Authentication

- **Register:** form with username, full name, email, password, confirm password, phone number — client-side and server-side validation — duplicate email and username handled gracefully
- **Login:** email and password form — on success a JWT token is stored in `localStorage` and the user is redirected to home or the previously attempted page
- **Logout:** clears JWT from `localStorage` and redirects to home

---

## Role 2 — Customer (Authenticated User)

All Guest features remain available. The following are added or unlocked after login.

---

### 5. Cart Management

- Cart is persisted server-side linked to the user account — survives browser refresh and device switch
- Add to Cart from both the product listing and product detail pages
- Cart page shows: product thumbnail, name, unit price, quantity selector (increment / decrement / manual input), line total, and a remove button
- Cart summary panel shows: subtotal, applied discount (if any), and estimated total
- Quantity changes trigger real-time price recalculation on the frontend — stock validation happens on the backend at checkout
- If a product becomes out of stock while in the cart, a warning is shown at cart review

---

### 6. Wishlist

- Add any product to wishlist from the product detail page
- Wishlist page shows all saved items with options to move each item to cart or remove it
- If a wishlisted product goes out of stock or is deleted by admin, it is shown as "Unavailable" instead of silently disappearing

---

### 7. Checkout Flow (Multi-Step)

**Step 1 — Address Selection**
- Customer selects a saved address from their address book or enters a new one
- New address fields: full name, phone, street, city, state, pincode, country
- Option to save the new address to the profile for future use

**Step 2 — Order Review**
- Shows all cart items, quantities, unit prices, and line totals
- Subtotal is calculated server-side
- Coupon input field: customer enters a code — backend validates it and returns the discount amount or an error message
- Final total is displayed after coupon deduction

**Step 3 — Payment**
- Payment is simulated — no real gateway integration
- Customer selects a payment method: Cash on Delivery or Mock Card Payment
- For Mock Card: inputs card number, expiry, CVV — no real processing; backend marks the payment as completed
- On submission: backend creates the Order record, decrements inventory for each item, clears the cart, and creates a Payment record — all within a single transaction

**Step 4 — Confirmation**
- Shows: order ID, summary of items, delivery address, payment method, and a hardcoded estimated delivery date
- Options to view order details or continue shopping

---

### 8. Order Management (Customer)

- **My Orders page:** lists all past orders in reverse chronological order
- Each order card shows: order ID, date, total amount, item count, and current status
- **Order Detail page:** full breakdown of items, quantities, prices, shipping address, payment method, payment status, and order status
- **Cancel Order:** customer can cancel an order only if its status is still `PENDING` — backend validates this rule and reverts inventory on cancellation

**Order Status values:** `PENDING` → `PROCESSING` → `SHIPPED` → `DELIVERED` / `CANCELLED`

---

### 9. Profile Management

- View and edit: username, full name, email, phone number
- **Change password:** requires current password, new password, and confirm new password
- **Address Book:** list of all saved addresses — add new, edit existing, delete, and set one as default

---

### 10. Reviews and Ratings

- Customer can submit a review on a product only if they have a `DELIVERED` order containing that product — verified server-side to prevent fake reviews
- Review form: star rating (1–5, required), title (required), body text (required)
- One review per customer per product — if a review already exists, the form pre-fills and switches to Edit Review mode
- Customer can delete their own review
- Reviews are publicly visible immediately

---

### 11. Coupon Application

- Coupons are applied at the Order Review step of checkout
- Backend validates: code exists, is active, not expired, usage limit not exceeded, minimum order value is met
- **Two discount types:**
  - `FLAT` — fixed amount off (e.g. ₹200 off)
  - `PERCENTAGE` — percentage off with an optional maximum discount cap (e.g. 15% off, capped at ₹500)
- One coupon per order

---

## Role 3 — Admin

Admins access a separate admin dashboard section. All admin API endpoints are protected server-side by role verification — frontend-only redirects are not sufficient.

---

### 12. Admin Dashboard (Overview)

- Summary cards: total revenue (all time), total orders today, total active products, total registered users, total pending orders
- Recent orders table: last 10 orders with order ID, customer name, total amount, status, and a link to order detail
- Low stock alerts: list of products where `quantity_available` is at or below `low_stock_threshold`

---

### 13. Product Management

- List all products with search by name, filter by category, and filter by status (active/inactive)
- **Create Product:** name, slug (auto-generated from name via `SlugUtil` but editable), description, price, category, initial stock quantity, image URLs (multiple), featured flag, active/inactive status
- **Edit Product:** same form pre-filled — all fields are optional for partial update
- **Delete Product:** soft delete — product is marked as inactive (`is_active = FALSE`) rather than physically deleted, preserving historical order records
- **Manage Images:** add or remove image URLs per product

---

### 14. Category Management

- List all categories (self-referencing tree — unlimited depth via `parent_id`)
- **Create Category:** name, slug, optional description, optional parent category ID
- Edit and delete categories
- Deleting a category that has products assigned to it is blocked with an informative error message

---

### 15. Inventory Management

- View current stock level per product
- Admin can manually adjust stock quantity with a required adjustment note (reason for change)
- Stock is automatically decremented when an order is placed and incremented when an order is cancelled
- Low stock threshold is configurable per product

---

### 16. Order Management (Admin)

- List all orders with filters: by status, by date range, by customer name or email
- View full order detail: all items, customer info, shipping address, payment info
- **Update order status:** Admin moves orders through the sequence: `PENDING` → `PROCESSING` → `SHIPPED` → `DELIVERED`; admin can also mark as `CANCELLED`
- Status transitions are sequential and enforced server-side — e.g. an order cannot be marked `DELIVERED` without first being `SHIPPED`

---

### 17. User Management

- List all registered customers with search by name or email
- View a user's profile: their details, order history, and review history
- **Ban/Unban a user:** banned users are blocked at login — JWT generation is refused for banned accounts
- Admin cannot delete user accounts (data integrity is preserved)

---

### 18. Coupon Management

- List all coupons with usage statistics
- **Create Coupon:** code (unique), discount type (FLAT or PERCENTAGE), discount value, minimum order value, maximum discount cap (for PERCENTAGE type), expiry date, usage limit, active/inactive toggle
- Edit and deactivate coupons
- View usage count per coupon

---

### 19. Review Moderation

- List all reviews across all products with filters by product and by rating
- Admin can delete any review that violates guidelines
- Admin cannot edit a customer's review content

---

### 20. Sales Report

- Revenue summary by configurable date range: total orders, total revenue, average order value
- Best-selling products: ranked list by total units sold in the given period
- Read-only — derived from the `orders` and `order_items` tables; no separate reporting database

---

## Cross-Cutting Behaviors

### Security

- All API endpoints except public ones require a valid JWT in the `Authorization: Bearer <token>` header
- Admin endpoints additionally verify that the authenticated user carries the `ROLE_ADMIN` authority
- Passwords are stored hashed using BCrypt — never stored or logged in plain text
- JWT expiry is enforced — expired tokens receive a 401 response and the frontend redirects to login
- Banned users are blocked at the JWT generation step — they cannot log in even with correct credentials

### Error Handling

- All API errors return a consistent JSON structure: `{ "success": false, "message": "...", "data": null }`
- Validation errors return field-level details: `{ "success": false, "message": "Validation failed.", "data": { "email": "must not be blank" } }`
- HTTP status codes: 400 for validation failures, 401 for missing/expired token, 403 for forbidden actions, 404 for not found, 500 for server errors with a generic message

### Pagination

- All list endpoints (products, orders, reviews, users, coupons) support `page` and `size` query parameters
- All paginated responses return: `content`, `currentPage`, `totalPages`, `totalElements`, `pageSize`, `isFirst`, `isLast`

### Data Integrity Rules (enforced server-side)

- Cannot place an order if the cart is empty
- Cannot place an order if any cart item quantity exceeds available stock
- Cannot apply an expired, inactive, or usage-exhausted coupon
- Cannot apply a coupon if the order subtotal is below the coupon's minimum order value
- Cannot cancel an order that is not in `PENDING` status (customer)
- Cannot submit a review for a product that has not been purchased and delivered
- Cannot submit more than one review per product per customer
- Cannot create a product with a duplicate slug
- Cannot create a coupon with a duplicate code
- Cannot delete a category that has products assigned to it
- Cannot set a new default address without first clearing the existing default for that user
