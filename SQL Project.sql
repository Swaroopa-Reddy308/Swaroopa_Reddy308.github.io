Create Database Hello;
Use Hello;

-- ********* Table — CUSTOMER ************

Create table Customer(Customer_ID Int, Customer_Name Varchar(40), City varchar(30), Join_Date Date);

Select * from Customer;
Desc Customer;

Insert into Customer Values
(101, 'Amit Sharma', 'Delhi', '2022-01-10'),
(102, 'Neha Verma', 'Mumbai', '2022-03-15'),
(103, 'Rahul Mehta', 'Bangalore', '2022-05-01'),
(104, 'Priya Singh', 'Delhi', '2023-01-12'),
(105, 'Karan Patel', 'Ahmedabad', '2023-02-20'),
(106, 'Sneha Reddy', 'Hyderabad', '2023-03-18'),
(107, 'Arjun Nair', 'Kochi', '2023-04-10'),
(108, 'Pooja Gupta', 'Jaipur', '2023-05-05');

Select * from Customer;

-- ********* Table — ORDERS ************

Create table Orders(Order_ID Int, Customer_ID Int, Order_Date Date, Employee_ID Int);

Select * from Orders;
Desc Orders;

Insert into Orders values
(301, 101, '2023-01-15', 401),
(302, 102, '2023-01-18', 402),
(303, 103, '2023-02-05', 401),
(304, 104, '2023-02-10', 403),
(305, 105, '2023-03-01', 404),
(306, 106, '2023-03-15', 402),
(307, 107, '2023-04-01', 401),
(308, 108, '2023-04-20', 403);

Select * from Orders;

-- ********* Table — PRODUCT ************

Create Table Product (Product_ID INT, Product_Name Varchar(30), Category Varchar(40), Price Decimal( 10,2));

Select * from Product;
Desc Product;

Insert into Product Values
    (201, 'Laptop', 'Electronics', 55000),
    (202, 'Mobile', 'Electronics', 25000),
    (203, 'Tablet', 'Electronics', 18000),
    (204, 'Headphones', 'Accessories', 2000),
    (205, 'Keyboard', 'Accessories', 1500),
    (206, 'Mouse', 'Accessories', 800),
    (207, 'Monitor', 'Electronics', 12000),
    (208, 'Printer', 'Electronics', 9000);

Select * from Product;

-- ************ Table — ORDER DETAILS ************

Create  Table OrderDetails(Order_Detail Int, Order_ID Int, Product_ID Int, Quantity Int);

Select * from OrderDetails;
Desc OrderDetails;

Insert into OrderDetails Values 
    (1, 301, 201, 1),
    (2, 301, 204, 2),
    (3, 302, 202, 1),
    (4, 303, 203, 1),
    (5, 304, 207, 2),
    (6, 305, 205, 3),
    (7, 306, 206, 5),
    (8, 307, 208, 1),
    (9, 308, 201, 1);
    
Select * from OrderDetails;

-- ************ Table — EMPLOYEE ************

Create Table Employee (Emp_ID Int, Emp_Name Varchar(30), Department Varchar(40), Hire_Date Date);

Select * from Employee;
Desc Employee;

Insert Into Employee Values(401, 'Rajesh Kumar', 'Sales', '2020-02-01'),
(402, 'Meena Iyer', 'Sales', '2021-06-15'),
(403, 'Vikram Shah', 'Sales', '2022-09-10'),
(404, 'Anil Gupta', 'Sales', '2023-01-05');

Select * from Employee;

-- ============================================================================
-- SECTION 1 — Joins (Basic to Intermediate)
-- ============================================================================


-- Question 1: Display all orders with customer names.
-- =====================================================
Select C.Customer_Name, O.Order_ID, O.Customer_ID From Customer C Join Orders O ON C.Customer_ID = O.Customer_ID;


-- Question 2: Show product names and quantities for each order.
-- ==============================================================
SELECT OD.Order_ID, P.Product_Name, OD.Quantity FROM OrderDetails OD
INNER JOIN Product P ON OD.Product_ID = P.Product_ID;


-- Question 3: Display employee name who handled each order.
-- =========================================================
Select O.Order_ID, E.Emp_Name from Orders O
Join Employee E on O.Employee_ID = E.Emp_ID;


-- Question 4: Show all customers and their orders (including customers without orders).
-- =====================================================================================
Select C.Customer_ID, C.Customer_Name, O.Order_ID, O.Order_Date from Customer C
Left Join Orders O on C.Customer_ID = O.Customer_ID;


