
/*

TWORZENIE PRODUKTU

Podajesz Produkt_Id i ilosc tego produktu a funkcja przeszukuje tabele ile danych czesci na produkt potrzeba i odejmuje 
z tabeli Magazyn_czesci ilosc czesci ktore trzeba miec na ten produkt o takiej ilosci



DOROBIC DO TEGO ZEBY DODAWALO LICZBE STWORZONYCH ASORTYMENTOW DO TABELI MAGAZYN PRODUKTOW ATRYBUT ILOSC_W_MAGAZYNIE <- wystarczy dodac wartosc
parametru ilosc_sztuk_p z funkcji IloscPotrzebnychCzesci 

CREATE TABLE Brakujace_Produkty
(
Produkt_ID INT,
Brakujaca_ilosc INT
);



*/


-- FUNKCJA
CREATE OR REPLACE FUNCTION OdejmijIloscZMagazynu(
    produkt_id_p INT,
    ilosc_sztuk_p INT
) RETURN VARCHAR2 AS
    ilosc_w_magazynie INT;
    nowa_ilosc INT;
BEGIN
    SELECT Ilosc_w_magazynie INTO ilosc_w_magazynie
    FROM Magazyn_czesci
    WHERE Czesc_ID = produkt_id_p;

    nowa_ilosc := ilosc_w_magazynie - ilosc_sztuk_p;

    IF nowa_ilosc < 0 THEN
        RETURN 'Nie można odjąć takiej ilości, brak wystarczającej liczby części w magazynie.';
    ELSE
        UPDATE Magazyn_czesci
        SET Ilosc_w_magazynie = nowa_ilosc
        WHERE Czesc_ID = produkt_id_p;

        COMMIT;
        RETURN 'Zaktualizowano ilość w magazynie.';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nie znaleziono informacji o danej części w magazynie.';
    WHEN OTHERS THEN
        RETURN 'Wystąpił inny błąd.';
END;
/



DECLARE
    result_message VARCHAR2(100);
BEGIN
    result_message := OdejmijIloscZMagazynu(3, 15000000); -- Przykład: odejmowanie 150 sztuk dla części o ID 3
    DBMS_OUTPUT.PUT_LINE(result_message);
END;
/


------------------------------------------


-- II WERSJA
CREATE OR REPLACE FUNCTION OdejmijIloscZMagazynu(
    produkt_id_p INT,
    ilosc_p INT
) RETURN VARCHAR2 IS
    ilosc_w_magazynie INT;
    nowa_ilosc INT;
BEGIN
    SELECT Ilosc_w_magazynie INTO ilosc_w_magazynie
    FROM Magazyn_produktow
    WHERE Produkt_ID = produkt_id_p;

    nowa_ilosc := ilosc_w_magazynie - ilosc_p;

    IF nowa_ilosc < 0 THEN
        INSERT INTO Zamowienia_Produkty (Produkt_ID, Brakujaca_ilosc)
        VALUES (produkt_id_p, ilosc_p - ilosc_w_magazynie);

        RETURN 'Wystąpił niedobór w magazynie dla produktu o ID: ' || produkt_id_p || '. Brakująca ilość: ' || (ilosc_p - ilosc_w_magazynie);
    ELSE
        UPDATE Magazyn_produktow
        SET Ilosc_w_magazynie = nowa_ilosc
        WHERE Produkt_ID = produkt_id_p;

        RETURN 'Pomyślnie odjęto ' || ilosc_p || ' sztuk z magazynu dla produktu o ID: ' || produkt_id_p;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nie znaleziono informacji o produkcie o ID: ' || produkt_id_p || ' w magazynie.';
    WHEN OTHERS THEN
        RETURN 'Wystąpił inny błąd.';
END;
/


-- FUNKCJA

DECLARE
    wynik VARCHAR2(200);
BEGIN
    wynik := OdejmijIloscZMagazynu(3, 150);
    DBMS_OUTPUT.PUT_LINE(wynik);
END;
/


-------------------------------- PROCEDURA

CREATE OR REPLACE PROCEDURE OdejmijIloscZMagazynu(
    produkt_id_p INT,
    ilosc_p INT
) IS
    ilosc_w_magazynie INT;
    nowa_ilosc INT;
BEGIN
    SELECT Ilosc_w_magazynie INTO ilosc_w_magazynie
    FROM Magazyn_produktow
    WHERE Produkt_ID = produkt_id_p;

    nowa_ilosc := ilosc_w_magazynie - ilosc_p;

    IF nowa_ilosc < 0 THEN
        INSERT INTO Zamowienia_Produkty (Produkt_ID, Brakujaca_ilosc)
        VALUES (produkt_id_p, ilosc_p - ilosc_w_magazynie);
        
        DBMS_OUTPUT.PUT_LINE('Wystąpił niedobór w magazynie dla produktu o ID: ' || produkt_id_p || '. Brakująca ilość: ' || (ilosc_p - ilosc_w_magazynie));
    ELSE
        UPDATE Magazyn_produktow
        SET Ilosc_w_magazynie = nowa_ilosc
        WHERE Produkt_ID = produkt_id_p;
        
        DBMS_OUTPUT.PUT_LINE('Pomyślnie odjęto ' || ilosc_p || ' sztuk z magazynu dla produktu o ID: ' || produkt_id_p);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono informacji o produkcie o ID: ' || produkt_id_p || ' w magazynie.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił inny błąd.');
END;
/




DECLARE
    wynik VARCHAR2(200);
BEGIN
    OdejmijIloscZMagazynu(3, 150);
    -- Tutaj możesz wyświetlić wynik, np. wynik := OdejmijIloscZMagazynu(3, 150);
END;
/


----- Z KOLEKCJAMI I OBIEKTAMI <- DZIALA, ZASTANOWIC SIE NAD RAISE_APPLICATION ERROR JAK ZROBIC

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
BEGIN
    SELECT Ilosc_w_magazynie INTO v_ilosc_w_magazynie
    FROM Magazyn_produktow
    WHERE Produkt_ID = p_produkt_id;

    v_nowa_ilosc := v_ilosc_w_magazynie - p_ilosc;

    IF v_nowa_ilosc < 0 THEN
        v_produkty.EXTEND();
        v_produkty(v_produkty.LAST) := Produkt_Object(p_produkt_id, p_ilosc - v_ilosc_w_magazynie);

        FOR i IN 1..v_produkty.COUNT LOOP
            INSERT INTO Zamowienia_Produkty (Produkt_ID, Brakujaca_ilosc)
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
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił inny błąd.');
END;
/


BEGIN
    OdejmijIloscZMagazynu(123, 5); -- Przykładowe ID produktu i ilość do odjęcia
END;
/
