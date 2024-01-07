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


TUTAJ PRZYDALOBY SIE ZROBIC ZEBY ILOSC NIE MOGLA BYC WIEKSZA OD ILOSCI W MAGAZYNIE, ALE JEBAC TO NARAZIE 


*/

CREATE OR REPLACE PROCEDURE DodajSzczegolyZamowienia (
    p_Szczegoly_zamowienia_ID IN Szczegoly_zamowienia.Szczegoly_zamowienia_ID%TYPE,
    p_Znizka IN Szczegoly_zamowienia.Znizka%TYPE,
    p_Lokacja_ID IN Szczegoly_zamowienia.Lokacja_ID%TYPE,
    p_Zamowienie_ID IN Szczegoly_zamowienia.Zamowienie_ID%TYPE,
    p_Kwota IN Szczegoly_zamowienia.Kwota%TYPE,
    p_Rodzaj_platnosci IN Szczegoly_zamowienia.Rodzaj_platnosci%TYPE
) AS
    v_Przewidywany_czas_realizacji NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_Przewidywany_czas_realizacji
    FROM Harmonogram_urlopow hu
    JOIN Pracownicy p ON hu.PESEL = p.PESEL
    JOIN Zatrudnienie z ON p.id_zatrudnienia = z.id_zatrudnienia
    WHERE z.Nazwa_stanowiska = 'Pracownik magazynu'
      AND SYSDATE BETWEEN hu.Od_kiedy AND hu.Do_kiedy;

    IF v_Przewidywany_czas_realizacji = 0 THEN
        INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE);
    ELSE
        INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE + 3);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Szczegoly_zamowienia.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych w tabeli Harmonogram_urlopow.');

    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nieprawidłowe typy danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- WYWOLANIE PROCEDURY

DECLARE
    v_Szczegoly_zamowienia_ID Szczegoly_zamowienia.Szczegoly_zamowienia_ID%TYPE := 17; 
    v_Znizka Szczegoly_zamowienia.Znizka%TYPE := 0.1; 
    v_Lokacja_ID Szczegoly_zamowienia.Lokacja_ID%TYPE := 1;
    v_Zamowienie_ID Szczegoly_zamowienia.Zamowienie_ID%TYPE := 1; 
    v_Kwota Szczegoly_zamowienia.Kwota%TYPE := 1000; 
    v_Rodzaj_platnosci Szczegoly_zamowienia.Rodzaj_platnosci%TYPE := 'Gotowka'; 
BEGIN
    DodajSzczegolyZamowienia(
        p_Szczegoly_zamowienia_ID => v_Szczegoly_zamowienia_ID,
        p_Znizka => v_Znizka,
        p_Lokacja_ID => v_Lokacja_ID,
        p_Zamowienie_ID => v_Zamowienie_ID,
        p_Kwota => v_Kwota,
        p_Rodzaj_platnosci => v_Rodzaj_platnosci
    );
END;
/


-------------------

-- WERSJA KTORA NIE MA SYS + 3, tylko do_kiedy + 2 dni, ale CHUJ WIE CZY TO DZIALA NIE SPRAWDZALEM


CREATE OR REPLACE PROCEDURE DodajSzczegolyZamowienia (
    p_Szczegoly_zamowienia_ID IN Szczegoly_zamowienia.Szczegoly_zamowienia_ID%TYPE,
    p_Znizka IN Szczegoly_zamowienia.Znizka%TYPE,
    p_Lokacja_ID IN Szczegoly_zamowienia.Lokacja_ID%TYPE,
    p_Zamowienie_ID IN Szczegoly_zamowienia.Zamowienie_ID%TYPE,
    p_Kwota IN Szczegoly_zamowienia.Kwota%TYPE,
    p_Rodzaj_platnosci IN Szczegoly_zamowienia.Rodzaj_platnosci%TYPE
) AS
    v_Przewidywany_czas_realizacji NUMBER;
    v_Do_kiedy DATE;
BEGIN
    SELECT COUNT(*), MAX(hu.Do_kiedy)
    INTO v_Przewidywany_czas_realizacji, v_Do_kiedy
    FROM Harmonogram_urlopow hu
    JOIN Pracownicy p ON hu.PESEL = p.PESEL
    JOIN Zatrudnienie z ON p.id_zatrudnienia = z.id_zatrudnienia
    WHERE z.Nazwa_stanowiska = 'Pracownik magazynu'
      AND SYSDATE BETWEEN hu.Od_kiedy AND hu.Do_kiedy;

    IF v_Przewidywany_czas_realizacji = 0 THEN
        INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE);
    ELSE
        INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, v_Do_kiedy + 2);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Szczegoly_zamowienia.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych w tabeli Harmonogram_urlopow.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nieprawidłowe typy danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/



-- TUTAJ WERSJA CO SPRAWDZA CZY Nazwa_asortymentu jest w bazie danych, tez chuj wie czy to dziala

