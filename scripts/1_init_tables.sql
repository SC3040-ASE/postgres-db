DROP TABLE IF EXISTS ORDER_REQUEST_TAG;
DROP TABLE IF EXISTS ORDER_REQUEST;
DROP TABLE IF EXISTS _ORDER;
DROP TABLE IF EXISTS PRODUCT_TAG;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS TAG;
DROP TABLE IF EXISTS CATEGORY;
DROP TABLE IF EXISTS _USER;

CREATE TABLE _USER (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    telegram_handle VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CATEGORY (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE TAG (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    tag_name VARCHAR(255) NOT NULL,
    embedding vector(1536),
    FOREIGN KEY (category_id) REFERENCES CATEGORY (id),
    CONSTRAINT unique_category_tag UNIQUE (category_id, tag_name)
);

CREATE TABLE PRODUCT (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    condition VARCHAR(255) NOT NULL,
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_quantity INTEGER NOT NULL,
    current_quantity INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    description TEXT,
    embedding vector(1536),
    FOREIGN KEY (owner_id) REFERENCES _USER (id),
    FOREIGN KEY (category_id) REFERENCES CATEGORY (id)
);

CREATE TABLE PRODUCT_TAG (
    product_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCT (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES TAG (id) ON DELETE CASCADE
);

CREATE TABLE _ORDER (
    id SERIAL PRIMARY KEY,
    buyer_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    ordered_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fulfilled_on TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES _USER (id),
    FOREIGN KEY (seller_id) REFERENCES _USER (id),
    FOREIGN KEY (product_id) REFERENCES PRODUCT (id)
);

CREATE TABLE ORDER_REQUEST(
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    target_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    requestor_id INTEGER NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    condition VARCHAR(50) NOT NULL,
    description TEXT,
    FOREIGN KEY (category_id) REFERENCES CATEGORY (id),
    FOREIGN KEY (requestor_id) REFERENCES _USER (id)
);

CREATE TABLE ORDER_REQUEST_TAG (
    order_request_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (order_request_id, tag_id),
    FOREIGN KEY (order_request_id) REFERENCES ORDER_REQUEST (id),
    FOREIGN KEY (tag_id) REFERENCES TAG (id)
);

