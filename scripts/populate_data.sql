-- Insert sample users
INSERT INTO "USER" (username, password, email, is_admin) VALUES
('john_doe', 'hashed_password_1', 'john@example.com', false),
('jane_smith', 'hashed_password_2', 'jane@example.com', false),
('admin_user', 'admin_password_hashed', 'admin@example.com', true);

-- Insert sample products
INSERT INTO PRODUCT (owner_id, product_name, price, tags, condition, product_image, total_quantity, current_quantity, category, description) VALUES
(1, 'Vintage Guitar', 599.99, ARRAY['music', 'instrument'], 'Used', 'guitar.jpg', 1, 1, 'Musical Instruments', 'A beautiful vintage guitar from the 1970s'),
(1, 'Programming Book', 49.99, ARRAY['book', 'programming', 'computer science'], 'New', 'prog_book.jpg', 50, 48, 'Books', 'Comprehensive guide to modern programming'),
(2, 'Smartphone', 399.99, ARRAY['electronics', 'mobile'], 'Refurbished', 'smartphone.jpg', 10, 9, 'Electronics', 'Latest model smartphone, factory refurbished'),
(2, 'Hiking Boots', 129.99, ARRAY['outdoor', 'shoes'], 'New', 'hiking_boots.jpg', 20, 18, 'Outdoor Gear', 'Durable hiking boots for all terrains');

-- Insert sample orders
INSERT INTO "ORDER" (buyer_id, seller_id, status) VALUES
(2, 1, 'Completed'),
(1, 2, 'Processing');

-- Insert sample product orders
INSERT INTO PRODUCT_ORDER (product_id, order_id, order_quantity) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1),
(4, 2, 2);

-- Update current quantities for products
UPDATE PRODUCT SET current_quantity = total_quantity - 1 WHERE id = 1;
UPDATE PRODUCT SET current_quantity = total_quantity - 2 WHERE id = 2;
UPDATE PRODUCT SET current_quantity = total_quantity - 1 WHERE id = 3;
UPDATE PRODUCT SET current_quantity = total_quantity - 2 WHERE id = 4;
