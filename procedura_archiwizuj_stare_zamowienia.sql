CREATE TABLE archiwum(
Zamowienie_ID INT PRIMARY KEY NOT NULL,
Data_zamowienia DATE NOT NULL,
id_kod_adresu INT,
PESEL VARCHAR(11),
Klient_ID INT,
Rodzaj_wysylki_ID INT,
Miejscowosc VARCHAR(45),
Ilosc INT,
Data_wysylki DATE,
Znizka FLOAT,
Lokacja_ID INT,
Kwota FLOAT,
Rodzaj_platnosci VARCHAR(45)
)

CREATE OR REPLACE PROCEDURE archiwizuj_stare_zamowienia AS
  vs_Znizka NUMBER;
  vs_Lokacja_ID NUMBER;
  vs_Kwota NUMBER;
  vs_Rodzaj_platnosci VARCHAR2(50); -- Określ długość VARCHAR2

BEGIN
  FOR rec IN (SELECT * FROM zamowienia WHERE DATA_ZAMOWIENIA < SYSDATE - 365) LOOP
    -- Pobierz dane ze szczegoly_zamowienia
    SELECT Znizka, Lokacja_ID, Kwota, Rodzaj_platnosci
    INTO vs_Znizka, vs_Lokacja_ID, vs_Kwota, vs_Rodzaj_platnosci
    FROM szczegoly_zamowienia
    WHERE Zamowienie_ID = rec.Zamowienie_ID;

    -- Wstaw dane do tabeli archiwum
    INSERT INTO archiwum VALUES (
      rec.Zamowienie_ID, 
      rec.Data_zamowienia, 
      rec.id_kod_adresu, 
      rec.PESEL, 
      rec.Klient_ID,
      rec.Rodzaj_wysylki_ID, 
      rec.Miejscowosc, 
      rec.Ilosc, 
      rec.Data_wysylki,
      vs_Znizka,
      vs_Lokacja_ID, 
      vs_Kwota, 
      vs_Rodzaj_platnosci
    );
    
    -- Usuń rekordy ze szczegoly_zamowienia
    DELETE FROM szczegoly_zamowienia WHERE Zamowienie_ID = rec.Zamowienie_ID;

    -- Usuń rekordy z zamowienia
    DELETE FROM zamowienia WHERE Zamowienie_ID = rec.Zamowienie_ID;
  END LOOP;

  COMMIT;
END archiwizuj_stare_zamowienia;
/

BEGIN
    archiwizuj_stare_zamowienia;
END;
/

select * from zamowienia;
select * from szczegoly_zamowienia;
select * from archiwum;