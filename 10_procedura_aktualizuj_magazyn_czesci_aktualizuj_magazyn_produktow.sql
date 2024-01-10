
/*
Sprawdza ile czesci potrzeba na dana ilosc asortymentu i sprawdza czy jest tyle czesci w magazynie, a jesli tak to
usuwa dana ilosc czesci i aktualizuje wartosc ilosc_w_magazynie dla Magazyn_produktow dla danego Produkt_ID



*/




CREATE OR REPLACE PROCEDURE AktualizujIloscWMagazynie (
    p_Produkt_ID Magazyn_produktow.Produkt_ID%TYPE,
    p_Ilosc_asortymentu Magazyn_produktow.Ilosc_w_magazynie%TYPE
)
IS
BEGIN
    UPDATE Magazyn_produktow
    SET Ilosc_w_magazynie = Ilosc_w_magazynie + p_Ilosc_asortymentu
    WHERE Produkt_ID = p_Produkt_ID;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END AktualizujIloscWMagazynie;
/

    
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
    -- Wywołanie funkcji AktualizujIloscWMagazynie
    AktualizujIloscWMagazynie(v_czesc_id, v_ilosc_potrzebna);

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



--- WYWOLANIE 


DECLARE
    v_Produkt_ID Magazyn_produktow.Produkt_ID%TYPE := 1; -- Przykładowe ID produktu
    v_Ilosc_asortymentu Magazyn_produktow.Ilosc_w_magazynie%TYPE := 10; -- Przykładowa ilość asortymentu do dodania

BEGIN
    AktualizujIloscWMagazynie(v_Produkt_ID, v_Ilosc_asortymentu);
    DBMS_OUTPUT.PUT_LINE('Procedura AktualizujIloscWMagazynie została wykonana.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END;



-- ORYGINAL

CREATE OR REPLACE PROCEDURE AktualizujMagazynCzesci(p_czesci_cur SYS_REFCURSOR) AS
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
            
            -- Aktualizacja ilości w magazynie produktów
            UPDATE Magazyn_produktow
            SET Ilosc_w_magazynie = Ilosc_w_magazynie + v_ilosc_potrzebna
            WHERE Produkt_ID = (SELECT Produkt_ID FROM Produkt_czesci WHERE Czesc_ID = v_czesc_id);

            DBMS_OUTPUT.PUT_LINE('Zaktualizowano Magazyn_produktow dla Produkt_ID ' || v_czesc_id);
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



