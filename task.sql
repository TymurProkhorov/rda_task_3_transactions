-- Use our database
USE ShopDB; 

INSERT INTO Products (Name, Description, Price, WarehouseAmount)
VALUES ('AwersomeProduct', 'Product Description', 5, 42);

INSERT INTO Customers (FirstName, LastName, Email, Address)
VALUES ('John', 'Dou', 'j@dou.ua', 'far, far away');

-- Start the transaction 
START TRANSACTION; 

INSERT INTO Orders (CustomerID, Date)
VALUES (1, '2023-01-01');

SET @order_id = LAST_INSERT_ID();

INSERT INTO OrderItems (OrderID, ProductID, Count)
VALUES (@order_id, 1, 1);

UPDATE Products
SET WarehouseAmount = WarehouseAmount - 1
WHERE ID = 1;

COMMIT; 