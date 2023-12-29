CREATE TYPE employee_info AS OBJECT (
    PESEL VARCHAR(11),
	Imie VARCHAR(45),
    Nazwisko VARCHAR(45),
    id_kod_adresu INT,
    Linia_ID INT,
    id_zatrudnienia INT,
    Data_urodzenia DATE,
    Miejscowosc VARCHAR(45),
    Email VARCHAR(45),
    Telefon VARCHAR(20),
    Wyksztalcenie VARCHAR(45),
    Stanowisko VARCHAR(45),
    Pensja FLOAT,
    Data_zatrudnienia DATE,
    Umowa_nazwa VARCHAR(45),
    Dzial_nazwa VARCHAR(45),
    Opis_zmiany VARCHAR(45) 
)

CREATE OR REPLACE PROCEDURE InsertEmployeeDetails(
    emp_data IN employee_info
) AS
    v_error BOOLEAN := FALSE;
BEGIN
    IF emp_data.Imie IS NULL OR emp_data.Nazwisko IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: First name or last name is empty for employee ID ' || emp_data.PESEL);
        v_error := TRUE;
    ELSIF INSTR(emp_data.Email, '@') = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Email for employee ' || emp_data.PESEL || ' does not contain "@".');
        v_error := TRUE;
    ELSIF emp_data.Stanowisko IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Stanowisko is empty for employee ' || emp_data.PESEL);
        v_error := TRUE;
    ELSE

		INSERT INTO Zatrudnienie(
            id_zatrudnienia, Nazwa_stanowiska, Pensja, Data_zatrudnienia, Umowa_nazwa, Dzial_nazwa, Opis_zmiany
        )
        VALUES (
            emp_data.id_zatrudnienia, emp_data.Stanowisko, emp_data.Pensja, emp_data.Data_zatrudnienia,
            emp_data.Umowa_nazwa, emp_data.Dzial_nazwa, emp_data.Opis_zmiany
        );

  
        INSERT INTO Pracownicy(
            PESEL, Imie, Nazwisko, id_kod_adresu, Linia_ID, id_zatrudnienia, Data_urodzenia, Miejscowosc,
            Email, Telefon, Wyksztalcenie
        )
        VALUES (
            emp_data.PESEL, emp_data.Imie, emp_data.Nazwisko, emp_data.id_kod_adresu, emp_data.Linia_ID,
            emp_data.id_zatrudnienia, emp_data.Data_urodzenia, emp_data.Miejscowosc, emp_data.Email,
            emp_data.Telefon, emp_data.Wyksztalcenie
        );

        

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Employee details inserted successfully.');
    END IF;

    IF v_error THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-2001, 'Validation failed');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;


DECLARE
    emp_data employee_info := employee_info(
        '12345678901', -- PESEL
        'John', -- Imie
        'Doe', -- Nazwisko
        1, -- IdKodAdresu
        1, -- Linia_ID
        1, -- Id_zatrudnienia
        TO_DATE('1990-01-01', 'YYYY-MM-DD'), -- Data_urodzenia
        'SampleCity', -- Miejscowosc
        'john@example.com', -- Email
        '123456789', -- Telefon
        'Degree', -- Wyksztalcenie
        'Manager', -- Stanowisko
        5000, -- Pensja
        TO_DATE('2023-11-20', 'YYYY-MM-DD'), -- Data_zatrudnienia
        'Contract', -- Umowa_nazwa
        'Department', -- Dzial_nazwa
        'Description' -- Opis_zmiany
    );
BEGIN
    InsertEmployeeDetails(emp_data);
    COMMIT;
END;