-- ====================================================================
-- Script: 01_create_user.sql
-- Description: Creates dedicated Oracle application user and grants privileges
-- Target: Oracle Database XE 10g (and compatible)
-- Execute as: SYS or SYSTEM with SYSDBA privilege
-- Example: sqlplus "sys/password@localhost:1521/XE as sysdba" @01_create_user.sql
-- ====================================================================

PROMPT [1/5] Creating application user for Online Shopping Cart...

-- Drop user if recreating (commented out by default for safety)
-- DROP USER shoppingcart CASCADE;

CREATE USER shoppingcart IDENTIFIED BY shoppingcart123
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;

GRANT CONNECT, RESOURCE, CREATE VIEW TO shoppingcart;

PROMPT User shoppingcart created and granted necessary privileges.
