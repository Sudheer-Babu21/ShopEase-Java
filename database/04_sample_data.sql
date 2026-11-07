-- ====================================================================
-- Script: 04_sample_data.sql
-- Description: Inserts realistic seed data for categories, products,
--              initial users, and demonstration orders.
-- Target: Oracle Database XE 10g (and compatible)
-- Execute as: shoppingcart user
-- ====================================================================

SET DEFINE OFF;
SET FEEDBACK ON;

PROMPT [4/5] Inserting sample data...

-- Clear existing data in correct FK order
DELETE FROM ORDER_ITEMS;
DELETE FROM ORDERS;
DELETE FROM CART_ITEMS;
DELETE FROM PRODUCTS;
DELETE FROM CATEGORIES;
DELETE FROM USERS;
COMMIT;

-- --------------------------------------------------------------------
-- 1. SEED USERS (BCrypt hashed passwords)
-- Default customer password: Customer@123 ($2a$10$eXpFBHwxv/2Tt5KAEG0/U.Ve12UZ5VgB0bKSH9xcHGkE6q922UFri)
-- Default admin password:    Admin@123    ($2a$10$eXpFBHwxv/2Tt5KAEG0/U.jtLloxDSBcRMgpKi.w3///8XjLLHtwG)
-- --------------------------------------------------------------------
INSERT INTO USERS (USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT)
VALUES (SEQ_USERS.NEXTVAL, 'System Administrator', 'admin@shoppingcart.com', 
        '$2a$10$eXpFBHwxv/2Tt5KAEG0/U.jtLloxDSBcRMgpKi.w3///8XjLLHtwG', 
        '9876543210', 'ADMIN', CURRENT_TIMESTAMP);

INSERT INTO USERS (USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT)
VALUES (SEQ_USERS.NEXTVAL, 'John Customer', 'john@example.com', 
        '$2a$10$eXpFBHwxv/2Tt5KAEG0/U.Ve12UZ5VgB0bKSH9xcHGkE6q922UFri', 
        '9876543211', 'CUSTOMER', CURRENT_TIMESTAMP);

INSERT INTO USERS (USER_ID, NAME, EMAIL, PASSWORD_HASH, PHONE, ROLE, CREATED_AT)
VALUES (SEQ_USERS.NEXTVAL, 'Jane Smith', 'jane@example.com', 
        '$2a$10$eXpFBHwxv/2Tt5KAEG0/U.Ve12UZ5VgB0bKSH9xcHGkE6q922UFri', 
        '9876543212', 'CUSTOMER', CURRENT_TIMESTAMP);

-- --------------------------------------------------------------------
-- 2. SEED CATEGORIES
-- --------------------------------------------------------------------
INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION)
VALUES (SEQ_CATEGORIES.NEXTVAL, 'Electronics', 'Laptops, headphones, smartphones, smartwatches and accessories');

INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION)
VALUES (SEQ_CATEGORIES.NEXTVAL, 'Fashion & Apparel', 'Modern clothing, shoes, jackets and everyday fashion');

INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION)
VALUES (SEQ_CATEGORIES.NEXTVAL, 'Home & Kitchen', 'Ergonomic furniture, cookware, drinkware and home essentials');

INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION)
VALUES (SEQ_CATEGORIES.NEXTVAL, 'Books & Stationery', 'Technology books, notebooks, pens and office reading');

INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION)
VALUES (SEQ_CATEGORIES.NEXTVAL, 'Sports & Fitness', 'Fitness gear, yoga mats, running shoes and training gear');

-- --------------------------------------------------------------------
-- 3. SEED PRODUCTS
-- --------------------------------------------------------------------
-- Electronics (Category 1)
INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 1, 'Ultrabook Pro 14" Laptop', 
        'Intel Core i7, 16GB RAM, 512GB NVMe SSD, 14-inch 2.8K OLED display with all-day battery life.', 
        899.99, 15, 'assets/images/laptop.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 1, 'Wireless ANC Headphones', 
        'Active noise-cancelling over-ear headphones with 40-hour battery life and high-res audio.', 
        149.99, 30, 'assets/images/headphones.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 1, 'Smart Fitness Watch v2', 
        'Heart rate monitoring, SPO2 sensor, GPS tracking, 5ATM water resistance, 7-day battery.', 
        79.99, 25, 'assets/images/smartwatch.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 1, 'Mechanical Gaming Keyboard', 
        'Custom tactile mechanical switches, RGB backlighting, aircraft-grade aluminum top frame.', 
        99.00, 20, 'assets/images/keyboard.jpg', 1);

