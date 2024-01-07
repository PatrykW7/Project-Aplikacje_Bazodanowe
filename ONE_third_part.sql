/*
LACZENIE FIRST_PART i SECOND_PART 
napisz nową funkcje, ktora oblicza ile danej czesci brakuje, 
jako parametr przyjmuje kursor zbudowany z Czesc_ID i Ilosc_potrzebna 
i oblicza różnicę między tym, a ilością danej części na magazynie, 
wykorzystując tabele Magazyn_czesci
*/

-- BEZ KURSORA
CREATE OR REPLACE FUNCTION ObliczBrakujaceCzesci(
    czesc_id_p INT,
    ilosc_potrzebna_p INT
) RETURN INT IS
    ilosc_w_magazynie INT;
    brakujaca_ilosc INT;
BEGIN
    SELECT Ilosc_w_magazynie INTO ilosc_w_magazynie
    FROM Magazyn_czesci
    WHERE Czesc_ID = czesc_id_p;

    IF ilosc_w_magazynie >= ilosc_potrzebna_p THEN
        brakujaca_ilosc := 0;
    ELSE
        brakujaca_ilosc := ilosc_potrzebna_p - ilosc_w_magazynie;
    END IF;

    RETURN brakujaca_ilosc;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono informacji o danej części w magazynie.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Wystąpił inny błąd.');
END;
/

-- Z KURSOREM

CREATE OR REPLACE FUNCTION ObliczBrakujaceCzesci(
    czesc_id_p INT,
    ilosc_potrzebna_p INT
) RETURN SYS_REFCURSOR IS
    ilosc_w_magazynie INT;
    brakujaca_ilosc INT;
    cur SYS_REFCURSOR;
BEGIN
    OPEN cur FOR
        SELECT CASE
                   WHEN Ilosc_w_magazynie >= ilosc_potrzebna_p THEN 0
                   ELSE ilosc_potrzebna_p - Ilosc_w_magazynie
               END AS brakujaca_ilosc
        FROM Magazyn_czesci
        WHERE Czesc_ID = czesc_id_p;

    RETURN cur;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono informacji o danej części w magazynie.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Wystąpił inny błąd.');
END;
/




-- WYWOLANIE 

DECLARE
    ilosc_czesci_cur SYS_REFCURSOR;
    czesc_id Produkt_czesci.Czesc_ID%TYPE;
    ilosc_potrzebna Produkt_czesci.wymagana_ilosc_czesci%TYPE;
    brakujaca_ilosc INT;
BEGIN
    ilosc_czesci_cur := IloscPotrzebnychCzesci(2, 5); -- Przykład: ID produktu = 2, ilość sztuk = 5

    LOOP
        FETCH ilosc_czesci_cur INTO czesc_id, ilosc_potrzebna;
        EXIT WHEN ilosc_czesci_cur%NOTFOUND;

        -- Wywołanie funkcji ObliczBrakujaceCzesci dla każdej części z wyniku IloscPotrzebnychCzesci
        brakujaca_ilosc := ObliczBrakujaceCzesci(czesc_id, ilosc_potrzebna);

        DBMS_OUTPUT.PUT_LINE('Czesc_ID: ' || czesc_id || ', Ilosc potrzebna: ' || ilosc_potrzebna ||
                             ', Brakujaca ilosc: ' || brakujaca_ilosc);
    END LOOP;

    CLOSE ilosc_czesci_cur;
END;
/

-- WYWOLANIE Z KURSOREM

DECLARE
    ilosc_czesci_cur SYS_REFCURSOR;
    czesc_id Produkt_czesci.Czesc_ID%TYPE;
    ilosc_potrzebna Produkt_czesci.wymagana_ilosc_czesci%TYPE;
    brakujaca_ilosc INT;
    cur SYS_REFCURSOR; -- Kursor do przechowywania wyniku funkcji ObliczBrakujaceCzesci
BEGIN
    ilosc_czesci_cur := IloscPotrzebnychCzesci(2, 5); -- Przykład: ID produktu = 2, ilość sztuk = 5

    LOOP
        FETCH ilosc_czesci_cur INTO czesc_id, ilosc_potrzebna;
        EXIT WHEN ilosc_czesci_cur%NOTFOUND;

        -- Wywołanie funkcji ObliczBrakujaceCzesci dla każdej części z wyniku IloscPotrzebnychCzesci
        cur := ObliczBrakujaceCzesci(czesc_id, ilosc_potrzebna);

        -- Odczytanie wartości z kursora i wyświetlenie ich
        LOOP
            FETCH cur INTO brakujaca_ilosc;
            EXIT WHEN cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Czesc_ID: ' || czesc_id || ', Ilosc potrzebna: ' || ilosc_potrzebna ||
                                 ', Brakujaca ilosc: ' || brakujaca_ilosc);
        END LOOP;

        CLOSE cur; -- Zamknięcie kursora po odczytaniu wartości
    END LOOP;

    CLOSE ilosc_czesci_cur;
END;
/