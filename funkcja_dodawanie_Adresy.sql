CREATE TYPE address_info AS OBJECT (
    id_kod_adresu INTEGER,
    kod_pocztowy VARCHAR(6),
    ulica VARCHAR(45),
    Nr_domu_lokalu VARCHAR(45)
);


CREATE OR REPLACE FUNCTION AddAddressDetails (
    address_data IN address_info
) RETURN BOOLEAN AS
BEGIN
    IF address_data.Nr_domu_lokalu IS NULL OR address_data.ulica IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: One of the following attributes is empty: Nr_domu_lokalu or ulica.');
        RAISE_APPLICATION_ERROR(-2001, 'Validation failed: Empty attributes');
        RETURN FALSE;
    ELSIF NOT REGEXP_LIKE(address_data.kod_pocztowy, '^\d{2}-\d{3}$') THEN
        DBMS_OUTPUT.PUT_LINE('Error: Wrong format for kod_pocztowy: ' || address_data.kod_pocztowy);
        RAISE_APPLICATION_ERROR(-2002, 'Validation failed: Incorrect kod_pocztowy format');
        RETURN FALSE;
    ELSE
        INSERT INTO Adresy (id_kod_adresu, kod_pocztowy, ulica, Nr_domu_lokalu)
        VALUES (address_data.id_kod_adresu, address_data.kod_pocztowy, address_data.ulica, address_data.Nr_domu_lokalu);
        DBMS_OUTPUT.PUT_LINE('Address details added successfully.');
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        RETURN FALSE;
END;


DECLARE
    address_data address_info; -- Przykładowe dane adresowe, dostosuj do swoich potrzeb
    success BOOLEAN;
BEGIN
    -- Inicjalizacja danych adresowych
    address_data := address_info(
        id_kod_adresu => 101,
        kod_pocztowy => '12-345',
        ulica => 'Sample Street',
        Nr_domu_lokalu => '12A'
    );

    -- Wywołanie funkcji
    success := AddAddressDetails(address_data);

    -- Sprawdzenie rezultatu
    IF success THEN
        DBMS_OUTPUT.PUT_LINE('Operacja zakończona pomyślnie.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Operacja zakończona niepowodzeniem.');
    END IF;
END;
