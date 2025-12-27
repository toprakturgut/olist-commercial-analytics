--Ödeme tiplerinin satır tekrarı oluşturmaması için order_id'de aggregate edilmesi.
WITH payment_agg AS (
    SELECT
        order_id,
        SUM(CASE WHEN payment_value > 0 THEN payment_value ELSE 0 END) AS total_payment_value,
        MAX(payment_type) FILTER (WHERE payment_value > 0) AS main_payment_type
    FROM olist_order_payments_dataset
    GROUP BY order_id
),
--Data içindeki bazı tekrarlayan/tutarsız reviewları tek order_id'de toplamak için aggregation.
review_agg AS (
    SELECT
        order_id,
        ROUND(AVG(review_score)::numeric, 2) AS review_score
    FROM olist_order_reviews_dataset
    GROUP BY order_id
),
--Temel olarak gerekli olan verilerin base_data'da toplanması ve data sağlığı için filtrelemeler
base_data AS (
    SELECT
    	--ID'ler
        o.order_id,
        oi.order_item_id,
        o.customer_id,
        c.customer_unique_id,
        oi.product_id,
        oi.seller_id,
		
        --Zaman bilgileri
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        oi.shipping_limit_date,
        TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS purchase_year_month,
        
		--Lokasyon Bilgileri
        c.customer_city,
        c.customer_state,
        s.seller_city,
        s.seller_state,
        
		--Kategori İsimler ve İngilizcesi
        p.product_category_name,
        COALESCE(t.product_category_name_english, p.product_category_name) AS product_category_name_english,
		
        --Fiyat Bilgileri
        oi.price,
        oi.freight_value,
        (oi.price + oi.freight_value) AS total_order_item_value,
        
		--Payment Aggregationda Oluşturduğumuz Bilgiler
        pay.total_payment_value,
        pay.main_payment_type,
        
		--Review Aggregationda Oluşturduğumuz review_score
        r.review_score
        
	--Joinler
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi 
        ON o.order_id = oi.order_id
    JOIN olist_customers_dataset c 
        ON o.customer_id = c.customer_id
    JOIN olist_sellers_dataset s 
        ON oi.seller_id = s.seller_id
    JOIN olist_products_dataset p 
        ON oi.product_id = p.product_id
    LEFT JOIN olist_product_category_name_translation t 
        ON p.product_category_name = t.product_category_name
    LEFT JOIN payment_agg pay 
        ON o.order_id = pay.order_id
    LEFT JOIN review_agg r 
        ON o.order_id = r.order_id
        
	--Mantık ve Tutarlılık Filtreleri
    WHERE 
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.order_delivered_carrier_date IS NOT NULL
        AND o.order_delivered_customer_date >= o.order_delivered_carrier_date
)

SELECT
    bd.*,
	
    --Görev 1 Teslimat Süresi
    DATE_PART('day', bd.order_delivered_customer_date::timestamp - bd.order_purchase_timestamp) 
        AS delivery_time_days,
	--Ek Sorgu
    DATE_PART('day', bd.order_delivered_customer_date::timestamp - bd.order_delivered_carrier_date::timestamp) 
        AS transit_time_days,
	--Görev 1 Gecikme Göstergesi
    CASE 
        WHEN bd.order_delivered_customer_date > bd.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_late,
	--Gecikme Kaynağına Dair Ek Sorgu
    CASE 
        WHEN bd.order_delivered_customer_date <= bd.order_estimated_delivery_date THEN 'On Time Delivery'
        WHEN bd.order_delivered_carrier_date > bd.shipping_limit_date THEN 'Seller Caused Delay'
        ELSE 'Logistics/Carrier Caused Delay'
    END AS delay_source

FROM base_data bd;