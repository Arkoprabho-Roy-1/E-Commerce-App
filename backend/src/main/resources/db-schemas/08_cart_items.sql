CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    price_at_time_of_adding NUMERIC(10,2) NOT NULL,
    UNIQUE(cart_id, product_id)
);
--Also worth adding a UNIQUE constraint on the combination of cart_id and product_id — the same product should not appear as two separate rows in the same cart. If a user adds the same product twice, your service layer should increment quantity instead:                                        UNIQUE(cart_id, product_id)

--For cart items, if a product is deleted the cart item should be deleted too — a cart item with no product is meaningless
