
-- Business Question: Which category generated the highest revenue from sales?
SELECT c.category_name,
       SUM(t.qty_change * t.unit_price * -1) AS total_revenue
FROM stock_transactions t
JOIN products p ON p.product_id = t.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE t.event_type = 'sale'
GROUP BY c.category_name
ORDER BY total_revenue DESC;
