-- Utworzenie funkcji
CREATE OR REPLACE FUNCTION GetEmployeeData
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT PESEL, Imie, Nazwisko, id_kod_adresu, Linia_ID, id_zatrudnienia, Data_urodzenia, Miejscowosc, Email, Telefon, Wyksztalcenie
        FROM Pracownicy;

    RETURN v_cursor;
END;
/

--Wywolanie funkcji
DECLARE
    v_result_cursor SYS_REFCURSOR;
    v_pesel VARCHAR2(11);
    v_imie VARCHAR2(45);
    v_nazwisko VARCHAR2(45);
    v_id_kod_adresu INT;
    v_linia_id INT;
    v_id_zatrudnienia INT;
    v_data_urodzenia DATE;
    v_miejscowosc VARCHAR2(45);
    v_email VARCHAR2(45);
    v_telefon VARCHAR2(20);
    v_wyksztalcenie VARCHAR2(45);
BEGIN
    v_result_cursor := GetEmployeeData;

    LOOP
        FETCH v_result_cursor INTO v_pesel, v_imie, v_nazwisko, v_id_kod_adresu, v_linia_id, v_id_zatrudnienia, v_data_urodzenia, v_miejscowosc, v_email, v_telefon, v_wyksztalcenie;
        EXIT WHEN v_result_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('PESEL: ' || v_pesel || ', Imię: ' || v_imie || ', Nazwisko: ' || v_nazwisko || ', Telefon: ' || v_telefon);
    END LOOP;

    CLOSE v_result_cursor;
END;
/

