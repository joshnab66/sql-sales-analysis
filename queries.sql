-- Q1: Which brands bring the most net sales?

SELECT p.brand_name,
       SUM(sl.net_amount) AS net_sales
FROM sale_lines sl
JOIN products p ON sl.product_code = p.product_code
GROUP BY p.brand_name
ORDER BY net_sales DESC limit 10;

-- Q2: How much of our sales value is lost to returns?
WITH totals AS (
    SELECT SUM(CASE WHEN b.record_type = 'Sale'   THEN sl.net_amount END) AS sales_value,
           SUM(CASE WHEN b.record_type = 'Return' THEN sl.net_amount END) AS return_value
    FROM bills b
    JOIN sale_lines sl ON sl.bill_number = b.bill_number
)
SELECT ROUND(sales_value, 2)                          AS sales_value,
       ROUND(-return_value, 2)                        AS returned_value,
       ROUND(-return_value * 100.0 / sales_value, 2)  AS return_pct
FROM totals;

-- Q3: Which retailers are our most frequent buyers (more than 5 bills)?
SELECT r.retailer_id,
       COUNT(DISTINCT b.bill_number)  AS bill_count,
       ROUND(SUM(sl.net_amount), 2)   AS net_sales
FROM retailers r
JOIN bills b       ON b.retailer_id = r.retailer_id
JOIN sale_lines sl ON sl.bill_number = b.bill_number
WHERE b.record_type = 'Sale'
  AND r.retailer_id <> 'R258'   -- R258 = counter sales, not a real shop
GROUP BY r.retailer_id
HAVING COUNT(DISTINCT b.bill_number) > 5
ORDER BY net_sales DESC;

-- Q4: How does each salesman perform (routes, retailers, bills, net sales)?
SELECT s.sm_name,
       COUNT(DISTINCT rt.route_code)  AS routes,
       COUNT(DISTINCT r.retailer_id)  AS retailers,
       COUNT(DISTINCT b.bill_number)  AS bills,
       ROUND(SUM(sl.net_amount), 2)   AS net_sales
FROM salesmen s
JOIN routes rt     ON rt.sm_code     = s.sm_code
JOIN retailers r   ON r.route_code   = rt.route_code
JOIN bills b       ON b.retailer_id  = r.retailer_id
JOIN sale_lines sl ON sl.bill_number = b.bill_number
WHERE b.record_type = 'Sale'
  AND r.retailer_id <> 'R258'
GROUP BY s.sm_name
ORDER BY net_sales DESC;

-- Q5: How many bills are small, medium or large?

WITH bill_totals AS (
    SELECT b.bill_number,
           SUM(sl.net_amount) AS bill_value
    FROM bills b
    JOIN sale_lines sl ON sl.bill_number = b.bill_number
    WHERE b.record_type = 'Sale'
    GROUP BY b.bill_number
)
SELECT CASE
           WHEN bill_value < 2000  THEN 'Small (<2k)'
           WHEN bill_value < 10000 THEN 'Medium (2k-10k)'
           ELSE 'Large (10k+)'
       END                          AS bill_size,
       COUNT(*)                     AS bills,
       ROUND(SUM(bill_value), 2)    AS net_sales
FROM bill_totals
GROUP BY 1
ORDER BY net_sales DESC;

-- Q6: Which retail channels bring the most sales?

SELECT r.channel,
       COUNT(DISTINCT b.bill_number) AS bills,
       ROUND(SUM(sl.net_amount), 2)  AS net_sales
FROM bills b
JOIN retailers r   ON r.retailer_id  = b.retailer_id
JOIN sale_lines sl ON sl.bill_number = b.bill_number
WHERE b.record_type = 'Sale'
GROUP BY r.channel
ORDER BY net_sales DESC;

-- Q7: Average vs median bill value per salesman (counter sales excluded)
WITH bill_totals AS (
    SELECT b.bill_number,
           b.retailer_id,
           SUM(sl.net_amount) AS bill_value
    FROM bills b
    JOIN sale_lines sl ON sl.bill_number = b.bill_number
    WHERE b.record_type = 'Sale'
      AND b.retailer_id <> 'R258'
    GROUP BY b.bill_number, b.retailer_id
)
SELECT s.sm_name,
       COUNT(*)                                                               AS bills,
       ROUND(AVG(bt.bill_value), 2)                                           AS avg_bill_value,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY bt.bill_value))::numeric, 2) AS median_bill_value,
       (SELECT ROUND(AVG(bill_value), 2) FROM bill_totals)                    AS overall_avg,
       (SELECT ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY bill_value))::numeric, 2)
        FROM bill_totals)                                                     AS overall_median
FROM bill_totals bt
JOIN retailers r ON r.retailer_id = bt.retailer_id
JOIN routes rt   ON rt.route_code = r.route_code
JOIN salesmen s  ON s.sm_code     = rt.sm_code
GROUP BY s.sm_name
ORDER BY avg_bill_value DESC;

-- Q8: What are the top 3 products inside each brand (sales only)?
WITH product_sales AS (
    SELECT p.brand_name,
           p.product_description,
           SUM(sl.net_amount) AS net_sales
    FROM sale_lines sl
    JOIN bills b    ON b.bill_number  = sl.bill_number
    JOIN products p ON p.product_code = sl.product_code
    WHERE b.record_type = 'Sale'
    GROUP BY p.brand_name, p.product_description
)
SELECT brand_name, product_description, ROUND(net_sales, 2) AS net_sales, rnk
FROM (
    SELECT ps.*,
           RANK() OVER (PARTITION BY brand_name ORDER BY net_sales DESC) AS rnk
    FROM product_sales ps
) ranked
WHERE rnk <= 3
ORDER BY brand_name, rnk;

-- Q9: What does cumulative daily net sales look like across the month?

WITH daily AS (
    SELECT b.bill_date,
           SUM(sl.net_amount) AS daily_sales
    FROM bills b
    JOIN sale_lines sl ON sl.bill_number = b.bill_number
    GROUP BY b.bill_date
)
SELECT bill_date,
       ROUND(daily_sales, 2)                              AS daily_sales,
       ROUND(SUM(daily_sales) OVER (ORDER BY bill_date), 2) AS running_total
FROM daily
ORDER BY bill_date;
