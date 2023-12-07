-- DEKLARACJA FUNKCJI

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


