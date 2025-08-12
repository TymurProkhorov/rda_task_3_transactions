-- Use our database
USE ShopDB; 

INSERT INTO Products (Name, Description, Price, WarehouseAmount)
VALUES ('AwersomeProduct', 'Product Description', 5, 42);

INSERT INTO Customers (FirstName, LastName, Email, Address)
VALUES ('John', 'Dou', 'j@dou.ua', 'far, far away');

-- Start the transaction 
START TRANSACTION;

-- 1. Добавляем клиента, если не существует
INSERT INTO Customers (CustomerName)
SELECT 'John Doe'
WHERE NOT EXISTS (
    SELECT 1 FROM Customers WHERE CustomerName = 'John Doe'
);

-- Получаем ID клиента
SET @customerId = (SELECT CustomerID FROM Customers WHERE CustomerName = 'John Doe');

-- 2. Добавляем продукт, если не существует
INSERT INTO Products (ProductName, WarehouseAmount)
SELECT 'Laptop', 10
WHERE NOT EXISTS (
    SELECT 1 FROM Products WHERE ProductName = 'Laptop'
);

-- Получаем ID продукта
SET @productId = (SELECT ProductID FROM Products WHERE ProductName = 'Laptop');

-- 3. Проверка и блокировка склада
SELECT WarehouseAmount
INTO @stock
FROM Products
WHERE ProductID = @productId
FOR UPDATE;

-- Если товара не хватает — откат
IF @stock < 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for product';
END IF;

-- 4. Создаем заказ
INSERT INTO Orders (CustomerID, OrderDate)
VALUES (@customerId, NOW());

-- Получаем ID заказа
SET @orderId = LAST_INSERT_ID();

-- 5. Добавляем детали заказа
INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES (@orderId, @productId, 1);

-- 6. Обновляем количество на складе
UPDATE Products
SET WarehouseAmount = WarehouseAmount - 1
WHERE ProductID = @productId;

COMMIT; 