CREATE SEQUENCE SEQ_KLIENT
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE SEQ_POJAZD
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE SEQ_FAKTURA
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE SEQ_NAPRAWA
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE SEQ
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Procedura 1: Dodaj Klienta Z Pojazdem i zleceniem naprawy i faktura
CREATE OR REPLACE PROCEDURE DodajKlienta (
    p_Imie VARCHAR2,
    p_Nazwisko VARCHAR2,
    p_VIN NUMBER,
    p_Opis VARCHAR2,
    p_OpisNaprawy VARCHAR2,
    p_Cena NUMBER
) AS
    v_ID_Klienta NUMBER;
    v_ID_Pojazdu NUMBER;
    v_ID_Faktury NUMBER;
    v_ID_naprawy NUMBER;
BEGIN
    INSERT INTO Klient (ID_Klienta, Imie, Nazwisko) VALUES (SEQ_KLIENT.NEXTVAL, p_Imie, p_Nazwisko) RETURNING ID_Klienta INTO v_ID_Klienta;

    INSERT INTO Pojazd (ID_Pojazdu, VIN, Opis, Klient_ID_Klienta) VALUES (SEQ_POJAZD.NEXTVAL, p_VIN, p_Opis, v_ID_Klienta) RETURNING ID_Pojazdu INTO v_ID_Pojazdu;

    SELECT SEQ_FAKTURA.NEXTVAL INTO v_ID_Faktury FROM DUAL;
    INSERT INTO Faktura (ID_Faktury, Klient_ID_Klienta, Sprzedawca, Cena, Sprzedawca_ID) VALUES (v_ID_Faktury, v_ID_Klienta, 'Leszek', p_Cena, 1) RETURNING ID_Faktury INTO v_ID_Faktury;

    SELECT SEQ_NAPRAWA.NEXTVAL INTO v_ID_naprawy FROM DUAL;
    INSERT INTO Naprawa (ID_Naprawy, DATA_ROZPOCZECIA_NAPRAWY, DATA_ZAKONCZENIA_NAPRAWY, POJAZD_ID, STANOWISKO_ID_STANOWISKA, OPIS_USTERKI, FAKTURA_ID_FAKTURY)
    VALUES (v_ID_naprawy, SYSDATE, NULL, v_ID_Pojazdu, 1, p_OpisNaprawy, v_ID_Faktury);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dodano klienta z pojazdem, naprawą i fakturą.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania klienta z pojazdem, naprawą i fakturą: ' || SQLERRM);
END DodajKlienta;

SELECT * FROM Klient K
JOIN Pojazd P ON K.ID_Klienta = P.Klient_ID_Klienta;
SELECT * FROM FAKTURA;

CALL DodajKlienta('Adaś', 'Niezgódka', 1946, 'Tramwaj', 'nie dziala', 0);

SELECT k.ID_Klienta, k.Imie, k.Nazwisko, p.ID_Pojazdu, p.VIN, p.Opis, n.ID_NAPRAWY
FROM Klient k
JOIN Pojazd p ON k.ID_Klienta = p.Klient_ID_Klienta
LEFT JOIN Naprawa n ON p.ID_Pojazdu = n.Pojazd_ID
WHERE k.Nazwisko = 'Niezgódka';


-- Procedura 2: Aktualizuj Status Naprawy
CREATE OR REPLACE PROCEDURE AktualizujStatusNaprawy (
    p_ID_Naprawy NUMBER,
    p_Cena NUMBER,
    v_ID_Faktury NUMBER
) AS
BEGIN
    UPDATE Naprawa SET Data_Zakonczenia_Naprawy = SYSDATE WHERE ID_Naprawy = p_ID_Naprawy;

    --SELECT SEQ_FAKTURA.NEXTVAL INTO v_ID_Faktury FROM DUAL;

    UPDATE Faktura SET Cena = p_cena WHERE ID_FAKTURY = v_ID_Faktury;
    --INSERT INTO Faktura (ID_Faktury, Klient_ID_Klienta, Sprzedawca, Cena, Sprzedawca_ID)
    --VALUES (v_ID_Faktury, p_Klient_ID, 'Leszek', p_Cena, p_Sprzedawca_ID);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Zaktualizowano status naprawy.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Błąd podczas aktualizacji statusu naprawy: ' || SQLERRM);
END AktualizujStatusNaprawy;

CALL AktualizujStatusNaprawy(8, 12000, 5);

SELECT * FROM FAKTURA;
SELECT * FROM NAPRAWA;

