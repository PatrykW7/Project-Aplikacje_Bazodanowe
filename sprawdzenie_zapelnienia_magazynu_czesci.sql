CREATE TYPE magazyn_czesci_info AS OBJECT (
   	LOKACJA_ID NUMBER,
	CZESC_ID NUMBER,
	ILOSC_W_MAGAZYNIE NUMBER,
	MAX_POJEMNOSC NUMBER
);
CREATE OR REPLACE PROCEDURE CheckStorageFullnes(
    magazyn_czesci_data OUT magazyn_czesci_info
) AS
    v_error BOOLEAN := FALSE;
    v_lokacja_id Magazyn_czesci.LOKACJA_ID%TYPE;
    v_czesc_id Magazyn_czesci.CZESC_ID%TYPE;
    v_ilosc_w_magazynie Magazyn_czesci.ILOSC_W_MAGAZYNIE%TYPE;
    v_max_pojemnosc Magazyn_czesci.MAX_POJEMNOSC%TYPE;
    v_fullness_percent NUMBER;
    CURSOR magazyn_cursor IS
        SELECT * FROM Magazyn_Czesci;
BEGIN
    FOR magazyn_record IN magazyn_cursor LOOP
        v_lokacja_id := magazyn_record.LOKACJA_ID;
        v_czesc_id  := magazyn_record.CZESC_ID;
        v_ilosc_w_magazynie := magazyn_record.ILOSC_W_MAGAZYNIE;
        v_max_pojemnosc := magazyn_record.MAX_POJEMNOSC;
        v_fullness_percent := v_ilosc_w_magazynie/v_max_pojemnosc*100;
        IF v_czesc_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Parts are empty for location ' || v_lokacja_id);
            v_error := TRUE;
        ELSIF v_ilosc_w_magazynie > v_max_pojemnosc/2 THEN
            DBMS_OUTPUT.PUT_LINE('Location ' || v_lokacja_id || ' has ' || ROUND(v_fullness_percent,2) || '% of capacity of part ' || v_czesc_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Not enough part ' || v_czesc_id || ' in location ' || v_lokacja_id || '. ' || ROUND(v_fullness_percent,2) || '% of capacity is not enough for production');
        END IF;
        IF v_error THEN
            RAISE_APPLICATION_ERROR(-2001, 'Validation failed');
        END IF;
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Location data not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
DECLARE
    v_storage_data magazyn_czesci_info;
BEGIN
    CheckStorageFullnes(magazyn_czesci_data => v_storage_data);
END;
