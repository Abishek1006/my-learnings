-- Exercise 3: Stored Procedures
-- This file contains solutions for all three scenarios in Exercise 3

-- ============================================
-- Scenario 1: Process Monthly Interest for Savings Accounts
-- ============================================

CREATE OR REPLACE PROCEDURE ProcessMonthlyInterest(
    p_interest_rate IN NUMBER DEFAULT 1.0,
    p_result OUT VARCHAR2
) AS
    v_account_count NUMBER := 0;
    v_total_interest NUMBER := 0;
    v_updated_count NUMBER := 0;
    v_transaction_id NUMBER;
BEGIN
    -- Initialize result
    p_result := 'SUCCESS';
    
    -- Validate interest rate
    IF p_interest_rate <= 0 OR p_interest_rate > 10 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Interest rate must be between 0 and 10 percent');
    END IF;
    
    -- Get next transaction ID
    SELECT NVL(MAX(TransactionID), 0) + 1 INTO v_transaction_id FROM Transactions;
    
    -- Process interest for all savings accounts
    FOR account_rec IN (SELECT a.AccountID, a.CustomerID, a.Balance, c.Name
                       FROM Accounts a
                       JOIN Customers c ON a.CustomerID = c.CustomerID
                       WHERE a.AccountType = 'Savings'
                       ORDER BY a.AccountID) LOOP
        
        v_account_count := v_account_count + 1;
        
        -- Calculate interest amount
        DECLARE
            v_interest_amount NUMBER;
            v_new_balance NUMBER;
        BEGIN
            v_interest_amount := account_rec.Balance * (p_interest_rate / 100);
            v_new_balance := account_rec.Balance + v_interest_amount;
            v_total_interest := v_total_interest + v_interest_amount;
            
            -- Update account balance
            UPDATE Accounts 
            SET Balance = v_new_balance, LastModified = SYSDATE 
            WHERE AccountID = account_rec.AccountID;
            
            -- Record interest transaction
            INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
            VALUES (v_transaction_id, account_rec.AccountID, SYSDATE, v_interest_amount, 'Interest');
            
            v_transaction_id := v_transaction_id + 1;
            v_updated_count := v_updated_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Account: ' || account_rec.AccountID || 
                                ' - Customer: ' || account_rec.Name ||
                                ' - Interest: $' || ROUND(v_interest_amount, 2) ||
                                ' - New Balance: $' || ROUND(v_new_balance, 2));
                                
        END;
    END LOOP;
    
    -- Log summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Monthly Interest Processing Summary:');
    DBMS_OUTPUT.PUT_LINE('Interest Rate: ' || p_interest_rate || '%');
    DBMS_OUTPUT.PUT_LINE('Savings accounts processed: ' || v_account_count);
    DBMS_OUTPUT.PUT_LINE('Accounts updated: ' || v_updated_count);
    DBMS_OUTPUT.PUT_LINE('Total interest paid: $' || ROUND(v_total_interest, 2));
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_result := 'SYSTEM_ERROR';
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END ProcessMonthlyInterest;
/

-- ============================================
-- Scenario 2: Employee Bonus Scheme
-- ============================================

CREATE OR REPLACE PROCEDURE UpdateEmployeeBonus(
    p_department IN VARCHAR2,
    p_bonus_percentage IN NUMBER,
    p_result OUT VARCHAR2
) AS
    v_employee_count NUMBER := 0;
    v_updated_count NUMBER := 0;
    v_total_bonus NUMBER := 0;
    v_old_total_salary NUMBER := 0;
    v_new_total_salary NUMBER := 0;
