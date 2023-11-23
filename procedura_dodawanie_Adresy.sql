CREATE TYPE address_info AS OBJECT (
    id_kod_adresu INTEGER,
    kod_pocztowy VARCHAR(6),
    ulica VARCHAR(45),
    Nr_domu_lokalu VARCHAR(45)
);

-- Deklaracja Procedury
CREATE OR REPLACE PROCEDURE AddAddressDetails (
    address_data IN address_info
) AS
BEGIN
    IF address_data.Nr_domu_lokalu IS NULL OR address_data.ulica IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: One of the following attributes is empty: Nr_domu_lokalu or ulica.');
        RAISE_APPLICATION_ERROR(-2001, 'Validation failed: Empty attributes');
    ELSIF NOT REGEXP_LIKE(address_data.kod_pocztowy, '^\d{2}-\d{3}$') THEN
        DBMS_OUTPUT.PUT_LINE('Error: Wrong format for kod_pocztowy: ' || address_data.kod_pocztowy);
        RAISE_APPLICATION_ERROR(-2002, 'Validation failed: Incorrect kod_pocztowy format');
    ELSE
        INSERT INTO Adresy (id_kod_adresu, kod_pocztowy, ulica, Nr_domu_lokalu)
        VALUES (address_data.id_kod_adresu, address_data.kod_pocztowy, address_data.ulica, address_data.Nr_domu_lokalu);
        DBMS_OUTPUT.PUT_LINE('Address details added successfully.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

-- Wywolanie procedury
DECLARE
    v_address_data address_info := address_info(1, '12-345', 'Sample Street', '12A');
BEGIN
    AddAddressDetails(address_data => v_address_data);
END;