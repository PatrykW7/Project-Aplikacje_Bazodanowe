-- DEFINICJA PROCEDURY

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


