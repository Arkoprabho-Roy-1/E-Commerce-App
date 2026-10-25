CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    product_name VARCHAR(200) NOT NULL,
    product_image_url VARCHAR(200) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INT NOT NULL,
    line_total NUMERIC(10,2) NOT NULL,
    UNIQUE(order_id, product_id)
);
-- So basically, 1 order can have multiple products. Multiple orders can have the same product

-- Yes, exactly. That is the classic **many-to-many relationship** between `orders` and `products`, and `order_items` is the **junction table** that sits between them resolving it.

-- ```
-- orders          order_items            products
-- ------          -----------            --------
-- order 1    →    order 1, product A  →  product A
--            →    order 1, product B  →  product B

-- order 2    →    order 2, product A  →  product A (same product, different order)
--            →    order 2, product C  →  product C
-- ```

-- So:
-- - One order → many order_items ✓
-- - One product → many order_items ✓
-- - One order cannot have the same product twice → enforced by `UNIQUE(order_id, product_id)` ✓

-- Same relationship exists between `carts` and `products` via `cart_items` for the exact same reason.