-- Question 5: Display total number of orders handled by each employee.
-- ====================================================================
Select E.Emp_ID, E.Emp_Name, Count(O.Order_ID) as Total_Orders from Employee E
Left Join Orders O on E.Emp_ID = O.Employee_ID Group By E.Emp_ID, E.Emp_Name;



-- ============================================================================
-- SECTION 2 — SUB QUERIES
-- ============================================================================

-- Question 6: Find customers who placed more than 1 order.
-- =========================================================
SELECT C.Customer_ID, C.Customer_Name FROM Customer C
WHERE Customer_ID IN (SELECT Customer_ID FROM Orders GROUP BY Customer_ID HAVING COUNT(Order_ID) > 1);


-- Question 7: Display products with price higher than the average product price.
-- ==============================================================================
Select Product_ID, Product_Name, Price from Product where Price > (Select Avg(Price) from Product);


-- Question 8: Find the customer who placed the highest number of orders
-- =====================================================================
Select Customer_ID, Customer_Name from Customer 
where Customer_ID = (Select Customer_ID from Orders Group By Customer_ID Order By COUNT(Order_ID) Desc Limit 1);


-- Question 9: Show orders where total quantity is greater than the average quantity
-- ==================================================================================
Select Order_ID, SUM(Quantity) as Total_Quantity from OrderDetails Group By Order_ID having Sum(Quantity) > (Select Avg(OrderQty)
From (Select Sum(Quantity) AS OrderQty from OrderDetails Group By Order_ID) as T);


-- Question 10: Find employees who handled more orders than the average employee
-- ==============================================================================
Select E.Emp_ID, E.Emp_Name from Employee E Join Orders O on E.Emp_ID = O.Employee_ID
Group By E.Emp_ID, E.Emp_Name Having Count(o.Order_ID) > (Select Avg(Emp_Orders)
From (Select Count(Order_ID) AS Emp_Orders From Orders Group By Employee_ID) as T);



-- ============================================================================
-- SECTION 3 — WINDOW FUNCTIONS
-- ============================================================================

-- Question 11: Assign rank to customers based on total purchase amount
-- =====================================================================

-- Step 1: Create the View using an explicit CASE statement for zero-spending customers
Create View Customer_Spending as
Select 
    c.Customer_ID, 
    c.Customer_Name, 
    CASE 
        WHEN SUM(p.Price * od.Quantity) IS NULL THEN 0 
        ELSE SUM(p.Price * od.Quantity) END AS Total_Spent
FROM Customer c
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID
LEFT JOIN OrderDetails od ON o.Order_ID = od.Order_ID
LEFT JOIN Product p ON od.Product_ID = p.Product_ID
GROUP BY c.Customer_ID, c.Customer_Name;

-- Step 2: Query the View to assign customer ranks
SELECT 
    Customer_ID, 
    Customer_Name, 
    Total_Spent,
    RANK() OVER (ORDER BY Total_Spent DESC) AS Customer_Rank FROM Customer_Spending;


-- Question 12: Display cumulative sales amount by order date
-- ============================================================

-- Step 1: Create the View for daily total aggregates
Create View Daily_Sales_Summary AS
Select O.Order_Date, 
    SUM(P.Price * OD.Quantity) as Daily_Total
FROM Orders O 
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Product P ON OD.Product_ID = P.Product_ID 
Group By O.Order_Date;

-- Step 2: Query the View to calculate cumulative sales over time
Select 
    Order_Date, 
    Daily_Total, 
    SUM(Daily_Total) OVER (ORDER BY Order_Date) AS Cumulative_Sales 
FROM Daily_Sales_Summary;


-- Question 13: Display running total of sales for each employee
-- ===============================================================

-- Step 1: Create the View for individual order amounts per employee
Create View Employee_Order_Sales AS
Select 
    O.Order_ID, 
    O.Employee_ID, 
    O.Order_Date, 
    SUM(P.Price * OD.Quantity) AS Order_Amount From Orders O 
Join OrderDetails OD ON O.Order_ID = OD.Order_ID 
Join Product P ON OD.Product_ID = P.Product_ID
Group By O.Order_ID, O.Employee_ID, O.Order_Date;

-- Step 2: Query the View to calculate the running total
Select 
    Order_ID, 
    Employee_ID, 
    Order_Date, 
    Order_Amount, 
    SUM(Order_Amount) OVER (
        Partition by Employee_ID 
        Order By Order_Date, Order_ID) as Running_Total 
From Employee_Order_Sales;



