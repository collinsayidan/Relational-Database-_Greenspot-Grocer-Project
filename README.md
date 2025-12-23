
# Greenspot Grocer — Relational Database Project

> **Author:** Collins Ayidan  
> **Stack:** MySQL, MySQL Workbench  
> **Artifacts:** EER diagram (PNG + `.mwb`), schema & data scripts, validation queries, insights write‑up

A production‑style conversion of a grocery spreadsheet into a **normalized relational database**.  
This project reorganizes mixed purchase/sale rows from a single CSV into clean tables with referential integrity and a unified transaction ledger suited for reporting and growth.

---

## 📦 Repository Structure

```
.
├─ greenspot_schema.sql                # DDL: tables, PKs, FKs, indexes
├─ greenspot_load_data.sql             # INSERTs generated from GreenspotDataset.csv
├─ greenspot_join_queries.sql          # Validation JOIN queries
├─ greenspot_business_query.sql        # Business question query (revenue by category)
├─ greenspot_insights.txt              # Anomalies + design decisions + scalability notes
├─ greenspot_submission_summary.txt    # One-pager for reviewers
├─ docs/
│  ├─ greenspot_eer_dark.png           # ERD image (high-resolution, dark theme)
│  └─ (optional) greenspot_eer_light.png
└─ (optional) greenspot_model.mwb      # MySQL Workbench model
```

> **Tip:** If viewing on GitHub, open `docs/greenspot_eer_dark.png` to see the ERD with datatypes.

---

## 🗺️ Entity‑Relationship Overview

Core tables and relationships:

- `categories(category_id)` → `products(category_id)`
- `storage_locations(location_id)` → `products.default_location_id`, `stock_transactions.location_id`
- `suppliers(supplier_id)` → `stock_transactions.vendor_id`
- `customers(customer_id)` → `stock_transactions.customer_id`
- `products(product_id)` → `stock_transactions.product_id`

The design follows **3NF**, removes duplication, and supports both **purchases** and **sales** in a single ledger: `stock_transactions(event_type = 'purchase' | 'sale')`.

![Greenspot ERD](docs/greenspot_eer_dark.png)

---

## 🚀 Quick Start

> Requires **MySQL 8+** and **MySQL Workbench**.

1. **Create schema & tables**
   ```sql
   SOURCE greenspot_schema.sql;
   ```

2. **Load sample data**
   ```sql
   SOURCE greenspot_load_data.sql;
   ```

3. **Run validation queries**
   ```sql
   SOURCE greenspot_join_queries.sql;
   SOURCE greenspot_business_query.sql;
   ```

If you prefer Workbench:
- Open each script → click **Run** (⚡).
- Or use *Server → Data Import* to execute scripts.

---

## ✅ What This Project Demonstrates

- **Normalization & Modeling**
  - Separates reference data (categories, suppliers, customers, storage locations) from transactional facts.
  - Captures **both purchases and sales** in a unified ledger with optional `on_hand_after` snapshots.

- **Integrity & Performance**
  - Primary/foreign keys + helpful indexes on common joins and filters.
  - Datatypes tailored to the CSV (e.g., `unit_of_measure` kept `VARCHAR` to accommodate variations like `12 oz can`, `12-oz can`).

- **Scalability**
  - Easily add products, suppliers, locations, and transactions without schema changes.
  - Provides reliable join paths for reporting (e.g., category revenue, stock snapshots).

---

## 🔎 Sample Queries

### 1) Products with categories & default location
```sql
SELECT p.product_id, p.sku, p.product_name, c.category_name, s.location_code AS default_location
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN storage_locations s ON s.location_id = p.default_location_id
ORDER BY c.category_name, p.product_name;
```

