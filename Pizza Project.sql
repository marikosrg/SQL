-- What is the Total Revenue? 

SELECT SUM(total_price) AS Total_Revenue
FROM pizza_sales



-- What is the Average Order Value?

SELECT SUM(total_price)/COUNT(DISTINCT order_id) AS AVG_Order_Value
FROM pizza_sales



-- What is the total pizza sold?

SELECT SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales



--What is the total number of orders?

SELECT COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales

--What is the average pizzas per order?

SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2))/
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS Average_Pizzas_Per_Order
FROM pizza_sales


-- Daily Trend for Orders

SELECT DATENAME(DW, order_date) AS Order_Day,
COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY DATENAME(DW, order_date)

-- Hourly Trend for Orders

SELECT DATEPART(HOUR, order_time) AS Hourly_Orders,
COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time)


-- % of Sales by Pizza Category (January)

SELECT pizza_category,
SUM(total_price) AS Total_Sales,
SUM(total_price)*100 /(SELECT SUM(total_price) FROM pizza_sales WHERE MONTH(order_date) = 1) AS Percent_Total_Sales
FROM pizza_sales
WHERE MONTH(order_date) = 1
GROUP BY pizza_category


-- % of Sales by Pizza Size (first quarter)

SELECT pizza_size,
CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Sales,
CAST(SUM(total_price)*100 /(SELECT SUM(total_price) FROM pizza_sales WHERE DATEPART(quarter, order_date)=1) AS DECIMAL(10,2)) AS Percent_Total_Sales
FROM pizza_sales
WHERE DATEPART(quarter, order_date)=1
GROUP BY pizza_size
ORDER BY Percent_Total_Sales DESC


-- Total Pizzas Sold by Pizza Category

SELECT pizza_category,
SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_category


-- Top 5 best Sellers by Total Pizzas Sold

SELECT TOP 5 pizza_name,
SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizzas_Sold DESC


-- Bottom 5 Best Sellers by Total Pizzas Sold

SELECT TOP 5 pizza_name,
SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizzas_Sold ASC
