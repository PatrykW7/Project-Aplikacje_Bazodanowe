CREATE TYPE client_info AS OBJECT (
    Klient_ID Integer,
    Nazwa_klienta VARCHAR(45),
    Miejscowosc VARCHAR(45),
    Email VARCHAR(45),
    Telefon VARCHAR(45),
    Typ_klienta VARCHAR(45),
    id_kod_adresu VARCHAR(45)
);


CREATE OR REPLACE FUNCTION InsertClientDetails(
    p_client_data IN client_info
) RETURN BOOLEAN AS
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

    RETURN NOT v_error; -- Zwracamy TRUE, jeśli operacja przebiegła pomyślnie, FALSE w przeciwnym razie
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
        RETURN FALSE; -- Zwracamy FALSE w przypadku wystąpienia błędu
END;


DECLARE
    client_data client_info; -- Przykładowe dane klienta, dostosuj do swoich potrzeb
    success BOOLEAN;
BEGIN
    -- Inicjalizacja danych klienta
    client_data := client_info(
        Klient_ID => 69,
        Nazwa_klienta => 'Przykładowa Firma',
        Miejscowosc => 'Warszawa',
        Email => 'przykladowa@firma.com',
        Telefon => '123456789',
        Typ_klienta => 'normalny',
        id_kod_adresu => '14'
    );

    -- Wywołanie funkcji
    success := InsertClientDetails(client_data);

    -- Sprawdzenie rezultatu
    IF success THEN
        DBMS_OUTPUT.PUT_LINE('Operacja zakończona pomyślnie.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Operacja zakończona niepowodzeniem.');
    END IF;
END;
/
