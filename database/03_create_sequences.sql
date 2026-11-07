-- ====================================================================
-- Script: 03_create_sequences.sql
-- Description: Creates sequences for Oracle XE 10g primary keys
-- Target: Oracle Database XE 10g (and compatible)
-- Execute as: shoppingcart user
-- ====================================================================

PROMPT [3/5] Creating sequences for primary keys...

-- Drop existing sequences if present
BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name IN 
        ('SEQ_USERS', 'SEQ_CATEGORIES', 'SEQ_PRODUCTS', 'SEQ_CART_ITEMS', 'SEQ_ORDERS', 'SEQ_ORDER_ITEMS')) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

CREATE SEQUENCE SEQ_USERS
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_CATEGORIES
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_PRODUCTS
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_CART_ITEMS
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_ORDERS
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_ORDER_ITEMS
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

PROMPT Sequences created successfully.
