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



