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

-- Create PRODUCT table
CREATE TABLE PRODUCT (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    tags TEXT[],
    condition VARCHAR(50) NOT NULL,
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    product_image VARCHAR(255),
    total_quantity INTEGER NOT NULL,
    current_quantity INTEGER NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (owner_id) REFERENCES "USER" (id)
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
