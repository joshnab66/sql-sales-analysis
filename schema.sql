CREATE TABLE stg_sales (
    sm_code text,
    sm_name text,
    route_code text,
    route_name text,
    bill_number text,
    bill_date date,
    status text,
    coverage_type text,
    channel text,
    sub_channel text,
    business text,
    brand_code text,
    brand_name text,
    mother_pack_code text,
    mother_pack_name text,
    product_code bigint,
    product_description text,
    mrp numeric,
    purchase_rate_before_tax numeric,
    purchase_rate_with_tax numeric,
    total_qty_ea integer,
    qty_cs integer,
    qty_pc integer,
    free_qty integer,
    free_value numeric,
    selling_rate_before_tax numeric,
    gross numeric,
    scheme_disc numeric,
    key_disc numeric,
    rd_wsh_disc numeric,
    taxable_value numeric,
    tax_pct numeric,
    tax_amount numeric,
    net_amount numeric,
    net_volume_gms numeric,
    record_type text,
    retailer_id text
);

select * from stg_sales;

SELECT COUNT(*) AS row_count, SUM(net_amount) AS total_net FROM stg_sales;


CREATE TABLE salesmen (
    sm_code   varchar(10) PRIMARY KEY,
    sm_name   varchar(30) NOT NULL
);

CREATE TABLE routes (
    route_code  varchar(10) PRIMARY KEY,
    route_name  varchar(50) NOT NULL,
    sm_code     varchar(10) NOT NULL REFERENCES salesmen(sm_code)
);

CREATE TABLE retailers (
    retailer_id    varchar(10) PRIMARY KEY,
    route_code     varchar(10) NOT NULL REFERENCES routes(route_code),
    coverage_type  varchar(30),
    channel        varchar(40),
    sub_channel    varchar(40)
);

CREATE TABLE products (
    product_code         bigint PRIMARY KEY,
    product_description  varchar(100) NOT NULL,
    brand_code           varchar(10),
    brand_name           varchar(80),
    mother_pack_code     varchar(30),
    mother_pack_name     varchar(100),
    business             varchar(80)
);

CREATE TABLE bills (
    bill_number  varchar(20) PRIMARY KEY,
    bill_date    date NOT NULL,
    retailer_id  varchar(10) NOT NULL REFERENCES retailers(retailer_id),
    status       varchar(20) NOT NULL,
    record_type  varchar(10) NOT NULL CHECK (record_type IN ('Sale', 'Return'))
);

CREATE TABLE sale_lines (
    line_id                   serial PRIMARY KEY,
    bill_number               varchar(20) NOT NULL REFERENCES bills(bill_number),
    product_code              bigint NOT NULL REFERENCES products(product_code),
    mrp                       numeric(14,6),
    purchase_rate_before_tax  numeric(14,6),
    purchase_rate_with_tax    numeric(14,6),
    total_qty_ea              integer,
    qty_cs                    integer,
    qty_pc                    integer,
    free_qty                  integer,
    free_value                numeric(14,6),
    selling_rate_before_tax   numeric(14,6),
    gross                     numeric(14,6),
    scheme_disc               numeric(14,6),
    key_disc                  numeric(14,6),
    rd_wsh_disc               numeric(14,6),
    taxable_value             numeric(14,6),
    tax_pct                   numeric(5,2),
    tax_amount                numeric(14,6),
    net_amount                numeric(14,6),
    net_volume_gms            numeric(14,3)
);



