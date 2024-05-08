/*CASE 1 ORDER_ANALYSIS
QUESTION 1
Check the order status on a monthly basis. Use order_approved_at for date data*/


Select (Date_Trunc('month',O.Order_Approved_At))::date As Payment_Month,
	Count(O.Order_Id) As Order_Count
From Payments As P
Join Orders As O On O.Order_Id = P.Order_Id
Where O.Order_Approved_At Is Not Null
Group By 1
Order By Payment_Month;

/* CASE 1 ORDER ANALYSIS
QUESTION 2 
Examine the order numbers in the order_ status breakdown on a monthly basis. Visualize the output of the query with Excel.
Are there months where there is a dramatic decline or rise? Examine and interpret the data*/

/*Order_Status Shipped olan : */

SELECT
    TO_CHAR(o.order_approved_at, 'YYYY-MM') AS payment_month,
    o.order_status,
    COUNT(p.order_id) AS order_count
FROM
    orders o
LEFT JOIN
    payments p ON o.order_id = p.order_id
WHERE
    o.order_status = 'shipped' AND
    o.order_approved_at IS NOT NULL
GROUP BY
    1, 2
ORDER BY
    1, 2;

/*Order_Status Canceled olan : */

SELECT
    TO_CHAR(o.order_approved_at, 'YYYY-MM') AS payment_month,
    o.order_status,
    COUNT(p.order_id) AS order_count
FROM
    orders o
LEFT JOIN
    payments p ON o.order_id = p.order_id
WHERE
    o.order_status = 'canceled' AND
    o.order_approved_at IS NOT NULL
GROUP BY
    1, 2
ORDER BY
    1, 2;

/* CASE 1 
QUESTION 3
 Examine the order numbers in the product category breakdown.
 What are the prominent categories on special days? For example, New Year's Eve, Valentine's Day...*/ 


SELECT DISTINCT P.PRODUCT_CATEGORY_NAME,
	T.CATEGORY_NAME_ENGLISH,
	COUNT(DISTINCT O.ORDER_ID) AS ORDER_COUNT
FROM ORDERS O
LEFT JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
LEFT JOIN TRANSLATION T ON T.CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN PAYMENTS PY ON O.ORDER_ID = PY.ORDER_ID
WHERE P.PRODUCT_CATEGORY_NAME IS NOT NULL
GROUP BY 1,2
ORDER BY ORDER_COUNT DESC

/* Special Days: New Year's Eve, Valentine's Day, Black Friday, Christmas, etc.*/

SELECT 
	P.PRODUCT_CATEGORY_NAME,
	T.CATEGORY_NAME_ENGLISH,
	SUM(CASE WHEN O.ORDER_PURCHASE_TIMESTAMP::date  = '2017-11-24' THEN 1 ELSE 0 END) AS Black_Friday,
	SUM(CASE WHEN O.ORDER_DELIVERED_CUSTOMER_DATE BETWEEN '2017-02-07' AND '2017-02-14' THEN 1 ELSE 0 END) AS Valenties_Day_2017,
	SUM(CASE WHEN O.ORDER_DELIVERED_CUSTOMER_DATE BETWEEN '2018-02-07' AND '2018-02-14' THEN 1 ELSE 0 END) AS Valenties_Day_2018,
	SUM(CASE WHEN O.ORDER_DELIVERED_CUSTOMER_DATE BETWEEN '2017-12-25' AND '2018-01-01' THEN 1 ELSE 0 END) AS New_Year
FROM ORDERS O
LEFT JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
LEFT JOIN TRANSLATION T ON T.CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN PAYMENTS PY ON O.ORDER_ID = PY.ORDER_ID
GROUP BY 1,2
ORDER BY Black_Friday,valenties_day_2017,valenties_day_2018,new_year DESC


/*CASE 1 
QUESTION 4
Examine the order numbers on the basis of days of the week (Monday, Thursday, ....) and month days (such as the 1st, 2nd of the month).
Create a visual in Excel with the output of the query you wrote and interpret the data.*/


/*Days of the week: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday*/

SELECT 
    DISTINCT (TO_CHAR(ORDER_PURCHASE_TIMESTAMP,'DAY')) AS day_of_week,
    COUNT(DISTINCT order_id) AS order_count
FROM 
    orders
GROUP BY day_of_week
ORDER BY ORDER_COUNT DESC

