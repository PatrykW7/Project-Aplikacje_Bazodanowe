-- Deklaracja Funkcji
CREATE OR REPLACE FUNCTION CheckCustomerData
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT Klient_ID, Nazwa_klienta, Miejscowosc, Email, Telefon, Typ_klienta, id_kod_adresu
        FROM Klienci;

    RETURN v_cursor;
END;
/

-- Wywolanie Funkcji
DECLARE
    v_result_cursor SYS_REFCURSOR;
    v_klient_id Klienci.Klient_ID%TYPE;
    v_nazwa_klienta Klienci.Nazwa_klienta%TYPE;
    v_miejscowosc Klienci.Miejscowosc%TYPE;
    v_email Klienci.Email%TYPE;
    v_telefon Klienci.Telefon%TYPE;
    v_typ_klienta Klienci.Typ_klienta%TYPE;
    v_id_kod_adresu Klienci.id_kod_adresu%TYPE;
BEGIN
    v_result_cursor := CheckCustomerData;

    LOOP
        FETCH v_result_cursor INTO v_klient_id, v_nazwa_klienta, v_miejscowosc, v_email, v_telefon, v_typ_klienta, v_id_kod_adresu;
        EXIT WHEN v_result_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Klient ID: ' || v_klient_id || ', Nazwa klienta: ' || v_nazwa_klienta || ', Miejscowość: ' || v_miejscowosc || ', Email: ' || v_email || ', Telefon: ' || v_telefon || ', Typ klienta: ' || v_typ_klienta || ', ID kodu adresu: ' || v_id_kod_adresu);
    END LOOP;

    CLOSE v_result_cursor;
END;
/

