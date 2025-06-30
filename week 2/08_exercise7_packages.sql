-- Exercise 7: Packages
-- This file contains solutions for all three scenarios in Exercise 7

-- ============================================
-- Scenario 1: CustomerManagement Package
-- ============================================

CREATE OR REPLACE PACKAGE CustomerManagement AS
    PROCEDURE AddCustomer(
        p_customer_id IN NUMBER,
        p_name IN VARCHAR2,
        p_dob IN DATE,
        p_initial_balance IN NUMBER,
        p_result OUT VARCHAR2
    );
    PROCEDURE UpdateCustomerDetails(
        p_customer_id IN NUMBER,
        p_name IN VARCHAR2,
        p_dob IN DATE,
        p_result OUT VARCHAR2
    );
    FUNCTION GetCustomerBalance(
        p_customer_id IN NUMBER
    ) RETURN NUMBER;
END CustomerManagement;
/

CREATE OR REPLACE PACKAGE BODY CustomerManagement AS
    PROCEDURE AddCustomer(
        p_customer_id IN NUMBER,
        p_name IN VARCHAR2,
        p_dob IN DATE,
        p_initial_balance IN NUMBER,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified, IsVIP)
        VALUES (p_customer_id, p_name, p_dob, p_initial_balance, SYSDATE, 'N');
        p_result := 'SUCCESS';
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            p_result := 'CUSTOMER_EXISTS';
        WHEN OTHERS THEN
            p_result := 'ERROR';
    END;

    PROCEDURE UpdateCustomerDetails(
        p_customer_id IN NUMBER,
        p_name IN VARCHAR2,
        p_dob IN DATE,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        UPDATE Customers SET Name = p_name, DOB = p_dob WHERE CustomerID = p_customer_id;
        IF SQL%ROWCOUNT = 0 THEN
            p_result := 'NOT_FOUND';
        ELSE
            p_result := 'SUCCESS';
            COMMIT;
        END IF;
    END;

    FUNCTION GetCustomerBalance(
        p_customer_id IN NUMBER
    ) RETURN NUMBER IS
        v_balance NUMBER;
    BEGIN
        SELECT Balance INTO v_balance FROM Customers WHERE CustomerID = p_customer_id;
        RETURN v_balance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;
END CustomerManagement;
/

-- ============================================
-- Scenario 2: EmployeeManagement Package
-- ============================================

CREATE OR REPLACE PACKAGE EmployeeManagement AS
    PROCEDURE HireEmployee(
        p_employee_id IN NUMBER,
        p_name IN VARCHAR2,
        p_position IN VARCHAR2,
        p_salary IN NUMBER,
        p_department IN VARCHAR2,
        p_hiredate IN DATE,
        p_result OUT VARCHAR2
    );
    PROCEDURE UpdateEmployeeDetails(
        p_employee_id IN NUMBER,
        p_name IN VARCHAR2,
        p_position IN VARCHAR2,
        p_salary IN NUMBER,
        p_department IN VARCHAR2,
        p_result OUT VARCHAR2
    );
    FUNCTION CalculateAnnualSalary(
        p_employee_id IN NUMBER
    ) RETURN NUMBER;
END EmployeeManagement;
/

CREATE OR REPLACE PACKAGE BODY EmployeeManagement AS
    PROCEDURE HireEmployee(
        p_employee_id IN NUMBER,
        p_name IN VARCHAR2,
        p_position IN VARCHAR2,
        p_salary IN NUMBER,
        p_department IN VARCHAR2,
        p_hiredate IN DATE,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
        VALUES (p_employee_id, p_name, p_position, p_salary, p_department, p_hiredate);
        p_result := 'SUCCESS';
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            p_result := 'EMPLOYEE_EXISTS';
        WHEN OTHERS THEN
            p_result := 'ERROR';
    END;

    PROCEDURE UpdateEmployeeDetails(
        p_employee_id IN NUMBER,
        p_name IN VARCHAR2,
        p_position IN VARCHAR2,
        p_salary IN NUMBER,
        p_department IN VARCHAR2,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        UPDATE Employees SET Name = p_name, Position = p_position, Salary = p_salary, Department = p_department WHERE EmployeeID = p_employee_id;
        IF SQL%ROWCOUNT = 0 THEN
            p_result := 'NOT_FOUND';
        ELSE
            p_result := 'SUCCESS';
            COMMIT;
        END IF;
    END;

    FUNCTION CalculateAnnualSalary(
        p_employee_id IN NUMBER
    ) RETURN NUMBER IS
        v_salary NUMBER;
    BEGIN
        SELECT Salary INTO v_salary FROM Employees WHERE EmployeeID = p_employee_id;
        RETURN v_salary * 12;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;
END EmployeeManagement;
/

-- ============================================
-- Scenario 3: AccountOperations Package
-- ============================================

CREATE OR REPLACE PACKAGE AccountOperations AS
    PROCEDURE OpenAccount(
        p_account_id IN NUMBER,
        p_customer_id IN NUMBER,
        p_account_type IN VARCHAR2,
        p_balance IN NUMBER,
        p_result OUT VARCHAR2
    );
    PROCEDURE CloseAccount(
        p_account_id IN NUMBER,
        p_result OUT VARCHAR2
    );
    FUNCTION GetTotalBalance(
        p_customer_id IN NUMBER
    ) RETURN NUMBER;
END AccountOperations;
/

CREATE OR REPLACE PACKAGE BODY AccountOperations AS
    PROCEDURE OpenAccount(
        p_account_id IN NUMBER,
        p_customer_id IN NUMBER,
        p_account_type IN VARCHAR2,
        p_balance IN NUMBER,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
        VALUES (p_account_id, p_customer_id, p_account_type, p_balance, SYSDATE);
        p_result := 'SUCCESS';
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            p_result := 'ACCOUNT_EXISTS';
        WHEN OTHERS THEN
            p_result := 'ERROR';
    END;

    PROCEDURE CloseAccount(
        p_account_id IN NUMBER,
        p_result OUT VARCHAR2
    ) IS
    BEGIN
        DELETE FROM Accounts WHERE AccountID = p_account_id;
        IF SQL%ROWCOUNT = 0 THEN
            p_result := 'NOT_FOUND';
        ELSE
            p_result := 'SUCCESS';
            COMMIT;
        END IF;
    END;

    FUNCTION GetTotalBalance(
        p_customer_id IN NUMBER
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT SUM(Balance) INTO v_total FROM Accounts WHERE CustomerID = p_customer_id;
        RETURN NVL(v_total, 0);
    END;
END AccountOperations;
/

-- ============================================
-- Test the Packages
-- ============================================

SET SERVEROUTPUT ON;
DECLARE
    v_result VARCHAR2(50);
    v_balance NUMBER;
    v_annual_salary NUMBER;
    v_total_balance NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Exercise 7: Packages Test ===');
    -- Test CustomerManagement
    CustomerManagement.AddCustomer(10, 'Test Customer', TO_DATE('1995-01-01', 'YYYY-MM-DD'), 5000, v_result);
    DBMS_OUTPUT.PUT_LINE('AddCustomer result: ' || v_result);
    CustomerManagement.UpdateCustomerDetails(10, 'Test Customer Updated', TO_DATE('1995-01-01', 'YYYY-MM-DD'), v_result);
    DBMS_OUTPUT.PUT_LINE('UpdateCustomerDetails result: ' || v_result);
    v_balance := CustomerManagement.GetCustomerBalance(10);
    DBMS_OUTPUT.PUT_LINE('GetCustomerBalance: $' || v_balance);
    -- Test EmployeeManagement
    EmployeeManagement.HireEmployee(10, 'Test Employee', 'Tester', 4000, 'QA', SYSDATE, v_result);
    DBMS_OUTPUT.PUT_LINE('HireEmployee result: ' || v_result);
    EmployeeManagement.UpdateEmployeeDetails(10, 'Test Employee Updated', 'QA Tester', 4500, 'QA', v_result);
    DBMS_OUTPUT.PUT_LINE('UpdateEmployeeDetails result: ' || v_result);
    v_annual_salary := EmployeeManagement.CalculateAnnualSalary(10);
    DBMS_OUTPUT.PUT_LINE('CalculateAnnualSalary: $' || v_annual_salary);
    -- Test AccountOperations
    AccountOperations.OpenAccount(20, 10, 'Savings', 2000, v_result);
    DBMS_OUTPUT.PUT_LINE('OpenAccount result: ' || v_result);
    v_total_balance := AccountOperations.GetTotalBalance(10);
    DBMS_OUTPUT.PUT_LINE('GetTotalBalance: $' || v_total_balance);
    AccountOperations.CloseAccount(20, v_result);
    DBMS_OUTPUT.PUT_LINE('CloseAccount result: ' || v_result);
END;
/

-- Show results
SELECT 'Exercise 7 Results Summary' as Summary FROM DUAL;
SELECT * FROM Customers WHERE CustomerID = 10;
SELECT * FROM Employees WHERE EmployeeID = 10;
SELECT * FROM Accounts WHERE AccountID = 20; 