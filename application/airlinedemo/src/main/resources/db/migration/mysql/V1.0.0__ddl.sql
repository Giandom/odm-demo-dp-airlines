CREATE TABLE airline (
        airline_code VARCHAR(20),
        apt_org VARCHAR(20),
        apt_dst VARCHAR(20),
        flt_freq integer,
        PRIMARY KEY (airline_code, apt_org, apt_dst)
        );

LOAD DATA LOCAL INFILE './src/main/resources/db/migration/data.csv' INTO TABLE airline
    FIELDS TERMINATED BY '^'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;