/*Month days: 1st, 2nd, 3rd, 4th, 5th, 6th, 7th, 8th, 9th, 10th, 11th, 12th, 13th, 14th, 15th, 16th, 17th, 18th, 19th, 20th, 21st, 22nd, 23rd, 24th, 25th, 26th, 27th, 28th, 29th, 30th, 31st*/

SELECT DISTINCT (TO_CHAR(ORDER_PURCHASE_TIMESTAMP,'DAY')) AS DAYOFWEEK,
	   COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT
FROM ORDERS
GROUP BY DAYOFWEEK
ORDER BY ORDER_COUNT DESC;



 /*
Case 2 : CUSTOMER ANALYSIS
Question 1 : 
-In which cities do customers shop more?
Determine the customer's city as the city from which they place the most orders and perform the analysis accordingly.



For example; Sibel places orders from 3 different cities: 3 from Çanakkale, 8 from Muğla and 10 from Istanbul.
You should select Sibel's city as Istanbul, which is the city she orders the most, and
Sibel's orders should appear as 21 orders from Istanbul.*/


WITH CUSTOMER_ORDER_COUNT AS
	(SELECT C.CUSTOMER_UNIQUE_ID,
			C.CUSTOMER_CITY,
			COUNT(O.ORDER_ID) AS ORDER_COUNT
		FROM CUSTOMERS C
		JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
		GROUP BY C.CUSTOMER_UNIQUE_ID,
			C.CUSTOMER_CITY)
SELECT C.CUSTOMER_CITY AS MOST_ORDERS_CITY,
	COUNT(C.ORDER_COUNT) AS ORDER_COUNT
FROM CUSTOMER_ORDER_COUNT C
JOIN
	(SELECT CUSTOMER_UNIQUE_ID,
			CUSTOMER_CITY,
			ORDER_COUNT
		FROM CUSTOMER_ORDER_COUNT
		WHERE (CUSTOMER_UNIQUE_ID,
										ORDER_COUNT,
										CUSTOMER_CITY) IN
				(SELECT CUSTOMER_UNIQUE_ID,
						MAX(ORDER_COUNT) AS MAX_ORDER_COUNT,
						CUSTOMER_CITY
					FROM CUSTOMER_ORDER_COUNT
					GROUP BY CUSTOMER_UNIQUE_ID,
						CUSTOMER_CITY) ) MAX_ORDER_CITIES ON C.CUSTOMER_UNIQUE_ID = MAX_ORDER_CITIES.CUSTOMER_UNIQUE_ID
AND C.CUSTOMER_CITY = MAX_ORDER_CITIES.CUSTOMER_CITY
AND C.ORDER_COUNT = MAX_ORDER_CITIES.ORDER_COUNT
GROUP BY C.CUSTOMER_CITY
ORDER BY ORDER_COUNT DESC;

/*
Case 3: SELLER ANALYSIS
Question 1 : 
-Who are the sellers who deliver orders to customers in the fastest way? Bring top 5.
Examine and comment on the order numbers of these sellers and the comments and ratings on their products.
*/

/* All of the fastest sellers in this query have sold only once.So the fastest sellers are the new ones
But with only one order so. It's not a very meaningfull data*/

SELECT
    s.seller_id,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS avg_delivery_time,
    COUNT(o.order_id) AS order_count,
    ROUND(AVG(COALESCE(r.review_score, 0)), 2) AS avg_review_score,
    COUNT(r.review_id) AS comment_count
FROM sellers s
LEFT JOIN order_items AS oi ON s.seller_id = oi.seller_id
LEFT JOIN orders AS o ON o.order_id = oi.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_id
ORDER BY avg_delivery_time
LIMIT 5;


/* In this query, the top 5 sellers who have sold more than the average number of orders and delivered the fastest
has been brought A bit more meaningful data.*/ 


SELECT
    s.seller_id,
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS avg_delivery_time,
    COUNT(o.order_id) AS order_count,
    ROUND(AVG(COALESCE(r.review_score, 0)), 2) AS avg_review_score,
    COUNT(r.review_id) AS comment_count
FROM sellers s
LEFT JOIN order_items AS oi ON s.seller_id = oi.seller_id
LEFT JOIN orders AS o ON o.order_id = oi.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_id
HAVING COUNT(DISTINCT O.ORDER_ID) >
	(SELECT COUNT(DISTINCT O.ORDER_ID) / COUNT(DISTINCT S.SELLER_ID)
		FROM ORDERS O
		JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
		JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID)
