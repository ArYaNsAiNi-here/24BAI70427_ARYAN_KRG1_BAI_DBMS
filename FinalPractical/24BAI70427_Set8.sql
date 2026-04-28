
-- DROP TABLES (optional, to avoid errors if re-running)
DROP TABLE IF EXISTS Tbl_Supply_logs;
DROP TABLE IF EXISTS Tbl_Orders;
DROP TABLE IF EXISTS Tbl_Suppliers;
DROP TABLE IF EXISTS Tbl_Products;  

-- =========================
-- CREATE TABLES 
-- =========================

CREATE TABLE Tbl_Products (
    prod_id INT PRIMARY KEY,
    prod_name VARCHAR(100), 
    category VARCHAR(50),
    price INT,
    stock_qty INT
);

CREATE TABLE Tbl_Suppliers (
    sup_id INT PRIMARY KEY,
    sup_name VARCHAR(100),
    city VARCHAR(50),
    rating INT
);

CREATE TABLE Tbl_Orders (
    order_id INT PRIMARY KEY,
    prod_id INT,
    cust_id INT,
    order_date DATE,
    qty INT,
    FOREIGN KEY (prod_id) REFERENCES Tbl_Products(prod_id)
);

CREATE TABLE Tbl_Supply_logs (
    log_id INT PRIMARY KEY,
    action_type VARCHAR(20),
    prod_id INT,
    old_qty INT,
    new_qty INT,
    log_time TIMESTAMP,
    FOREIGN KEY (prod_id) REFERENCES Tbl_Products(prod_id)
);

-- =========================
-- INSERT DATA
-- =========================

-- Products
INSERT INTO Tbl_Products VALUES
(501, 'Laptop Pro', 'Electronics', 75000, 15),
(502, 'Ergo Chair', 'Furniture', 15000, 8);

-- Suppliers
INSERT INTO Tbl_Suppliers VALUES
(701, 'NextGen Tech', 'Bangalore', 5),
(702, 'Comfort Hub', 'Mumbai', 4);

-- Orders
INSERT INTO Tbl_Orders VALUES
(9001, 501, 101, '2026-04-20', 1),
(9002, 502, 102, '2026-04-21', 2);

-- Supply Logs
INSERT INTO Tbl_Supply_logs VALUES
(1, 'UPDATE', 501, 20, 15, '2026-04-20 10:00:00');

-- =========================
-- VERIFY
-- =========================

SELECT * FROM Tbl_Products;
SELECT * FROM Tbl_Suppliers;
SELECT * FROM Tbl_Orders;
SELECT * FROM Tbl_Supply_logs;


SELECT 
    p.prod_name, 
    COUNT(o.order_id) AS total_orders
FROM 
    Tbl_Products p
LEFT JOIN 
    Tbl_Orders o ON p.prod_id = o.prod_id
GROUP BY 
    p.prod_name
ORDER BY 
    total_orders DESC;


CREATE OR REPLACE PROCEDURE swap_supplier_cities(
    p_supid_1 INT,
    p_supid_2 INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_city1 VARCHAR(50);
    v_city2 VARCHAR(50);
BEGIN
    SELECT city INTO v_city1 FROM Tbl_Suppliers WHERE sup_id = p_supid_1;
    SELECT city INTO v_city2 FROM Tbl_Suppliers WHERE sup_id = p_supid_2;

    IF v_city1 IS NOT NULL AND v_city2 IS NOT NULL THEN
        
        UPDATE Tbl_Suppliers 
        SET city = v_city2 
        WHERE sup_id = p_supid_1;

        UPDATE Tbl_Suppliers 
        SET city = v_city1 
        WHERE sup_id = p_supid_2;

        RAISE NOTICE 'Cities swapped successfully.';
        
    ELSE
        RAISE NOTICE 'Swap failed: One or both of the provided sup_id values do not exist.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'An error occurred during the swap. The transaction has been rolled back.';
        RAISE;
END;
$$;