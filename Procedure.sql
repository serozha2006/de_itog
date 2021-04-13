
PROCEDURE vitrina_pervii_sloi
  is
  V_order_id                 cherenkov_ss.orders_excel.order_id%TYPE;
    V_ORDER_STATUS             cherenkov_ss.orders_excel.ORDER_STATUS%TYPE;
    V_ORDER_PURCHASE           cherenkov_ss.orders_excel.order_purchase_timestamp%TYPE;
    V_customer_unique_id       cherenkov_ss.customers_excel.customer_unique_id%TYPE;
    V_CUSTOMER_CITY            cherenkov_ss.customers_excel.CUSTOMER_CITY%TYPE;
    V_CUSTOMER_STATE           cherenkov_ss.customers_excel.CUSTOMER_STATE%TYPE;
    V_PRICE                    cherenkov_ss.order_items_excel.PRICE%TYPE;
    V_FREIGHT_VALUE            cherenkov_ss.order_items_excel.FREIGHT_VALUE%TYPE;
    V_PRODUCT_CATEGORY_NAME    cherenkov_ss.products_excel.PRODUCT_CATEGORY_NAME%TYPE;
    V_SELLER_CITY              cherenkov_ss.sellers_excel.SELLER_CITY%TYPE;
    V_SELLER_STATE             cherenkov_ss.sellers_excel.SELLER_STATE%TYPE;
    V_PAYMENT_TYPE             cherenkov_ss.order_payments_excel.PAYMENT_TYPE%TYPE;
    V_PAYMENT_VALUE            cherenkov_ss.order_payments_excel.PAYMENT_VALUE%TYPE;
  
  CURSOR vitrina_perv_sloi_CURSOR
  IS
    select distinct
    orders.order_id
    ,orders.ORDER_STATUS  
    ,trunc(orders.ORDER_PURCHASE_TIMESTAMP) as ORDER_PURCHASE
    ,customers.customer_unique_id
    ,customers.CUSTOMER_CITY
    ,customers.CUSTOMER_STATE
    ,order_items.PRICE
    ,order_items.FREIGHT_VALUE
    ,products.PRODUCT_CATEGORY_NAME
    ,sellers.SELLER_CITY
    ,sellers.SELLER_STATE
    ,order_payments.PAYMENT_TYPE
    ,order_payments.PAYMENT_VALUE

    from cherenkov_ss.orders_excel orders
    left join cherenkov_ss.customers_excel      customers        on customers.customer_id = orders.customer_id
    left join cherenkov_ss.order_items_excel    order_items      on order_items.order_id = orders.order_id
    left join cherenkov_ss.order_payments_excel order_payments   on order_payments.order_id = orders.order_id
    left join cherenkov_ss.products_excel       products         on products.PRODUCT_ID = order_items.PRODUCT_ID
    left join cherenkov_ss.sellers_excel        sellers          on sellers.SELLER_ID = order_items.SELLER_ID
    ;
BEGIN
  Delete from cherenkov_ss.vitrina_perv_sloi;
  commit;
  
  OPEN vitrina_perv_sloi_CURSOR;
       LOOP
         FETCH vitrina_perv_sloi_CURSOR INTO V_order_id, V_ORDER_STATUS, V_ORDER_PURCHASE, V_customer_unique_id, V_CUSTOMER_CITY, V_CUSTOMER_STATE, V_PRICE, V_FREIGHT_VALUE, V_PRODUCT_CATEGORY_NAME, V_SELLER_CITY, V_SELLER_STATE, V_PAYMENT_TYPE, V_PAYMENT_VALUE; 
            EXIT WHEN vitrina_perv_sloi_CURSOR%NOTFOUND; 
            INSERT INTO cherenkov_ss.vitrina_perv_sloi VALUES (V_order_id, V_ORDER_STATUS, V_ORDER_PURCHASE, V_customer_unique_id, V_CUSTOMER_CITY, V_CUSTOMER_STATE, V_PRICE, V_FREIGHT_VALUE, V_PRODUCT_CATEGORY_NAME, V_SELLER_CITY, V_SELLER_STATE, V_PAYMENT_TYPE, V_PAYMENT_VALUE);
       END LOOP;
       DBMS_OUTPUT.PUT_LINE( 'Lines inserted: '|| vitrina_perv_sloi_CURSOR%ROWCOUNT ||'.'); 
  CLOSE vitrina_perv_sloi_CURSOR;
commit;
end vitrina_pervii_sloi;


