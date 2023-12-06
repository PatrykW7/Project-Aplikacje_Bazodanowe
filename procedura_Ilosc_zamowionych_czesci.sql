-- DEFINICJA PROCEDURY

CREATE OR REPLACE PROCEDURE DodajCzescZamowienia (
    p_czesci_zamowienia_ID IN Czesci_Zamowienia.czesci_zamowienia_ID%TYPE,
    p_Lokacja_ID IN Magazyn_czesci.Lokacja_ID%TYPE
) AS
    v_ilosc_zamowionych_czesci INT;
BEGIN
    SELECT Max_pojemnosc - Ilosc_w_magazynie
    INTO v_ilosc_zamowionych_czesci
    FROM Magazyn_czesci
    WHERE Lokacja_ID = p_Lokacja_ID;

    INSERT INTO Czesci_Zamowienia (czesci_zamowienia_ID, Lokacja_ID, ilosc_zamowionych_czesci)
    VALUES (p_czesci_zamowienia_ID, p_Lokacja_ID, v_ilosc_zamowionych_czesci);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Czesci_Zamowienia.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych dla podanej Lokacja_ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- WYWOLANIE PROCEDURY

BEGIN
    DodajCzescZamowienia(1, 1); -- Przykładowe wartości dla czesci_zamowienia_ID i Lokacja_ID
END;
/