-- Q14: Find the highest priced product in each category
-- =======================================================

-- Step 1: Create the View to rank products by category price
CREATE VIEW Category_Top_Products AS
WITH Ranked_Products AS (SELECT 
        Product_ID, 
        Product_Name, 
        Category, 
        Price,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Price DESC) AS Row_Num FROM Product)
SELECT 
    Product_ID, 
    Product_Name, 
    Category, 
    Price,
    Row_Num
FROM Ranked_Products;

-- Step 2: Query the View for the highest priced product in each category
SELECT 
    Product_ID, 
    Product_Name, 
    Category, 
    Price 
FROM Category_Top_Products WHERE Row_Num = 1;



-- ============================================================================
-- OPTIONAL ADVANCED BONUS TASKS
-- ============================================================================


-- Question 15: Find customers who never placed an order
-- ======================================================
SELECT C.Customer_ID, C.Customer_Name FROM Customer C
LEFT JOIN Orders O ON C.Customer_ID = O.Customer_ID WHERE O.Order_ID IS NULL;


-- Question 16: Find the second highest selling product (by total quantity sold)
-- ================================================================================

-- 1. Create a View for Product Sales Ranking
Create View Product_Sales_Rank AS
Select 
    P.Product_ID, 
    P.Product_Name, 
    P.Category,
    SUM(OD.Quantity) AS Total_Qty_Sold,
    DENSE_RANK() OVER (ORDER BY SUM(OD.Quantity) DESC) AS Rank_Num
From Product P 
Join OrderDetails OD ON P.Product_ID = OD.Product_ID
Group By P.Product_ID, P.Product_Name, P.Category;

-- 2. Query the View to get the 2nd Highest Selling Product
Select 
    Product_ID, 
    Product_Name, 
    Category,
    Total_Qty_Sold
From Product_Sales_Rank 
where Rank_Num = 2;


-- Question 17: Identify duplicate orders placed on the same day by the same customer
-- ===================================================================================
SELECT Customer_ID, Order_Date, COUNT(Order_ID) AS Order_Count FROM Orders
GROUP BY Customer_ID, Order_Date HAVING COUNT(Order_ID) > 1;


-- Question 18: Calculate monthly sales growth percentage
-- ==========================================================

-- 1. Create a View for Monthly Sales Totals
Create View Monthly_Sales AS Select DATE_FORMAT(o.Order_Date, '%Y-%m') AS Sales_Month,
SUM(P.Price * OD.Quantity) AS Total_Sales
FROM Orders O JOIN OrderDetails OD ON o.Order_ID = OD.Order_ID
JOIN Product P ON OD.Product_ID = P.Product_ID
GROUP BY DATE_FORMAT(O.Order_Date, '%Y-%m');

-- 2. Query the View using LAG() to calculate Growth Percentage
Select Sales_Month, Total_Sales, LAG(Total_Sales, 1) OVER (Order By Sales_Month) AS Prev_Month_Sales,
ROUND(((Total_Sales - Lag(Total_Sales, 1) OVER (ORDER BY Sales_Month)) 
/ LAG(Total_Sales, 1) Over (Order By Sales_Month)) * 100, 2) AS Growth_Percentage from Monthly_Sales;


-- Question 19: Find the top performing employee each month (by sales revenue)
-- =============================================================================

-- 1. Create a View for Monthly Employee Sales Performance
Create View Monthly_Top_Employee as with Monthly_Emp_Sales AS 
(Select DATE_FORMAT(O.Order_Date, '%Y-%m') AS Sales_Month, O.Employee_ID,
SUM(P.Price * OD.Quantity) AS Total_Sales, DENSE_RANK() OVER 
(PARTITION BY DATE_FORMAT(O.Order_Date, '%Y-%m') ORDER BY SUM(P.Price * OD.Quantity) DESC) AS Rank_Num
FROM Orders O JOIN OrderDetails od ON O.Order_ID = OD.Order_ID
JOIN Product P ON OD.Product_ID = P.Product_ID
GROUP BY DATE_FORMAT(O.Order_Date, '%Y-%m'), O.Employee_ID)
SELECT m.Sales_Month, e.Emp_Name, m.Total_Sales, m.Rank_Num
FROM Monthly_Emp_Sales m JOIN Employee e ON m.Employee_ID = e.Emp_ID;

-- 2. Query the View to get the Top Performer(s) for each month
Select Sales_Month, Emp_Name, Total_Sales FROM Monthly_Top_Employee WHERE Rank_Num = 1;






 

    
    
    
    