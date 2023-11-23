-- Definicja funkcji
CREATE OR REPLACE FUNCTION CheckProductStorageFullness
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT LOKACJA_ID, LOKACJA_NAZWA, ILOSC_W_MAGAZYNIE, MAKSYMALNA_POJEMNOSC, PRODUKT_ID,
               ILOSC_W_MAGAZYNIE/MAKSYMALNA_POJEMNOSC*100 AS ProductStorageFullnes
        FROM Magazyn_produktow;
    RETURN v_cursor;
END;
/


-- Wywolanie funkcji
DECLARE
    v_result_cursor SYS_REFCURSOR;
    v_lokacja_id Magazyn_produktow.LOKACJA_ID%TYPE;
	v_lokacja_nazwa Magazyn_produktow.LOKACJA_NAZWA%TYPE;
    v_ilosc_w_magazynie Magazyn_produktow.ILOSC_W_MAGAZYNIE%TYPE;
    v_max_pojemnosc Magazyn_produktow.MAKSYMALNA_POJEMNOSC%TYPE;
    v_product_id Magazyn_produktow.PRODUKT_ID%TYPE;
    v_product_storage_fullness NUMBER;
BEGIN
    v_result_cursor := CheckProductStorageFullness;

    LOOP
        FETCH v_result_cursor INTO v_lokacja_id, v_lokacja_nazwa, v_ilosc_w_magazynie, v_max_pojemnosc, v_product_id, v_product_storage_fullness;
        EXIT WHEN v_result_cursor%NOTFOUND;

        
        DBMS_OUTPUT.PUT_LINE('Lokacja: ' || v_lokacja_id || ', produkt: ' || v_product_id || ', zapełnienie: ' || ROUND(v_product_storage_fullness,2) || '%');
    END LOOP;

    CLOSE v_result_cursor;
END;
/