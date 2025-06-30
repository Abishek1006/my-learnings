-- Scenario 1: Apply discount to loan interest rates for customers above 60
-- ============================================

DECLARE
    v_customer_age NUMBER;
    v_old_rate NUMBER;
    v_new_rate NUMBER;
    v_customer_count NUMBER := 0;
    v_updated_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Scenario 1: Applying 1% discount to customers above 60 ===');
    DBMS_OUTPUT.PUT_LINE('Processing customers for loan interest rate discount...');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    
    -- Loop through all customers
    FOR customer_rec IN (SELECT c.CustomerID, c.Name, c.DOB, l.LoanID, l.InterestRate
                        FROM Customers c
                        LEFT JOIN Loans l ON c.CustomerID = l.CustomerID
                        ORDER BY c.CustomerID) LOOP
        
        v_customer_count := v_customer_count + 1;
        
        -- Calculate customer age
        v_customer_age := FLOOR(MONTHS_BETWEEN(SYSDATE, customer_rec.DOB)/12);
        
        -- Check if customer has loans and is above 60
        IF customer_rec.LoanID IS NOT NULL AND v_customer_age > 60 THEN
            v_old_rate := customer_rec.InterestRate;
            v_new_rate := customer_rec.InterestRate - 1;
            
            -- Update the loan interest rate
            UPDATE Loans 
            SET InterestRate = v_new_rate 
            WHERE LoanID = customer_rec.LoanID;
            
            v_updated_count := v_updated_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.Name || 
                                ' (Age: ' || v_customer_age || 
                                ') - Loan ID: ' || customer_rec.LoanID ||
                                ' - Rate updated from ' || v_old_rate || '% to ' || v_new_rate || '%');
        ELSIF customer_rec.LoanID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.Name || 
                                ' (Age: ' || v_customer_age || ') - No loans found');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.Name || 
                                ' (Age: ' || v_customer_age || ') - Below 60, no discount applied');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total customers processed: ' || v_customer_count);
    DBMS_OUTPUT.PUT_LINE('Loans updated with discount: ' || v_updated_count);
    DBMS_OUTPUT.PUT_LINE('');
    
    COMMIT;
END;
/

-- ============================================
-- Scenario 2: Promote customers to VIP status based on balance
-- ============================================

DECLARE
    v_customer_count NUMBER := 0;
    v_vip_promoted NUMBER := 0;
    v_already_vip NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Scenario 2: Promoting customers to VIP status ===');
    DBMS_OUTPUT.PUT_LINE('Processing customers for VIP promotion...');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    
    -- Loop through all customers
    FOR customer_rec IN (SELECT CustomerID, Name, Balance, IsVIP 
                        FROM Customers 
                        ORDER BY CustomerID) LOOP
        
        v_customer_count := v_customer_count + 1;
        
        -- Check if customer qualifies for VIP status
        IF customer_rec.Balance > 10000 THEN
            IF customer_rec.IsVIP = 'N' THEN
                -- Update customer to VIP status
                UPDATE Customers 
                SET IsVIP = 'Y', LastModified = SYSDATE 
                WHERE CustomerID = customer_rec.CustomerID;
                
                v_vip_promoted := v_vip_promoted + 1;
                
                DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.Name || 
                                    ' - Balance: $' || customer_rec.Balance ||
                                    ' - PROMOTED to VIP status');
            ELSE
                v_already_vip := v_already_vip + 1;
                DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.Name || 
                                    ' - Balance: $' || customer_rec.Balance ||
                                    ' - Already VIP');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Customer: ' || customer_rec.Name || 
                                ' - Balance: $' || customer_rec.Balance ||
                                ' - Below $10,000 threshold');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total customers processed: ' || v_customer_count);
    DBMS_OUTPUT.PUT_LINE('New VIP promotions: ' || v_vip_promoted);
    DBMS_OUTPUT.PUT_LINE('Already VIP: ' || v_already_vip);
    DBMS_OUTPUT.PUT_LINE('');
    
    COMMIT;
