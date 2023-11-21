/*
    ZASTANOWIC SIE CZY TUTAJ ZROBIC TAK JAK U BARYKI 50% <, >
    CZY WYSWIETLAC NP. WSZYSTKIE MALEJĄCO / ROSNĄCO

*/


CREATE TYPE magazyn_produktow_info AS OBJECT (
    Lokacja_ID INTEGER,
    Lokacja_nazwa VARCHAR(45),
	Ilosc_w_magazynie INTEGER,
    Maksymalna_pojemnosc INTEGER,
    Produkt_ID INTEGER
    );


CREATE OR REPLACE PROCEDURE CheckProductStorageFullnes(
    magazyn_produktow_data OUT magazyn_produktow_info
) AS 
	
	v_error BOOLEAN:= FALSE;
	v_Lokacja_ID Magazyn_produktow.Lokacja_ID%TYPE;
	v_Ilosc_w_magazynie Magazyn_produktow.Ilosc_w_magazynie%TYPE;
	v_Maksymalna_pojemnosc Magazyn_produktow.Maksymalna_pojemnosc%TYPE;
	v_Produkt_ID Magazyn_produktow.Produkt_ID%TYPE;
	v_fullness_percent FLOAT;

	CURSOR prod_cursor IS 
		SELECT * FROM Magazyn_produktow;

BEGIN
	FOR prod_rec in prod_cursor LOOP
		v_Lokacja_ID := prod_rec.Lokacja_ID;
		v_Ilosc_w_magazynie := prod_rec.Ilosc_w_magazynie;
		v_Maksymalna_pojemnosc := prod_rec.Maksymalna_pojemnosc;
		v_Produkt_ID := prod_rec.Produkt_ID;
		v_fullness_percent := v_Ilosc_w_magazynie / v_Maksymalna_pojemnosc*100;

		IF v_Produkt_ID IS NULL THEN
			DBMS_OUTPUT.PUT_LINE('Error: No products For this Location: ' || v_Lokacja_ID);
			v_error:= TRUE;

		ELSIF v_Ilosc_w_magazynie IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error Storage for Product ID: ' || v_Produkt_ID || ' is empty');
			v_error:=TRUE;

		ELSIF v_Ilosc_w_magazynie > v_Maksymalna_pojemnosc THEN
			DBMS_OUTPUT.PUT_LINE('Error: Storage is higher than maximum value for product: ' || v_Produkt_ID);
			v_error:= TRUE;

		ELSE 
			DBMS_OUTPUT.PUT_LINE('Product: ' || v_Produkt_ID || 'has fullness: ' || v_fullness_percent);
	
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
    v_address_data magazyn_produktow_info; 
BEGIN
   CheckProductStorageFullnes(magazyn_produktow_data => v_address_data);
    
END;

