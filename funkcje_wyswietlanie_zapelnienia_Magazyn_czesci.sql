-- Definicja funkcji
CREATE OR REPLACE FUNCTION CheckPartStorageFullness
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT LOKACJA_ID, CZESC_ID, ILOSC_W_MAGAZYNIE, MAX_POJEMNOSC,
               ILOSC_W_MAGAZYNIE/MAX_POJEMNOSC*100 AS PartStorageFullnes
        FROM Magazyn_czesci;

    RETURN v_cursor;
END;
/

-- Wywolanie funkcji 
DECLARE
    v_result_cursor SYS_REFCURSOR;
    v_lokacja_id Magazyn_czesci.LOKACJA_ID%TYPE;
    v_czesc_id Magazyn_czesci.CZESC_ID%TYPE;
    v_ilosc_w_magazynie Magazyn_czesci.ILOSC_W_MAGAZYNIE%TYPE;
    v_max_pojemnosc Magazyn_czesci.MAX_POJEMNOSC%TYPE;
    v_part_storage_fullness NUMBER;
BEGIN
    v_result_cursor := CheckPartStorageFullness;

    LOOP
        FETCH v_result_cursor INTO v_lokacja_id, v_czesc_id, v_ilosc_w_magazynie, v_max_pojemnosc, v_part_storage_fullness;
        EXIT WHEN v_result_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Lokacja: ' || v_lokacja_id || ', czesc: ' || v_czesc_id || ', zapełnienie: ' || ROUND(v_part_storage_fullness,2) || '%');
    END LOOP;

    CLOSE v_result_cursor;
END;
/