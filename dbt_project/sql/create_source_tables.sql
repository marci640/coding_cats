-- Create raw source schema and tables defined in models/sources.yml
-- Azure SQL Database compatible version


DROP TABLE IF EXISTS dbo.contact_info;
DROP TABLE IF EXISTS dbo.phone_log;
DROP TABLE IF EXISTS dbo.usage_hours;
DROP TABLE IF EXISTS dbo.referral_codes;
DROP TABLE IF EXISTS dbo.enterprise_accounts;

CREATE TABLE dbo.contact_info (
    id INT NOT NULL,
    phone VARCHAR(255) NULL,
    street VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    state VARCHAR(255) NULL,
    postal_code VARCHAR(20) NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dbo.phone_log (
    id INT NOT NULL,
    call_timestamp DATETIME2 NOT NULL,
    direction VARCHAR(50) NOT NULL,
    reason VARCHAR(255) NULL,
    agent_id INT NULL,
    duration_seconds INT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dbo.usage_hours (
    id INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    hours_used DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dbo.referral_codes (
    id FLOAT NOT NULL,
    referral_code VARCHAR(100) NULL,
    status VARCHAR(50) NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dbo.enterprise_accounts (
    id INT NOT NULL,
    business_name VARCHAR(255) NULL,
    contract_value_usd DECIMAL(10,2) NULL,
    renewal_date DATE NULL,
    PRIMARY KEY (id)
);
