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


--- KOLEKCJA + OBIEKT

CREATE OR REPLACE TYPE ProductStorageInfo AS OBJECT (
    Lokacja_ID INT,
    Lokacja_nazwa VARCHAR(45),
    Ilosc_w_magazynie INT,
    Maksymalna_pojemnosc INT,
    Produkt_ID INT,
    Produkt_zapelnienie NUMBER
);
/

CREATE OR REPLACE TYPE ProductStorageInfoList AS TABLE OF ProductStorageInfo;
/

CREATE OR REPLACE FUNCTION CheckProductStorageFullness
RETURN ProductStorageInfoList
AS
    v_product_storage_list ProductStorageInfoList := ProductStorageInfoList();
    v_index INT := 1;
BEGIN
    FOR storage_info IN (
        SELECT LOKACJA_ID, LOKACJA_NAZWA, ILOSC_W_MAGAZYNIE, MAKSYMALNA_POJEMNOSC, PRODUKT_ID,
               ILOSC_W_MAGAZYNIE / MAKSYMALNA_POJEMNOSC * 100 AS ProductStorageFullnes
        FROM Magazyn_produktow
    )
    LOOP
        v_product_storage_list.extend;
        v_product_storage_list(v_index) := ProductStorageInfo(
            storage_info.LOKACJA_ID,
            storage_info.LOKACJA_NAZWA,
            storage_info.ILOSC_W_MAGAZYNIE,
            storage_info.MAKSYMALNA_POJEMNOSC,
            storage_info.PRODUKT_ID,
            storage_info.ProductStorageFullnes
        );
        v_index := v_index + 1;
    END LOOP;

    RETURN v_product_storage_list;
END;
/

DECLARE
    v_result ProductStorageInfoList := ProductStorageInfoList();
BEGIN
    v_result := CheckProductStorageFullness;

    FOR i IN 1..v_result.count LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Lokacja: ' || v_result(i).Lokacja_ID || ', produkt: ' || v_result(i).Produkt_ID ||
            ', zapełnienie: ' || ROUND(v_result(i).Produkt_zapelnienie, 2) || '%'
        );
    END LOOP;
END;
/



-- WYWOLANIE 

DECLARE
    v_result ProductStorageInfoList := ProductStorageInfoList();
BEGIN
    v_result := CheckProductStorageFullness;

    FOR i IN 1..v_result.count LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Lokacja: ' || v_result(i).Lokacja_ID || ', produkt: ' || v_result(i).Produkt_ID ||
            ', zapełnienie: ' || ROUND(v_result(i).Produkt_zapelnienie, 2) || '%'
        );
    END LOOP;
END;
/
