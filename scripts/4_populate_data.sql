-- Insert sample users
INSERT INTO _USER (username, password, email, is_admin) VALUES
('john_doe', 'hashed_password_1', 'john@example.com', false),
('jane_smith', 'hashed_password_2', 'jane@example.com', false),
('admin_user', 'admin_password_hashed', 'admin@example.com', true);

-- Insert sample Categories
INSERT INTO CATEGORY (category_name) VALUES ('Musical Instruments');
INSERT INTO CATEGORY (category_name) VALUES ('Books');
INSERT INTO CATEGORY (category_name) VALUES ('Electronics');

-- Insert sample Tags
INSERT INTO TAG (tag_name) VALUES ('music');
INSERT INTO TAG (tag_name) VALUES ('instrument');
INSERT INTO TAG (tag_name) VALUES ('book');
INSERT INTO TAG (tag_name) VALUES ('programming');
INSERT INTO TAG (tag_name) VALUES ('computer science');
INSERT INTO TAG (tag_name) VALUES ('electronics');
INSERT INTO TAG (tag_name) VALUES ('mobile');

-- Insert sample products
INSERT INTO PRODUCT (owner_id, product_name, price, condition, product_image, total_quantity, current_quantity, category_id, description) VALUES
(1, 'Vintage Guitar', 599.99, 'Used', 'guitar.jpg', 1, 1, 1, 'A beautiful vintage guitar from the 1970s'),
(1, 'Programming Book', 49.99, 'New', 'prog_book.jpg', 50, 48, 2, 'Comprehensive guide to modern programming'),
(2, 'Smartphone', 399.99, 'Refurbished', 'smartphone.jpg', 10, 9, 3, 'Latest model smartphone, factory refurbished');


-- Insert relationships for 'Vintage Guitar'
INSERT INTO PRODUCT_TAG (product_id, tag_id)
VALUES 
((SELECT id FROM PRODUCT WHERE product_name = 'Vintage Guitar'), (SELECT id FROM TAG WHERE tag_name = 'music')),
((SELECT id FROM PRODUCT WHERE product_name = 'Vintage Guitar'), (SELECT id FROM TAG WHERE tag_name = 'instrument'));

-- Insert relationships for 'Programming Book'
INSERT INTO PRODUCT_TAG (product_id, tag_id)
VALUES 
((SELECT id FROM PRODUCT WHERE product_name = 'Programming Book'), (SELECT id FROM TAG WHERE tag_name = 'book')),
((SELECT id FROM PRODUCT WHERE product_name = 'Programming Book'), (SELECT id FROM TAG WHERE tag_name = 'programming')),
((SELECT id FROM PRODUCT WHERE product_name = 'Programming Book'), (SELECT id FROM TAG WHERE tag_name = 'computer science'));

-- Insert relationships for 'Smartphone'
INSERT INTO PRODUCT_TAG (product_id, tag_id)
VALUES 
((SELECT id FROM PRODUCT WHERE product_name = 'Smartphone'), (SELECT id FROM TAG WHERE tag_name = 'electronics')),
((SELECT id FROM PRODUCT WHERE product_name = 'Smartphone'), (SELECT id FROM TAG WHERE tag_name = 'mobile'));


-- Insert sample orders
INSERT INTO _ORDER (buyer_id, seller_id, status) VALUES
(2, 1, 'Completed'),
(1, 2, 'Processing');

-- Insert sample product orders
INSERT INTO PRODUCT_ORDER (product_id, order_id, order_quantity) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1);

-- Update current quantities for products
UPDATE PRODUCT SET current_quantity = total_quantity - 1 WHERE id = 1;
UPDATE PRODUCT SET current_quantity = total_quantity - 2 WHERE id = 2;
UPDATE PRODUCT SET current_quantity = total_quantity - 1 WHERE id = 3;