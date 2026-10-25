CREATE TABLE IF NOT EXISTS coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    discount_type VARCHAR(20) NOT NULL,
    discount_value NUMERIC(10,2) NOT NULL,
    minimum_order_value NUMERIC(10,2) NOT NULL,
    maximum_discount_cap NUMERIC(10,2),
    expiry_date DATE,
    usage_limit INT,
    usage_count INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);
-- Two coupons cannot have the same code.

-- discount type must always exist, it cannot be null. A coupon must be either FLAT or PERCENTAGE, there is no third option.

-- maximum_discount_cap should be nullable. Maximum discount cap only applies to PERCENTAGE type coupons. A FLAT coupon has no cap.

-- expiry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP — wrong default. Setting expiry to the current timestamp means every coupon expires immediately upon creation. Expiry date should be nullable — some coupons may never expire.

-- Also changed to DATE instead of TIMESTAMP — expiry is a date, not a specific time, consistent with LocalDate in your Coupon.java model.

-- usage_count INT — should default to 0 since every new coupon starts with zero uses.

-- is_active BOOLEAN NOT NULL DEFAULT FALSE — same concern as products earlier. A newly created coupon defaulting to inactive means admin has to manually activate every coupon. Consider defaulting to TRUE:

-- sql
-- is_active BOOLEAN NOT NULL DEFAULT TRUE

