BEGIN TRY
    BEGIN TRANSACTION;

    -- Clear existing data in child-to-parent order
    DELETE FROM dbo.phone_log;
    DELETE FROM dbo.usage_hours;
    DELETE FROM dbo.referral_codes;
    DELETE FROM dbo.enterprise_accounts;
    DELETE FROM dbo.contact_info;

    -- Seed contact_info
    INSERT INTO dbo.contact_info (id, phone, street, city, state, postal_code) VALUES
        (1, '555-0101', '101 Oak St', 'Austin', 'TX', '78701'),
        (2, '555-0102', '202 Pine St', 'Seattle', 'WA', '98101'),
        (3, '555-0103', '303 Maple St', 'Denver', 'CO', '80202'),
        (4, '555-0104', '404 Cedar St', 'Chicago', 'IL', '60601'),
        (5, '555-0105', '505 Birch St', 'Miami', 'FL', '33101'),
        (6, '555-0106', '606 Walnut St', 'Boston', 'MA', '02108'),
        (7, '555-0107', '707 Elm St', 'Phoenix', 'AZ', '85001'),
        (8, '555-0108', '808 Spruce St', 'San Jose', 'CA', '95112'),
        (9, '555-0109', '909 Ash St', 'Portland', 'OR', '97201'),
        (10, '555-0110', '1001 Willow St', 'Nashville', 'TN', '37201');

    -- Seed phone_log with unique IDs
    INSERT INTO dbo.phone_log (id, call_timestamp, direction, reason, agent_id, duration_seconds) VALUES
        (1, '2025-01-20 09:10:00', 'inbound', 'billing', 1001, 420),
        (2, '2025-02-03 14:22:00', 'outbound', 'follow_up', 1002, 240),
        (3, '2025-02-21 10:30:00', 'inbound', 'setup', 1003, 300),
        (4, '2025-04-10 11:45:00', 'inbound', 'contract', 1004, 900),
        (5, '2025-04-18 16:15:00', 'outbound', 'renewal', 1004, 600),
        (6, '2025-06-20 13:05:00', 'inbound', 'feature_request', 1005, 360),
        (7, '2025-09-02 15:40:00', 'inbound', 'sla_review', 1006, 780),
        (8, '2025-09-21 08:55:00', 'outbound', 'onboarding', 1002, 210);

    -- Seed usage_hours with unique IDs
    INSERT INTO dbo.usage_hours (id, month, year, hours_used) VALUES
        (1, 1, 2025, 22.50),
        (2, 2, 2025, 28.75),
        (3, 2, 2025, 8.25),
        (4, 3, 2025, 16.00),
        (5, 4, 2025, 55.50),
        (6, 5, 2025, 11.75),
        (7, 6, 2025, 31.20),
        (8, 7, 2025, 6.50),
        (9, 8, 2025, 62.00),
        (10, 9, 2025, 40.40),
        (11, 10, 2025, 9.10);

    -- Seed referral_codes
    INSERT INTO dbo.referral_codes (id, referral_code, status) VALUES
        (1.0, 'REF-ALICE-01', 'active'),
        (2.0, 'REF-BOB-02', 'inactive'),
        (3.0, 'REF-CAROL-03', 'active'),
        (4.0, 'REF-DAVID-04', 'expired'),
        (5.0, 'REF-EVE-05', 'active'),
        (6.0, 'REF-FRANK-06', 'inactive'),
        (7.0, 'REF-GRACE-07', 'active'),
        (8.0, 'REF-HANK-08', 'expired'),
        (9.0, 'REF-IVY-09', 'active'),
        (10.0, 'REF-JACK-10', 'inactive');

    -- Seed enterprise_accounts
    INSERT INTO dbo.enterprise_accounts (id, business_name, contract_value_usd, renewal_date) VALUES
        (4, 'Northwind Dynamics', 85000.00, '2026-04-30'),
        (8, 'Blue Harbor Systems', 42000.00, '2026-09-15');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;