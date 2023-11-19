-- CREATING OBJECT FOR USE IN PROCEDURE
CREATE TYPE employee_info AS OBJECT (
    PESEL VARCHAR(11),
    Imie VARCHAR(45),
    Nazwisko VARCHAR(45),
    IdKodAdresu INT,
    LiniaId INT,
    IdZatrudnienia INT,
    DataUrodzenia DATE,
    Miejscowosc VARCHAR(45),
    Email VARCHAR(45),
    Telefon VARCHAR(45),
    Wyksztalcenie VARCHAR(45),
    Nazwa_stanowiska VARCHAR(45)
);

-- PROCEDURE CREATING TWORZENIE PROCEDURY
CREATE OR REPLACE PROCEDURE GetEmployeeDetailsForAllEmployees(
    employee_data OUT employee_info
) AS
    v_error BOOLEAN := FALSE;
    v_pesel Pracownicy.PESEL%TYPE;
    v_imie Pracownicy.Imie%TYPE;
    v_nazwisko Pracownicy.Nazwisko%TYPE;
    v_email Pracownicy.Email%TYPE;
    v_telefon Pracownicy.Telefon%TYPE;
    v_wyksztalcenie Pracownicy.Wyksztalcenie%TYPE;
    v_stanowisko Zatrudnienie.Nazwa_stanowiska%TYPE;
    CURSOR emp_cursor IS
        SELECT PESEL, Imie, Nazwisko, Email, Telefon, Wyksztalcenie, Nazwa_stanowiska
        FROM Pracownicy INNER JOIN Zatrudnienie ON Zatrudnienie.id_zatrudnienia = Pracownicy.id_zatrudnienia;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        v_pesel := emp_rec.PESEL;
        v_imie := emp_rec.Imie;
        v_nazwisko := emp_rec.Nazwisko;
        v_email := emp_rec.Email;
        v_telefon := emp_rec.Telefon;
        v_wyksztalcenie := emp_rec.Wyksztalcenie;
        v_stanowisko := emp_rec.Nazwa_stanowiska;
        IF v_nazwisko IS NULL OR v_imie IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: First name or last name is empty for employee ID ' || v_pesel);
            v_error := TRUE;
        ELSIF INSTR(v_email, '@') = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Error: Email for employee ' || v_pesel || ' does not contain "@".');
            v_error := TRUE;
        ELSIF v_wyksztalcenie IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error: Wyksztalcenie is empty for employee ' || v_pesel);
            v_error := TRUE;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Employee details retrieved for PESEL: ' || v_pesel || ' Imie: '|| v_imie|| ' Nazwisko: '|| v_nazwisko || ' Wykształcenie: ' || v_wyksztalcenie || ' Stanowisko: ' || v_stanowisko );
            
        END IF;

        IF v_error THEN
            RAISE_APPLICATION_ERROR(-2001, 'Validation failed');
        END IF;
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee data not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

-- PROCEDURE EXEC
DECLARE
    v_emp_data employee_info; 
BEGIN
    GetEmployeeDetailsForAllEmployees(employee_data => v_emp_data);
    
END;