-- Fashion & Apparel (Category 2)
INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 2, 'Organic Cotton Crewneck T-Shirt', 
        '100% certified organic ring-spun cotton, ultra-soft hand feel, pre-shrunk breathable fabric.', 
        24.99, 50, 'assets/images/tshirt.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 2, 'Classic Washed Denim Jacket', 
        'Timeless relaxed-fit denim jacket with button flap chest pockets and adjustable waist tabs.', 
        69.99, 18, 'assets/images/jacket.jpg', 1);

-- Home & Kitchen (Category 3)
INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 3, 'Ergonomic Mesh Office Chair', 
        'Adjustable lumbar support, 3D armrests, breathable high-density mesh, pneumatic seat height.', 
        189.50, 10, 'assets/images/chair.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 3, 'Vacuum Insulated Thermal Tumbler 24oz', 
        'Double-wall stainless steel insulation keeps drinks cold 24 hrs or hot 12 hrs. Leak-proof lid.', 
        24.99, 45, 'assets/images/tumbler.jpg', 1);

-- Books & Stationery (Category 4)
INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 4, 'The Pragmatic Programmer 20th Anniversary', 
        'Your journey to mastery. Classic software engineering handbook for modern developers.', 
        49.99, 40, 'assets/images/book.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 4, 'Hardcover Dotted Grid Journal', 
        '160 gsm bleed-resistant acid-free bamboo paper, pen loop, ribbon markers, expandable inner pocket.', 
        18.50, 35, 'assets/images/journal.jpg', 1);

-- Sports & Fitness (Category 5)
INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 5, 'Pro Cushion Running Shoes', 
        'Breathable knit upper, responsive high-rebound cushioning foam, durable rubber traction outsole.', 
        89.00, 22, 'assets/images/shoes.jpg', 1);

INSERT INTO PRODUCTS (PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE)
VALUES (SEQ_PRODUCTS.NEXTVAL, 5, 'Eco-Friendly Non-Slip Yoga Mat', 
        '6mm high-density TPE dual-layer grip texture with alignment line guidelines and carry strap.', 
        34.50, 30, 'assets/images/yogamat.jpg', 1);

-- --------------------------------------------------------------------
-- 4. SEED SAMPLE ORDERS (For John Customer, USER_ID = 2)
-- --------------------------------------------------------------------
-- Order 1: Delivered
INSERT INTO ORDERS (ORDER_ID, USER_ID, ORDER_DATE, TOTAL_AMOUNT, STATUS, SHIPPING_ADDRESS, PAYMENT_METHOD)
VALUES (SEQ_ORDERS.NEXTVAL, 2, CURRENT_TIMESTAMP - 5, 174.98, 'DELIVERED', 
        '123 Market St, Suite 400, San Francisco, CA 94105', 'COD');

INSERT INTO ORDER_ITEMS (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, QUANTITY, UNIT_PRICE)
VALUES (SEQ_ORDER_ITEMS.NEXTVAL, 1, 2, 1, 149.99);

INSERT INTO ORDER_ITEMS (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, QUANTITY, UNIT_PRICE)
VALUES (SEQ_ORDER_ITEMS.NEXTVAL, 1, 5, 1, 24.99);

-- Order 2: Placed
INSERT INTO ORDERS (ORDER_ID, USER_ID, ORDER_DATE, TOTAL_AMOUNT, STATUS, SHIPPING_ADDRESS, PAYMENT_METHOD)
VALUES (SEQ_ORDERS.NEXTVAL, 2, CURRENT_TIMESTAMP - 1, 899.99, 'PLACED', 
        '123 Market St, Suite 400, San Francisco, CA 94105', 'MOCK');

INSERT INTO ORDER_ITEMS (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, QUANTITY, UNIT_PRICE)
VALUES (SEQ_ORDER_ITEMS.NEXTVAL, 2, 1, 1, 899.99);

COMMIT;

PROMPT Sample data inserted successfully.
