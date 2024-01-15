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
