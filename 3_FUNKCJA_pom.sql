/*
Funkcja przyjmujaca jako parametr nazwe asortymentu i jego ilosc, wyswietla ile danej czesci jest 
potrzebne do zbudowania danego asortymentu



TO BEDZIE FUNKCJA POMOCNICZA
*/

CREATE OR REPLACE FUNCTION IloscPotrzebnychCzesci(
    produkt_id_p INT,
    ilosc_sztuk_p INT
) RETURN SYS_REFCURSOR IS
    ilosc_czesci_cur SYS_REFCURSOR;
BEGIN
    OPEN ilosc_czesci_cur FOR
        SELECT pc.Czesc_ID, pc.wymagana_ilosc_czesci * ilosc_sztuk_p AS ilosc_potrzebna
        FROM Produkt_czesci pc
        WHERE pc.Produkt_ID = produkt_id_p;

    RETURN ilosc_czesci_cur;
END;
/


DECLARE
    ilosc_czesci_cur SYS_REFCURSOR;
    czesc_id Produkt_czesci.Czesc_ID%TYPE;
    ilosc_potrzebna Produkt_czesci.wymagana_ilosc_czesci%TYPE;
BEGIN
    ilosc_czesci_cur := IloscPotrzebnychCzesci(2, 5); -- Przykład: ID produktu = 2, ilość sztuk = 5

    LOOP
        FETCH ilosc_czesci_cur INTO czesc_id, ilosc_potrzebna;
        EXIT WHEN ilosc_czesci_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Czesc_ID: ' || czesc_id || ', Ilosc potrzebna: ' || ilosc_potrzebna);
    END LOOP;

    CLOSE ilosc_czesci_cur;
END;
/

---------------------------


/* 
WYWOLANIE OBU FUNKCJI, POLACZANE FUNKCJA I i II



ZASTANOWIC SIE CZY W TEJ POSTACI TO MA SENS W OGOLE 
*/



DECLARE
    brakujace_produkty ListaBrakujacychProduktow;
    ilosc_czesci_cur SYS_REFCURSOR;
    czesc_id Produkt_czesci.Czesc_ID%TYPE;
    ilosc_potrzebna Produkt_czesci.wymagana_ilosc_czesci%TYPE;
    produkt_id Produkty.Produkt_ID%TYPE; -- Dodaj deklarację zmiennej produkt_id
BEGIN
    brakujace_produkty := SprawdzDostepnoscProduktu('Pralka', 10); -- Podaj nazwę produktu i ilość do zamówienia

    IF brakujace_produkty IS NOT NULL AND brakujace_produkty.COUNT > 0 THEN
        FOR i IN 1..brakujace_produkty.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Brakuje ' || brakujace_produkty(i).Brakujaca_ilosc ||
                                  ' sztuk produktu ' || brakujace_produkty(i).Nazwa_produktu);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Produkty są dostępne w wystarczającej ilości.');

        -- Pobranie id produktu na podstawie nazwy zwróconej przez funkcję SprawdzDostepnoscProduktu
        SELECT Produkt_ID INTO produkt_id
        FROM Produkty
        WHERE Nazwa_produktu = 'Pralka';

        -- Wywołanie funkcji IloscPotrzebnychCzesci z parametrami z funkcji SprawdzDostepnoscProduktu
        ilosc_czesci_cur := IloscPotrzebnychCzesci(produkt_id, 10); -- Przykład: ID produktu = 2, ilość sztuk = 10

        LOOP
            FETCH ilosc_czesci_cur INTO czesc_id, ilosc_potrzebna;
            EXIT WHEN ilosc_czesci_cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Czesc_ID: ' || czesc_id || ', Ilosc potrzebna: ' || ilosc_potrzebna);
        END LOOP;

        CLOSE ilosc_czesci_cur;
    END IF;
END;
/
