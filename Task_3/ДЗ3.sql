-- 1 задание
select v.tariff
--      , uniqExact(o.idhash_view) as cnt_orders_view
--      , uniqExact(o.order_dttm) as cnt_create_order
     , (uniqExact(o.idhash_view) - uniqExact(o.order_dttm)) as d_orders_view_create_order
--      , uniqExact(o.da_dttm) as cnt_find_driver
     , (uniqExact(o.order_dttm) - uniqExact(o.da_dttm) ) as d_create_find_driver
--      , uniqExact(o.rfc_dttm) as cnt_delivery_car
     , (uniqExact(o.da_dttm) - uniqExact(o.rfc_dttm)) as d_find_driver_delivery_car
--      , uniqExact(o.cc_dttm) as cnt_getting_into_car
     , (uniqExact(o.rfc_dttm) - uniqExact(o.cc_dttm)) as d_delivery_car_getting_into_car
--      , uniqExact(o.finish_dttm) as cnt_finish_order
     ,  (uniqExact(o.cc_dttm) - uniqExact(o.finish_dttm)) as d_getting_into_car_cnt_finish_order

     , countIf( o.cc_dttm, o.cc_dttm > 0) as getting_into_car, countIf( o.rfc_dttm, o.rfc_dttm> 0)as delivery_car

from views v join orders o on v.idhash_order = o.idhash_order
where o.status = 'CP'
group by v.tariff
order by uniqExact(o.idhash_view) desc;
-- По итогу запроса можно сделать вывод, что теряем больше всего клиентов:
-- 1) с момента просмотра цены до создания заказа
-- 2) для тарифов "Эконом", "Комфорт+" и "Бизнес" потеря идет с момента доставки машины и завершением заказа
--    для тарифа "Комфорт" с момента нахождения водителя и подачей машины


-- 2 задание
-- По каждому клиенту вывести топ используемых им
-- тарифов по убыванию, а также подсчитать сколькими тарифами он пользуется.

-- топ 2 используемых тарифов для каждого клиента по убыванию
select
        DISTINCT idhash_client
        , tarif
        , tariff
from
    (   select DISTINCT v.idhash_client
                      , v.tariff
                      , count(v.tariff) as tarif
        from views v join orders o on v.idhash_order = o.idhash_order
        where idhash_client > 0
        group by v.idhash_client , v.tariff
        order by v.idhash_client, tarif desc
--         limit 1 by idhash_client
    )
group by idhash_client, tariff, tarif
order by idhash_client , tarif desc
limit 2 by idhash_client
;

-- всего используемых тарифов для каждого клиента
select
      DISTINCT idhash_client,
      count(cnt_tariff) as cnt_tariff_used
from
    (
     select  DISTINCT v.idhash_client
          , count(v.tariff) as cnt_tariff
          , v.tariff
    from views v join orders o on v.idhash_order = o.idhash_order
    where idhash_client > 0
    group by v.idhash_client, v.tariff
    order by v.idhash_client, cnt_tariff desc
    )
group by idhash_client
order by idhash_client
;

-- 3 задание
-- Вывести топ 10 гексагонов (размер 7) из которых уезжают
-- с 7 до 10 утра и в которые едут с 18-00 до 20-00 в сумме по всем дням

-- из которых уезжают с 7 до 10 время
select geoToH3(latitude, longitude, 7) as geo_start
     , count(geo_start) as cnt_geo
--      , geoToH3(del_latitude, del_longitude, 7) as geo_finish
--      , cc_dttm as get_into_car
--      , finish_dttm as finish_trip
--      , v.idhash_client
--      , abs(geo_start - geoToH3(del_latitude, del_longitude, 7)) as diff_geo
from views v join orders o on v.idhash_order = o.idhash_order
where toHour(cc_dttm) >= 07 and toHour(cc_dttm) <= 10
    and abs(geo_start - geoToH3(del_latitude, del_longitude, 7)) > 0
group by  geo_start --, geoToH3(del_latitude, del_longitude, 7) --v.idhash_client,get_into_car, finish_trip,
order by cnt_geo desc
limit 10
--;
union all
-- в которые едут с 18-00 до 20-00
select geoToH3(del_latitude, del_longitude, 7) as geo_finish
     , count(geo_finish) as cnt_geo
--      , geoToH3(del_latitude, del_longitude, 7) as geo_finish
--      , cc_dttm as get_into_car
--      , finish_dttm as finish_trip
--      , v.idhash_client
--      , abs(geo_start - geoToH3(del_latitude, del_longitude, 7)) as diff_geo
from views v join orders o on v.idhash_order = o.idhash_order
where toHour(cc_dttm) >= 18 and toHour(cc_dttm) <= 20

    and abs(geoToH3(latitude, longitude, 7) - geo_finish) > 0
group by  geo_finish --, geoToH3(del_latitude, del_longitude, 7) --v.idhash_client,get_into_car, finish_trip,
order by cnt_geo desc
limit 10;


-- 4 задание
-- Вывести медиану и 95 квантиль времени поиска водителя.

select idhash_client
--        order_dttm as create_order
--      , da_dttm as driver_found
--      , dateDiff('minute', order_dttm, da_dttm) as diff_min
     , quantileIf(0.95)(dateDiff('minute', order_dttm, da_dttm), dateDiff('minute', order_dttm, da_dttm)>0) as percentile_95
     , medianIf(dateDiff('minute', order_dttm, da_dttm), dateDiff('minute', order_dttm, da_dttm)>0) as median_diff_time
from orders o join views v on o.idhash_order = v.idhash_order
group by idhash_client
having percentile_95>0 and median_diff_time>0
order by idhash_client  -- diff_min desc
;










