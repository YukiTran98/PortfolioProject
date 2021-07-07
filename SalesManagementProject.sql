USE MyProject

--Create Foreign Key for tables in database
ALTER TABLE	dbo.AdventureWorksSales ADD CONSTRAINT fk_sal_cus FOREIGN KEY(CustomerKey) REFERENCES dbo.AdventureWorksCustomers(CustomerKey)
ALTER TABLE	dbo.AdventureWorksSales ADD CONSTRAINT fk_sal_pro FOREIGN KEY(ProductKey) REFERENCES dbo.AdventureWorksProducts(ProductKey)
ALTER TABLE	dbo.AdventureWorksSales ADD CONSTRAINT fk_sal_ter FOREIGN KEY(TerritoryKey) REFERENCES dbo.AdventureWorksTerritories(SalesTerritoryKey)
ALTER TABLE	dbo.AdventureWorksSales ADD CONSTRAINT fk_sal_date FOREIGN KEY(OrderDate) REFERENCES dbo.AdventureWorksCalendar(Date)
ALTER TABLE	dbo.AdventureWorksProducts ADD CONSTRAINT fk_pro_sub FOREIGN KEY(ProductSubcategoryKey) REFERENCES dbo.AdventureWorksProductSubcategor(ProductSubcategoryKey)
ALTER TABLE	dbo.AdventureWorksProductSubcategor ADD CONSTRAINT fk_sub_cat FOREIGN KEY(ProductCategoryKey) REFERENCES dbo.AdventureWorksProductCategorie(ProductCategoryKey)

-- Q1: How many products are sold?
SELECT COUNT(*) FROM dbo.AdventureWorksProducts

-- Q2: How many customer do we have?
SELECT COUNT(*) FROM dbo.AdventureWorksCustomers

-- Q3: looking at country we sold the product
SELECT DISTINCT(Country) FROM dbo.AdventureWorksTerritories

-- Q4: Total Amount
--with quantity at Sales table, and price at Product table
SELECT SUM(s.OrderQuantity*p.ProductPrice) 
FROM dbo.AdventureWorksSales s
INNER JOIN dbo.AdventureWorksProducts p
ON p.ProductKey = s.ProductKey

--Q5: Top spenders for products by gender
SELECT * FROM 
(SELECT TOP 10 c.CustomerKey,c.Gender,CONCAT(c.FirstName,' ',c.LastName) AS Name, SUM(s.OrderQuantity*p.ProductPrice) AS per_amount
FROM dbo.AdventureWorksCustomers c
INNER JOIN dbo.AdventureWorksSales s
ON s.CustomerKey = c.CustomerKey
INNER JOIN dbo.AdventureWorksProducts p
ON p.ProductKey = s.ProductKey
GROUP BY c.CustomerKey,c.Gender,c.FirstName,c.LastName
ORDER BY  per_amount DESC) t
ORDER BY t.Gender DESC,t.per_amount DESC 

--Q6: TOP 10 products by quantity
SELECT s.ProductKey,p.ProductName,SUM(s.OrderQuantity) AS num_sold
FROM dbo.AdventureWorksSales s
INNER JOIN dbo.AdventureWorksProducts p
ON p.ProductKey = s.ProductKey
GROUP BY s.ProductKey,p.ProductName

--Q7: Classification of customer groups
SELECT c.Occupation, COUNT(*) AS Number FROM dbo.AdventureWorksCustomers c
GROUP BY c.Occupation

--Q8: Number of products sold of each type of sub-catergory, catergory
SELECT pc.CategoryName,ps.SubcategoryName,SUM(s.OrderQuantity) AS Num
FROM dbo.AdventureWorksSales s
INNER JOIN dbo.AdventureWorksProducts p
ON p.ProductKey = s.ProductKey
INNER JOIN dbo.AdventureWorksProductSubcategor ps
ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
INNER JOIN dbo.AdventureWorksProductCategorie pc
ON pc.ProductCategoryKey = ps.ProductCategoryKey
GROUP BY pc.CategoryName,ps.SubcategoryName
ORDER BY pc.CategoryName, ps.SubcategoryName

--Q9: Sales Growth by year
WITH Year_sales (Year,Total_Sales) AS ( 
SELECT t.Year,SUM(t.Amount) FROM 
	(SELECT YEAR(s.OrderDate) AS Year,(s.OrderQuantity*p.ProductPrice) AS Amount    
	FROM dbo.AdventureWorksSales s
	INNER JOIN dbo.AdventureWorksProducts p
	ON p.ProductKey = s.ProductKey) AS t
GROUP BY t.Year
)

SELECT Year,s.Total_Sales,
	   FORMAT((s.Total_Sales-LAG(s.Total_Sales) OVER(ORDER BY s.Year))/s.Total_Sales,'p') AS Growth_rate
FROM Year_sales s
ORDER BY s.Year

--Q10: Number of products sold in each country
SELECT ter.Country,SUM(s.OrderQuantity) AS Num
FROM dbo.AdventureWorksSales s
INNER JOIN dbo.AdventureWorksTerritories ter
ON s.TerritoryKey=ter.SalesTerritoryKey
GROUP BY ter.Country

--Q11: How many customers on the list have purchased?
SELECT (COUNT(DISTINCT(s.CustomerKey))*100/(SELECT COUNT(*) FROM dbo.AdventureWorksCustomers)) AS Percentage
FROM dbo.AdventureWorksSales s

--Q12: Top 10 Products with the highest selling price
SELECT TOP 10 ProductKey,ProductName,ProductPrice FROM dbo.AdventureWorksProducts
ORDER BY ProductPrice DESC

-- Q13: Customers tend to buy a lot of goods in which month of the year
SELECT t.Month,AVG(t.Quantity) AS avg_by_month 
FROM
	(SELECT MONTH(s.OrderDate) AS Month,
		   s.OrderQuantity AS Quantity 
	FROM dbo.AdventureWorksSales s) t
GROUP BY t.Month
ORDER BY avg_by_month DESC

SELECT COUNT(*) FROM dbo.AdventureWorksSales


--Q14: which color is more popular
SELECT p.ProductColor,SUM(s.OrderQuantity) AS Quantity FROM dbo.AdventureWorksSales s
INNER JOIN dbo.AdventureWorksProducts p
ON p.ProductKey = s.ProductKey
WHERE p.ProductColor!='NA'
GROUP BY p.ProductColor
ORDER BY Quantity DESC

--Q15: Ranking countries by revenue
WITH Country_Sales AS 
(SELECT ter.Country,SUM(s.OrderQuantity*p.ProductPrice) AS Total_Revenue FROM dbo.AdventureWorksSales s
INNER JOIN dbo.AdventureWorksTerritories ter
ON ter.SalesTerritoryKey = s.TerritoryKey
INNER JOIN dbo.AdventureWorksProducts p
ON p.ProductKey = s.ProductKey
GROUP BY ter.Country)

SELECT cs.Country,cs.Total_Revenue,
		RANK() OVER(ORDER BY cs.Total_Revenue DESC) AS Rank
FROM Country_Sales cs

