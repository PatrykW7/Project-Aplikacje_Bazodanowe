
/*
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





-- WYKORZYSTANIE OBIEKTOW, KOLEKCJI, KURSORA <- TEZ NIE DZIALA XD

CREATE OR REPLACE TYPE Czesc_Object AS OBJECT (
    czesci_zamowienia_ID Czesci_Zamowienia.czesci_zamowienia_ID%TYPE,
    Lokacja_ID Magazyn_czesci.Lokacja_ID%TYPE,
    ilosc_zamowionych_czesci INT
);
/

CREATE OR REPLACE TYPE Czesc_Collection AS TABLE OF Czesc_Object;
/

CREATE OR REPLACE PROCEDURE DodajCzescZamowienia (
    p_czesci_zamowienia_ID IN Czesci_Zamowienia.czesci_zamowienia_ID%TYPE,
    p_Lokacja_ID IN Magazyn_czesci.Lokacja_ID%TYPE
) AS
    v_ilosc_zamowionych_czesci INT;
    v_czesc Czesc_Object;
    v_czesc_collection Czesc_Collection := Czesc_Collection();
    CURSOR c_magazyn_czesci IS
        SELECT Max_pojemnosc - Ilosc_w_magazynie AS ilosc
        FROM Magazyn_czesci
        WHERE Lokacja_ID = p_Lokacja_ID;
BEGIN
    OPEN c_magazyn_czesci;
    FETCH c_magazyn_czesci INTO v_ilosc_zamowionych_czesci;
    CLOSE c_magazyn_czesci;

    IF c_magazyn_czesci%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych dla podanej Lokacja_ID.');
        RETURN;
    ELSE
        v_czesc := Czesc_Object(p_czesci_zamowienia_ID, p_Lokacja_ID, v_ilosc_zamowionych_czesci);
        v_czesc_collection.extend();
        v_czesc_collection(v_czesc_collection.count) := v_czesc;

        INSERT INTO Czesci_Zamowienia (czesci_zamowienia_ID, Lokacja_ID, ilosc_zamowionych_czesci)
        VALUES (v_czesc.czesci_zamowienia_ID, v_czesc.Lokacja_ID, v_czesc.ilosc_zamowionych_czesci);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Czesci_Zamowienia.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/


-- WYWOLANIE PROCEDURY

BEGIN
    DodajCzescZamowienia(123, 456); -- Tutaj podaj konkretne wartości dla p_czesci_zamowienia_ID oraz p_Lokacja_ID
END;
/








------------------------------------


-- TESTY <- NIE DZIALA



CREATE OR REPLACE PROCEDURE DodajCzescZamowienia (
    p_czesci_zamowienia_ID IN Czesci_Zamowienia.czesci_zamowienia_ID%TYPE,
    p_Lokacja_ID IN Magazyn_czesci.Lokacja_ID%TYPE
) AS
    TYPE Czesc_Record IS RECORD (
        czesci_zamowienia_ID Czesci_Zamowienia.czesci_zamowienia_ID%TYPE,
        Lokacja_ID Magazyn_czesci.Lokacja_ID%TYPE,
        ilosc_zamowionych_czesci INT
    );
    
    TYPE Czesc_Collection IS TABLE OF Czesc_Record INDEX BY PLS_INTEGER;
    
    v_czesc_collection Czesc_Collection;
    v_ilosc_zamowionych_czesci INT;
BEGIN
    SELECT Max_pojemnosc - Ilosc_w_magazynie
    INTO v_ilosc_zamowionych_czesci
    FROM Magazyn_czesci
    WHERE Lokacja_ID = p_Lokacja_ID;

    v_czesc_collection(1).czesci_zamowienia_ID := p_czesci_zamowienia_ID;
    v_czesc_collection(1).Lokacja_ID := p_Lokacja_ID;
    v_czesc_collection(1).ilosc_zamowionych_czesci := v_ilosc_zamowionych_czesci;

    INSERT INTO Czesci_Zamowienia (czesci_zamowienia_ID, Lokacja_ID, ilosc_zamowionych_czesci)
    VALUES (v_czesc_collection(1).czesci_zamowienia_ID, v_czesc_collection(1).Lokacja_ID, v_czesc_collection(1).ilosc_zamowionych_czesci);

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


-- WYWOLANIE BEGIN

DodajCzescZamowienia(123, 456); -- Podaj odpowiednie wartości dla p_czesci_zamowienia_ID i p_Lokacja_ID
END;
/