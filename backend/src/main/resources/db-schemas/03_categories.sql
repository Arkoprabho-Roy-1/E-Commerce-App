CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description VARCHAR(200),
    parent_id BIGINT REFERENCES categories(id) ON DELETE SET NULL
);
-- parent_id BIGINT NOT NULL — this should be nullable. NOT NULL means every category must have a parent, which makes it impossible to create a top-level/root category like "Electronics" since it has no parent. Root categories have parent_id = NULL.

-- Two changes here:

-- Removed NOT NULL — allows root categories to have parent_id = NULL

-- ON DELETE CASCADE → ON DELETE SET NULL — if a parent category is deleted, its children should not be deleted too. Instead their parent_id becomes NULL, promoting them to root level. CASCADE would wipe out all child categories when a parent is deleted which is destructive and almost never what you want.  
