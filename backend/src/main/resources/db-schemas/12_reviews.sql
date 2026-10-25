CREATE TABLE IF NOT EXISTS reviews (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    rating INT NOT NULL DEFAULT 5,
    title VARCHAR(200) NOT NULL,
    body VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);
-- One user can review multiple products, one product can receive reviews from multiple users. Same many-to-many relationship as orders and products, resolved here by the composite unique constraint.
