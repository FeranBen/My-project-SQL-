Create Database [Kultra_Mega_Stores_Inventory_DB]

----import CSV files into KMS_db------

---CSV Table 1. [dbo].[KMS Sql Case Study]
---CSV table 2. [dbo].[Order_Status]

select * from [KMS sql case study]


------JOIN TABLES------ AND CREATING VIEW-------

Create view KMSORDER
		AS
SELECT [KMS Sql Case Study].ORDER_ID,
       [KMS Sql Case Study].Order_Quantity,
	   [KMS Sql Case Study].Unit_Price,
	   [KMS Sql Case Study].Discount,
	   [KMS Sql Case Study].Product_Base_Margin,
        [KMS Sql Case Study].Order_Date,
		[KMS Sql Case Study].Ship_Date,
		[KMS Sql Case Study].Customer_Name,
		[KMS Sql Case Study].Customer_Segment,
		[KMS Sql Case Study].Province,
		[KMS Sql Case Study].Region,
		[KMS Sql Case Study].Order_Priority,
		[KMS Sql Case Study].Sales,
		[KMS Sql Case Study].Profit,
		[KMS Sql Case Study].Ship_Mode,
		[KMS Sql Case Study].Shipping_Cost,
	    [KMS Sql Case Study].Product_Container,
		[KMS Sql Case Study].Product_Category,
		[KMS Sql Case Study].Product_Sub_Category,
		[KMS Sql Case Study].Product_Name,
		Order_Status.Status
		from [KMS Sql Case Study]
		JOIN Order_Status
		ON Order_Status.Order_Id=[KMS Sql Case Study].Order_ID


-----Select View------
SELECT * FROM KMSORDER

------Update View------

UPDATE [dbo].KMSORDER
SET [Product_Base_Margin] = COALESCE([Product_Base_Margin], 0.00)
WHERE [Product_Base_Margin] IS NULL


----Question 1: Which product category had the highest sales?


select top 1 Product_Category,
sum(sales) As total_sales
from  [dbo].KMSORDER
GROUP BY Product_Category
ORDER BY total_sales DESC

-----ANSWER: Product Category  with the highest sales is = (Technology) ---  total Sales = $605,426.04


------------------------------------------------------------------------------------------------------


----Question 2: What are the top 3 and bottom 3 regions in terms of sales------

--Top 3

Select top 3 Region,
sum(sales) As Total_sales
from KMSORDER
group by region
order by total_sales desc

---ANSWER: Top 3 Regions in term of sales; Ontario = $471,161.63 / West = $375,122.37 / Prarie = $296,732.24 
      -------------------------------

 --Bottom 3

SELECT top 3 Region,
MIN(SALES) AS Total_sales
from [dbo].KMSORDER
group by region
order by total_sales Asc

---ANSWER: Top b0ttom 3 Regions in term of sales; Ontario = $4.94, West = $5.06, Prarie $5.63
-----------------------------------------------------------------------------------------------


----Question 3: What were the total sales of appliances in Ontario?


SELECT Region,
    SUM(Sales) AS Total_Sales
FROM [dbo].KMSORDER
WHERE Region = 'Ontario'
  And Product_Sub_Category = 'appliances'
Group By Region

---ANSWER: = Total Sales of Appliances in Ontario is = $17,648.37


-----Select View------
SELECT * FROM KMSORDER

----- Question 4: Advise the management of KMS on what to do to increase the revenue from the bottom 10 customer.


Select Top 10
      Customer_Name,
	  Sum(Sales) As Total_Revenue
From [dbo].[KMSORDER]
Group by Customer_Name
Order by Total_Revenue Asc

--------- BOTTOM 10 CUSTOMERS-----------------------
--Customer Name          Total Revenue

