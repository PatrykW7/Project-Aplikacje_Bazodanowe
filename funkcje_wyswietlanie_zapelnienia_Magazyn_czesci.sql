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



----------------- OBIEKT + KOLEKCJE 


CREATE OR REPLACE TYPE PartStorageInfo AS OBJECT (
    Lokacja_ID INT,
    Czesc_ID INT,
    Ilosc_w_magazynie INT,
    Max_pojemnosc INT,
    Czesc_zapelnienie NUMBER
);
/

CREATE OR REPLACE TYPE PartStorageInfoList AS TABLE OF PartStorageInfo;
/

CREATE OR REPLACE FUNCTION CheckPartStorageFullness
RETURN PartStorageInfoList
AS
    v_part_storage_list PartStorageInfoList := PartStorageInfoList();
    v_index INT := 1;
BEGIN
    FOR storage_info IN (
        SELECT LOKACJA_ID, CZESC_ID, ILOSC_W_MAGAZYNIE, MAX_POJEMNOSC,
               ILOSC_W_MAGAZYNIE / MAX_POJEMNOSC * 100 AS PartStorageFullnes
        FROM Magazyn_czesci
    )
    LOOP
        v_part_storage_list.extend;
        v_part_storage_list(v_index) := PartStorageInfo(
            storage_info.LOKACJA_ID,
            storage_info.CZESC_ID,
            storage_info.ILOSC_W_MAGAZYNIE,
            storage_info.MAX_POJEMNOSC,
            storage_info.PartStorageFullnes
        );
        v_index := v_index + 1;
    END LOOP;

    RETURN v_part_storage_list;
END;
/

--------------- WYWOLANIE 

DECLARE
    v_result PartStorageInfoList := PartStorageInfoList();
BEGIN
    v_result := CheckPartStorageFullness;

    FOR i IN 1..v_result.count LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Lokacja: ' || v_result(i).Lokacja_ID || ', część: ' || v_result(i).Czesc_ID ||
            ', zapełnienie: ' || ROUND(v_result(i).Czesc_zapelnienie, 2) || '%'
        );
    END LOOP;
END;
/