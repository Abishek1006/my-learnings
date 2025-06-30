-- Exercise 5: Triggers
-- This file contains solutions for all three scenarios in Exercise 5

-- ============================================
-- Scenario 1: Update LastModified on Customer Update
-- ============================================

CREATE OR REPLACE TRIGGER UpdateCustomerLastModified
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    :NEW.LastModified := SYSDATE;
END;
/

-- ============================================
-- Scenario 2: Audit Log for Transactions
-- ============================================

CREATE OR REPLACE TRIGGER LogTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
DECLARE
    v_log_id NUMBER;
BEGIN
    SELECT NVL(MAX(LogID), 0) + 1 INTO v_log_id FROM AuditLog;
    INSERT INTO AuditLog (LogID, TableName, Action, RecordID, LogDate, UserName)
    VALUES (v_log_id, 'Transactions', 'INSERT', :NEW.TransactionID, SYSDATE, USER);
END;
/

-- ============================================
-- Scenario 3: Enforce Business Rules on Transactions
-- ============================================

CREATE OR REPLACE TRIGGER CheckTransactionRules
BEFORE INSERT ON Transactions
FOR EACH ROW
DECLARE
    v_balance NUMBER;
BEGIN
    -- Only check for withdrawals and deposits
    IF :NEW.TransactionType = 'Withdrawal' THEN
        SELECT Balance INTO v_balance FROM Accounts WHERE AccountID = :NEW.AccountID;
        IF :NEW.Amount > v_balance THEN
            RAISE_APPLICATION_ERROR(-20020, 'Withdrawal amount exceeds account balance');
        END IF;
        IF :NEW.Amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Withdrawal amount must be positive');
        END IF;
    ELSIF :NEW.TransactionType = 'Deposit' THEN
        IF :NEW.Amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'Deposit amount must be positive');
        END IF;
    END IF;
END;
/

-- ============================================
-- Test the Triggers
-- ============================================

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Exercise 5: Triggers Test ===');
    -- Test update on Customers (should update LastModified)
    UPDATE Customers SET Name = Name WHERE CustomerID = 1;
    DBMS_OUTPUT.PUT_LINE('Updated customer 1, LastModified should be current date.');
    -- Test valid deposit
    INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
    VALUES (100, 1, SYSDATE, 100, 'Deposit');
    DBMS_OUTPUT.PUT_LINE('Inserted valid deposit transaction.');
    -- Test valid withdrawal
    INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
    VALUES (101, 1, SYSDATE, 50, 'Withdrawal');
    DBMS_OUTPUT.PUT_LINE('Inserted valid withdrawal transaction.');
    -- Test invalid withdrawal (should fail)
    BEGIN
        INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
        VALUES (102, 1, SYSDATE, 999999, 'Withdrawal');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected error for excessive withdrawal: ' || SQLERRM);
    END;
    -- Test invalid deposit (should fail)
    BEGIN
        INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
        VALUES (103, 1, SYSDATE, -100, 'Deposit');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected error for negative deposit: ' || SQLERRM);
    END;
END;
/

-- Show trigger results
SELECT 'Exercise 5 Results Summary' as Summary FROM DUAL;
SELECT CustomerID, Name, LastModified FROM Customers WHERE CustomerID = 1;
SELECT * FROM AuditLog WHERE TableName = 'Transactions' ORDER BY LogID DESC;
SELECT * FROM Transactions WHERE TransactionID >= 100 ORDER BY TransactionID; 