--John Grady       =     $5.06
--Frank Atkinson   =     $10.48
--Sean Wendt       =     $12.80
--Sandra Glassco   =     $16.24
--Katherine Hughes =     $17.77 
--Bobby Elias      =     $22.56
--Noel Staavos     =     $24.91
--Thomas Boland    =     $28.01
--Brad Eason       =     $35.17
--Theresa Swint    =     $38.51
-------------------------------------------------------------

---ANSWER: MY ADVISE TO THE MANAGEMENT OF KMS IN ORDER TO INCREASE THE REVENUE FROM THE BOTTOM 10 CUSTOMERS......................
------- a- Identify the ten customers with the lowest total sales.
--------b- Analyze their buying behaviour and feedback.
--------c- Provide Personalized promotions or loyalty rewards.
--------d- Assign dedicated account managers or support staff to enchace engagement.
--------e- Suggest additional or complementary products to increase their purchase.
--------f- Enchance delivery speed and customer service experience.

-----Select View------
SELECT * FROM KMSORDER

---Question 5: KMS incurred the most shipping cost using which shipping method?

Select Top 1
      Order_Priority, Ship_Mode,
	  Sum(Shipping_Cost) As Total_Cost
From [dbo].KMSORDER
Group by Order_Priority, Ship_Mode
Order by Total_Cost Desc

---ANSWER: KMS incurred the most shipping cost using delivery truck which Cost = $1,659.14
---------------------------------------------------------------

------Question 6: Who are the most valuable customers, and what products or services do they typically purchase?


WITH CustomerRevenue AS (
    SELECT
        Customer_Name,
        Customer_Segment,
        SUM(Sales) AS Total_Revenue
    FROM [dbo].KMSORDER
    GROUP BY Customer_Name, Customer_Segment
),
CustomerProductRevenue AS (
    SELECT 
        Customer_Name,
        Product_Name,
		Order_Quantity,
        SUM(Sales) AS Product_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY Customer_Name 
            ORDER BY SUM(Sales) DESC, Product_Name DESC
        ) AS Product_Rank
    FROM [dbo].KMSORDER
    GROUP BY Customer_Name, Product_Name, Order_Quantity
)
SELECT TOP 5
    cr.Customer_Name,
    cr.Customer_Segment,
    cpr.Product_Name AS Top_Product,
	cpr.Order_Quantity,
    cr.Total_Revenue
FROM CustomerRevenue cr
JOIN CustomerProductRevenue cpr 
    ON cr.Customer_Name = cpr.Customer_Name 
    AND cpr.Product_Rank = 1
ORDER BY cr.Total_Revenue DESC
 
----ANSWER:The most valuable customers and the  products or services they purchase are listef below:S

------Customer_Name       Customer_Segment     Top_Product                                                                  Total_Revenue                         

---1---John Lucas          Small Business      Chromcraft Bull-Nose Wood 48" x 96" Rectangular Conference Tables             $37,919.43
---2---Lycoris Saunders    Corporate           Bretford CR8500 Series Meeting Room Furniture                                 $30,948.18
---3---Grant Carroll       Small Business      Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind   $26,485.12
---4---Erin Creighton      Corporate           Polycom VoiceStation 100                                                      $26,443.02
---5---Peter Fuller        Corporate           Panasonic KX-P3626 Dot Matrix Printer                                         $26,382.21
---------------------------------------------------------------------------

-----Select View------
SELECT * FROM KMSORDER

---Question 7: Which (Small business customer) had the highest sales?

WITH CustomerRevenue AS (
    SELECT 
        Customer_Name,
        Customer_Segment,
        SUM(Sales) AS Total_Revenue
    FROM [dbo].KMSORDER
	Where Customer_Segment = 'Small Business'
    GROUP BY Customer_Name, Customer_Segment
),
CustomerProductRevenue AS (
    SELECT 
        Customer_Name,
        Product_Name,
		Order_Quantity,
        SUM(Sales) AS Product_Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY Customer_Name 
            ORDER BY SUM(Sales) DESC, Product_Name DESC
        ) AS Product_Rank
    FROM [dbo].KMSORDER
    GROUP BY Customer_Name, Product_Name, Order_Quantity
)
SELECT TOP 1
    cr.Customer_Name,
    cr.Customer_Segment,
    cpr.Product_Name AS Top_Product,
	cpr.Order_Quantity,
    cr.Total_Revenue