CREATE OR REPLACE PROCEDURE DodajSzczegolyZamowienia (
    p_Szczegoly_zamowienia_ID IN Szczegoly_zamowienia.Szczegoly_zamowienia_ID%TYPE,
    p_Znizka IN Szczegoly_zamowienia.Znizka%TYPE,
    p_Lokacja_ID IN Szczegoly_zamowienia.Lokacja_ID%TYPE,
    p_Zamowienie_ID IN Szczegoly_zamowienia.Zamowienie_ID%TYPE,
    p_Kwota IN Szczegoly_zamowienia.Kwota%TYPE,
    p_Rodzaj_platnosci IN Szczegoly_zamowienia.Rodzaj_platnosci%TYPE
) AS
    v_Przewidywany_czas_realizacji NUMBER;
    v_CountProdukt NUMBER;
BEGIN
    -- Sprawdzenie czy podany asortyment istnieje w tabeli Produkty
    SELECT COUNT(*)
    INTO v_CountProdukt
    FROM Produkty
    WHERE Nazwa_produktu = 'nazwa_asortymentu'; -- Tutaj wpisz nazwę asortymentu

    IF v_CountProdukt = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nieprawidłowa nazwa asortymentu.');
    ELSE
        SELECT COUNT(*)
        INTO v_Przewidywany_czas_realizacji
        FROM Harmonogram_urlopow hu
        JOIN Pracownicy p ON hu.PESEL = p.PESEL
        JOIN Zatrudnienie z ON p.id_zatrudnienia = z.id_zatrudnienia
        WHERE z.Nazwa_stanowiska = 'Pracownik magazynu'
          AND SYSDATE BETWEEN hu.Od_kiedy AND hu.Do_kiedy;

        IF v_Przewidywany_czas_realizacji = 0 THEN
            INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
            VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE);
        ELSE
            INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
            VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE + 3);
        END IF;
    END IF;

    COMMIT;
    --DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Szczegoly_zamowienia.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych w tabeli Harmonogram_urlopow.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nieprawidłowe typy danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- WYWOLANIE 


BEGIN
    DodajSzczegolyZamowienia(
        p_Szczegoly_zamowienia_ID => 123, -- Twój ID
        p_Znizka => 0.1, -- Przykładowa zniżka
        p_Lokacja_ID => 456, -- ID lokacji
        p_Zamowienie_ID => 789, -- ID zamówienia
        p_Kwota => 100.50, -- Przykładowa kwota
        p_Rodzaj_platnosci => 'Gotówka' -- Przykładowy rodzaj płatności
    );
END;
/



------- ZMODYFIKOWANA WERSJA WPROWADZANIE DANYCH ALE NIE WYDAJE MI SIE ZEBY TO DZIALALO

CREATE OR REPLACE PROCEDURE DodajSzczegolyZamowienia (
    p_Szczegoly_zamowienia_ID IN Szczegoly_zamowienia.Szczegoly_zamowienia_ID%TYPE,
    p_Znizka IN Szczegoly_zamowienia.Znizka%TYPE,
    p_Lokacja_ID IN Szczegoly_zamowienia.Lokacja_ID%TYPE,
    p_Zamowienie_ID IN Szczegoly_zamowienia.Zamowienie_ID%TYPE,
    p_Kwota IN Szczegoly_zamowienia.Kwota%TYPE,
    p_Rodzaj_platnosci IN Szczegoly_zamowienia.Rodzaj_platnosci%TYPE
) AS
    v_Przewidywany_czas_realizacji NUMBER;
    v_Ilosc_w_magazynie INT;
BEGIN
    -- Sprawdzenie ilości w magazynie dla danej Lokacja_ID
    SELECT Ilosc_w_magazynie INTO v_Ilosc_w_magazynie
    FROM Magazyn_produktow
    WHERE Lokacja_ID = p_Lokacja_ID; -- Tutaj sprawdzana jest ilość dla konkretnego Lokacja_ID

    IF v_Ilosc_w_magazynie >= p_Ilosc THEN -- Warunek ilości w magazynie
        SELECT COUNT(*)
        INTO v_Przewidywany_czas_realizacji
        FROM Harmonogram_urlopow hu
        JOIN Pracownicy p ON hu.PESEL = p.PESEL
        JOIN Zatrudnienie z ON p.id_zatrudnienia = z.id_zatrudnienia
        WHERE z.Nazwa_stanowiska = 'Pracownik magazynu'
          AND SYSDATE BETWEEN hu.Od_kiedy AND hu.Do_kiedy;

        IF v_Przewidywany_czas_realizacji = 0 THEN
            INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
            VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE);
        ELSE
            INSERT INTO Szczegoly_zamowienia (Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID, Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
            VALUES (p_Szczegoly_zamowienia_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota, p_Rodzaj_platnosci, SYSDATE + 3);
        END IF;

        -- Dodanie danych do tabeli Zamowienia
        INSERT INTO Zamowienia (Zamowienie_ID, Data_zamowienia)
        VALUES (p_Zamowienie_ID, SYSDATE);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Dodano nowy rekord do tabeli Szczegoly_zamowienia i Zamowienia.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie można dodać zamówienia. Brak wystarczającej ilości w magazynie.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych w tabeli Harmonogram_urlopow.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Nieprawidłowe typy danych.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/