BEGIN
    -- Initialize result
    p_result := 'SUCCESS';
    
    -- Validate parameters
    IF p_bonus_percentage <= 0 OR p_bonus_percentage > 50 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Bonus percentage must be between 0 and 50 percent');
    END IF;
    
    -- Check if department exists
    DECLARE
        v_dept_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_dept_exists 
        FROM Employees 
        WHERE UPPER(Department) = UPPER(p_department);
        
        IF v_dept_exists = 0 THEN
            p_result := 'DEPARTMENT_NOT_FOUND';
            DBMS_OUTPUT.PUT_LINE('ERROR: Department "' || p_department || '" not found');
            RETURN;
        END IF;
    END;
    
    -- Process bonus for employees in the specified department
    FOR emp_rec IN (SELECT EmployeeID, Name, Position, Salary
                   FROM Employees 
                   WHERE UPPER(Department) = UPPER(p_department)
                   ORDER BY EmployeeID) LOOP
        
        v_employee_count := v_employee_count + 1;
        v_old_total_salary := v_old_total_salary + emp_rec.Salary;
        
        -- Calculate new salary with bonus
        DECLARE
            v_bonus_amount NUMBER;
            v_new_salary NUMBER;
        BEGIN
            v_bonus_amount := emp_rec.Salary * (p_bonus_percentage / 100);
            v_new_salary := emp_rec.Salary + v_bonus_amount;
            v_total_bonus := v_total_bonus + v_bonus_amount;
            v_new_total_salary := v_new_total_salary + v_new_salary;
            
            -- Update employee salary
            UPDATE Employees 
            SET Salary = v_new_salary 
            WHERE EmployeeID = emp_rec.EmployeeID;
            
            v_updated_count := v_updated_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Employee: ' || emp_rec.Name || 
                                ' - Position: ' || emp_rec.Position ||
                                ' - Old Salary: $' || emp_rec.Salary ||
                                ' - Bonus: $' || ROUND(v_bonus_amount, 2) ||
                                ' - New Salary: $' || ROUND(v_new_salary, 2));
        END;
    END LOOP;
    
    -- Log summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Employee Bonus Processing Summary:');
    DBMS_OUTPUT.PUT_LINE('Department: ' || p_department);
    DBMS_OUTPUT.PUT_LINE('Bonus Percentage: ' || p_bonus_percentage || '%');
    DBMS_OUTPUT.PUT_LINE('Employees processed: ' || v_employee_count);
    DBMS_OUTPUT.PUT_LINE('Employees updated: ' || v_updated_count);
    DBMS_OUTPUT.PUT_LINE('Total bonus paid: $' || ROUND(v_total_bonus, 2));
    DBMS_OUTPUT.PUT_LINE('Old total salary: $' || ROUND(v_old_total_salary, 2));
    DBMS_OUTPUT.PUT_LINE('New total salary: $' || ROUND(v_new_total_salary, 2));
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_result := 'SYSTEM_ERROR';
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END UpdateEmployeeBonus;
/

-- ============================================
-- Scenario 3: Transfer Funds Between Accounts
-- ============================================

CREATE OR REPLACE PROCEDURE TransferFunds(
    p_from_account_id IN NUMBER,
    p_to_account_id IN NUMBER,
    p_amount IN NUMBER,
    p_description IN VARCHAR2 DEFAULT 'Fund Transfer',
    p_result OUT VARCHAR2
) AS
    v_from_balance NUMBER;
    v_to_balance NUMBER;
    v_from_customer VARCHAR2(100);
    v_to_customer VARCHAR2(100);
    v_transaction_id NUMBER;
    v_success BOOLEAN := TRUE;
