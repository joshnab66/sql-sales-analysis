INSERT INTO salesmen (sm_code, sm_name)
SELECT DISTINCT sm_code, sm_name
FROM stg_sales;

select * from salesmen;
select * from routes;

INSERT INTO routes (route_code, route_name, sm_code)
SELECT DISTINCT route_code, route_name, sm_code
FROM stg_sales;

select * from retailers;

INSERT INTO retailers (retailer_id, route_code, coverage_type, channel, sub_channel)
SELECT DISTINCT retailer_id, route_code, coverage_type, channel, sub_channel
FROM stg_sales;

select * from products;

INSERT INTO products (product_code, product_description, brand_code, brand_name,
                      mother_pack_code, mother_pack_name, business)
SELECT DISTINCT product_code, product_description, brand_code, brand_name,
                mother_pack_code, mother_pack_name, business
FROM stg_sales;

select * from bills;

INSERT INTO bills (bill_number, bill_date, retailer_id, status, record_type)
SELECT DISTINCT bill_number, bill_date, retailer_id, status, record_type
FROM stg_sales;

select * from sale_lines;

INSERT INTO sale_lines (bill_number, product_code, mrp, purchase_rate_before_tax,
                        purchase_rate_with_tax, total_qty_ea, qty_cs, qty_pc, free_qty,
                        free_value, selling_rate_before_tax, gross, scheme_disc, key_disc,
                        rd_wsh_disc, taxable_value, tax_pct, tax_amount, net_amount,
                        net_volume_gms)
SELECT bill_number, product_code, mrp, purchase_rate_before_tax,
       purchase_rate_with_tax, total_qty_ea, qty_cs, qty_pc, free_qty,
       free_value, selling_rate_before_tax, gross, scheme_disc, key_disc,
       rd_wsh_disc, taxable_value, tax_pct, tax_amount, net_amount,
       net_volume_gms
FROM stg_sales;

SELECT 'salesmen' AS tbl, COUNT(*) FROM salesmen
UNION ALL SELECT 'routes', COUNT(*) FROM routes
UNION ALL SELECT 'retailers', COUNT(*) FROM retailers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'bills', COUNT(*) FROM bills
UNION ALL SELECT 'sale_lines', COUNT(*) FROM sale_lines;

--net_amount of the sale_line

SELECT SUM(net_amount) FROM sale_lines;
