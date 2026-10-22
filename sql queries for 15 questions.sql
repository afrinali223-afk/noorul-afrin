
USE food_delivery_analysis;

SELECT COUNT(*) AS total_orders
FROM food_orders;

SELECT *
FROM food_orders
LIMIT 5;



USE food_delivery_analysis;

-- =====================================================
-- CUSTOMER & ORDER ANALYSIS
-- =====================================================

-- QUESTION 1: Identify Top-Spending Customers
SELECT
    Customer_ID,
    COUNT(*) AS total_orders,
    ROUND(SUM(Order_Value), 2) AS total_spending,
    ROUND(AVG(Order_Value), 2) AS average_order_value
FROM food_orders
WHERE Order_Status = 'Delivered'
GROUP BY Customer_ID
ORDER BY total_spending DESC
LIMIT 10;


-- QUESTION 2: Analyze Age Group vs Order Value
SELECT
    Customer_Age_Group,
    COUNT(*) AS total_orders,
    ROUND(AVG(Order_Value), 2) AS average_order_value,
    ROUND(SUM(Order_Value), 2) AS total_order_value
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND Customer_Age_Group IS NOT NULL
GROUP BY Customer_Age_Group
ORDER BY average_order_value DESC;


-- QUESTION 3: Weekend vs Weekday Order Patterns
SELECT
    Is_Weekend,
    COUNT(*) AS total_orders,
    ROUND(AVG(Order_Value), 2) AS average_order_value,
    ROUND(SUM(Order_Value), 2) AS total_order_value
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND Is_Weekend IS NOT NULL
GROUP BY Is_Weekend
ORDER BY Is_Weekend;


-- =====================================================
-- REVENUE & PROFIT ANALYSIS
-- =====================================================

-- QUESTION 4: Monthly Revenue Trends
SELECT
    Order_Year,
    Order_Month,
    COUNT(*) AS delivered_orders,
    ROUND(SUM(Order_Value), 2) AS total_order_value,
    ROUND(SUM(Final_Amount), 2) AS recorded_final_revenue,
    SUM(Final_Amount IS NULL) AS missing_final_amount_count
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND Order_Year IS NOT NULL
  AND Order_Month IS NOT NULL
GROUP BY Order_Year, Order_Month
ORDER BY Order_Year, Order_Month;


-- QUESTION 5: Impact of Discounts on Profit
SELECT
    Discount_Category,
    COUNT(*) AS total_orders,
    ROUND(AVG(Discount_Applied), 2) AS average_discount,
    ROUND(AVG(Order_Value), 2) AS average_order_value,
    ROUND(AVG(Profit_Margin), 4) AS average_profit_margin,
    ROUND(AVG(Discount_Percentage), 2) AS average_discount_percentage
FROM food_orders
WHERE Order_Status = 'Delivered'
GROUP BY Discount_Category
ORDER BY average_discount_percentage;


-- QUESTION 6: High-Revenue Cities and Cuisines
SELECT
    'City' AS analysis_type,
    City AS category,
    COUNT(*) AS delivered_orders,
    ROUND(SUM(Order_Value), 2) AS total_order_value
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND City IS NOT NULL
GROUP BY City

UNION ALL

SELECT
    'Cuisine' AS analysis_type,
    Cuisine_Type AS category,
    COUNT(*) AS delivered_orders,
    ROUND(SUM(Order_Value), 2) AS total_order_value
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND Cuisine_Type IS NOT NULL
GROUP BY Cuisine_Type
ORDER BY analysis_type, total_order_value DESC;


-- =====================================================
-- DELIVERY PERFORMANCE
-- =====================================================

-- QUESTION 7: Average Delivery Time by City
SELECT
    City,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(Delivery_Time_Min), 2) AS average_delivery_minutes,
    ROUND(MIN(Delivery_Time_Min), 2) AS minimum_delivery_minutes,
    ROUND(MAX(Delivery_Time_Min), 2) AS maximum_delivery_minutes
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND City IS NOT NULL
  AND Delivery_Time_Min IS NOT NULL
