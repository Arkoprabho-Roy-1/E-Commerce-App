CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL,
    method VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    transaction_id VARCHAR(200),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- One order should have exactly one payment.

-- transaction ID should be nullable. For Cash on Delivery orders, there is no transaction ID at the time of order placement since no actual payment transaction occurs. Only mock card payments generate a transaction ID immediately. 
