/*
Sprawdza ile czesci potrzeba na dana ilosc asortymentu i sprawdza czy jest tyle czesci w magazynie, a jesli tak to
usuwa dana ilosc czesci 


ZAWIERA POMOCNICZA FUNKCJE IloscPotrzebnychCzesci

*/






CREATE OR REPLACE PROCEDURE AktualizujMagazyny(p_czesci_cur SYS_REFCURSOR) AS
    v_czesc_id Magazyn_czesci.Czesc_ID%TYPE;
    v_ilosc_potrzebna INT;
    v_brakuje BOOLEAN := false;
BEGIN
    LOOP
        FETCH p_czesci_cur INTO v_czesc_id, v_ilosc_potrzebna;
        EXIT WHEN p_czesci_cur%NOTFOUND;

        -- Sprawdzenie czy ilość potrzebna jest większa od ilości w magazynie
        FOR magazyn IN (SELECT Ilosc_w_magazynie FROM Magazyn_czesci WHERE Czesc_ID = v_czesc_id) LOOP
            IF v_ilosc_potrzebna > magazyn.Ilosc_w_magazynie THEN
                v_brakuje := true;
                EXIT;
            END IF;
        END LOOP;

        IF v_brakuje THEN
            DBMS_OUTPUT.PUT_LINE('Brak dla Czesc_ID ' || v_czesc_id || ' - ' || v_ilosc_potrzebna);
            v_brakuje := false;
        ELSE
            -- Aktualizacja ilości w magazynie
            UPDATE Magazyn_czesci
            SET Ilosc_w_magazynie = Ilosc_w_magazynie - v_ilosc_potrzebna
            WHERE Czesc_ID = v_czesc_id;

            DBMS_OUTPUT.PUT_LINE('Zaktualizowano Magazyn_czesci dla Czesc_ID ' || v_czesc_id);
        END IF;
    END LOOP;

    CLOSE p_czesci_cur;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono informacji o danej części w magazynie.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił inny błąd.');
END;
/



-- WYWOLANIE 

DECLARE
    ilosc_czesci_cur SYS_REFCURSOR;
BEGIN
    ilosc_czesci_cur := IloscPotrzebnychCzesci(1, 10); -- Przykład: ID produktu = 1, ilość sztuk = 10
    AktualizujMagazyny(ilosc_czesci_cur);
END;
/