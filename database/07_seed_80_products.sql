-- ====================================================================
-- Script: 07_seed_80_products.sql
-- Description: Idempotent expansion of product catalog to 88+ products
--              across all 10 standard categories with genuine studio photographs.
-- Target: Oracle Database XE 10g (and compatible)
-- Execute as: shoppingcart user
-- ====================================================================

SET SERVEROUTPUT ON;
SET DEFINE OFF;
SET FEEDBACK ON;

PROMPT [7/7] Seeding comprehensive product catalog across 10 categories...

DECLARE
    v_cat_count       NUMBER := 0;
    v_inserted_count  NUMBER := 0;
    v_updated_count   NUMBER := 0;
    v_val             NUMBER := 0;

    PROCEDURE upsert_category(
        p_id   IN NUMBER,
        p_name IN VARCHAR2,
        p_desc IN VARCHAR2
    ) IS
        v_exists NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO v_exists FROM CATEGORIES WHERE CATEGORY_ID = p_id;
        IF v_exists > 0 THEN
            UPDATE CATEGORIES 
            SET NAME = TRIM(p_name), DESCRIPTION = TRIM(p_desc)
            WHERE CATEGORY_ID = p_id;
        ELSE
            SELECT COUNT(*) INTO v_exists FROM CATEGORIES WHERE LOWER(TRIM(NAME)) = LOWER(TRIM(p_name));
            IF v_exists = 0 THEN
                INSERT INTO CATEGORIES (CATEGORY_ID, NAME, DESCRIPTION)
                VALUES (p_id, TRIM(p_name), TRIM(p_desc));
                v_cat_count := v_cat_count + 1;
            END IF;
        END IF;
    END;

    PROCEDURE upsert_product(
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

        IF v_exists > 0 THEN
            UPDATE PRODUCTS
            SET CATEGORY_ID = p_category_id,
                DESCRIPTION = TRIM(p_desc),
                PRICE       = p_price,
                STOCK_QTY   = p_stock,
                IMAGE_PATH  = TRIM(p_image_path),
                IS_ACTIVE   = p_is_active
            WHERE LOWER(TRIM(NAME)) = LOWER(TRIM(p_name));
            v_updated_count := v_updated_count + 1;
        ELSE
            INSERT INTO PRODUCTS (
                PRODUCT_ID, CATEGORY_ID, NAME, DESCRIPTION, PRICE, STOCK_QTY, IMAGE_PATH, IS_ACTIVE
            ) VALUES (
                SEQ_PRODUCTS.NEXTVAL, p_category_id, TRIM(p_name), TRIM(p_desc), p_price, p_stock, TRIM(p_image_path), p_is_active
            );
            v_inserted_count := v_inserted_count + 1;
        END IF;
    END;

BEGIN
    -- 1. Ensure all 10 Categories are configured
    upsert_category(1, 'Electronics and mobile accessories', 'Smartphones, audio gear, charging accessories, and computer peripherals.');
    upsert_category(2, 'Fashion and clothing', 'Men and women apparel, jackets, ethnic wear, and daily casuals.');
    upsert_category(3, 'Shoes and footwear', 'Running shoes, casual sneakers, formal oxfords, and hiking boots.');
    upsert_category(4, 'Home and kitchen', 'Home decor, cookware, bedsheets, storage solutions, and appliances.');
    upsert_category(5, 'Beauty and personal care', 'Skincare essentials, serums, sunscreens, and personal grooming appliances.');
    upsert_category(6, 'Books and education', 'Engineering textbooks, programming manuals, and bestselling self-help guides.');
    upsert_category(7, 'Sports and fitness', 'Gym equipment, yoga mats, resistance bands, and athletic accessories.');
    upsert_category(8, 'Bags, watches and accessories', 'Backpacks, travel kits, leather wallets, sunglasses, and wristwatches.');
    upsert_category(9, 'Toys and games', 'Board games, puzzles, building blocks, and collectibles for all ages.');
    upsert_category(10, 'Office supplies and stationery', 'Desk mats, notebooks, gel pens, organizers, and productivity accessories.');

    -- Synchronize SEQ_CATEGORIES sequence past max category id
    LOOP
        SELECT SEQ_CATEGORIES.NEXTVAL INTO v_val FROM DUAL;
        EXIT WHEN v_val >= 10;
    END LOOP;

    -- 2. Upsert Products
    upsert_product(1, 'Wireless Bluetooth Headphones', 'Over-ear active noise cancelling headphones with 40mm neodymium drivers and 30-hour battery life.', 1499.00, 35, 'assets/products/wireless-headphones.jpg', 1);
    upsert_product(1, 'Bluetooth Earbuds', 'True wireless stereo earbuds with low-latency gaming mode, touch controls, and IPX5 water resistance.', 999.00, 40, 'assets/products/wireless-earbuds.jpg', 1);
    upsert_product(1, 'Smartwatch', '1.78-inch AMOLED touchscreen smartwatch with 24/7 heart rate monitoring, SpO2 sensor, and sleep tracking.', 1999.00, 25, 'assets/products/smartwatch.jpg', 1);
    upsert_product(1, 'Wireless Mouse', 'Ergonomic 2.4GHz optical wireless mouse with silent click buttons and adjustable 1600 DPI.', 699.00, 45, 'assets/products/wireless-mouse.jpg', 1);
    upsert_product(1, 'Mechanical Gaming Keyboard', 'Tenkeyless RGB backlit mechanical gaming keyboard with responsive blue tactile switches and anti-ghosting.', 2499.00, 20, 'assets/products/gaming-keyboard.jpg', 1);
    upsert_product(1, 'Portable Bluetooth Speaker', '16W powerful stereo sound portable wireless speaker with deep bass radiator and 12-hour continuous playtime.', 1299.00, 30, 'assets/products/bluetooth-speaker.jpg', 1);
    upsert_product(1, 'Fast Charging Power Bank', '20,000mAh high-capacity lithium-polymer power bank with 22.5W Power Delivery and dual USB-A outputs.', 899.00, 50, 'assets/products/power-bank.jpg', 1);
    upsert_product(1, 'USB-C Fast Charger', '33W GaN compact wall adapter with dual Type-C and USB-A ports supporting PD 3.0 and QC 4.0.', 499.00, 60, 'assets/products/usb-c-charger.jpg', 1);
    upsert_product(1, 'Braided USB-C Cable', 'Tough nylon-braided 60W fast-charging Type-C to Type-C cable with reinforced strain relief collars (1.5m).', 299.00, 75, 'assets/products/braided-cable.jpg', 1);
    upsert_product(2, 'Organic Cotton Crewneck T-Shirt', '100% bio-washed combed organic cotton breathable crewneck tee in versatile charcoal grey.', 499.00, 50, 'assets/products/crew-neck-tshirt.jpg', 1);
    upsert_product(2, 'Slim-Fit Jeans', 'Stretchable dark-indigo denim jeans featuring a modern tapered fit and reinforced five-pocket styling.', 1299.00, 30, 'assets/products/slim-fit-jeans.jpg', 1);
    upsert_product(2, 'Casual Shirt', 'Premium breathable linen-blend casual shirt with button-down collar and curved hem for smart-casual wear.', 899.00, 40, 'assets/products/casual-cotton-shirt.jpg', 1);
    upsert_product(2, 'Zip-Up Hoodie Jacket', 'Fleece-lined heavyweight cotton blend zipper hoodie with adjustable drawstring hood and kangaroo pockets.', 1499.00, 25, 'assets/products/zip-up-hoodie.jpg', 1);
    upsert_product(2, 'Women''s Kurti', 'A-line straight cotton ethnic kurti with intricate floral embroidery and side slits for festive elegance.', 799.00, 35, 'assets/products/embroidered-kurti.jpg', 1);
    upsert_product(2, 'Women''s Casual Top', 'Lightweight chiffon floral flutter-sleeve summer blouse with keyhole neckline and relaxed silhouette.', 699.00, 32, 'assets/products/summer-dress.jpg', 1);
    upsert_product(2, 'Classic Washed Denim Jacket', 'Vintage washed rugged denim trucker jacket with brass hardware and adjustable waist tabs.', 1899.00, 20, 'assets/products/denim-jacket.jpg', 1);
    upsert_product(2, 'Winter Woolen Scarf', 'Ultra-soft cashmere-touch woven woolen muffler with fringed edges for cozy winter warmth.', 399.00, 40, 'assets/products/woolen-scarf.jpg', 1);
    upsert_product(2, 'Puffer Winter Jacket', 'Quilted water-resistant thermal puffer jacket with stand collar and synthetic down insulation.', 2499.00, 15, 'assets/products/puffer-jacket.jpg', 1);
    upsert_product(3, 'Pro Cushion Running Shoes', 'Engineered breathable mesh road running shoes with responsive EVA foam midsole and anti-skid rubber grip.', 1799.00, 30, 'assets/products/running-shoes.jpg', 1);
    upsert_product(3, 'Casual Sneakers', 'Low-top white canvas lifestyle sneakers with cushioned insole and vulcanized rubber outsole.', 1199.00, 40, 'assets/products/canvas-sneakers.jpg', 1);
    upsert_product(3, 'Formal Oxford Leather Shoes', 'Handcrafted genuine leather closed-lace Oxford dress shoes with burnished toe and soft leather lining.', 2299.00, 20, 'assets/products/oxford-leather-shoes.jpg', 1);
    upsert_product(3, 'Casual Loafers Slip-On', 'Flexible suede moccasin penny loafers with memory foam padding for effortless all-day comfort.', 1499.00, 25, 'assets/products/casual-loafers.jpg', 1);
    upsert_product(3, 'Trail Hiking Boots', 'Ankle-support waterproof nubuck hiking boots with rugged lugged traction sole for outdoor terrain.', 2799.00, 18, 'assets/products/hiking-boots.jpg', 1);
    upsert_product(3, 'Lightweight Sports Sliders', 'Ergonomic contoured footbed slip-on slides with textured grip strap for post-workout relaxation.', 499.00, 50, 'assets/products/sports-sliders.jpg', 1);
    upsert_product(3, 'Sports Shoes', 'Multi-sport cross-training shoes with lateral stability support and shock-absorbing heel cushioning.', 1399.00, 35, 'assets/products/mesh-walking-shoes.jpg', 1);
    upsert_product(3, 'High-Top Basketball Sneakers', 'Performance high-top basketball shoes with padded collar, air-cushioned unit, and pivot point traction.', 2999.00, 15, 'assets/products/basketball-sneakers.jpg', 1);
    upsert_product(4, 'Stainless Steel Water Bottle', 'BPA-free vacuum insulated stainless steel flask keeping beverages cold for 24 hours or hot for 12 hours.', 399.00, 50, 'assets/products/steel-water-bottle.jpg', 1);
    upsert_product(4, 'Insulated Travel Mug', 'Spill-proof double-wall thermal coffee tumbler with 360-degree drinkable lid and sweat-free powder finish.', 499.00, 45, 'assets/products/travel-mug.jpg', 1);
    upsert_product(4, 'Table Lamp', 'Nordic minimalist bedside desk lamp with natural wood base, linen fabric shade, and warm LED bulb.', 799.00, 22, 'assets/products/minimalist-table-lamp.jpg', 1);
    upsert_product(4, 'Bedsheet Set', '100% pure Egyptian cotton 300 thread count double king bedsheet with 2 matching envelope pillow covers.', 999.00, 30, 'assets/products/bedsheet-set.jpg', 1);
    upsert_product(4, 'Storage Organizer', 'Foldable linen-textured multi-compartment closet storage box with clear label window and reinforced handles.', 599.00, 40, 'assets/products/storage-organizer.jpg', 1);
    upsert_product(4, 'Non-Stick Cookware Set', '3-piece granite-coated non-stick cookware set including fry pan, kadai with glass lid, and tawa.', 1499.00, 18, 'assets/products/non-stick-cookware.jpg', 1);
    upsert_product(4, 'Electric Kettle', '1.5-liter rapid boil cordless stainless steel electric kettle with automatic shut-off and boil-dry protection.', 999.00, 25, 'assets/products/electric-kettle.jpg', 1);
    upsert_product(4, 'Aromatherapy Oil Diffuser', 'Ultrasonic cool mist essential oil humidifier with 7 color ambient LED lights and whisper-quiet operation.', 899.00, 28, 'assets/products/oil-diffuser.jpg', 1);
    upsert_product(4, 'Ceramic Coffee Mug Set', 'Set of 4 handcrafted matte ceramic mugs with heat-resistant handles for specialty coffee and tea (350ml).', 599.00, 35, 'assets/products/ceramic-mugs.jpg', 1);
    upsert_product(5, 'Hydrating Facial Cleanser', 'Gentle foaming face wash with hyaluronic acid, ceramides, and aloe vera for deep pore cleansing.', 349.00, 45, 'assets/products/facial-cleanser.jpg', 1);
    upsert_product(5, 'Vitamin C Brightening Serum', '20% active Vitamin C facial serum enriched with Ferulic acid and Vitamin E for glowing skin complexion.', 599.00, 40, 'assets/products/vitamin-c-serum.jpg', 1);
    upsert_product(5, 'SPF 50 Matte Sunscreen Gel', 'Broad spectrum UVA/UVB PA++++ matte finish sunscreen gel leaving no white cast, water and sweat resistant.', 449.00, 50, 'assets/products/matte-sunscreen.jpg', 1);
    upsert_product(5, 'Herbal Nourishing Shampoo', 'Sulfate and paraben-free onion and bhringraj restorative shampoo preventing hair fall and boosting strength.', 399.00, 40, 'assets/products/herbal-shampoo.jpg', 1);
    upsert_product(5, 'Organic Argan Hair Oil', 'Cold-pressed Moroccan argan oil elixir infused with almond oil for frizz control, shine, and scalp health.', 499.00, 35, 'assets/products/argan-hair-oil.jpg', 1);
    upsert_product(5, 'Shea Butter Body Moisturizer', 'Deep nourishing cocoa and shea butter body lotion providing 48-hour intense hydration for dry skin.', 379.00, 40, 'assets/products/body-moisturizer.jpg', 1);
    upsert_product(5, 'Beard Grooming Kit & Oil', 'Complete men''s beard grooming pack including cedarwood beard oil, organic balm, and pearwood comb.', 699.00, 25, 'assets/products/beard-grooming-kit.jpg', 1);
    upsert_product(5, 'Sonic Electric Toothbrush', 'Rechargeable ultrasonic electric toothbrush with 40,000 vibrations/min, smart 2-minute timer, and 3 heads.', 1299.00, 30, 'assets/products/electric-toothbrush.jpg', 1);
    upsert_product(6, 'Java Programming Guide', 'Comprehensive modern Java developer reference covering Java 21 LTS features, concurrency, and OOP patterns.', 599.00, 40, 'assets/products/java-programming-book.jpg', 1);
    upsert_product(6, 'Data Structures and Algorithms', 'In-depth algorithmic analysis textbook covering asymptotic complexity, trees, graphs, and dynamic programming.', 699.00, 35, 'assets/products/dsa-textbook.jpg', 1);
    upsert_product(6, 'Database Management Systems', 'Standard collegiate reference on relational database systems, ACID transactions, SQL, and indexing theory.', 549.00, 30, 'assets/products/dbms-textbook.jpg', 1);
    upsert_product(6, 'Operating Systems Textbook', 'Foundational guide to CPU scheduling, virtual memory, concurrency deadlocks, and Linux kernel internals.', 649.00, 28, 'assets/products/os-textbook.jpg', 1);
    upsert_product(6, 'Computer Networks Guide', 'Top-down approach to Internet protocols, TCP/IP socket programming, routing algorithms, and network security.', 599.00, 32, 'assets/products/cn-guide-book.jpg', 1);
    upsert_product(6, 'Software Engineering Textbook', 'Modern software engineering methodologies including Agile Scrum, CI/CD pipelines, DevOps, and clean design.', 499.00, 35, 'assets/products/se-textbook.jpg', 1);
    upsert_product(6, 'Atomic Habits Productivity Book', 'International bestselling guide on tiny behavioral changes, compound habit formation, and everyday focus.', 450.00, 60, 'assets/products/atomic-habits-book.jpg', 1);
    upsert_product(6, 'Clean Code Handbook', 'Agile software craftsmanship handbook on writing readable, testable, and maintainable enterprise code.', 799.00, 25, 'assets/products/clean-code-book.jpg', 1);
    upsert_product(7, 'Eco-Friendly Non-Slip Yoga Mat', '6mm high-density TPE dual-sided textured exercise mat with body alignment lines and carry strap.', 699.00, 30, 'assets/products/eco-yoga-mat.jpg', 1);
    upsert_product(7, 'Adjustable Dumbbell Set', '20kg home gym dumbbell weight set with solid chrome connector bar, rubber coated plates, and star locks.', 1999.00, 15, 'assets/products/dumbbell-set.jpg', 1);
    upsert_product(7, 'Fitness Resistance Bands', 'Set of 5 natural latex loop exercise bands with progressive resistance levels from 5 lbs to 40 lbs.', 399.00, 50, 'assets/products/resistance-bands.jpg', 1);
    upsert_product(7, 'High-Speed Skipping Rope', 'Tangle-free steel wire speed jump rope with 360-degree ball bearing rotation and aluminum grip handles.', 249.00, 60, 'assets/products/skipping-rope.jpg', 1);
    upsert_product(7, 'Stainless Steel Protein Shaker', '750ml insulated metal shaker bottle with wire whisk blending ball, measurement markings, and leakproof flip cap.', 449.00, 45, 'assets/products/protein-shaker.jpg', 1);
    upsert_product(7, 'Deep Tissue Foam Roller', 'High-density trigger point muscle roller for physical therapy, myofascial release, and athletic recovery.', 599.00, 30, 'assets/products/foam-roller.jpg', 1);
    upsert_product(7, 'Gym Weightlifting Gloves', 'Breathable workout gloves with silicone palm grip padding, integrated wrist wraps, and pull tabs.', 349.00, 40, 'assets/products/gym-gloves.jpg', 1);
    upsert_product(7, 'Standard Size 5 Football', 'FIFA quality synthetic leather soccer ball with butyl bladder for optimal air retention and outdoor play.', 799.00, 25, 'assets/products/soccer-football.jpg', 1);
    upsert_product(8, 'Analog Wristwatch', 'Sleek quartz analog wristwatch with stainless steel mesh band, scratch-resistant mineral glass, and date display.', 1299.00, 25, 'assets/products/analog-wristwatch.jpg', 1);
    upsert_product(8, 'Wallet', 'Handcrafted top-grain genuine leather bifold wallet featuring RFID blocking shield and dual cash slots.', 499.00, 45, 'assets/products/leather-wallet.jpg', 1);
    upsert_product(8, 'Sunglasses', 'Classic unisex polarized sunglasses with 100% UV400 protection coating and durable matte polycarbonate frame.', 799.00, 35, 'assets/products/polarized-sunglasses.jpg', 1);
    upsert_product(8, 'Laptop Backpack', 'Water-resistant 30L commuter backpack with padded 15.6" laptop compartment and USB external charging port.', 1299.00, 30, 'assets/products/laptop-backpack.jpg', 1);
    upsert_product(8, 'Everyday Backpack', 'Vintage washed canvas multi-pocket daypack with drawstring closure and magnetic flap for college and day trips.', 899.00, 35, 'assets/products/canvas-backpack.jpg', 1);
    upsert_product(8, 'Travel Toiletry Bag', 'Hanging waterproof travel wash bag with clear inner compartments, metal swivel hook, and leakproof zippers.', 449.00, 40, 'assets/products/toiletry-bag.jpg', 1);
    upsert_product(8, 'Leather Reversible Dress Belt', 'Genuine leather reversible belt with rotating zinc alloy buckle switching easily between black and brown.', 549.00, 40, 'assets/products/leather-belt.jpg', 1);
    upsert_product(8, 'Gym Duffle Bag', 'Lightweight cylindrical gym duffel with separate ventilated shoe compartment and water-resistant lining.', 999.00, 25, 'assets/products/gym-duffle-bag.jpg', 1);
    upsert_product(9, 'Strategy Board Game Catan', 'Classic cooperative settlement strategy board game for 3-4 players with modular hexagonal board tiles.', 1899.00, 20, 'assets/products/board-game.jpg', 1);
    upsert_product(9, 'Speed Rubik Cube 3x3', 'Magnetic stickerless speed cube with anti-pop mechanism and smooth corner-cutting tension adjustment.', 299.00, 55, 'assets/products/speed-rubik-cube.jpg', 1);
    upsert_product(9, 'Creative Building Blocks Set', '500-piece colorful architectural brick construction playset inspiring spatial imagination for ages 6+.', 1199.00, 30, 'assets/products/building-blocks.jpg', 1);
    upsert_product(9, 'Remote Control Monster Truck', '1:16 scale all-terrain off-road RC rock crawler with independent suspension shocks and 2.4GHz remote.', 1499.00, 22, 'assets/products/rc-monster-truck.jpg', 1);
    upsert_product(9, 'Wooden Chess Set with Storage', 'Handcrafted folding wooden chess board with magnetic Staunton chessmen pieces and felted interior slots.', 999.00, 25, 'assets/products/wooden-chess-set.jpg', 1);
    upsert_product(9, '1000-Piece Landscape Jigsaw Puzzle', 'Precision die-cut high-definition scenic landscape puzzle printed on non-glare recycled blue puzzle board.', 649.00, 30, 'assets/products/jigsaw-puzzle.jpg', 1);
    upsert_product(9, 'Stuffed Plush Teddy Bear', '14-inch super soft huggable plush teddy bear made with hypoallergenic materials and embroidered paws.', 499.00, 40, 'assets/products/plush-teddy-bear.jpg', 1);
    upsert_product(9, 'Die-Cast Racing Car Set', 'Pack of 5 authentic 1:64 scale die-cast metal speedway sports cars with realistic aerodynamic details.', 599.00, 35, 'assets/products/diecast-cars.jpg', 1);
    upsert_product(10, 'Hardcover Dotted Grid Journal', 'Premium 160 GSM bleed-proof bamboo paper notebook with numbered pages, inner pocket, and ribbon marker.', 349.00, 50, 'assets/products/dotted-journal.jpg', 1);
    upsert_product(10, 'Desk Organizer', 'Black steel wire mesh multi-compartment desktop organizer with pull-out drawer for stationery and pens.', 349.00, 50, 'assets/products/mesh-desk-organizer.jpg', 1);
    upsert_product(10, 'Executive Metal Gel Pen Set', 'Set of 3 weighted matte black metal body rollerball pens with 0.5mm smooth quick-dry Japanese archival ink.', 299.00, 60, 'assets/products/gel-pen-set.jpg', 1);
    upsert_product(10, 'Dual-Sided PU Leather Desk Mat', 'Large 80x40cm waterproof desk blotter protector pad for keyboard and mouse with non-slip suede base.', 599.00, 40, 'assets/products/leather-desk-mat.jpg', 1);
    upsert_product(10, 'Ergonomic Laptop Stand', 'Foldable aluminum alloy ventilated laptop elevator riser supporting up to 17-inch devices with silicone pads.', 899.00, 35, 'assets/products/laptop-stand.jpg', 1);
    upsert_product(10, 'Pastel Color Sticky Notes Pack', '8 pads of aesthetic muted pastel repositionable self-adhesive reminder notes (100 sheets per pad).', 199.00, 70, 'assets/products/sticky-notes.jpg', 1);
    upsert_product(10, 'Heavy Duty Desktop Stapler', 'All-metal ergonomic desktop stapler with 25-sheet capacity, low staple indicator, and 1000 standard staples.', 249.00, 45, 'assets/products/desktop-stapler.jpg', 1);
    upsert_product(10, 'Dry Erase Magnetic Whiteboard', 'Compact 40x30cm aluminum framed desktop whiteboard with magnetic dry-erase marker and pen tray.', 749.00, 25, 'assets/products/magnetic-whiteboard.jpg', 1);
    upsert_product(10, 'Aesthetic Pastel Highlighters', 'Set of 6 soft water-based chisel tip chisel highlighters for journaling and Bible study with zero bleed.', 229.00, 55, 'assets/products/pastel-highlighters.jpg', 1);
    upsert_product(10, 'A4 Expanding Document Folder', '13-pocket durable polypropylene expanding accordion file organizer with customizable colored index tabs.', 299.00, 50, 'assets/products/document-folder.jpg', 1);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Product catalog seed execution finished.');
    DBMS_OUTPUT.PUT_LINE('New categories added:  ' || v_cat_count);
    DBMS_OUTPUT.PUT_LINE('New products inserted: ' || v_inserted_count);
    DBMS_OUTPUT.PUT_LINE('Products updated:      ' || v_updated_count);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');
END;
/

PROMPT Verification summary:
SELECT c.CATEGORY_ID, c.NAME, COUNT(p.PRODUCT_ID) AS PRODUCT_COUNT
FROM CATEGORIES c
LEFT JOIN PRODUCTS p ON c.CATEGORY_ID = p.CATEGORY_ID
GROUP BY c.CATEGORY_ID, c.NAME
ORDER BY c.CATEGORY_ID;

SELECT COUNT(*) AS TOTAL_ACTIVE_PRODUCTS FROM PRODUCTS WHERE IS_ACTIVE = 1;
