
/*


CREATE TABLE Brakujace_Produkty
(
Produkt_ID INT,
Brakujaca_ilosc INT
);



*/

CREATE OR REPLACE TYPE Produkt_Object AS OBJECT (
    Produkt_ID INT,
    Brakujaca_ilosc INT
);
/

CREATE OR REPLACE TYPE Produkty_Collection AS TABLE OF Produkt_Object;
/

CREATE OR REPLACE PROCEDURE OdejmijIloscZMagazynu(
    p_produkt_id INT,
    p_ilosc INT
) IS
    v_ilosc_w_magazynie INT;
    v_nowa_ilosc INT;
    v_produkty Produkty_Collection := Produkty_Collection();
	BAD_PROD EXCEPTION;
	BAD_NUMB EXCEPTION;
BEGIN
    SELECT Ilosc_w_magazynie INTO v_ilosc_w_magazynie
    FROM Magazyn_produktow
    WHERE Produkt_ID = p_produkt_id;

	IF v_ilosc_w_magazynie = 0 THEN
        RAISE BAD_PROD;
	END IF;

	if p_ilosc < 0 THEN
        RAISE BAD_NUMB;
	END IF;

    v_nowa_ilosc := v_ilosc_w_magazynie - p_ilosc;

    IF v_nowa_ilosc < 0 THEN
        v_produkty.EXTEND();
        v_produkty(v_produkty.LAST) := Produkt_Object(p_produkt_id, p_ilosc - v_ilosc_w_magazynie);

        FOR i IN 1..v_produkty.COUNT LOOP
            INSERT INTO Brakujace_produkty (Produkt_ID, Brakujaca_ilosc)
            VALUES (v_produkty(i).Produkt_ID, v_produkty(i).Brakujaca_ilosc);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Wystąpił niedobór w magazynie dla produktu o ID: ' || p_produkt_id || '. Brakująca ilość: ' || (p_ilosc - v_ilosc_w_magazynie));
    ELSE
        UPDATE Magazyn_produktow
        SET Ilosc_w_magazynie = v_nowa_ilosc
        WHERE Produkt_ID = p_produkt_id;

        DBMS_OUTPUT.PUT_LINE('Pomyślnie odjęto ' || p_ilosc || ' sztuk z magazynu dla produktu o ID: ' || p_produkt_id);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono informacji o produkcie o ID: ' || p_produkt_id || ' w magazynie.');
	WHEN BAD_PROD THEN
        DBMS_OUTPUT.PUT_LINE('Podane ID produktu nie istnieje w bazie danych Produkty.');
	WHEN BAD_NUMB THEN
        DBMS_OUTPUT.PUT_LINE('Ilosc musi byc wieksza od 0');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił inny błąd.');
END;
/


-- WYWOLANIE 

BEGIN
    OdejmijIloscZMagazynu(3, 1); -- Tutaj zmień ID produktu i ilość
END;
/

