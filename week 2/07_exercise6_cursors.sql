-- Exercise 6: Cursors
-- This file contains solutions for all three scenarios in Exercise 6

-- ============================================
-- Scenario 1: Generate Monthly Statements for All Customers
-- ============================================

SET SERVEROUTPUT ON;
DECLARE
    CURSOR cur_customers IS
        SELECT CustomerID, Name FROM Customers ORDER BY CustomerID;
    CURSOR cur_transactions(p_cust_id NUMBER) IS
        SELECT t.TransactionID, t.AccountID, t.TransactionDate, t.Amount, t.TransactionType
        FROM Transactions t
        JOIN Accounts a ON t.AccountID = a.AccountID
        WHERE a.CustomerID = p_cust_id
          AND TO_CHAR(t.TransactionDate, 'YYYYMM') = TO_CHAR(SYSDATE, 'YYYYMM')
        ORDER BY t.TransactionDate;
    v_txn_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Exercise 6: Monthly Statements ===');
    FOR cust_rec IN cur_customers LOOP
        v_txn_count := 0;
        DBMS_OUTPUT.PUT_LINE('Customer: ' || cust_rec.Name || ' (ID: ' || cust_rec.CustomerID || ')');
        DBMS_OUTPUT.PUT_LINE('Transactions for current month:');
        FOR txn_rec IN cur_transactions(cust_rec.CustomerID) LOOP
            v_txn_count := v_txn_count + 1;
            DBMS_OUTPUT.PUT_LINE('  TxnID: ' || txn_rec.TransactionID || ', Account: ' || txn_rec.AccountID || ', Date: ' || TO_CHAR(txn_rec.TransactionDate, 'DD-MON-YYYY') || ', Amount: $' || txn_rec.Amount || ', Type: ' || txn_rec.TransactionType);
        END LOOP;
        IF v_txn_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('  No transactions this month.');
        END IF;
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
END;
/

-- ============================================
-- Scenario 2: Apply Annual Fee to All Accounts
-- ============================================

DECLARE
    CURSOR cur_accounts IS
        SELECT AccountID, Balance FROM Accounts ORDER BY AccountID;
    v_fee NUMBER := 50; -- annual fee
    v_new_balance NUMBER;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Applying Annual Fee to All Accounts ===');
    FOR acc_rec IN cur_accounts LOOP
        v_new_balance := acc_rec.Balance - v_fee;
        UPDATE Accounts SET Balance = v_new_balance, LastModified = SYSDATE WHERE AccountID = acc_rec.AccountID;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Account: ' || acc_rec.AccountID || ' - Fee: $' || v_fee || ' - New Balance: $' || v_new_balance);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total accounts charged: ' || v_count);
    COMMIT;
END;
/

-- ============================================
-- Scenario 3: Update Loan Interest Rates Based on New Policy
-- ============================================

DECLARE
    CURSOR cur_loans IS
        SELECT LoanID, InterestRate FROM Loans ORDER BY LoanID;
    v_new_rate NUMBER;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Updating Loan Interest Rates (New Policy) ===');
    FOR loan_rec IN cur_loans LOOP
        -- Example policy: decrease all rates by 0.5%, but not below 3%
        v_new_rate := GREATEST(loan_rec.InterestRate - 0.5, 3);
        UPDATE Loans SET InterestRate = v_new_rate WHERE LoanID = loan_rec.LoanID;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('Loan: ' || loan_rec.LoanID || ' - Old Rate: ' || loan_rec.InterestRate || '% - New Rate: ' || v_new_rate || '%');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total loans updated: ' || v_count);
    COMMIT;
END;
/

-- Show results
SELECT 'Exercise 6 Results Summary' as Summary FROM DUAL;
SELECT AccountID, Balance FROM Accounts ORDER BY AccountID;
SELECT LoanID, InterestRate FROM Loans ORDER BY LoanID; 