ORDER BY AVG_DELIVERY_TIME ASC,
	ORDER_COUNT DESC
LIMIT 5;


/*
Case 3
Question 2 : 
-Which sellers sell products from more categories?
 Do sellers with many categories also have a high number of orders?
*/


SELECT S.SELLER_ID,
	COUNT(DISTINCT P.PRODUCT_CATEGORY_NAME) AS CATEGORY_COUNT,
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM SELLERS S
LEFT JOIN ORDER_ITEMS OI ON S.SELLER_ID = OI.SELLER_ID
LEFT JOIN ORDERS O ON O.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE P.PRODUCT_CATEGORY_NAME IS NOT NULL
GROUP BY S.SELLER_ID
ORDER BY 2 DESC, 3 DESC


/*
Case 4 : Payment Analysis
Question 1 : 
Which region do the users with the highest number of installments live in? Interpret this output.
*/

SELECT 
    C.CUSTOMER_STATE,
    AVG(P.PAYMENT_INSTALLMENTS) AS TOTAL_INSTALLMENTS
FROM 
    CUSTOMERS AS C
JOIN 
    ORDERS AS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
JOIN 
    PAYMENTS AS P ON O.ORDER_ID = P.ORDER_ID
WHERE 
    P.PAYMENT_INSTALLMENTS > 1
GROUP BY 
    C.CUSTOMER_STATE
ORDER BY 
    TOTAL_INSTALLMENTS DESC;

/*
Case 4 
Question 2 : 
Calculate the number of successful orders and total successful payment amount according to payment type.
Rank them in order from the most used payment type to the least. */

SELECT P.PAYMENT_TYPE,
	   COUNT(DISTINCT O.ORDER_ID) AS SUCCESFUL_ORDER_COUNT,
	   SUM(P.PAYMENT_VALUE)::integer AS TOTAL_PAYMENT
FROM PAYMENTS P
LEFT JOIN ORDERS O ON P.ORDER_ID = O.ORDER_ID
AND O.ORDER_STATUS = 'delivered'
GROUP BY 1
ORDER BY SUCCESFUL_ORDER_COUNT DESC

/*
Case 4 
Question 3 : 
-Make a category-based analysis of orders paid in one shot and in installments.
In which categories is payment in installments used most?
*/

/*Payment in one shot*/

SELECT 
    PR.PRODUCT_CATEGORY_NAME,
    T.CATEGORY_NAME_ENGLISH,
    COUNT(DISTINCT O.ORDER_ID) AS ORDER_COUNT
FROM 
    PRODUCTS PR
LEFT JOIN 
    ORDER_ITEMS OI ON PR.PRODUCT_ID = OI.PRODUCT_ID
JOIN 
    ORDERS O ON O.ORDER_ID = OI.ORDER_ID
JOIN 
    PAYMENTS P ON P.ORDER_ID = O.ORDER_ID AND P.PAYMENT_INSTALLMENTS = 1
JOIN 
    TRANSLATION T ON T.CATEGORY_NAME = PR.PRODUCT_CATEGORY_NAME
AND P.PAYMENT_INSTALLMENTS = 1
GROUP BY 
    PR.PRODUCT_CATEGORY_NAME, T.CATEGORY_NAME_ENGLISH
ORDER BY 
    ORDER_COUNT DESC;

/*Payment in installments*/

SELECT 
    PR.PRODUCT_CATEGORY_NAME,
    T.CATEGORY_NAME_ENGLISH,
    COUNT(DISTINCT O.ORDER_ID) AS ORDER_COUNT
FROM 
    PRODUCTS PR
LEFT JOIN 
    ORDER_ITEMS OI ON PR.PRODUCT_ID = OI.PRODUCT_ID
JOIN 
    ORDERS O ON O.ORDER_ID = OI.ORDER_ID
JOIN 
    PAYMENTS P ON P.ORDER_ID = O.ORDER_ID AND P.PAYMENT_INSTALLMENTS = 1
JOIN 
    TRANSLATION T ON T.CATEGORY_NAME = PR.PRODUCT_CATEGORY_NAME
AND P.PAYMENT_INSTALLMENTS = 1
GROUP BY 
    PR.PRODUCT_CATEGORY_NAME, T.CATEGORY_NAME_ENGLISH
ORDER BY 
    ORDER_COUNT DESC;
