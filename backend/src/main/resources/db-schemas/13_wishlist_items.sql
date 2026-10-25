CREATE TABLE IF NOT EXISTS wishlist_items (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);
-- One user can add multiple products to wishlist and Multiple users can add the same product to their wishlists. However, the same user cannot add the same product more than once to their wishlist as enforced by UNIQUE(user_id, product_id).  
