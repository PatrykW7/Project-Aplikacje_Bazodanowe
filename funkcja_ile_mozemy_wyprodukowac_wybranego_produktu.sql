CREATE OR REPLACE FUNCTION WyswietlIloscProdukcji(
    nazwa_asortymentu IN VARCHAR2
) RETURN VARCHAR2 AS
    v_output VARCHAR2(32000);
BEGIN
    FOR prod IN (
        SELECT DISTINCT p.Produkt_ID, p.Nazwa_produktu
        FROM Produkty p
        WHERE p.Nazwa_produktu = nazwa_asortymentu
    ) LOOP
        v_output := v_output || 'Produkt: ' || prod.Nazwa_produktu || ', Produkt ID: ' || prod.Produkt_ID || CHR(10);

        FOR part IN (
            SELECT pc.Czesc_ID, c.Nazwa_czesci, FLOOR(MIN(m.Ilosc_w_magazynie / pc.wymagana_ilosc_czesci)) AS minimalne_dzielenie
            FROM Produkt_czesci pc
            JOIN Magazyn_czesci m ON pc.Czesc_ID = m.Czesc_ID
            JOIN Czesci c ON m.Czesc_ID = c.Czesc_ID
            WHERE pc.Produkt_ID = prod.Produkt_ID
            GROUP BY pc.Czesc_ID, c.Nazwa_czesci
        ) LOOP
            v_output := v_output || 'Część: ' || part.Nazwa_czesci || ', Część ID: ' || part.Czesc_ID || ', Minimalne dzielenie: ' || part.minimalne_dzielenie || CHR(10);
        END LOOP;
    END LOOP;

    RETURN v_output;
END;
/



-- SAMA NAJMNIEJSZA WARTOSC
CREATE OR REPLACE FUNCTION WyswietlIloscProdukcji(
    nazwa_asortymentu IN VARCHAR2
) RETURN INT AS
    v_minimalne_dzielenie INT;
BEGIN
    FOR prod IN (
        SELECT DISTINCT p.Produkt_ID, p.Nazwa_produktu
        FROM Produkty p
        WHERE p.Nazwa_produktu = nazwa_asortymentu
    ) LOOP
        FOR part IN (
            SELECT FLOOR(MIN(m.Ilosc_w_magazynie / pc.wymagana_ilosc_czesci)) AS minimalne_dzielenie
            FROM Produkt_czesci pc
            JOIN Magazyn_czesci m ON pc.Czesc_ID = m.Czesc_ID
            WHERE pc.Produkt_ID = prod.Produkt_ID
        ) LOOP
            IF part.minimalne_dzielenie < v_minimalne_dzielenie OR v_minimalne_dzielenie IS NULL THEN
                v_minimalne_dzielenie := part.minimalne_dzielenie;
            END IF;
        END LOOP;
    END LOOP;

    RETURN v_minimalne_dzielenie;
END;
/



-- WYKOANNIE FUNKCJI 

DECLARE
    v_result VARCHAR2(32000);
BEGIN
    v_result := WyswietlIloscProdukcji('Nazwa_asortymentu');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/



-- FUNKJCA Z EXCEPTIONS


CREATE OR REPLACE FUNCTION WyswietlIloscProdukcji(
    nazwa_asortymentu IN VARCHAR2
) RETURN INT AS
    v_minimalne_dzielenie INT;
    v_produkt_id Produkty.Produkt_ID%TYPE;
BEGIN
    FOR prod IN (
        SELECT DISTINCT p.Produkt_ID, p.Nazwa_produktu
        FROM Produkty p
        WHERE p.Nazwa_produktu = nazwa_asortymentu
    ) LOOP
        v_produkt_id := prod.Produkt_ID; -- Przechowuje ID dla obsługi błędów

        FOR part IN (
            SELECT FLOOR(MIN(m.Ilosc_w_magazynie / pc.wymagana_ilosc_czesci)) AS minimalne_dzielenie
            FROM Produkt_czesci pc
            JOIN Magazyn_czesci m ON pc.Czesc_ID = m.Czesc_ID
            WHERE pc.Produkt_ID = prod.Produkt_ID
        ) LOOP
            IF part.minimalne_dzielenie < v_minimalne_dzielenie OR v_minimalne_dzielenie IS NULL THEN
                v_minimalne_dzielenie := part.minimalne_dzielenie;
            END IF;
        END LOOP;
    END LOOP;

    IF v_produkt_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Produkt o podanej nazwie nie istnieje.');
    END IF;

    RETURN v_minimalne_dzielenie;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak danych dla podanego produktu.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Wystąpił inny błąd.');
END;
/
