/*
Napisz procedure, która wprowadza wartości do tabel Zamowienia i szczegoly_zamowienia, 
dla atrybutu Lokacja_ID z tabeli Magazyn_produktow, sprawdza czy dla danego Produkt_ID 
wartosc atrybutu Ilosc_w_magazynie jest wieksza niz 
atrybut Ilosc z tabeli Zamowienia
*/

-- COS TUTAJ TRZEBA WYMYSLIC BO TO JEST ZA MALO 


CREATE OR REPLACE PROCEDURE ZlozZamowienie(
    p_Zamowienie_ID INT,
    p_Data_zamowienia DATE,
    p_id_kod_adresu INT,
    p_PESEL VARCHAR,
    p_Klient_ID INT,
    p_Rodzaj_wysylki_ID INT,
    p_Miejscowosc VARCHAR,
    p_Ilosc INT,
    p_Data_wysylki DATE,
    p_Lokacja_ID INT,
    p_Znizka FLOAT,
    p_Kwota FLOAT,
    p_Rodzaj_platnosci VARCHAR,
    p_Przewidywany_czas_realizacji DATE
) IS
    v_Ilosc_magazyn INT;
BEGIN
    -- Sprawdzenie warunku na podstawie wartości z tabeli Magazyn_produktow
    SELECT Ilosc_w_magazynie INTO v_Ilosc_magazyn
    FROM Magazyn_produktow
    WHERE Produkt_ID = p_Zamowienie_ID AND Lokacja_ID = p_Lokacja_ID;

    IF v_Ilosc_magazyn > p_Ilosc THEN
        -- Wprowadzenie wartości do tabeli Zamowienia
        INSERT INTO Zamowienia(Zamowienie_ID, Data_zamowienia, id_kod_adresu, PESEL, Klient_ID,
                               Rodzaj_wysylki_ID, Miejscowosc, Ilosc, Data_wysylki)
        VALUES (p_Zamowienie_ID, p_Data_zamowienia, p_id_kod_adresu, p_PESEL, p_Klient_ID,
                p_Rodzaj_wysylki_ID, p_Miejscowosc, p_Ilosc, p_Data_wysylki);

        -- Wprowadzenie wartości do tabeli Szczegoly_zamowienia
        INSERT INTO Szczegoly_zamowienia(Szczegoly_zamowienia_ID, Znizka, Lokacja_ID, Zamowienie_ID,
                                         Kwota, Rodzaj_platnosci, Przewidywany_czas_realizacji)
        VALUES (p_Zamowienie_ID, p_Znizka, p_Lokacja_ID, p_Zamowienie_ID, p_Kwota,
                p_Rodzaj_platnosci, p_Przewidywany_czas_realizacji);
        
        DBMS_OUTPUT.PUT_LINE('Zamówienie złożone pomyślnie.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie można złożyć zamówienia. Brak wystarczającej ilości produktu w magazynie.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono informacji o danym produkcie w magazynie.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił inny błąd.');
END;
/


-- WYWOLANIE 
DECLARE
    v_Zamowienie_ID INT := 1;
    v_Data_zamowienia DATE := SYSDATE;
    v_id_kod_adresu INT := 123; -- Twój odpowiedni ID kodu adresu
    v_PESEL VARCHAR(11) := '12345678901'; -- Twój odpowiedni PESEL
    v_Klient_ID INT := 456; -- Twój odpowiedni Klient_ID
    v_Rodzaj_wysylki_ID INT := 789; -- Twój odpowiedni Rodzaj_wysylki_ID
    v_Miejscowosc VARCHAR(45) := 'Warszawa'; -- Twój odpowiednią miejscowość
    v_Ilosc INT := 5; -- Twój odpowiednią ilość
    v_Data_wysylki DATE := SYSDATE + 7; -- Twój odpowiednią datę wysyłki
    v_Lokacja_ID INT := 101; -- Twój odpowiedni Lokacja_ID
    v_Znizka FLOAT := 0.1; -- Twój odpowiednią zniżkę
    v_Kwota FLOAT := 100.50; -- Twój odpowiednią kwotę
    v_Rodzaj_platnosci VARCHAR(45) := 'Karta'; -- Twój odpowiedni rodzaj płatności
    v_Przewidywany_czas_realizacji DATE := SYSDATE + 14; -- Twój odpowiedni przewidywany czas realizacji
BEGIN
    ZlozZamowienie(v_Zamowienie_ID, v_Data_zamowienia, v_id_kod_adresu, v_PESEL, v_Klient_ID,
                   v_Rodzaj_wysylki_ID, v_Miejscowosc, v_Ilosc, v_Data_wysylki, v_Lokacja_ID,
                   v_Znizka, v_Kwota, v_Rodzaj_platnosci, v_Przewidywany_czas_realizacji);
END;
/