-- Procedura 3: Usun klienta wraz z jego pojazdami, naprawami i fakturami
CREATE OR REPLACE PROCEDURE UsunKlienta (
    p_ID_Klienta NUMBER
) AS
BEGIN
    BEGIN

        DELETE FROM Naprawa WHERE Pojazd_ID IN (
            SELECT ID_Pojazdu FROM Pojazd WHERE Klient_ID_Klienta = p_ID_Klienta
        );

        DELETE FROM Faktura WHERE Klient_ID_Klienta IN (
            SELECT ID_Klienta FROM Klient WHERE ID_Klienta = p_ID_Klienta
        );

        DELETE FROM Pojazd WHERE Klient_ID_Klienta = p_ID_Klienta;

        DELETE FROM Klient WHERE ID_Klienta = p_ID_Klienta;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Usunięto klienta wraz z pojazdami, naprawami i fakturami.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Błąd podczas usuwania klienta: ' || SQLERRM);
    END;
END UsunKlienta;

CALL UsunKlienta(36);

SELECT k.ID_Klienta, k.Imie, k.Nazwisko, p.ID_Pojazdu, p.VIN, p.Opis, n.ID_NAPRAWY
FROM Klient k
JOIN Pojazd p ON k.ID_Klienta = p.Klient_ID_Klienta
LEFT JOIN Naprawa n ON p.ID_Pojazdu = n.Pojazd_ID
WHERE k.ID_Klienta = 22;

-- Procedura 4: Zwieksz cene na wszystkich fakturach o 20%:
CREATE OR REPLACE PROCEDURE ZwiekszCeneFaktur (
    p_ID_Klienta NUMBER
)
IS
BEGIN
    UPDATE Faktura
    SET Cena = Cena * 1.2
    WHERE Klient_ID_Klienta = p_ID_Klienta;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Zwiększono cenę faktur dla klienta o ID ' || p_ID_Klienta || ' o 20%.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Błąd podczas zwiększania ceny faktur: ' || SQLERRM);
END ZwiekszCeneFaktur;

CALL ZwiekszCeneFaktur(7);
SELECT * FROM FAKTURA

-- Procedura 5: Aktualizacja statusu naprawy z automatycznym przydzielaniem pracownika
CREATE OR REPLACE PROCEDURE AktualizujStatusNaprawy(p_id_naprawy IN NUMBER) AS
    v_status VARCHAR2(50);
    v_pracownik_id NUMBER;
BEGIN
    SELECT Status INTO v_status FROM Naprawa WHERE ID_Naprawy = p_id_naprawy;

    IF v_status = 'W trakcie naprawy' THEN
        SELECT ID_Pracownika INTO v_pracownik_id FROM Pracownik WHERE ROWNUM = 1;

        UPDATE Naprawa SET Status = 'Naprawa zlecona', Pracownik_ID_Pracownika = v_pracownik_id
        WHERE ID_Naprawy = p_id_naprawy;

        INSERT INTO LogPrzydzieleniaPracownika (ID_Naprawy, ID_Pracownika, DataPrzydzielenia)
        VALUES (p_id_naprawy, v_pracownik_id, SYSDATE);

        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie można przydzielić pracownika w aktualnym stanie naprawy.');
    END IF;
END AktualizujStatusNaprawy;

-- Procedura 6 * dodatkowa:
-- Procedura ma:
-- wypisać średnią wartość wszystkich faktur
-- wypisać średnią wartość wszystkich faktur względem Sprzedawca_ID
-- zwiększyć o 5% wartość wszystkich faktur Sprzedawcy którego średnia jest największa
-- zwiększyć o 10% wartość wszystkich faktur Sprzedawcy którego średnia jest najmniejsza.
-- wypisać dla których Sprzedawców faktury zostały podniesione i zmniejszone.
-- zwiększyć o 20% każdą fakturę która sumarycznie została wyceniona na mniej niż 1000.
-- wypisać każdą fakturę która została zwiększona o 20%.
CREATE OR REPLACE PROCEDURE ModyfikujFaktury AS
    v_SredniaMin NUMBER;
    v_PodniesionoSprzedawcaID NUMBER;
    v_ZmniejszonoSprzedawcaID NUMBER;
    v_SprzedawcaID NUMBER;
    v_Srednia NUMBER;
    v_MinimalnaSuma NUMBER := 1000;

