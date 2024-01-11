
/*

PROCEDURA POLEGA NA ZLOZENIU ZAMOWIEN NA CZESCI DO TABELI CZESCI_ZAMOWIENIA
TAK ABY UZUPELNIC MAKSYMALNA ILOSC DANEJ LOKALIZACJI W MAGAZYNIE


CREATE TABLE Czesci_Zamowienia
(
czesci_zamowienia_ID INT PRIMARY KEY NOT NULL,
Lokacja_ID INT,
ilosc_zamowionych_czesci INT,
FOREIGN KEY (Lokacja_ID) REFERENCES Magazyn_czesci(Lokacja_ID)
);



*/
-- DEFINICJA PROCEDURY


CREATE OR REPLACE PROCEDURE DodajCzescZamowienia (
    p_czesci_zamowienia_ID IN Czesci_Zamowienia.czesci_zamowienia_ID%TYPE,
    p_Lokacja_ID IN Magazyn_czesci.Lokacja_ID%TYPE
) AS
    v_ilosc_zamowionych_czesci INT;
    v_count NUMBER;
    CURSOR c_magazyn_czesci (p_Lokacja_ID Magazyn_czesci.Lokacja_ID%TYPE) IS
        SELECT Max_pojemnosc - Ilosc_w_magazynie AS roznica
        FROM Magazyn_czesci
        WHERE Lokacja_ID = p_Lokacja_ID;
    BAD_LOCAL EXCEPTION;
BEGIN
    -- Sprawdzenie, czy Lokacja_ID istnieje w tabeli Magazyn_czesci
    SELECT COUNT(*)
    INTO v_count
    FROM Magazyn_czesci
    WHERE Lokacja_ID = p_Lokacja_ID;

    IF v_count = 0 THEN
        RAISE BAD_LOCAL;
    END IF;

    OPEN c_magazyn_czesci(p_Lokacja_ID);
    FETCH c_magazyn_czesci INTO v_ilosc_zamowionych_czesci;
    CLOSE c_magazyn_czesci;

    INSERT INTO Czesci_Zamowienia (czesci_zamowienia_ID, Lokacja_ID, ilosc_zamowionych_czesci)
    VALUES (p_czesci_zamowienia_ID, p_Lokacja_ID, v_ilosc_zamowionych_czesci);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Czesci_Zamowienia.');
EXCEPTION
    WHEN BAD_LOCAL THEN
        DBMS_OUTPUT.PUT_LINE('Podane Lokacja_ID nie istnieje w tabeli Magazyn_czesci.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych dla podanej Lokacja_ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- WYWOLANIE BEGIN

BEGIN
    DodajCzescZamowienia(4, 4); -- Przykładowe wartości dla czesci_zamowienia_ID i Lokacja_ID
END;
