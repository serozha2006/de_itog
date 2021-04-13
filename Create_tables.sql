create table cherenkov_ss.customers_excel (
customer_id               varchar2(100)
,customer_unique_id       varchar2(100)
,customer_zip_code_prefix varchar2(50)
,customer_city            varchar2(60)
,customer_state           varchar2(50)
);
/

create table cherenkov_ss.order_items_excel (
order_id              varchar2(100)                        
,order_item_id        varchar2(50)
,product_id           varchar2(100) 
,seller_id            varchar2(100) 
,shipping_limit_date  date
,price                number(10,2)
,freight_value        number(10,2)
);
/

create table cherenkov_ss.products_excel (
product_id              varchar2(100)                        
,product_category_name  varchar2(100)
);
/

create table cherenkov_ss.sellers_excel (
seller_id                varchar2(100)                   
,seller_zip_code_prefix  varchar2(50)
,seller_city             varchar2(100)
,seller_state            varchar2(10)
);
/

create table cherenkov_ss.order_payments_excel (
order_id               varchar2(100)                        
,payment_sequential    number(5)
,payment_type          varchar2(100)
,payment_installments  number(5)
,payment_value         number(10,2)
);
/

create table cherenkov_ss.orders_excel (
order_id                       varchar2(100)   CONSTRAINT orders_excel_pk_order_id primary key                       
,customer_id                   varchar2(100)   
,order_status                  varchar2(50)
,order_purchase_timestamp      date
,order_approved_at             date
,order_delivered_carrier_date  date
,order_delivered_customer_date date
,order_estimated_delivery_date date
);
/

create table cherenkov_ss.vitrina_perv_sloi (
order_id                  varchar2(100)
,order_status             varchar2(50)
,order_purchase_timestamp date
,customer_unique_id       varchar2(100)
,customer_city            varchar2(60)
,customer_state           varchar2(50)
,price                    number(10,2)
,freight_value            number(10,2)
,product_category_name    varchar2(100)
,seller_city              varchar2(100)
,seller_state             varchar2(10)
,payment_type             varchar2(100)
,payment_value            number(10,2)
);
/

create table cherenkov_ss.vitrina_agg_2zakaza_sum500 (
CUSTOMER_UNIQUE_ID       varchar2(100)
,KOLVO_ZAKAZOV_CLIENTA    number(10)
,SUMMA_ZAKAZOV            number(10,2)
,CUSTOMER_ZIP_CODE_PREFIX varchar2(50)
,CUSTOMER_CITY            varchar2(60)
,customer_state           varchar2(50)
);
/

create table cherenkov_ss.vitrina_agg_city_year (
YEAR                     number(4)
,CUSTOMER_CITY            varchar2(60)
,KOLVO_ZAKAZOV            number(10)
,SUMMA_ZAKAZOV            number(10,2)
,average_order_amount     number(10,2)
);
/

create table cherenkov_ss.vitrina_slice_month_orders (
slice_month            varchar2(60)
,SUMMA_ZAKAZOV         number(10,2)

);
/
