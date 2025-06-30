-- Exercise 4: Functions
-- This file contains solutions for all three scenarios in Exercise 4

-- ============================================
-- Scenario 1: Calculate Age of Customer
-- ============================================

CREATE OR REPLACE FUNCTION CalculateAge(
    p_dob IN DATE
) RETURN NUMBER IS
    v_age NUMBER;
BEGIN
    IF p_dob IS NULL THEN
        RETURN NULL;
    END IF;
    v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    RETURN v_age;
END CalculateAge;
/

-- ============================================
-- Scenario 2: Calculate Monthly Installment for Loan
-- ============================================

CREATE OR REPLACE FUNCTION CalculateMonthlyInstallment(
    p_loan_amount IN NUMBER,
    p_interest_rate IN NUMBER,
    p_years IN NUMBER
) RETURN NUMBER IS
    v_monthly_rate NUMBER;
    v_months NUMBER;
    v_installment NUMBER;
BEGIN
    IF p_loan_amount <= 0 OR p_interest_rate < 0 OR p_years <= 0 THEN
        RETURN NULL;
    END IF;
    v_monthly_rate := p_interest_rate / 12 / 100;
    v_months := p_years * 12;
    IF v_monthly_rate = 0 THEN
        v_installment := p_loan_amount / v_months;
    ELSE
        v_installment := p_loan_amount * v_monthly_rate / (1 - POWER(1 + v_monthly_rate, -v_months));
    END IF;
    RETURN ROUND(v_installment, 2);
END CalculateMonthlyInstallment;
/

-- ============================================
-- Scenario 3: Check Sufficient Balance
-- ============================================

CREATE OR REPLACE FUNCTION HasSufficientBalance(
    p_account_id IN NUMBER,
    p_amount IN NUMBER
) RETURN BOOLEAN IS
    v_balance NUMBER;
BEGIN
    IF p_amount <= 0 THEN
        RETURN FALSE;
    END IF;
    SELECT Balance INTO v_balance FROM Accounts WHERE AccountID = p_account_id;
    RETURN v_balance >= p_amount;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END HasSufficientBalance;
/

-- ============================================
-- Test the Functions
-- ============================================

SET SERVEROUTPUT ON;
DECLARE
    v_age NUMBER;
    v_installment NUMBER;
    v_has_balance BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Exercise 4: Functions Test ===');
    DBMS_OUTPUT.PUT_LINE('');
    -- Test CalculateAge
    v_age := CalculateAge(TO_DATE('1985-05-15', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Age for DOB 1985-05-15: ' || v_age);
    -- Test CalculateMonthlyInstallment
    v_installment := CalculateMonthlyInstallment(10000, 6, 5);
    DBMS_OUTPUT.PUT_LINE('Monthly installment for $10,000, 6% interest, 5 years: $' || v_installment);
    -- Test HasSufficientBalance
    v_has_balance := HasSufficientBalance(1, 5000);
    IF v_has_balance THEN
        DBMS_OUTPUT.PUT_LINE('Account 1 has sufficient balance for $5000');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Account 1 does NOT have sufficient balance for $5000');
    END IF;
    v_has_balance := HasSufficientBalance(4, 10000);
    IF v_has_balance THEN
        DBMS_OUTPUT.PUT_LINE('Account 4 has sufficient balance for $10000');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Account 4 does NOT have sufficient balance for $10000');
    END IF;
END;
/

-- Show function results in SQL
SELECT 'Exercise 4 Results Summary' as Summary FROM DUAL;
SELECT CustomerID, Name, DOB, CalculateAge(DOB) as Age FROM Customers ORDER BY CustomerID;
SELECT CalculateMonthlyInstallment(15000, 5, 7) as Installment FROM DUAL;
SELECT AccountID, Balance, HasSufficientBalance(AccountID, 1000) as Has_Enough FROM Accounts; 