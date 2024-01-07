-- DEKLARACJA PROCEDURY

CREATE OR REPLACE PROCEDURE DodajDostawe (
    p_Dostawa_ID IN Dostawy.Dostawa_ID%TYPE,
    p_Ilosc IN Dostawy.Ilosc%TYPE,
    p_Czesc_ID IN Dostawy.Czesc_ID%TYPE,
    p_PESEL IN Dostawy.PESEL%TYPE,
    p_Dostawca_ID IN Dostawy.Dostawca_ID%TYPE,
    p_Kwota_bez_zniki IN Dostawy.Kwota_bez_zniki%TYPE,
    p_Data_dostawy IN Dostawy.Data_dostawy%TYPE
) AS
    v_Znizka FLOAT;
    v_Cena_dostawy FLOAT;
BEGIN
    SELECT CASE WHEN d.Dostawca_ID = most_common.Dostawca_ID THEN 0.7 ELSE 1 END
    INTO v_Znizka
    FROM (
        SELECT Dostawca_ID, COUNT(*) AS count_dostawca
        FROM Dostawy
        GROUP BY Dostawca_ID
        ORDER BY count_dostawca DESC
    ) most_common
    INNER JOIN Dostawcy d ON most_common.Dostawca_ID = d.Dostawca_ID
    WHERE ROWNUM = 1;

    v_Cena_dostawy := p_Kwota_bez_zniki * v_Znizka;

    INSERT INTO Dostawy (Dostawa_ID, Ilosc, Czesc_ID, PESEL, Dostawca_ID, Kwota_bez_zniki, Data_dostawy, Znizka, Cena_dostawy)
    VALUES (p_Dostawa_ID, p_Ilosc, p_Czesc_ID, p_PESEL, p_Dostawca_ID, p_Kwota_bez_zniki, p_Data_dostawy, v_Znizka, v_Cena_dostawy);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nową dostawę do tabeli Dostawy.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- WYWOLANIE PROCEDURY

BEGIN
    DodajDostawe(17, 500, 1, '13987456321', 5, 1500, '04-NOV-22');
   
END;
/


--- WERSJA Z REGEXP TRZEBA SPRAWDZIC, CHUJ WIE CZY DZIALA TAK JAK POWINNO

CREATE OR REPLACE PROCEDURE DodajDostawe (
    p_Dostawa_ID IN Dostawy.Dostawa_ID%TYPE,
    p_Ilosc IN Dostawy.Ilosc%TYPE,
    p_Czesc_ID IN Dostawy.Czesc_ID%TYPE,
    p_PESEL IN Dostawy.PESEL%TYPE,
    p_Dostawca_ID IN Dostawy.Dostawca_ID%TYPE,
    p_Kwota_bez_zniki IN Dostawy.Kwota_bez_zniki%TYPE,
    p_Data_dostawy IN Dostawy.Data_dostawy%TYPE
) AS
    v_Znizka FLOAT;
    v_Cena_dostawy FLOAT;
    v_Data DATE;
BEGIN
    -- Sprawdzenie poprawności PESEL za pomocą wyrażenia regularnego
    IF NOT REGEXP_LIKE(p_PESEL, '^[0-9]{11}$') THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: PESEL powinien składać się z 11 cyfr.');
        RETURN;
    END IF;

    -- Sprawdzenie poprawności daty w formacie 'DD-MON-YY'
    BEGIN
        v_Data := TO_DATE(p_Data_dostawy, 'DD-MON-YY');
    EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Błąd: Nieprawidłowy format daty. Podaj datę w formacie ''DD-MON-YY'', na przykład ''04-NOV-22''.');
            RETURN;
    END;

    -- Reszta procedury z poprawionym SELECTem

    SELECT CASE WHEN d.Dostawca_ID = most_common.Dostawca_ID THEN 0.7 ELSE 1 END
    INTO v_Znizka
    FROM (
        SELECT Dostawca_ID, COUNT(*) AS count_dostawca
        FROM Dostawy
        GROUP BY Dostawca_ID
        ORDER BY count_dostawca DESC
    ) most_common
    INNER JOIN Dostawcy d ON most_common.Dostawca_ID = d.Dostawca_ID
    WHERE ROWNUM = 1;

    v_Cena_dostawy := p_Kwota_bez_zniki * v_Znizka;

    INSERT INTO Dostawy (Dostawa_ID, Ilosc, Czesc_ID, PESEL, Dostawca_ID, Kwota_bez_zniki, Data_dostawy, Znizka, Cena_dostawy)
    VALUES (p_Dostawa_ID, p_Ilosc, p_Czesc_ID, p_PESEL, p_Dostawca_ID, p_Kwota_bez_zniki, p_Data_dostawy, v_Znizka, v_Cena_dostawy);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano nową dostawę do tabeli Dostawy.');
EXCEPTION
    
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: Wartość niepoprawna.');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

-- WYWOLANIE 

BEGIN
    DodajDostawe(
        'ID1234', -- p_Dostawa_ID
        100,      -- p_Ilosc
        123,      -- p_Czesc_ID
        '12345678901', -- p_PESEL
        456,      -- p_Dostawca_ID
        500.50,   -- p_Kwota_bez_zniki
        '04-NOV-22' -- p_Data_dostawy
    );
END;
/


