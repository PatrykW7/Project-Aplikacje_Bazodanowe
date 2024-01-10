/*
  FUNKCJA KTORA WYSWIETLA ILE MOZEMY WYPRODUKOWAC DANYCH ASORTYMENTOW Z CZESCI W MAGAZYNIE
*/

-- DEKLARACJA FUNKCJI

CREATE OR REPLACE FUNCTION WyswietlIloscProdukcji RETURN VARCHAR2 AS
  TYPE ProduktInfo IS RECORD (
    Produkt_ID Produkty.Produkt_ID%TYPE,
    Nazwa_produktu Produkty.Nazwa_produktu%TYPE
  );

  TYPE CzescInfo IS RECORD (
    Czesc_ID Produkt_czesci.Czesc_ID%TYPE,
    Nazwa_czesci Czesci.Nazwa_czesci%TYPE,
    Minimalne_dzielenie NUMBER
  );

  TYPE ProduktCzesciInfo IS TABLE OF CzescInfo INDEX BY BINARY_INTEGER;
  TYPE WszystkieProduktyInfo IS TABLE OF ProduktInfo INDEX BY BINARY_INTEGER;

  v_output VARCHAR2(32000);
  v_produkty WszystkieProduktyInfo;
BEGIN
  -- Zbieranie informacji o produktach
  SELECT DISTINCT p.Produkt_ID, p.Nazwa_produktu
  BULK COLLECT INTO v_produkty
  FROM Produkty p;

  -- Przetwarzanie informacji o produktach i częściach
  FOR i IN 1 .. v_produkty.COUNT LOOP
    v_output := v_output || 'Produkt: ' || v_produkty(i).Nazwa_produktu || ', Produkt ID: ' || v_produkty(i).Produkt_ID || CHR(10);

    DECLARE
      v_czesci ProduktCzesciInfo;
    BEGIN
      SELECT pc.Czesc_ID, c.Nazwa_czesci, FLOOR(MIN(m.Ilosc_w_magazynie / pc.wymagana_ilosc_czesci)) AS minimalne_dzielenie
      BULK COLLECT INTO v_czesci
      FROM Produkt_czesci pc
      JOIN Magazyn_czesci m ON pc.Czesc_ID = m.Czesc_ID
      JOIN Czesci c ON m.Czesc_ID = c.Czesc_ID
      WHERE pc.Produkt_ID = v_produkty(i).Produkt_ID
      GROUP BY pc.Czesc_ID, c.Nazwa_czesci;

      FOR j IN 1 .. v_czesci.COUNT LOOP
        v_output := v_output || 'Część: ' || v_czesci(j).Nazwa_czesci || ', Część ID: ' || v_czesci(j).Czesc_ID || ', Liczba produktów do wyprodukowania z części: ' || v_czesci(j).minimalne_dzielenie || CHR(10);
      END LOOP;
    END;
  END LOOP;

  RETURN v_output;
END;
/


-- WYWOLANIE FUNKCJI

 DECLARE
  v_wynik VARCHAR2(32000);
BEGIN
  v_wynik := WyswietlIloscProdukcji();
  DBMS_OUTPUT.PUT_LINE(v_wynik);
END;
/
 











CREATE OR REPLACE FUNCTION WyswietlIloscProdukcji RETURN VARCHAR2 AS
  v_output VARCHAR2(32000);
BEGIN
  FOR prod IN (SELECT DISTINCT p.Produkt_ID, p.Nazwa_produktu FROM Produkty p) LOOP
    v_output := v_output || 'Produkt: ' || prod.Nazwa_produktu || ', Produkt ID: ' || prod.Produkt_ID || CHR(10);
    
    FOR part IN (
      SELECT pc.Czesc_ID, c.Nazwa_czesci, FLOOR(MIN(m.Ilosc_w_magazynie / pc.wymagana_ilosc_czesci)) AS minimalne_dzielenie
      FROM Produkt_czesci pc
      JOIN Magazyn_czesci m ON pc.Czesc_ID = m.Czesc_ID
      JOIN Czesci c ON m.Czesc_ID = c.Czesc_ID
      WHERE pc.Produkt_ID = prod.Produkt_ID
      GROUP BY pc.Czesc_ID, c.Nazwa_czesci
    ) LOOP
      v_output := v_output || 'Część: ' || part.Nazwa_czesci || ', Część ID: ' || part.Czesc_ID || ', Liczba produktow do wyprodukowania z czesci: ' || part.minimalne_dzielenie || CHR(10);
    END LOOP;
  END LOOP;

  RETURN v_output;
END;
/

-- WYWOLANIE FUNKCJI

DECLARE
  result VARCHAR2(32000);
BEGIN
  result := WyswietlIloscProdukcji;
  DBMS_OUTPUT.PUT_LINE(result);
END;
/


