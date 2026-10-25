CREATE TABLE IF NOT EXISTS inventory (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL UNIQUE references products(id) ON DELETE CASCADE,
    quantity_available INT NOT NULL,
    low_stock_threshold INT NOT NULL DEFAULT 5,
    last_adjusted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    adjustment_note VARCHAR(200)
);
--DEFAULT 5 on low_stock_threshold — a sensible default so you do not have to specify it every time a product is created.

-- product_id should be NOT NULL and UNIQUE.
-- NOT NULL — an inventory record must always belong to a product
-- UNIQUE — each product should have exactly one inventory record, one-to-one relationship. Without UNIQUE, you could accidentally insert multiple inventory rows for the same product which would break your stock tracking logic
