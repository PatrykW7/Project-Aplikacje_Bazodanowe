/*
    
    Podstawowa procedura sprawdzajaca czy klient posiada nazwe, czy numer telefon ma miedzy 9 i 11 znakow,
    sprawdza czy adres email posiada znak '@', czy klient ma id_kod_adresu

    ZASTANOWIC SIE CZY COS JESZCZE TUTAJ MOZNA DOROBIC
*/

-- STOWRZENIE TYPU SLUZACEGO DO PRZECHOWYWANIA DANYCH W PROCEDURZE
CREATE TYPE client_info AS OBJECT (
    Klient_ID Integer,
    Nazwa_klienta VARCHAR(45),
    Miejscowosc VARCHAR(45),
    Email VARCHAR(45),
    Telefon VARCHAR(45),
    Typ_klienta VARCHAR(45),
    id_kod_adresu VARCHAR(45)
);


-- STOWRZENIE PROCEDURY
CREATE OR REPLACE PROCEDURE GetClientDetails(
    client_data OUT client_info
) AS
	v_error BOOLEAN := FALSE;
	v_Klient_ID Klienci.Klient_ID%TYPE;
	v_Nazwa_klienta Klienci.Nazwa_klienta%TYPE;
	v_Miejscowosc Klienci.Miejscowosc%TYPE;
	v_Email Klienci.Email%TYPE;
	v_Telefon Klienci.Telefon%TYPE;
	v_Typ_klienta Klienci.Typ_klienta%TYPE;
	v_id_kod_adresu Klienci.id_kod_adresu%TYPE;
	emp_cursor SYS_REFCURSOR;

BEGIN 
	OPEN emp_cursor FOR 
		SELECT Klient_ID, Nazwa_klienta, Miejscowosc, Email, Telefon, Typ_klienta, id_kod_adresu FROM Klienci;

	LOOP
		FETCH emp_cursor INTO v_Klient_ID, v_Nazwa_klienta, v_Miejscowosc, v_Email, v_Telefon, v_Typ_klienta, v_id_kod_adresu;
		EXIT WHEN emp_cursor%NOTFOUND;

		IF v_Nazwa_klienta IS NULL THEN
			DBMS_OUTPUT.PUT_LINE('Error: CLient Name NOT FOUND OR ID' || v_Klient_ID);
			v_error:=TRUE;
		ELSIF INSTR(v_Email, '@') = 0 THEN
			DBMS_OUTPUT.PUT_LINE('Error: Email address for Client ID: ' ||v_Klient_ID|| 'is empty');
			v_error:=TRUE;
		ELSIF LENGTH(v_Telefon) NOT BETWEEN 9 AND 11 THEN
			DBMS_OUTPUT.PUT_LINE('Error: Phone number is wrong for Client ID' || v_Klient_ID);
			v_error:=TRUE;

        ELSIF v_id_kod_adresu IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error Client doesnt have address: ' ||v_Klient_ID);
            v_error:=TRUE;

		ELSE
			DBMS_OUTPUT.PUT_LINE('Clients details retrieved for Client ID: ' || v_Klient_ID || ' Nazwa: '|| v_Nazwa_klienta|| 'Email' || v_email || 'Telefon' || v_Telefon);
		END IF;

		IF v_error THEN
			RAISE_APPLICATION_ERROR(-2001, 'Validation failed');
		END IF;
	END LOOP;

	CLOSE emp_cursor;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Client Data Not Found');
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('An error occured: ' || SQLERRM);
		IF emp_cursor%ISOPEN THEN
			CLOSE emp_cursor;
		END IF;

END;

-- WYWOLANIE PROCEDURY
DECLARE
    v_client_data client_info; 
BEGIN
    GetClientDetails(client_data => v_client_data);
    
END;