BEGIN
    -- Initialize result
    p_result := 'SUCCESS';
    
    -- Validate input parameters
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Transfer amount must be positive');
    END IF;
    
    IF p_from_account_id = p_to_account_id THEN
        RAISE_APPLICATION_ERROR(-20011, 'Cannot transfer to the same account');
    END IF;
    
    -- Get source account information
    BEGIN
        SELECT a.Balance, c.Name 
        INTO v_from_balance, v_from_customer
        FROM Accounts a
        JOIN Customers c ON a.CustomerID = c.CustomerID
        WHERE a.AccountID = p_from_account_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_result := 'SOURCE_ACCOUNT_NOT_FOUND';
            DBMS_OUTPUT.PUT_LINE('ERROR: Source account ' || p_from_account_id || ' not found');
            RETURN;
    END;
    
    -- Check sufficient balance
    IF v_from_balance < p_amount THEN
        p_result := 'INSUFFICIENT_FUNDS';
        DBMS_OUTPUT.PUT_LINE('ERROR: Insufficient funds in source account');
        DBMS_OUTPUT.PUT_LINE('Current balance: $' || v_from_balance || ', Required: $' || p_amount);
        RETURN;
    END IF;
    
    -- Get destination account information
    BEGIN
        SELECT a.Balance, c.Name 
        INTO v_to_balance, v_to_customer
        FROM Accounts a
        JOIN Customers c ON a.CustomerID = c.CustomerID
        WHERE a.AccountID = p_to_account_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_result := 'DESTINATION_ACCOUNT_NOT_FOUND';
            DBMS_OUTPUT.PUT_LINE('ERROR: Destination account ' || p_to_account_id || ' not found');
            RETURN;
    END;
    
    -- Get next transaction ID
    SELECT NVL(MAX(TransactionID), 0) + 1 INTO v_transaction_id FROM Transactions;
    
    -- Perform the transfer
    UPDATE Accounts SET Balance = Balance - p_amount WHERE AccountID = p_from_account_id;
    UPDATE Accounts SET Balance = Balance + p_amount WHERE AccountID = p_to_account_id;
    
    -- Record transactions
    INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
    VALUES (v_transaction_id, p_from_account_id, SYSDATE, -p_amount, 'Transfer');
    
    INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
    VALUES (v_transaction_id + 1, p_to_account_id, SYSDATE, p_amount, 'Transfer');
    
    -- Log successful transfer
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Fund transfer completed');
    DBMS_OUTPUT.PUT_LINE('Description: ' || p_description);
    DBMS_OUTPUT.PUT_LINE('From: ' || v_from_customer || ' (Account: ' || p_from_account_id || ')');
    DBMS_OUTPUT.PUT_LINE('To: ' || v_to_customer || ' (Account: ' || p_to_account_id || ')');
    DBMS_OUTPUT.PUT_LINE('Amount: $' || p_amount);
    DBMS_OUTPUT.PUT_LINE('Transaction ID: ' || v_transaction_id);
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_result := 'SYSTEM_ERROR';
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END TransferFunds;
/

-- ============================================
-- Test the Stored Procedures
-- ============================================

DECLARE
    v_result VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Exercise 3: Stored Procedures Test ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test Scenario 1: Process Monthly Interest
    DBMS_OUTPUT.PUT_LINE('--- Testing Monthly Interest Processing ---');
    ProcessMonthlyInterest(1.5, v_result);
    DBMS_OUTPUT.PUT_LINE('Interest processing result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test Scenario 2: Employee Bonus Scheme
    DBMS_OUTPUT.PUT_LINE('--- Testing Employee Bonus Scheme ---');
    UpdateEmployeeBonus('IT', 15, v_result);
    DBMS_OUTPUT.PUT_LINE('Bonus processing result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test with non-existent department
    UpdateEmployeeBonus('NONEXISTENT', 10, v_result);
    DBMS_OUTPUT.PUT_LINE('Bonus processing result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test Scenario 3: Transfer Funds
    DBMS_OUTPUT.PUT_LINE('--- Testing Fund Transfer ---');
    TransferFunds(2, 3, 1000, 'Test transfer between accounts', v_result);
    DBMS_OUTPUT.PUT_LINE('Transfer result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test insufficient funds
    TransferFunds(4, 5, 10000, 'Test insufficient funds', v_result);
    DBMS_OUTPUT.PUT_LINE('Transfer result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test invalid account
    TransferFunds(999, 1, 100, 'Test invalid account', v_result);
    DBMS_OUTPUT.PUT_LINE('Transfer result: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('');
    
END;
/

-- Display results after testing
SELECT 'Exercise 3 Results Summary' as Summary FROM DUAL;

-- Show updated account balances after interest and transfers
SELECT 'Updated Account Balances' as Info FROM DUAL;
SELECT a.AccountID, c.Name, a.AccountType, a.Balance
FROM Accounts a
JOIN Customers c ON a.CustomerID = c.CustomerID
ORDER BY a.AccountID;

-- Show updated employee salaries after bonus
SELECT 'Updated Employee Salaries' as Info FROM DUAL;
SELECT EmployeeID, Name, Department, Salary
FROM Employees
ORDER BY EmployeeID;

-- Show recent transactions
SELECT 'Recent Transactions' as Info FROM DUAL;
SELECT TransactionID, AccountID, TransactionDate, Amount, TransactionType
FROM Transactions
ORDER BY TransactionID DESC; 