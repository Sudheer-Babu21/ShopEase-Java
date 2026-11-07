-- ====================================================================
-- Script: 06_seed_extended_catalog.sql
-- Description: Idempotent expansion of product catalog (38 products across 5 categories)
-- Target: Oracle Database XE 10g (and compatible)
-- Execute as: shoppingcart user
-- ====================================================================

SET SERVEROUTPUT ON;
SET DEFINE OFF;
SET FEEDBACK ON;

PROMPT [6/6] Seeding extended product catalog (safe, idempotent insert)...

DECLARE
    v_inserted_count NUMBER := 0;
    v_skipped_count  NUMBER := 0;

    PROCEDURE add_product(
        p_category_id IN NUMBER,
        p_name        IN VARCHAR2,
        p_desc        IN VARCHAR2,
        p_price       IN NUMBER,
        p_stock       IN NUMBER,
        p_image_path  IN VARCHAR2,
        p_is_active   IN NUMBER DEFAULT 1
    ) IS
        v_exists NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO v_exists 
        FROM PRODUCTS 
        WHERE LOWER(TRIM(NAME)) = LOWER(TRIM(p_name));

        IF v_exists = 0 THEN
            INSERT INTO PRODUCTS (
                PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE
            ) VALUES (
                SEQ_PRODUCTS.NEXTVAL, p_category_id, TRIM(p_name), p_desc, p_price, p_stock, p_image_path, p_is_active
            );
            v_inserted_count := v_inserted_count + 1;
        ELSE
            v_skipped_count := v_skipped_count + 1;
        END IF;
    END;

