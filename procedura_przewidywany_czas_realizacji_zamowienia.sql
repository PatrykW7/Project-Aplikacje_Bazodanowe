-- DEFINICJA PROCEDURY


-- PAMIETAJ O DODANIU TABELI HARMONOGRAM URLOPOW


/*

CREATE TABLE Harmonogram_urlopow
(
Urlop_ID INT PRIMARY KEY NOT NULL,
PESEL VARCHAR(11),
Od_kiedy DATE,
Do_kiedy DATE,
FOREIGN KEY(PESEL) REFERENCES Pracownicy(PESEL)
);




INSERT ALL
    INTO Harmonogram_urlopow
(Urlop_ID,PESEL,Od_kiedy,Do_kiedy) VALUES (1, '12345678909', '01-JAN-01','15-JAN-01')
    INTO Harmonogram_urlopow(Urlop_ID,PESEL,Od_kiedy,Do_kiedy) VALUES (2, '23258741369','21-MAR-05', '30-MAR-05')
SELECT 1 FROM dual;

*/

CREATE OR REPLACE TYPE SzczegolyZamowienia_Object AS OBJECT (
    Szczegoly_zamowienia_ID INT,
    Znizka FLOAT,
    Lokacja_ID INT,
    Zamowienie_ID INT,
    Kwota FLOAT,
    Rodzaj_platnosci VARCHAR(45),
    Przewidywany_czas_realizacji DATE
);
/


CREATE OR REPLACE PROCEDURE DodajSzczegolyZamowienia (
    p_Szczegoly_zamowienia SzczegolyZamowienia_Object
) AS
    v_Przewidywany_czas_realizacji NUMBER;
	BAD_LOC EXCEPTION;
	BAD_KWOTA EXCEPTION;
BEGIN
    SELECT COUNT(*)
    INTO v_Przewidywany_czas_realizacji
    FROM Magazyn_produktow
    WHERE Lokacja_ID = p_Szczegoly_zamowienia.Lokacja_ID;

    IF v_Przewidywany_czas_realizacji = 0 THEN
        RAISE BAD_LOC;
    END IF;

	IF p_Szczegoly_zamowienia.Kwota <= 0 THEN
        RAISE BAD_KWOTA;
    END IF; 
    
    SELECT COUNT(*)
    INTO v_Przewidywany_czas_realizacji
    FROM Harmonogram_urlopow hu
    JOIN Pracownicy p ON hu.PESEL = p.PESEL
    JOIN Zatrudnienie z ON p.id_zatrudnienia = z.id_zatrudnienia
    WHERE z.Nazwa_stanowiska = 'Pracownik magazynu'
      AND SYSDATE BETWEEN hu.Od_kiedy AND hu.Do_kiedy;

    IF v_Przewidywany_czas_realizacji = 0 THEN
        INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Szczegoly_zamowienia.Szczegoly_zamowienia_ID, p_Szczegoly_zamowienia.Znizka, p_Szczegoly_zamowienia.Lokacja_ID, p_Szczegoly_zamowienia.Zamowienie_ID, p_Szczegoly_zamowienia.Kwota, p_Szczegoly_zamowienia.Rodzaj_platnosci, SYSDATE);
    ELSE
        INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Szczegoly_zamowienia.Szczegoly_zamowienia_ID, p_Szczegoly_zamowienia.Znizka, p_Szczegoly_zamowienia.Lokacja_ID, p_Szczegoly_zamowienia.Zamowienie_ID, p_Szczegoly_zamowienia.Kwota, p_Szczegoly_zamowienia.Rodzaj_platnosci, SYSDATE + 3);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Szczegoly_zamowienia.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych w tabeli Harmonogram_urlopow.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nieprawidłowe typy danych.');
	WHEN BAD_LOC THEN
        DBMS_OUTPUT.PUT_LINE('Podane Lokacja_ID nie istnieje w tabeli Magazyn_produktow.');
	WHEN BAD_KWOTA THEN
        DBMS_OUTPUT.PUT_LINE('Błędna kwota. Kwota musi być większa od zera.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/





-- WYWOLANIE

DECLARE
    szczegoly_zamowienia SzczegolyZamowienia_Object;
BEGIN
    -- Inicjalizacja obiektu z danymi
    szczegoly_zamowienia := SzczegolyZamowienia_Object(
        Szczegoly_zamowienia_ID => 22,
        Znizka => 0.1,
        Lokacja_ID => 123,
        Zamowienie_ID => 20,
        Kwota => 100.0,
        Rodzaj_platnosci => 'Gotówka',
        Przewidywany_czas_realizacji => SYSDATE
    );

    -- Wywołanie procedury z obiektem jako parametrem
    DodajSzczegolyZamowienia(p_Szczegoly_zamowienia => szczegoly_zamowienia);
END;
/

