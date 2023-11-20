CREATE TYPE address_info AS OBJECT (
    id_kod_adresu INTEGER,
    kod_pocztowy VARCHAR(6),
    ulica VARCHAR(45),
    Nr_domu_lokalu VARCHAR(45)
);

CREATE OR REPLACE PROCEDURE GetAddressDetails (
    	address_data OUT address_info

) AS
	v_error BOOLEAN := FALSE;
	v_id_kod_adresu Adresy.id_kod_adresu%TYPE;
	v_kod_pocztowy Adresy.kod_pocztowy%TYPE;
	v_ulica Adresy.ulica%TYPE;
	v_Nr_domu_lokalu Adresy.Nr_domu_lokalu%TYPE;
	
	CURSOR addr_cursor IS 
		SELECT id_kod_adresu, kod_pocztowy, ulica, Nr_domu_lokalu FROM Adresy;

BEGIN 
	FOR addr_rec in addr_cursor LOOP
    	v_id_kod_adresu := addr_rec.id_kod_adresu;
    	v_kod_pocztowy := addr_rec.kod_pocztowy;
    	v_ulica := addr_rec.ulica;
    	v_Nr_domu_lokalu := addr_rec.Nr_domu_lokalu;
    
    	IF v_Nr_domu_lokalu IS NULL OR v_ulica IS NULL THEN
    		DBMS_OUTPUT.PUT_LINE('Error: One of following' || v_Nr_domu_lokalu || ' or ' || v_ulica || ' is empty');
    		v_error := TRUE;
    	-- IF REGEXP_LIKE(v_kod_pocztowy, '^\d{2}-\d{3}$')
    	ELSIF NOT REGEXP_LIKE(v_kod_pocztowy, '^\d{2}-\d{3}$') THEN
    		DBMS_OUTPUT.PUT_LINE('Error: Your kod_pocztowy has wrong format, for address_id: ' || v_id_kod_adresu);
    		v_error := TRUE;
    
    	END IF;
    
    	IF v_error THEN
    		RAISE_APPLICATION_ERROR(-2001, 'Validation failed');
    	END IF;
	END LOOP;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Addreses not found');
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('An error occured ' || SQLERRM);
END;


DECLARE
    v_address_data address_info; 
BEGIN
   GetAddressDetails(address_data => v_address_data);
    
END;
































	






