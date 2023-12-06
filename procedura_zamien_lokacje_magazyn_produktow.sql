CREATE OR REPLACE PROCEDURE zamien_lokacje_magazyn_produktow(
  p_lokacja_id_1 NUMBER,
  p_lokacja_id_2 NUMBER
) AS
  v_ilosc_lokacja_1 NUMBER;
  v_ilosc_lokacja_2 NUMBER;
  v_max_lokacja_1 NUMBER;
  v_max_lokacja_2 NUMBER;
  v_produkt_1 NUMBER;
  v_produkt_2 NUMBER;
BEGIN
  -- Pobierz ilość towaru dla obu lokacji
  SELECT Ilosc_w_magazynie, Maksymalna_pojemnosc, Produkt_id
  INTO v_ilosc_lokacja_1, v_max_lokacja_1, v_produkt_1
  FROM magazyn_produktow
  WHERE Lokacja_ID = p_lokacja_id_1;

  SELECT Ilosc_w_magazynie, Maksymalna_pojemnosc, Produkt_id
  INTO v_ilosc_lokacja_2, v_max_lokacja_2, v_produkt_2
  FROM magazyn_produktow
  WHERE Lokacja_ID = p_lokacja_id_2;

  -- Zamień miejscami towary
  IF v_max_lokacja_1 > v_ilosc_lokacja_2 AND v_max_lokacja_2 > v_ilosc_lokacja_1 THEN
      UPDATE magazyn_produktow
      SET Ilosc_w_magazynie = v_ilosc_lokacja_2, Produkt_ID = v_produkt_2
      WHERE Lokacja_ID = p_lokacja_id_1;

      UPDATE magazyn_produktow
      SET Ilosc_w_magazynie = v_ilosc_lokacja_1, Produkt_ID = v_produkt_1
      WHERE Lokacja_ID = p_lokacja_id_2;
	  DBMS_OUTPUT.PUT_LINE('Zamieniono towar miejscami');
  ELSE
      DBMS_OUTPUT.PUT_LINE('Nie zamieniono towar miejscami');
  END IF;

  COMMIT;
END zamien_lokacje_magazyn_produktow;
/

select * from magazyn_produktow;

BEGIN
   zamien_lokacje(10,11);
END;
/

select * from magazyn_produktow