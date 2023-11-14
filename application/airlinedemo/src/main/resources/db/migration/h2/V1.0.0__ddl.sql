CREATE TABLE airline (
        airline_code VARCHAR(20),
        apt_org VARCHAR(20),
        apt_dst VARCHAR(20),
        flt_freq integer,
        PRIMARY KEY (airline_code, apt_org, apt_dst)
        )
        AS SELECT * FROM CSVREAD('./src/main/resources/db/migration/data.csv', NULL, 'fieldSeparator=^');