END;
/

-- ============================================
-- Scenario 3: Send reminders for loans due within 30 days
-- ============================================

DECLARE
    v_loan_count NUMBER := 0;
    v_due_soon_count NUMBER := 0;
    v_days_remaining NUMBER;
    v_reminder_message VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Scenario 3: Sending loan due reminders ===');
    DBMS_OUTPUT.PUT_LINE('Checking loans due within 30 days...');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    
    -- Loop through all loans
    FOR loan_rec IN (SELECT l.LoanID, l.LoanAmount, l.InterestRate, l.EndDate,
                           c.CustomerID, c.Name, c.Balance
                    FROM Loans l
                    JOIN Customers c ON l.CustomerID = c.CustomerID
                    ORDER BY l.EndDate) LOOP
        
        v_loan_count := v_loan_count + 1;
        
        -- Calculate days remaining until loan is due
        v_days_remaining := l.EndDate - SYSDATE;
        
        -- Check if loan is due within 30 days
        IF v_days_remaining <= 30 AND v_days_remaining > 0 THEN
            v_due_soon_count := v_due_soon_count + 1;
            
            -- Create appropriate reminder message based on days remaining
            IF v_days_remaining <= 7 THEN
                v_reminder_message := 'URGENT: Your loan is due in ' || v_days_remaining || ' days!';
            ELSIF v_days_remaining <= 14 THEN
                v_reminder_message := 'IMPORTANT: Your loan is due in ' || v_days_remaining || ' days.';
            ELSE
                v_reminder_message := 'REMINDER: Your loan is due in ' || v_days_remaining || ' days.';
            END IF;
            
            DBMS_OUTPUT.PUT_LINE('Customer: ' || loan_rec.Name);
            DBMS_OUTPUT.PUT_LINE('  Loan ID: ' || loan_rec.LoanID);
            DBMS_OUTPUT.PUT_LINE('  Amount: $' || loan_rec.LoanAmount);
            DBMS_OUTPUT.PUT_LINE('  Interest Rate: ' || loan_rec.InterestRate || '%');
            DBMS_OUTPUT.PUT_LINE('  Due Date: ' || TO_CHAR(loan_rec.EndDate, 'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('  Days Remaining: ' || v_days_remaining);
            DBMS_OUTPUT.PUT_LINE('  Message: ' || v_reminder_message);
            DBMS_OUTPUT.PUT_LINE('  Current Balance: $' || loan_rec.Balance);
            DBMS_OUTPUT.PUT_LINE('  ---');
            
        ELSIF v_days_remaining <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('Customer: ' || loan_rec.Name || 
                                ' - Loan ID: ' || loan_rec.LoanID ||
                                ' - OVERDUE by ' || ABS(v_days_remaining) || ' days');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Customer: ' || loan_rec.Name || 
                                ' - Loan ID: ' || loan_rec.LoanID ||
                                ' - Due in ' || v_days_remaining || ' days (no reminder needed)');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total loans processed: ' || v_loan_count);
    DBMS_OUTPUT.PUT_LINE('Reminders sent: ' || v_due_soon_count);
    DBMS_OUTPUT.PUT_LINE('');
    
END;
/

-- Display results after running all scenarios
SELECT 'Exercise 1 Results Summary' as Summary FROM DUAL;

-- Show updated loan interest rates
SELECT 'Updated Loan Interest Rates' as Info FROM DUAL;
SELECT l.LoanID, c.Name, l.InterestRate, l.LoanAmount
FROM Loans l
JOIN Customers c ON l.CustomerID = c.CustomerID
ORDER BY l.LoanID;

-- Show VIP status
SELECT 'VIP Status Updates' as Info FROM DUAL;
SELECT CustomerID, Name, Balance, IsVIP
FROM Customers
ORDER BY CustomerID; 