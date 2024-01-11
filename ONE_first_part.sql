
/*
Sprawdzany jest stan produków, ile jest na magazynie tego co chce kupic klient, 
jeśli tego nie ma to sprawdzamy ile produktów brakuje do spełnienia zamówienia i wyswietlamy ta informacje
*/

CREATE OR REPLACE TYPE BrakujacyProdukt AS OBJECT (
    Produkt_ID INT,
    Brakujaca_ilosc INT
);
/

CREATE OR REPLACE TYPE ListaBrakujacychProduktow AS TABLE OF BrakujacyProdukt;
/

CREATE OR REPLACE PROCEDURE SprawdzIloscWMagazynie(
    p_Produkt_ID IN INT,
    p_ilosc IN INT
) IS
    ilosc_w_magazynie INT;
    roznica INT;
    brakujace_produkty ListaBrakujacychProduktow := ListaBrakujacychProduktow();
    brakujacy_produkt BrakujacyProdukt;
    BAD_NUMB EXCEPTION;
BEGIN 
    SELECT Ilosc_w_magazynie INTO ilosc_w_magazynie
    FROM Magazyn_produktow
    WHERE Produkt_ID = p_Produkt_ID;

    IF p_ilosc < 0 THEN
        RAISE BAD_NUMB;
    END IF;

    IF ilosc_w_magazynie >= p_ilosc THEN
        DBMS_OUTPUT.PUT_LINE('Wystarczająca ilość w magazynie');
    ELSE
        roznica := p_ilosc - ilosc_w_magazynie;
        DBMS_OUTPUT.PUT_LINE('Brakuje ' || roznica || ' produktu');

        -- Dodanie brakujących produktów do kolekcji
        brakujacy_produkt := BrakujacyProdukt(p_Produkt_ID, roznica);
        brakujace_produkty.EXTEND();
        brakujace_produkty(brakujace_produkty.COUNT) := brakujacy_produkt;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono produktu o podanym ID.');
    WHEN BAD_NUMB THEN
        DBMS_OUTPUT.PUT_LINE('Ilość nie może być mniejsza od zera');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił inny błąd.');
END;
/


-- WYWOLANIE 

DECLARE
    ProduktID INT := 123; -- Zmienić na istniejące ID produktu
    IloscDoZamowienia INT := 50; -- Zmienić na odpowiednią ilość do zamówienia
BEGIN
    SprawdzIloscWMagazynie(ProduktID, IloscDoZamowienia);
END;
/