### 2) Sales joined to customers & products
```sql
SELECT t.transaction_id, t.event_date, p.sku, p.product_name,
       t.qty_change AS qty_sold, t.unit_price, cu.external_ref AS customer_ref
FROM stock_transactions t
JOIN products p   ON p.product_id  = t.product_id
LEFT JOIN customers cu ON cu.customer_id = t.customer_id
WHERE t.event_type = 'sale'
ORDER BY t.event_date, p.product_name;
```

### 3) Purchases joined to suppliers & products
```sql
SELECT t.transaction_id, t.event_date, p.sku, p.product_name,
       t.unit_cost, sup.supplier_name, t.on_hand_after
FROM stock_transactions t
JOIN products p  ON p.product_id   = t.product_id
LEFT JOIN suppliers sup ON sup.supplier_id = t.vendor_id
WHERE t.event_type = 'purchase'
ORDER BY t.event_date, p.product_name;
```

### 4) Business question — **Which category generated the highest revenue?**
```sql
SELECT c.category_name,
       SUM(t.qty_change * t.unit_price * -1) AS total_revenue
FROM stock_transactions t
JOIN products p  ON p.product_id  = t.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE t.event_type = 'sale'
GROUP BY c.category_name
ORDER BY total_revenue DESC;
```

---

## 🧪 Validation Checklist

- Tables created with appropriate **PKs, FKs, and datatypes**.
- All CSV data mapped into normalized tables via `greenspot_load_data.sql`.
- JOIN queries successfully retrieve data across all related tables.
- Example business query demonstrates insight (revenue by category).

---

## 📝 Insights & Design Rationale (short)

- **Anomalies in the source CSV**
  - Mixed purchase/sale rows in one sheet.
  - Missing purchase quantities (only `cost` and occasional `on_hand` snapshots).
  - Inconsistent unit strings; case‑sensitive location codes.
  - Vendor/customer identifiers repeated across rows.

- **Design responses**
  - Reference tables for categories, suppliers, customers, locations.
  - Unified `stock_transactions` ledger with `event_type`, optional `on_hand_after`.
  - `unit_of_measure` kept flexible (`VARCHAR`) to accept all present variants while allowing future normalization.

- **Growth readiness**
  - Minimal friction to add new product lines, suppliers, and depots.
  - A clear path to richer analytics (e.g., reorder analysis, best sellers, profitability).

For the full narrative, see **`greenspot_insights.txt`** and **`greenspot_submission_summary.txt`**.

---

## 🛠️ Reproducing / Editing the EER Diagram

1. Open **MySQL Workbench** and run `greenspot_schema.sql`.
2. **Reverse Engineer**: *Database → Reverse Engineer* → pick schema **`greenspot`**.
3. Arrange tables, save as **`greenspot_model.mwb`**.
4. Export PNG: *File → Export → Export Diagram as PNG* → `docs/greenspot_eer_light.png`.

> This repo includes a high‑resolution **dark‑theme ERD** (`docs/greenspot_eer_dark.png`) as a ready visual.

---

## 🧭 Roadmap (Future Enhancements)

- Normalize **units** into a lookup table and map legacy variants.
- Add **purchase quantity** to capture true stock movement for receipts.
- Expand **customers** with names/emails and build order history views.
- Add **derived views** (e.g., stock below reorder, 30‑day best sellers).
- Optional **triggers** to maintain last‑known on‑hand or to validate negative stock.

---

## 🙌 How to Use in Interviews

- Walk evaluators through the **ERD** and explain how the design fixes CSV anomalies.
- Run the **business query** to show quick insight (revenue by category).
- Discuss the **tradeoff** of flexible units now vs. future normalization.
- Outline the **roadmap** to productionize (triggers, procedures, monitoring).

---

## 📄 License

You’re free to clone and adapt for learning and portfolio demonstrations.  
(If publishing publicly, add a license that matches your preference, e.g., MIT.)

---

## 🔗 Author
**Collins Ayidan** — Data & Back‑End Developer  
If you have questions or want a customized extension (promotions, supplier costing, or delivery slots), feel free to open an issue or reach out.
