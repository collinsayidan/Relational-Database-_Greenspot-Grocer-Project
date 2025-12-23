
USE greenspot;

-- 1) Products with categories and default locations
SELECT p.product_id, p.sku, p.product_name, c.category_name, s.location_code AS default_location
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN storage_locations s ON s.location_id = p.default_location_id
ORDER BY c.category_name, p.product_name;

-- 2) Sales transactions joined to customers and products
SELECT t.transaction_id, t.event_date, p.sku, p.product_name, t.qty_change AS qty_sold, t.unit_price, cu.external_ref AS customer_ref
FROM stock_transactions t
JOIN products p ON p.product_id = t.product_id
LEFT JOIN customers cu ON cu.customer_id = t.customer_id
WHERE t.event_type = 'sale'
ORDER BY t.event_date, p.product_name;

-- 3) Purchase transactions joined to suppliers and products
SELECT t.transaction_id, t.event_date, p.sku, p.product_name, t.unit_cost, sup.supplier_name, t.on_hand_after
FROM stock_transactions t
JOIN products p ON p.product_id = t.product_id
LEFT JOIN suppliers sup ON sup.supplier_id = t.vendor_id
WHERE t.event_type = 'purchase'
ORDER BY t.event_date, p.product_name;

-- 4) Current stock snapshot per product (use last known on_hand_after)
SELECT p.product_id, p.sku, p.product_name,
       (SELECT st.on_hand_after FROM stock_transactions st
        WHERE st.product_id = p.product_id AND st.on_hand_after IS NOT NULL
        ORDER BY st.event_date DESC, st.transaction_id DESC LIMIT 1) AS last_on_hand
FROM products p
ORDER BY p.product_name;
