-- Exercise 2: Error Handling
-- This file contains solutions for all three scenarios in Exercise 2

-- ============================================
-- Scenario 1: Safe Fund Transfer with Error Handling
-- ============================================

CREATE OR REPLACE PROCEDURE SafeTransferFunds(
    p_from_account_id IN NUMBER,
    p_to_account_id IN NUMBER,
    p_amount IN NUMBER,
    p_result OUT VARCHAR2
) AS
    v_from_balance NUMBER;
    v_to_balance NUMBER;
    v_from_customer VARCHAR2(100);
    v_to_customer VARCHAR2(100);
    v_transaction_id NUMBER;
BEGIN
    -- Initialize result
    p_result := 'SUCCESS';
    
    -- Validate input parameters
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Transfer amount must be positive');
    END IF;
    
    IF p_from_account_id = p_to_account_id THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot transfer to the same account');
    END IF;
    
    -- Get account information with validation
    SELECT a.Balance, c.Name 
    INTO v_from_balance, v_from_customer
    FROM Accounts a
    JOIN Customers c ON a.CustomerID = c.CustomerID
    WHERE a.AccountID = p_from_account_id;
    
    IF v_from_balance < p_amount THEN
        p_result := 'INSUFFICIENT_FUNDS';
        DBMS_OUTPUT.PUT_LINE('ERROR: Insufficient funds in account ' || p_from_account_id);
        DBMS_OUTPUT.PUT_LINE('Current balance: $' || v_from_balance || ', Required: $' || p_amount);
        RETURN;
    END IF;
    
    -- Get destination account information
    SELECT a.Balance, c.Name 
    INTO v_to_balance, v_to_customer
    FROM Accounts a
    JOIN Customers c ON a.CustomerID = c.CustomerID
    WHERE a.AccountID = p_to_account_id;
    
    -- Get next transaction ID
    SELECT NVL(MAX(TransactionID), 0) + 1 INTO v_transaction_id FROM Transactions;
    
    -- Perform the transfer
    UPDATE Accounts SET Balance = Balance - p_amount WHERE AccountID = p_from_account_id;
    UPDATE Accounts SET Balance = Balance + p_amount WHERE AccountID = p_to_account_id;
    
    -- Record the transaction
    INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
    VALUES (v_transaction_id, p_from_account_id, SYSDATE, -p_amount, 'Transfer');
    
    INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
    VALUES (v_transaction_id + 1, p_to_account_id, SYSDATE, p_amount, 'Transfer');
    
    -- Log successful transfer
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Transfer completed');
    DBMS_OUTPUT.PUT_LINE('From: ' || v_from_customer || ' (Account: ' || p_from_account_id || ')');
    DBMS_OUTPUT.PUT_LINE('To: ' || v_to_customer || ' (Account: ' || p_to_account_id || ')');
    DBMS_OUTPUT.PUT_LINE('Amount: $' || p_amount);
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 'ACCOUNT_NOT_FOUND';
        DBMS_OUTPUT.PUT_LINE('ERROR: One or both accounts not found');
        ROLLBACK;
    WHEN OTHERS THEN
        p_result := 'SYSTEM_ERROR';
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END SafeTransferFunds;
/

-- ============================================
-- Scenario 2: Employee Salary Update with Error Handling
-- ============================================

CREATE OR REPLACE PROCEDURE UpdateSalary(
    p_employee_id IN NUMBER,
    p_percentage IN NUMBER,
    p_result OUT VARCHAR2
) AS
    v_old_salary NUMBER;
    v_new_salary NUMBER;
    v_employee_name VARCHAR2(100);
    v_department VARCHAR2(50);
BEGIN
    -- Initialize result
    p_result := 'SUCCESS';
    
    -- Validate input parameters
    IF p_percentage <= 0 OR p_percentage > 100 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Percentage must be between 0 and 100');
    END IF;
    
    -- Get employee information
    SELECT Name, Salary, Department 
    INTO v_employee_name, v_old_salary, v_department
    FROM Employees 
    WHERE EmployeeID = p_employee_id;
    
    -- Calculate new salary
    v_new_salary := v_old_salary * (1 + p_percentage / 100);
    
    -- Update salary
    UPDATE Employees 
    SET Salary = v_new_salary 
    WHERE EmployeeID = p_employee_id;
    
    -- Log successful update
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Salary updated for employee ' || v_employee_name);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_department);
    DBMS_OUTPUT.PUT_LINE('Old Salary: $' || v_old_salary);
    DBMS_OUTPUT.PUT_LINE('New Salary: $' || v_new_salary);
    DBMS_OUTPUT.PUT_LINE('Increase: ' || p_percentage || '%');
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 'EMPLOYEE_NOT_FOUND';
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || p_employee_id || ' not found');
        ROLLBACK;
    WHEN OTHERS THEN
        p_result := 'SYSTEM_ERROR';
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END UpdateSalary;
/