BEGIN
    SELECT AVG(Cena) INTO v_SredniaMin FROM Faktura;

    DBMS_OUTPUT.PUT_LINE('Średnia wartość wszystkich faktur: ' || v_SredniaMin);

    FOR sprzedawca_rec IN (SELECT DISTINCT Sprzedawca_ID FROM Faktura) LOOP
        v_SprzedawcaID := sprzedawca_rec.Sprzedawca_ID;

        SELECT AVG(Cena) INTO v_Srednia
        FROM Faktura
        WHERE Sprzedawca_ID = v_SprzedawcaID;

        DBMS_OUTPUT.PUT_LINE('Średnia wartość faktur dla Sprzedawcy ' || v_SprzedawcaID || ': ' || v_Srednia);
    END LOOP;

    SELECT Sprzedawca_ID INTO v_PodniesionoSprzedawcaID
    FROM (SELECT Sprzedawca_ID
          FROM Faktura
          GROUP BY Sprzedawca_ID
          ORDER BY AVG(Cena) DESC
          FETCH FIRST 1 ROWS ONLY);

    UPDATE Faktura
    SET Cena = Cena * 1.05
    WHERE Sprzedawca_ID = v_PodniesionoSprzedawcaID;

    DBMS_OUTPUT.PUT_LINE('Zwiększono wartość faktur dla Sprzedawcy ' || v_PodniesionoSprzedawcaID || ' o 5%');

    SELECT Sprzedawca_ID INTO v_ZmniejszonoSprzedawcaID
    FROM (SELECT Sprzedawca_ID
          FROM Faktura
          GROUP BY Sprzedawca_ID
          ORDER BY AVG(Cena)
          FETCH FIRST 1 ROWS ONLY);

    UPDATE Faktura
    SET Cena = Cena * 1.10
    WHERE Sprzedawca_ID = v_ZmniejszonoSprzedawcaID;

    DBMS_OUTPUT.PUT_LINE('Zwiększono wartość faktur dla Sprzedawcy ' || v_ZmniejszonoSprzedawcaID || ' o 10%');

    FOR Faktura IN (SELECT ID_Faktury FROM Faktura WHERE Cena <= v_MinimalnaSuma) LOOP
        DBMS_OUTPUT.PUT_LINE('ID_Faktury zwiększone o 20%: ' || Faktura.ID_Faktury);
    END LOOP;

    UPDATE Faktura
    SET Cena = Cena * 1.20
    WHERE Sprzedawca_ID IS NOT NULL AND Cena <= v_MinimalnaSuma;

END ModyfikujFaktury;

CALL ModyfikujFaktury();

SELECT AVG(Cena) FROM Faktura;

SELECT Sprzedawca_ID, AVG(Cena) AS Srednia FROM Faktura
GROUP BY Sprzedawca_ID;

SELECT ID_Faktury, Cena, Sprzedawca_ID FROM Faktura
WHERE Cena <=1000;

SELECT * FROM Faktura;

-- Procedura 7 * dodatkowa:
-- przejrzyj wszystkich sprzedawców z tabeli sprzedawca
-- wypisz średnią każdego z nich
-- skasuj każdego z nich (i ich faktury), którzy mają średnią poniżej 5000.
DECLARE
    v_SprzedawcaID Sprzedawca.ID%TYPE;
    v_Srednia DECIMAL(18, 2);

    CURSOR sprzedawca_cursor IS
        SELECT ID, Sprzedawca
        FROM Sprzedawca;

BEGIN
    FOR sprzedawca_rec IN sprzedawca_cursor LOOP
        v_SprzedawcaID := sprzedawca_rec.ID;

        SELECT AVG(Cena) INTO v_Srednia
        FROM Faktura
        WHERE Sprzedawca_ID = v_SprzedawcaID;

        DBMS_OUTPUT.PUT_LINE('Średnia wartość faktur dla Sprzedawcy ' || v_SprzedawcaID || ' '|| v_Srednia);

        IF v_Srednia < 5000 THEN
            DELETE FROM Faktura WHERE Sprzedawca_ID = v_SprzedawcaID;
            DELETE FROM Sprzedawca WHERE ID = v_SprzedawcaID;

            DBMS_OUTPUT.PUT_LINE('Usunięto Sprzedawcę ' || v_SprzedawcaID || ' ' || ' i jego faktury ze względu na niską średnią.');
        END IF;
    END LOOP;
END;


SELECT Sprzedawca_ID, AVG(Cena) AS Srednia FROM Faktura
GROUP BY Sprzedawca_ID;

INSERT INTO Sprzedawca VALUES (4, 4);
INSERT INTO Faktura VALUES (200, 1, 'do usuniecia', 100, 4);

SELECT * FROM Sprzedawca;

SELECT * FROM Faktura;
