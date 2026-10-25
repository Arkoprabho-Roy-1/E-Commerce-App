CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY, 
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description VARCHAR(200),
    price NUMERIC(10,2) NOT NULL,
    category_id BIGINT references categories(id) ON DELETE SET NULL,
    average_rating NUMERIC(3,2) DEFAULT 0.00,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- when a product is first created, it has no reviews yet so its average rating does not exist. NOT NULL makes it impossible to insert a new product without providing a rating. It should be nullable with a default of 0.00
 
-- NUMERIC(3, 2) is the right choice:

-- 3 total digits
-- 2 digits after decimal point

-- So it can hold values like 4.35, 3.78, 5.00 — which covers the entire 1 to 5 rating range perfectly.

-- Why not FLOAT or DOUBLE PRECISION?

-- You could use them since average rating is just a display value and not a monetary calculation. But NUMERIC(3, 2) is still cleaner because:

-- It strictly limits the range — you cannot accidentally store 99.99 as a rating
-- It is consistent with the rest of your numeric fields
-- No floating point imprecision in storage

-- In PostgreSQL, BigDecimal maps to:
-- sql
-- NUMERIC(10, 2)
-- 10 — total number of digits
-- 2 — digits after the decimal point

-- So a value like 99999999.99 fits within NUMERIC(10, 2).

-- You can adjust the precision based on use case
-- For product prices and order amounts:

-- sql
-- NUMERIC(10, 2)

-- For discount percentages or average ratings:

-- sql
-- NUMERIC(5, 2)

-- Why not DECIMAL?
-- DECIMAL is also valid in PostgreSQL and is actually an alias for NUMERIC — they are identical. Either works. NUMERIC is the more commonly used term in PostgreSQL specifically.

-- Why not FLOAT or DOUBLE PRECISION?
-- Same floating point precision problem discussed earlier — avoid these for monetary values. Always use NUMERIC for anything involving money.