FROM CustomerRevenue cr
JOIN CustomerProductRevenue cpr 
    ON cr.Customer_Name = cpr.Customer_Name 
    AND cpr.Product_Rank = 1
ORDER BY cr.Total_Revenue DESC

--ANSWER: The Small business customer  with the highest sales is John Lucas with the total revenue  = $37,919.43
-------------------------------------------------------------------------------------

-----Select View------
SELECT * FROM KMSORDER

----Question 8: Which (Corporate Customer) placed the most (number of orders) in (2009 – 2012)


SELECT TOP 1
   Customer_Segment, Customer_Name,
    SUM(Order_Quantity) AS Total_Orders
FROM [dbo].KMSORDER
WHERE Customer_Segment = 'Corporate'
    AND Ship_Date BETWEEN '2009-01-01' AND '2012-12-31'
GROUP BY Customer_Segment, Customer_Name
ORDER BY Total_Orders DESC

---ANSWER: The corporate customer with the most placed number of order in 2009 - 2012 Is: Erin Creighton, total orders = 261
------------------------------------------------------------------------------

---Question 9: Which (Consumer customer) was the (most profitable one)?

SELECT TOP 1
    Customer_Segment, Customer_Name,
    SUM(Sales) AS Total_Revenue
FROM [dbo].KMSORDER
WHERE Customer_Segment = 'Consumer'
GROUP BY Customer_Segment, Customer_Name
ORDER BY Total_Revenue Desc

------ANSWER: The Consumer customer with the most profitable one is Darren Budd = $23,034.35

-----Select View------
SELECT * FROM KMSORDER

----Question 10: Which customer returned items? And what segment do they belong to?

SELECT TOP 572
   Customer_Name, Customer_Segment,
    max([Status]) AS Total_Returned_Items
FROM [dbo].KMSORDER
GROUP BY Customer_Segment, Customer_Name, [Status]
ORDER BY Total_Returned_Items Desc

--Answer: All Customers returned their items according to their Segment
---------------------------------------------------------------------------------------------------------

-----Select View------
SELECT * FROM KMSORDER

-----Question 11....

---If the delivery truck is the most economical but the slowest shipping method and 
---Express Air is the fastest but the most expensive one, do you think the company 
---appropriately spent shipping costs based on the Order Priority? (Explain your answer)


-----Select View------
Select * From KMSORDER


SELECT  
    Order_Priority,  
    Ship_Mode,  
    SUM(Shipping_Cost) AS Total_Cost  
FROM [dbo].KMSORDER 
WHERE Ship_Mode IN ('Express Air', 'Delivery Truck')  
GROUP BY Order_Priority, Ship_Mode  
ORDER BY Ship_Mode, Total_Cost DESC

----Answer: Based on Order Priority				Ship Mode					Total Cost

-----		Low									Delivery Truck				$1,659.14
-----		High								Delivery Truck				$1,274.98
-----		Not	Specified						Delivery Truck				$1,040.76
-----		Medium								Delivery Truck				$925.25
-----		Critical							Delivery Truck				$829.01
-----		Low									Express Air					$289.95
-----		Not	Specified						Express Air					$257.40
-----		Critical							Express Air					$195.19
-----		Medium								Express Air					$167.27
-----		High								Express Air					$108.92

------Was shipping cost appropriately spent based on Order Priority?

----a- Appropriate spending involves aligning high-priority orders with fast shipping options like Express Air and using cost-effective methods suchs as delivery tracks for low-priority orders.
----b- If there are mismatches such as urgent items being shipped by delivery truck-the spendimg is considered inefficient or inappropriate. 
----c- A through audit of the data would verify that everything os properly aligned.
