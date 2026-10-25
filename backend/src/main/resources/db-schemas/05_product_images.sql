CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(200) NOT NULL,
    display_order INT NOT NULL
); 
--No, size is not needed for INT in PostgreSQL.

-- INT (which is an alias for INTEGER) in PostgreSQL is always a fixed 4-byte integer — it does not accept a size parameter like VARCHAR(200). The size specification only applies to types like VARCHAR and NUMERIC where it actually means something.

-- INT always stores whole numbers from -2,147,483,648 to 2,147,483,647 regardless. For a display order value like 1, 2, 3 that range is more than enough.

-- product_id BIGINT REFERENCES products(id) ON DELETE SET NULL — this should be ON DELETE CASCADE, not ON DELETE SET NULL. A product image has no meaning or purpose without its product. If a product is deleted, its images should be deleted too. SET NULL would leave orphaned image rows in the table with no product attached, which is wasteful and meaningless.

-- Also product_id should be NOT NULL — an image must always belong to a product. It cannot exist without one. 