GROUP BY City
ORDER BY average_delivery_minutes;


-- QUESTION 8: Distance vs Delivery Delay Analysis
SELECT
    Distance_Category,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(Distance_km), 2) AS average_distance_km,
    ROUND(AVG(Delivery_Time_Min), 2) AS average_delivery_minutes
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND Distance_Category IS NOT NULL
  AND Distance_km IS NOT NULL
  AND Delivery_Time_Min IS NOT NULL
GROUP BY Distance_Category
ORDER BY average_distance_km;


-- QUESTION 9: Delivery Rating vs Delivery Time
SELECT
    Delivery_Rating,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(Delivery_Time_Min), 2) AS average_delivery_minutes,
    ROUND(AVG(Distance_km), 2) AS average_distance_km
FROM food_orders
WHERE Order_Status = 'Delivered'
  AND Delivery_Rating IS NOT NULL
GROUP BY Delivery_Rating
ORDER BY Delivery_Rating DESC;


-- =====================================================
-- RESTAURANT PERFORMANCE
-- =====================================================

-- QUESTION 10: Top-Rated Restaurants

USE food_delivery_analysis;


SELECT
    Restaurant_Name,
    AVG(Restaurant_Rating) AS avg_rating,
    COUNT(*) AS total_orders
FROM food_orders
WHERE Order_Status = 'Delivered'
GROUP BY Restaurant_Name
ORDER BY avg_rating DESC
LIMIT 10;

-- QUESTION 11: Cancellation Rate by Restaurant

SELECT
    Restaurant_Name,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN Order_Status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_orders,
    ROUND(
        100.0 * SUM(CASE
            WHEN Order_Status = 'Cancelled' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM food_orders
GROUP BY Restaurant_Name
ORDER BY cancellation_rate_pct DESC
LIMIT 10;


-- QUESTION 12: Cuisine-Wise Performance
SELECT
    Cuisine_Type,
    COUNT(*) AS total_orders,
    SUM(Order_Status = 'Delivered') AS delivered_orders,
    SUM(Order_Status = 'Cancelled') AS cancelled_orders,
    ROUND(
        100.0 * SUM(Order_Status = 'Delivered') / COUNT(*),
        2
    ) AS delivery_success_percentage,
    ROUND(AVG(Order_Value), 2) AS average_order_value,
    ROUND(AVG(Restaurant_Rating), 2) AS average_restaurant_rating
FROM food_orders
WHERE Cuisine_Type IS NOT NULL
GROUP BY Cuisine_Type
ORDER BY delivered_orders DESC;


-- =====================================================
-- OPERATIONAL INSIGHTS
-- =====================================================

-- QUESTION 13: Peak Hour Demand Analysis


SELECT
    Peak_Hour,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN Order_Status = 'Delivered' THEN 1
        ELSE 0
    END) AS delivered_orders,
    SUM(CASE
        WHEN Order_Status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_orders
FROM food_orders
WHERE Peak_Hour IS NOT NULL
GROUP BY Peak_Hour
ORDER BY total_orders DESC;

-- QUESTION 14: Payment Mode Preferences
SELECT
    Payment_Mode,
    COUNT(*) AS total_orders,
    SUM(Order_Status = 'Delivered') AS delivered_orders,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM food_orders
         WHERE Payment_Mode IS NOT NULL),
        2
    ) AS percentage_of_orders
FROM food_orders
WHERE Payment_Mode IS NOT NULL
GROUP BY Payment_Mode
ORDER BY total_orders DESC;


-- QUESTION 15: Cancellation Reason Analysis
SELECT
    Cancellation_Reason,
    COUNT(*) AS cancelled_orders,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM food_orders
         WHERE Order_Status = 'Cancelled'),
        2
    ) AS percentage_of_all_cancelled_orders
FROM food_orders
WHERE Order_Status = 'Cancelled'
GROUP BY Cancellation_Reason
ORDER BY cancelled_orders DESC;