BEGIN
    -- ================================================================
    -- 1. ELECTRONICS (Category 1)
    -- ================================================================
    add_product(1, 'Wireless Bluetooth Headphones', 
        'High-fidelity over-ear Bluetooth headphones with deep bass, memory foam cushions, and 30-hour battery life.', 
        1499.00, 35, 'assets/images/headphones.jpg');

    add_product(1, 'Bluetooth Earbuds', 
        'True wireless stereo earbuds with touch controls, environmental noise cancellation, and compact USB-C case.', 
        999.00, 40, 'assets/images/earbuds.svg');

    add_product(1, 'Smartwatch', 
        '1.78" AMOLED display smartwatch with heart rate monitoring, SPO2 sensor, GPS activity tracking, and 7-day battery.', 
        1999.00, 25, 'assets/images/smartwatch.jpg');

    add_product(1, 'Wireless Mouse', 
        'Ergonomic 2.4GHz optical wireless mouse with silent clicks, adjustable DPI (800-1600), and USB nano receiver.', 
        499.00, 60, 'assets/images/mouse.svg');

    add_product(1, 'Mechanical Keyboard', 
        'RGB backlit mechanical keyboard with tactile blue switches, anti-ghosting keys, and aircraft-grade aluminum top plate.', 
        1799.00, 20, 'assets/images/keyboard.jpg');

    add_product(1, 'Portable Bluetooth Speaker', 
        'Rugged IPX7 waterproof portable speaker with 360-degree stereo sound, deep punchy bass, and 12-hour playtime.', 
        1299.00, 30, 'assets/images/speaker.svg');

    add_product(1, 'USB-C Fast Charger', 
        '65W GaN dual-port fast wall charger with Power Delivery 3.0 support for smartphones, tablets, and laptops.', 
        699.00, 50, 'assets/images/charger.svg');

    add_product(1, 'Laptop Backpack', 
        'Water-resistant business laptop backpack with padded compartment up to 15.6", anti-theft zipper, and USB charging port.', 
        1199.00, 28, 'assets/images/laptop_backpack.svg');

    -- ================================================================
    -- 2. FASHION & APPAREL (Category 2)
    -- ================================================================
    add_product(2, 'Men''s Cotton T-Shirt', 
        'Premium 100% combed cotton crew neck regular fit t-shirt, pre-shrunk and ultra-breathable for daily wear.', 
        499.00, 55, 'assets/images/tshirt.jpg');

    add_product(2, 'Casual Shirt', 
        'Breathable cotton-linen blend button-down casual shirt with modern spread collar and rounded cuffs.', 
        899.00, 35, 'assets/images/casual_shirt.svg');

    add_product(2, 'Slim-Fit Jeans', 
        'Comfort-stretch denim slim-fit jeans with classic 5-pocket styling and subtle whiskered wash.', 
        1299.00, 30, 'assets/images/jeans.svg');

    add_product(2, 'Women''s Kurti', 
        'Elegant floral printed straight cotton kurti with mandarin collar and three-quarter sleeves.', 
        799.00, 40, 'assets/images/kurti.svg');

    add_product(2, 'Women''s Casual Top', 
        'Contemporary ruffled tunic top crafted from lightweight viscose fabric with relaxed breathable fit.', 
        699.00, 35, 'assets/images/casual_top.svg');

    add_product(2, 'Sports Shoes', 
        'Lightweight running and training sports shoes with responsive EVA foam cushioning and breathable knit mesh.', 
        1799.00, 25, 'assets/images/shoes.jpg');

    add_product(2, 'Casual Sneakers', 
        'Low-top everyday lifestyle sneakers with vulcanized rubber traction outsole and cushioned insole.', 
        1499.00, 30, 'assets/images/sneakers.svg');

    add_product(2, 'Everyday Backpack', 
        'Lightweight compact daypack with dual water bottle holders, front organizer pocket, and padded shoulder straps.', 
        899.00, 35, 'assets/images/everyday_backpack.svg');

    -- ================================================================
    -- 3. HOME & KITCHEN (Category 3)
    -- ================================================================
    add_product(3, 'Stainless Steel Water Bottle', 
        'Food-grade 1000ml stainless steel single-wall leak-proof hydration bottle, rust-free and BPA-free.', 
        399.00, 50, 'assets/images/water_bottle.svg');

    add_product(3, 'Insulated Travel Mug', 
        'Double-wall vacuum insulated stainless steel coffee tumbler that keeps drinks hot for 8 hours or cold for 16 hours.', 
        499.00, 45, 'assets/images/tumbler.jpg');

    add_product(3, 'Table Lamp', 
        'Modern minimalist bedside desk lamp with solid wooden base, warm white LED illumination, and linen shade.', 
        799.00, 22, 'assets/images/table_lamp.svg');

    add_product(3, 'Bedsheet Set', 
        'Pure 100% cotton double bedsheet with two matching pillow covers, 250 thread count with fade-resistant dyes.', 
        999.00, 30, 'assets/images/bedsheet.svg');

    add_product(3, 'Storage Organizer', 
        'Multi-compartment foldable wardrobe fabric organizer with reinforced handles for clothes and accessories.', 
        599.00, 40, 'assets/images/storage_organizer.svg');

    add_product(3, 'Non-Stick Cookware Set', 
        '3-piece granite-finish non-stick cookware set including fry pan, kadai with glass lid, and tawa with induction base.', 
        1499.00, 18, 'assets/images/cookware.svg');

    add_product(3, 'Electric Kettle', 
        '1.8-litre rapid boil cordless stainless steel electric kettle with automatic shut-off and boil-dry protection.', 
        999.00, 25, 'assets/images/kettle.svg');

    add_product(3, 'Desk Organizer', 
        'Multi-compartment metal mesh desktop organizer with sliding drawer for pens, sticky notes, and office stationery.', 
        349.00, 50, 'assets/images/desk_organizer.svg');

    -- ================================================================
    -- 4. BOOKS & STATIONERY (Category 4)
    -- ================================================================
    add_product(4, 'Java Programming Guide', 
        'Comprehensive guide to modern Java 21, object-oriented principles, Servlets, JDBC, and enterprise design patterns.', 
        599.00, 40, 'assets/images/book.jpg');

    add_product(4, 'Data Structures and Algorithms', 
        'In-depth textbook on algorithmic complexity, trees, graphs, dynamic programming, and interview problem-solving.', 
        699.00, 35, 'assets/images/dsa_book.svg');

    add_product(4, 'Database Management Systems', 
        'Practical foundations of relational database design, SQL querying, indexing strategies, normalization, and ACID.', 
        549.00, 30, 'assets/images/dbms_book.svg');

    add_product(4, 'Operating Systems Textbook', 
        'Core concepts of modern operating systems: CPU scheduling, concurrency, virtual memory management, and file systems.', 
        649.00, 28, 'assets/images/os_book.svg');

    add_product(4, 'Computer Networks Guide', 
        'Clear exploration of network protocols, TCP/IP stack, socket programming, routing architectures, and internet security.', 
        599.00, 32, 'assets/images/cn_book.svg');

    add_product(4, 'Software Engineering Textbook', 
        'Best practices for Agile development, microservices, unit testing, continuous integration, and scalable software systems.', 
        499.00, 35, 'assets/images/se_book.svg');

    -- ================================================================
    -- 5. SPORTS & FITNESS (Category 5)
    -- ================================================================
    add_product(5, 'Analog Wristwatch', 
        'Classic stainless steel quartz analog wristwatch with genuine leather strap and 30m water resistance.', 
        1299.00, 25, 'assets/images/analog_watch.svg');

    add_product(5, 'Wallet', 
        'Slim bi-fold RFID-blocking genuine leather wallet with multiple card slots and currency compartment.', 
        499.00, 45, 'assets/images/wallet.svg');

    add_product(5, 'Sunglasses', 
        'Classic polarized UV400 protection unisex aviator sunglasses with lightweight durable metal alloy frame.', 
        799.00, 35, 'assets/images/sunglasses.svg');

    add_product(5, 'Yoga Mat', 
        '6mm high-density anti-skid eco-friendly TPE yoga and fitness workout mat with alignment guidelines and carry strap.', 
        699.00, 30, 'assets/images/yogamat.jpg');

    add_product(5, 'Adjustable Dumbbell Set', 
        'PVC-encased home workout adjustable dumbbell weight set with connector rod for barbell transformation.', 
        1999.00, 15, 'assets/images/dumbbell.svg');

    add_product(5, 'Fitness Resistance Bands', 
        'Set of 5 color-coded latex loop resistance bands with varying resistance levels for strength training and physical therapy.', 
        399.00, 50, 'assets/images/resistance_bands.svg');

    add_product(5, 'Travel Toiletry Bag', 
        'Water-resistant hanging cosmetic organizer travel bag with multiple zipper compartments and swivel hook.', 
        449.00, 40, 'assets/images/toiletry_bag.svg');

    add_product(5, 'Reusable Lunch Box', 
        '3-compartment leak-proof lunch box with food-grade stainless steel inner tray and insulated thermal bag.', 
        349.00, 45, 'assets/images/lunch_box.svg');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Extended product seeding complete.');
    DBMS_OUTPUT.PUT_LINE('Products newly inserted: ' || v_inserted_count);
    DBMS_OUTPUT.PUT_LINE('Products already existing (skipped): ' || v_skipped_count);
END;
/

PROMPT Verification: Total products in database:
SELECT COUNT(*) AS TOTAL_PRODUCTS FROM PRODUCTS;
SELECT c.NAME AS CATEGORY, COUNT(p.PRODUCT_ID) AS PRODUCT_COUNT
FROM CATEGORIES c
LEFT JOIN PRODUCTS p ON c.CATEGORY_ID = p.CATEGORY_ID
GROUP BY c.NAME
ORDER BY c.NAME;
