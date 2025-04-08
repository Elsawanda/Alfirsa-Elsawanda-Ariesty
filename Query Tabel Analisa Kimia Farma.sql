-- Melihat isi masing-masing tabel (opsional)
SELECT * FROM `rakamin-kf-analytics-455310.kimia_farma.kf_final_transaction` LIMIT 1000;
SELECT * FROM `rakamin-kf-analytics-455310.kimia_farma.kf_inventory` LIMIT 1000;
SELECT * FROM `rakamin-kf-analytics-455310.kimia_farma.kf_kantor_cabang` LIMIT 1000;
SELECT * FROM `rakamin-kf-analytics-455310.kimia_farma.kf_product` LIMIT 1000;

-- Mengganti nama kolom agar sesuai kebutuhan analisis
ALTER TABLE `rakamin-kf-analytics-455310.kimia_farma.kf_kantor_cabang`
RENAME COLUMN rating TO rating_cabang;

ALTER TABLE `rakamin-kf-analytics-455310.kimia_farma.kf_product`
RENAME COLUMN price TO actual_price;

ALTER TABLE `rakamin-kf-analytics-455310.kimia_farma.kf_final_transaction`
RENAME COLUMN rating TO rating_transaksi;

-- Membuat tabel analisis akhir
CREATE OR REPLACE TABLE `rakamin-kf-analytics-455310.kimia_farma.kf_analysis` AS
SELECT 
    t.transaction_id,
    t.date,
    t.branch_id,
    c.branch_name,
    c.kota,
    c.provinsi,
    c.rating_cabang,
    t.customer_name,
    t.product_id,
    p.product_name,
    p.actual_price,
    t.discount_percentage,

    -- Menghitung persentase gross laba berdasarkan harga
    CASE 
        WHEN p.actual_price <= 50000 THEN 0.10
        WHEN p.actual_price > 50000 AND p.actual_price <= 100000 THEN 0.15
        WHEN p.actual_price > 100000 AND p.actual_price <= 300000 THEN 0.20
        WHEN p.actual_price > 300000 AND p.actual_price <= 500000 THEN 0.25
        WHEN p.actual_price > 500000 THEN 0.30
        ELSE 0.00
    END AS persentase_gross_laba,

    -- Menghitung harga setelah diskon
    p.actual_price * (1 - t.discount_percentage / 100) AS nett_sales,

    -- Menghitung nett profit
    (p.actual_price * (1 - t.discount_percentage / 100)) * 
    CASE 
        WHEN p.actual_price <= 50000 THEN 0.10
        WHEN p.actual_price > 50000 AND p.actual_price <= 100000 THEN 0.15
        WHEN p.actual_price > 100000 AND p.actual_price <= 300000 THEN 0.20
        WHEN p.actual_price > 300000 AND p.actual_price <= 500000 THEN 0.25
        WHEN p.actual_price > 500000 THEN 0.30
        ELSE 0.00
    END AS nett_profit,

    t.rating_transaksi

FROM `rakamin-kf-analytics-455310.kimia_farma.kf_final_transaction` t
LEFT JOIN `rakamin-kf-analytics-455310.kimia_farma.kf_kantor_cabang` c 
    ON t.branch_id = c.branch_id
LEFT JOIN `rakamin-kf-analytics-455310.kimia_farma.kf_product` p 
    ON t.product_id = p.product_id;