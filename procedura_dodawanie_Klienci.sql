CREATE TYPE client_info AS OBJECT (
    Klient_ID Integer,
    Nazwa_klienta VARCHAR(45),
    Miejscowosc VARCHAR(45),
    Email VARCHAR(45),
    Telefon VARCHAR(45),
    Typ_klienta VARCHAR(45),
    id_kod_adresu VARCHAR(45)
);

-- Deklaracja procedury
CREATE OR REPLACE PROCEDURE InsertClientDetails(
    p_client_data IN client_info
) AS
    v_error BOOLEAN := FALSE;
BEGIN 
    IF p_client_data.Nazwa_klienta IS NULL OR p_client_data.Nazwa_klienta = '' THEN
        DBMS_OUTPUT.PUT_LINE('Error: Nazwa_klienta cannot be null or empty');
        v_error := TRUE;
    ELSIF p_client_data.Email IS NULL OR INSTR(p_client_data.Email, '@') = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid Email format');
        v_error := TRUE;
    ELSIF p_client_data.Telefon IS NULL OR LENGTH(p_client_data.Telefon) NOT BETWEEN 9 AND 11 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Telefon should be between 9 and 11 characters');
        v_error := TRUE;
    ELSE
        INSERT INTO Klienci (Klient_ID, Nazwa_klienta, Miejscowosc, Email, Telefon, Typ_klienta, id_kod_adresu)
        VALUES (p_client_data.Klient_ID, p_client_data.Nazwa_klienta, p_client_data.Miejscowosc, p_client_data.Email, p_client_data.Telefon, p_client_data.Typ_klienta, p_client_data.id_kod_adresu);
        
        COMMIT;
    END IF;
    
    IF v_error THEN
        RAISE_APPLICATION_ERROR(-20001, 'Validation failed');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
END;


-- wywolanie procedury
DECLARE
    v_client_data client_info := client_info(
        Klient_ID => 16,
        Nazwa_klienta => 'Wilkumka',
        Miejscowosc => 'BrzyskaUola',
        Email => 'romanisko@wp.pl',
        Telefon => '6942069420',
        Typ_klienta => 'Boss',
        id_kod_adresu => 16
    );
BEGIN
    InsertClientDetails(p_client_data => v_client_data);
END;