-- ============================================
-- Scenario 3: Add New Customer with Data Integrity
-- ============================================

CREATE OR REPLACE PROCEDURE AddNewCustomer(
    p_customer_id IN NUMBER,
    p_name IN VARCHAR2,
    p_dob IN DATE,
    p_initial_balance IN NUMBER,
    p_result OUT VARCHAR2
) AS
    v_existing_customer VARCHAR2(100);
BEGIN
    -- Initialize result
    p_result := 'SUCCESS';
    
    -- Validate input parameters
    IF p_customer_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Customer ID must be positive');
    END IF;
    
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Customer name cannot be empty');
    END IF;
    
    IF p_dob IS NULL OR p_dob > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20006, 'Invalid date of birth');
    END IF;
    
    IF p_initial_balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Initial balance cannot be negative');
    END IF;
    
    -- Check if customer already exists
    BEGIN
        SELECT Name INTO v_existing_customer 
        FROM Customers 
        WHERE CustomerID = p_customer_id;
        
        p_result := 'CUSTOMER_EXISTS';
        DBMS_OUTPUT.PUT_LINE('ERROR: Customer ID ' || p_customer_id || ' already exists');
        DBMS_OUTPUT.PUT_LINE('Existing customer: ' || v_existing_customer);
        RETURN;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Customer doesn't exist, proceed with insertion
    END;
    
    -- Insert new customer
    INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified, IsVIP)
    VALUES (p_customer_id, p_name, p_dob, p_initial_balance, SYSDATE, 'N');
    
    -- Log successful insertion
    DBMS_OUTPUT.PUT_LINE('SUCCESS: New customer added');
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || p_customer_id);
    DBMS_OUTPUT.PUT_LINE('Name: ' || p_name);
    DBMS_OUTPUT.PUT_LINE('Date of Birth: ' || TO_CHAR(p_dob, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('Initial Balance: $' || p_initial_balance);
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_result := 'SYSTEM_ERROR';
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END AddNewCustomer;
/

-- ============================================
-- Test the Error Handling Procedures
-- ============================================

DECLARE
    v_result VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Exercise 2: Error Handling Test ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test Scenario 1: Safe Fund Transfer
    DBMS_OUTPUT.PUT_LINE('--- Testing Safe Fund Transfer ---');
    
    -- Test successful transfer
    SafeTransferFunds(1, 2, 500, v_result);
    DBMS_OUTPUT.PUT_LINE('Transfer result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test insufficient funds
    SafeTransferFunds(4, 5, 10000, v_result);
    DBMS_OUTPUT.PUT_LINE('Transfer result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test invalid account
    SafeTransferFunds(999, 1, 100, v_result);
    DBMS_OUTPUT.PUT_LINE('Transfer result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test Scenario 2: Employee Salary Update
    DBMS_OUTPUT.PUT_LINE('--- Testing Employee Salary Update ---');
    
    -- Test successful update
    UpdateSalary(1, 10, v_result);
    DBMS_OUTPUT.PUT_LINE('Salary update result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test invalid employee
    UpdateSalary(999, 5, v_result);
    DBMS_OUTPUT.PUT_LINE('Salary update result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test Scenario 3: Add New Customer
    DBMS_OUTPUT.PUT_LINE('--- Testing Add New Customer ---');
    
    -- Test successful addition
    AddNewCustomer(6, 'Sarah Wilson', TO_DATE('1988-11-15', 'YYYY-MM-DD'), 7500, v_result);
    DBMS_OUTPUT.PUT_LINE('Customer addition result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test duplicate customer ID
    AddNewCustomer(1, 'Duplicate Customer', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 1000, v_result);
    DBMS_OUTPUT.PUT_LINE('Customer addition result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test invalid parameters
    AddNewCustomer(-1, 'Invalid Customer', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 1000, v_result);
    DBMS_OUTPUT.PUT_LINE('Customer addition result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
END;
/

-- Display results after testing
SELECT 'Exercise 2 Results Summary' as Summary FROM DUAL;

-- Show updated account balances
SELECT 'Updated Account Balances' as Info FROM DUAL;
SELECT a.AccountID, c.Name, a.AccountType, a.Balance
FROM Accounts a
JOIN Customers c ON a.CustomerID = c.CustomerID
ORDER BY a.AccountID;

-- Show updated employee salaries
SELECT 'Updated Employee Salaries' as Info FROM DUAL;
SELECT EmployeeID, Name, Department, Salary
FROM Employees
ORDER BY EmployeeID;

-- Show all customers including new one
SELECT 'All Customers' as Info FROM DUAL;
SELECT CustomerID, Name, DOB, Balance, IsVIP
FROM Customers
ORDER BY CustomerID; 