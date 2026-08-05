-- SL vs Distance Case Study

USE IS_Project;
WITH IS_SQL AS (
    SELECT
        order_id,
        CASE 
            WHEN order_status = 20 THEN 'Completed'
            WHEN order_status = 30 AND order_delivered_time IS NOT NULL THEN 'Completed'
            WHEN order_status = 30 THEN 'Cancelled'
            -- Note: 12 orders tagged as cancelled but were still able to deliver
            ELSE 'Completed' -- Note: There are 3 records with null order_status, but have completed delivery
        END AS order_status_label,

        CASE 
            WHEN delivery_service_level = 1 THEN 'Early'
            WHEN delivery_service_level = 2 THEN 'On Time'
            WHEN delivery_service_level = 3 THEN 'Late'
            ELSE 'Untagged'
        END AS delivery_performance, 

        COALESCE(
            ROUND(distance_rider_from_store,2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY distance_rider_from_store) OVER (partition BY delivery_service_level),2)
            ) AS rider_store_km,
        COALESCE(
            ROUND(distance_to_customer,2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY distance_to_customer) OVER (partition BY delivery_service_level),2)
            ) AS store_customer_km,
        COALESCE(
            ROUND((distance_rider_from_store + distance_to_customer),2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (distance_rider_from_store + distance_to_customer)) OVER (partition BY delivery_service_level),2)
            ) AS total_dist_km,
     
        COALESCE(
            ROUND(CAST((order_pickup_done_time - order_ready_for_pickup_time) AS float) * 1440.0,2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST((order_pickup_done_time - order_ready_for_pickup_time) AS float) * 1440.0) OVER (PARTITION BY delivery_service_level),2)
            ) AS mins_taken_to_pickup,
        COALESCE(
            ROUND(CAST((order_delivered_time - order_pickup_done_time) AS float) * 1440.0,2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST((order_delivered_time - order_pickup_done_time) AS float) * 1440.0) OVER (PARTITION BY delivery_service_level),2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST((order_delivered_time - order_pickup_done_time) AS float) * 1440.0) OVER (), 2)
            ) AS mins_taken_to_deliver_from_pickup,
        COALESCE(
            ROUND(CAST((order_delivered_time - order_ready_for_pickup_time) AS float) * 1440.0,2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST((order_delivered_time - order_ready_for_pickup_time) AS float) * 1440.0) OVER (PARTITION BY delivery_service_level),2),
            ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST((order_delivered_time - order_ready_for_pickup_time) AS float) * 1440.0) OVER (), 2)
            ) AS mins_total_service,
        order_ready_for_pickup_time,
        order_pickup_done_time,
        order_delivered_time
    FROM [SLvsDistance])
    SELECT
        order_id,
        order_status_label,
        delivery_performance,
        rider_store_km,
        store_customer_km,
        total_dist_km,
        mins_taken_to_pickup,
        mins_taken_to_deliver_from_pickup,
        mins_total_service,
        COUNT(*) AS stage_0,
        COUNT(order_ready_for_pickup_time) AS stage_1,
        COUNT(order_pickup_done_time) AS stage_2,
        COUNT(order_delivered_time) AS stage_3
    FROM IS_SQL
    GROUP BY order_id,
        order_status_label,
        delivery_performance,
        rider_store_km,
        store_customer_km,
        total_dist_km,
        mins_taken_to_pickup,
        mins_taken_to_deliver_from_pickup,
        mins_total_service,
    ORDER BY stage_0 DESC, stage_1 DESC, stage_2 DESC, stage_3 DESC;
