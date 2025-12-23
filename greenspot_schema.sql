
-- Greenspot Grocer database schema
CREATE DATABASE IF NOT EXISTS greenspot CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE greenspot;

-- Lookup: categories
CREATE TABLE categories (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Lookup: storage locations (aisle/bin codes)
CREATE TABLE storage_locations (
    location_id   INT PRIMARY KEY AUTO_INCREMENT,
    location_code VARCHAR(20) NOT NULL UNIQUE
);

-- Suppliers
CREATE TABLE suppliers (
    supplier_id   INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(255) NOT NULL UNIQUE
);

-- Customers (IDs only from dataset)
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    external_ref  VARCHAR(50) NOT NULL UNIQUE
);

-- Products
CREATE TABLE products (
    product_id       INT PRIMARY KEY AUTO_INCREMENT,
    sku              VARCHAR(50) NOT NULL UNIQUE,
    product_name     VARCHAR(255) NOT NULL,
    category_id      INT NOT NULL,
    unit_of_measure  VARCHAR(100) NOT NULL,
    price            DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    default_location_id INT NULL,
    CONSTRAINT fk_prod_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id) ON DELETE RESTRICT,
    CONSTRAINT fk_prod_location FOREIGN KEY (default_location_id)
        REFERENCES storage_locations(location_id) ON DELETE SET NULL
);

-- Unified stock transactions (purchases & sales)
CREATE TABLE stock_transactions (
    transaction_id   BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id       INT NOT NULL,
    event_type       ENUM('purchase','sale') NOT NULL,
    event_date       DATE NULL,
    location_id      INT NULL,
    vendor_id        INT NULL,
    customer_id      INT NULL,
    qty_change       DECIMAL(12,3) NULL, -- negative for sales; unknown for purchases in this dataset
    unit_cost        DECIMAL(10,2) NULL,
    unit_price       DECIMAL(10,2) NULL,
    on_hand_after    DECIMAL(12,3) NULL,
    CONSTRAINT fk_trx_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT fk_trx_location FOREIGN KEY (location_id)
        REFERENCES storage_locations(location_id) ON DELETE SET NULL,
    CONSTRAINT fk_trx_vendor FOREIGN KEY (vendor_id)
        REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    CONSTRAINT fk_trx_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE SET NULL
);

-- Helpful indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_trx_product_date ON stock_transactions(product_id, event_date);
CREATE INDEX idx_trx_type ON stock_transactions(event_type);
