-- Create USER table
CREATE TABLE "USER" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create TAG table
CREATE TABLE TAG (
    id SERIAL PRIMARY KEY,
    tag_name VARCHAR(255) UNIQUE NOT NULL
);

-- Create CATEGORY table
CREATE TABLE CATEGORY (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE NOT NULL
);

-- Create PRODUCT table
CREATE TABLE PRODUCT (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    condition VARCHAR(50) NOT NULL,
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    product_image VARCHAR(255),
    total_quantity INTEGER NOT NULL,
    current_quantity INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    description TEXT,
    embedding vector(1536),
    FOREIGN KEY (owner_id) REFERENCES "USER" (id),
    FOREIGN KEY (category_id) REFERENCES CATEGORY (id)
);

-- Create PRODUCT_TAG table for many-to-many relationship between PRODUCT and TAG
CREATE TABLE PRODUCT_TAG (
    product_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCT (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES TAG (id) ON DELETE CASCADE
);

-- Create ORDER table
CREATE TABLE "ORDER" (
    id SERIAL PRIMARY KEY,
    buyer_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,
    ordered_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fulfilled_on TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES "USER" (id),
    FOREIGN KEY (seller_id) REFERENCES "USER" (id)
);

-- Create PRODUCT_ORDER table
CREATE TABLE PRODUCT_ORDER (
    product_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    order_quantity INTEGER NOT NULL,
    PRIMARY KEY (product_id, order_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCT (id),
    FOREIGN KEY (order_id) REFERENCES "ORDER" (id)
);