PROCEDURE vitrina_agg_2zakaza_sum500
  is
    V_customer_unique_id       cherenkov_ss.customers_excel.customer_unique_id%TYPE;
    V_KOLVO_ZAKAZOV_CLIENTA    number(10);
    V_SUMMA_ZAKAZOV            number(10,2);
    V_CUSTOMER_ZIP_CODE_PREFIX cherenkov_ss.customers_excel.CUSTOMER_ZIP_CODE_PREFIX%TYPE;
    V_CUSTOMER_CITY            cherenkov_ss.customers_excel.CUSTOMER_CITY%TYPE;
    V_CUSTOMER_STATE           cherenkov_ss.customers_excel.CUSTOMER_STATE%TYPE;
      
  CURSOR agg_2zakaza_sum500_CURSOR
  IS
  Select 
    ce.CUSTOMER_UNIQUE_ID
    ,cust_3.KOLVO_ZAKAZOV_CLIENTA
    ,cust_3.SUMMA_ZAKAZOV
    ,ce.CUSTOMER_ZIP_CODE_PREFIX
    ,ce.CUSTOMER_CITY
    ,ce.customer_state

    From (
          select 
               CUSTOMER_UNIQUE_ID, 
               count(ORDER_ID) AS KOLVO_ZAKAZOV_CLIENTA
               ,SUM(payment_value) AS  SUMMA_ZAKAZOV
          From  vitrina_perv_sloi
          where 1=1 
          group by CUSTOMER_UNIQUE_ID
          having count(ORDER_ID) >1 AND SUM(payment_value) > 500
    ) cust_3
    left join customers_excel ce 
    ON cust_3.CUSTOMER_UNIQUE_ID = ce.CUSTOMER_UNIQUE_ID
    ;
  BEGIN
    Delete from cherenkov_ss.vitrina_agg_2zakaza_sum500;
    commit;
    
    OPEN agg_2zakaza_sum500_CURSOR;
         LOOP
           FETCH agg_2zakaza_sum500_CURSOR INTO V_customer_unique_id, V_KOLVO_ZAKAZOV_CLIENTA, V_SUMMA_ZAKAZOV,V_CUSTOMER_ZIP_CODE_PREFIX, V_CUSTOMER_CITY, V_CUSTOMER_STATE; 
              EXIT WHEN agg_2zakaza_sum500_CURSOR%NOTFOUND; 
              INSERT INTO cherenkov_ss.vitrina_agg_2zakaza_sum500 VALUES (V_customer_unique_id, V_KOLVO_ZAKAZOV_CLIENTA, V_SUMMA_ZAKAZOV,V_CUSTOMER_ZIP_CODE_PREFIX, V_CUSTOMER_CITY, V_CUSTOMER_STATE);
         END LOOP;
         DBMS_OUTPUT.PUT_LINE( 'Lines inserted: '|| agg_2zakaza_sum500_CURSOR%ROWCOUNT ||'.'); 
    CLOSE agg_2zakaza_sum500_CURSOR;
  commit;
  end vitrina_agg_2zakaza_sum500;


  PROCEDURE vitrina_agg_city_year
  is
    V_YEAR                     number(4);
    V_CUSTOMER_CITY            cherenkov_ss.customers_excel.CUSTOMER_CITY%TYPE;
    V_KOLVO_ZAKAZOV            number(10);
    V_SUMMA_ZAKAZOV            number(10,2);
    V_average_order_amount     number(10,2);
 
    CURSOR agg_city_year_CURSOR
    IS
      select 
      zzz.*
      ,round((zzz.SUMMA_ZAKAZOV / KOLVO_ZAKAZOV),2) as average_order_amount
      FROM (
            select 
            to_number(to_char(order_purchase_timestamp,'YYYY')) as YEAR
                 ,vit.CUSTOMER_CITY 
                ,count(distinct vit.order_ID) AS KOLVO_ZAKAZOV
                 ,SUM(vit.payment_value) AS  SUMMA_ZAKAZOV
            From  vitrina_perv_sloi vit
            group by vit.CUSTOMER_CITY, to_char(order_purchase_timestamp,'YYYY')
           ) zzz
      order by zzz.SUMMA_ZAKAZOV desc;

  BEGIN
    Delete from cherenkov_ss.vitrina_agg_city_year;
    commit;
    
    OPEN agg_city_year_CURSOR;
         LOOP
           FETCH agg_city_year_CURSOR INTO V_YEAR,V_CUSTOMER_CITY,V_KOLVO_ZAKAZOV,V_SUMMA_ZAKAZOV,V_average_order_amount; 
              EXIT WHEN agg_city_year_CURSOR%NOTFOUND; 
              INSERT INTO cherenkov_ss.vitrina_agg_city_year VALUES (V_YEAR,V_CUSTOMER_CITY,V_KOLVO_ZAKAZOV,V_SUMMA_ZAKAZOV,V_average_order_amount);
         END LOOP;
         DBMS_OUTPUT.PUT_LINE( 'Lines inserted: '|| agg_city_year_CURSOR%ROWCOUNT ||'.'); 
    CLOSE agg_city_year_CURSOR;
  commit;
  end vitrina_agg_city_year;




PROCEDURE vitrina_slice_month_orders
  is
    V_slice_month              varchar2(60);
    V_SUMMA_ZAKAZOV            number(10,2);
    
   
    CURSOR slice_month_orders_CURSOR
    IS
      select 
      to_char(zzz.slice_last_day_month,'MONTH YY') as slice_month
      ,zzz.SUMMA_ZAKAZOV
      FROM (
            select 
            LAST_DAY(to_date(vit.order_purchase_timestamp,'DD.MM.YYYY'))as slice_last_day_month
                 ,SUM(vit.payment_value) AS  SUMMA_ZAKAZOV
            From  vitrina_perv_sloi vit
            group by LAST_DAY(to_date(vit.order_purchase_timestamp,'DD.MM.YYYY'))
           ) zzz
      order by zzz.slice_last_day_month;

  BEGIN
    Delete from cherenkov_ss.vitrina_slice_month_orders;
    commit;
    
    OPEN slice_month_orders_CURSOR;
         LOOP
           FETCH slice_month_orders_CURSOR INTO V_slice_month,V_SUMMA_ZAKAZOV; 
              EXIT WHEN slice_month_orders_CURSOR%NOTFOUND; 
              INSERT INTO cherenkov_ss.vitrina_slice_month_orders VALUES (V_slice_month,V_SUMMA_ZAKAZOV);
         END LOOP;
         DBMS_OUTPUT.PUT_LINE( 'Lines inserted: '|| slice_month_orders_CURSOR%ROWCOUNT ||'.'); 
    CLOSE slice_month_orders_CURSOR;
  commit;
  end vitrina_slice_month_orders;
