
/*
Sprawdzany jest stan produków, ile jest na magazynie tego co chce kupic klient, 
jeśli tego nie ma to sprawdzamy ile produktów brakuje do spełnienia zamówienia
*/

CREATE OR REPLACE TYPE BrakujacyProdukt AS OBJECT (
    Nazwa_produktu VARCHAR(100),
    Brakujaca_ilosc INT
);
/

CREATE OR REPLACE TYPE ListaBrakujacychProduktow AS TABLE OF BrakujacyProdukt;
/

CREATE OR REPLACE FUNCTION SprawdzDostepnoscProduktu(
    nazwa_produktu IN VARCHAR,
    ilosc_do_zamowienia IN INT
) RETURN ListaBrakujacychProduktow IS
    ilosc_dostepna INT;
    brakujace_produkty ListaBrakujacychProduktow := ListaBrakujacychProduktow();
    brakujacy_produkt BrakujacyProdukt;
BEGIN
    IF ilosc_do_zamowienia <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ilość do zamówienia musi być liczbą dodatnią.');
    END IF;

    BEGIN
        SELECT MAX(mp.Ilosc_w_magazynie) INTO ilosc_dostepna
        FROM Magazyn_produktow mp
        JOIN Produkty p ON mp.Produkt_ID = p.Produkt_ID
        WHERE p.Nazwa_produktu = nazwa_produktu;

        IF ilosc_dostepna < ilosc_do_zamowienia THEN
            brakujacy_produkt := BrakujacyProdukt(nazwa_produktu, ilosc_do_zamowienia - ilosc_dostepna);
            brakujace_produkty.extend();
            brakujace_produkty(brakujace_produkty.count) := brakujacy_produkt;
        END IF;

        RETURN brakujace_produkty;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nazwa produktu nie istnieje w bazie danych.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'Wystąpił inny błąd.');
    END;
END;
/

-- WYWOLANIE 

DECLARE
    brakujace_produkty ListaBrakujacychProduktow;
BEGIN
    brakujace_produkty := SprawdzDostepnoscProduktu('NazwaProduktu', 10); -- Podaj nazwę produktu i ilość do zamówienia

    IF brakujace_produkty IS NOT NULL AND brakujace_produkty.COUNT > 0 THEN
        FOR i IN 1..brakujace_produkty.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Brakuje ' || brakujace_produkty(i).Brakujaca_ilosc ||
                                  ' sztuk produktu ' || brakujace_produkty(i).Nazwa_produktu);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Produkty są dostępne w wystarczającej ilości.');
    END IF;
END;
/


/*
INNE WYWOLANIE - BEZ PETLi
*/

DECLARE
    brakujace_produkty ListaBrakujacychProduktow;
BEGIN
    brakujace_produkty := SprawdzDostepnoscProduktu('Pralka', 10); -- Podaj nazwę produktu i ilość do zamówienia

    IF brakujace_produkty IS NOT NULL AND brakujace_produkty.COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brakuje ' || brakujace_produkty(1).Brakujaca_ilosc ||
                              ' sztuk produktu ' || brakujace_produkty(1).Nazwa_produktu);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Produkty są dostępne w wystarczającej ilości.');
    END IF;
END;
/

------------------------------------------------------------------------------------

-- FUNKCJA Z KOLEKCJA, SPRAWDZENIEM CZY LICZBA JEST WIEKSZA OD 0

CREATE OR REPLACE FUNCTION SprawdzDostepnoscProduktu(
    nazwa_produktu IN VARCHAR,
    ilosc_do_zamowienia IN INT
) RETURN ListaBrakujacychProduktow IS
    ilosc_dostepna INT;
    brakujace_produkty ListaBrakujacychProduktow := ListaBrakujacychProduktow();
    brakujacy_produkt BrakujacyProdukt;
BEGIN
    IF ilosc_do_zamowienia <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ilość do zamówienia musi być liczbą dodatnią.');
    END IF;

    BEGIN
        SELECT MAX(mp.Ilosc_w_magazynie) INTO ilosc_dostepna
        FROM Magazyn_produktow mp
        JOIN Produkty p ON mp.Produkt_ID = p.Produkt_ID
        WHERE p.Nazwa_produktu = nazwa_produktu;

        IF ilosc_dostepna < ilosc_do_zamowienia THEN
            brakujacy_produkt := BrakujacyProdukt(nazwa_produktu, ilosc_do_zamowienia - ilosc_dostepna);
            brakujace_produkty.extend();
            brakujace_produkty(brakujace_produkty.count) := brakujacy_produkt;
        END IF;

        RETURN brakujace_produkty;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nazwa produktu nie istnieje w bazie danych.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'Wystąpił inny błąd.');
    END;
END;
/




-- WYWOLANIE 


DECLARE
    brakujace_produkty ListaBrakujacychProduktow;
BEGIN
    brakujace_produkty := SprawdzDostepnoscProduktu('Pralka', 10); -- Podaj nazwę produktu i ilość do zamówienia

    IF brakujace_produkty IS NOT NULL AND brakujace_produkty.COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brakuje ' || brakujace_produkty(1).Brakujaca_ilosc ||
                              ' sztuk produktu ' || brakujace_produkty(1).Nazwa_produktu);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Produkty są dostępne w wystarczającej ilości.');
    END IF;
END;
/