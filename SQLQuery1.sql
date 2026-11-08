use BikeStores;

-------------------------------------
--INSERT WITH SINGLE ROW
------------------------------------
--Aapki table mein ek column hai:
--category_id
--Ye IDENTITY column hai.
--Iska matlab hai ke SQL Server automatically is column ki value generate karega.

INSERT INTO production.categories (category_name)
VALUES ('Electric Scooters');
--SQL mein jab hum INSERT INTO ke saath column names specify karte hain, 
--to unko parentheses () ke andar likhna zaroori hota hai.

-----------------------------------------------
----INSERT WITH MULTIPLE  ROW
------------------------------------------------

INSERT INTO production.brands (brand_name)
VALUES
    ('Cannondale'),
    ('Giant'),
    ('Scott');

------------------------------------
    -- CREATE ANOTHER TABLE
--------------------------------------

CREATE TABLE production.products_archive (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR (255) NOT NULL,
    brand_id     INT NOT NULL,
    category_id  INT NOT NULL,
    model_year   SMALLINT NOT NULL,
    list_price   DECIMAL (10, 2) NOT NULL
);

----------------------------
-- INSERT INTO SELECT
----------------------------

INSERT INTO production.products_archive (
    product_id, product_name, brand_id, category_id, model_year, list_price
)
--Yahan hum source table se woh 6 columns select kar rahe hain jin ka data copy karna hai.
SELECT product_id, product_name, brand_id, category_id, model_year, list_price
FROM production.products
WHERE model_year < 2017;
--Ye condition hai.Iska matlab hai ke sirf woh products select honge jinka model_year 2017 se chhota hai.

--------------------------
--UPDATED
--------------------------

--SQL mein UPDATE command ka use existing table ke andar already stored data ko modify ya change karne ke liye hota hai.

---Yani agar kisi product ki price change karni ho, employee ki salary increase karni ho ya kisi record 
--ki information update karni ho, to hum UPDATE use karte hain.

UPDATE production.products
--Yani original price mein 5% increase.
SET list_price = list_price * 1.05
WHERE category_id = 6
  AND model_year = 2018;

--SET SQL ka keyword hai jo batata hai ke kis column ki value change karni hai aur usmein new value kya honi chahiye.

--------------------------
--UPDATED WITL MULTIPLE ROWS
--------------------------


UPDATE sales.customers
SET
    phone = '(916) 555-0199',
    city  = 'Sacramento'
WHERE customer_id = 142;

---------------------------------------
--UPDATED WITH JOIN 
-------------------------------------
-- FOR CHECKING BEFORE UPDATED
SELECT
    p.product_id,
    p.product_name,
    p.list_price,
    c.category_name
FROM production.products AS p
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Electric Bikes';

--IN UPDATE
UPDATE p
SET p.list_price = p.list_price * 1.10
FROM production.products AS p
INNER JOIN production.categories AS c
--category_id ki help se SQL identify karega ke konsa product kis category mein hai.
    ON p.category_id = c.category_id
WHERE c.category_name = 'Electric Bikes';


--------------------------------
--DELET 
--------------------------------
DELETE FROM production.products
WHERE model_year < 2016;

-------------------------------
--DELETE WITH JOIN 
-----------------------------
DELETE p
FROM production.products AS p
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Electric Scooters';

------------------------
----TRUNCATE TABLE
--------------------------
TRUNCATE TABLE production.products_archive;

-----------------------------
--TRANSACTION
-----------------------------
--Transaction Log mein kya record hota hai?
--Generally SQL Server transaction log mein ye information hoti hai:

--Kaunsa transaction perform hua.

--Kis data mein change hua.

--Transaction commit hua ya rollback.

--Recovery ke liye required information.

BEGIN TRANSACTION;

UPDATE sales.orders
SET order_status = 4
WHERE order_id = 1;

UPDATE production.stocks
SET quantity = quantity - 1
WHERE product_id = 6 AND store_id = 1;

COMMIT;

BEGIN TRANSACTION;

BEGIN TRY
    UPDATE sales.orders SET order_status = 4 WHERE order_id = 1;
    UPDATE production.stocks SET quantity = quantity - 1 WHERE product_id = 6 AND store_id = 1;
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;
END CATCH;

----------------------------------
--MERGE
------------------------------------
--MERGE ka matlab hai ke do tables ke data ko compare karo aur difference ke 
--according target table mein changes karo

CREATE TABLE production.products_staging (
    product_id   INT NULL,
    product_name VARCHAR (255) NOT NULL,
    brand_id     INT NOT NULL,
    category_id  INT NOT NULL,
    model_year   SMALLINT NOT NULL,
    list_price   DECIMAL (10, 2) NOT NULL
);


--yahan humne products table ko target banaya hai.
MERGE production.products AS target
--Yahan humne doosri table ko source banaya hai
USING production.products_staging AS source
--Iska matlab hai ke dono tables ke records ko product_id ke through compare karo.
    ON target.product_id = source.product_id
  --Agar product_id dono tables mein match karta hai, lekin price ya model year different hai, 
   --to target table ko update karo.
WHEN MATCHED AND (
    target.list_price <> source.list_price
    OR target.model_year <> source.model_year
    --OR ka matlab hai dono mein se koi ek condition bhi true ho to update hoga.
)
    THEN UPDATE SET
        target.list_price = source.list_price,
        target.model_year = source.model_year
--Agar koi record source table mein available hai lekin target table mein nahi hai,
--to us record ko target table mein insert karo.
WHEN NOT MATCHED BY TARGET
    THEN INSERT (product_name, brand_id, category_id, model_year, list_price)
    VALUES (source.product_name, source.brand_id, source.category_id,
            source.model_year, source.list_price)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE;

-----------------------------------
--TRANSACTION
----------------------------------
--Iska matlab hai ke hum ek new transaction start kar rahe hain.
--Ab jo bhi database changes is transaction ke andar hongi, unko hum ek unit ke taur par manage kar sakte hain.
--Example:
--Aap online shopping karte hain aur ek product order karte hain.
--Is process mein:
--Order ka status update hoga.
--Product ka stock decrease hoga.
--Hum chahte hain ke dono operations properly complete hon.

BEGIN TRANSACTION;

UPDATE sales.orders
SET order_status = 4
WHERE order_id = 1;

UPDATE production.stocks
SET quantity = quantity - 1
WHERE product_id = 6 AND store_id = 1;

COMMIT;

BEGIN TRANSACTION;

BEGIN TRY
    UPDATE sales.orders SET order_status = 4 WHERE order_id = 1;
    UPDATE production.stocks SET quantity = quantity - 1 WHERE product_id = 6 AND store_id = 1;
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;
END CATCH;

--PRIMARY KEY
--Definition: Uniquely identifies each row. Only one per table. Cannot be NULL.

--Simple meaning: Primary Key har record ko ek unique identity deti hai.
--Duplicate IDs allowed nahi.
--NULL allowed nahi.
--Har record ki unique identity hoti hai.

--. FOREIGN KEY
--Definition: Enforces the relationship between two tables. The value must exist in the referenced table.
--Simple meaning: Foreign Key do tables ke darmiyan relationship establish karti hai.