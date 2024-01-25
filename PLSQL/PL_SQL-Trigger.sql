-- Wyzwalacz 1: Przed aktualizacją ceny w Fakturze, sprawdź, czy nowa cena jest większa niż stara
CREATE OR REPLACE TRIGGER SprawdzCenePrzedAktualizacja
BEFORE UPDATE ON Faktura
FOR EACH ROW
BEGIN
    IF NVL(:NEW.Cena, 0) <= NVL(:OLD.Cena, 0) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nowa cena musi być większa niż stara cena');
    END IF;
END SprawdzCenePrzedAktualizacja;

UPDATE Faktura
SET Cena = Cena - 10
WHERE ID_FAKTURY >= 1;

SELECT * FROM Faktura;

-- Wyzwalacz 2: Zablokowanie aktualizacji daty zakonczenia, jeśli naprawa została już zakończona
CREATE OR REPLACE TRIGGER BlokujAktualizacjeDaty
BEFORE UPDATE ON Naprawa
FOR EACH ROW
BEGIN
    IF :NEW.DATA_ZAKONCZENIA_NAPRAWY IS NOT NULL AND :NEW.DATA_ZAKONCZENIA_NAPRAWY >= :OLD.DATA_ZAKONCZENIA_NAPRAWY THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie można aktualizować daty zakończonej naprawy');
    END IF;
END BlokujAktualizacjeDaty;

INSERT INTO Naprawa (ID_Naprawy, DATA_ROZPOCZECIA_NAPRAWY, DATA_ZAKONCZENIA_NAPRAWY, POJAZD_ID, STANOWISKO_ID_STANOWISKA, OPIS_USTERKI, FAKTURA_ID_FAKTURY)
VALUES (100, SYSDATE - 10, SYSDATE - 5, 1, 1, 'Testowa naprawa', 100);

UPDATE Naprawa SET DATA_ZAKONCZENIA_NAPRAWY = SYSDATE - 6 WHERE ID_Naprawy = 100;

UPDATE Naprawa SET DATA_ZAKONCZENIA_NAPRAWY = TO_DATE('2023-02-01', 'YYYY-MM-DD') WHERE ID_Naprawy >= 1;

SELECT * FROM Naprawa;

-- Wyzwalacz 3: Po usunięciu klienta, usuń również powiązane pojazdy
CREATE OR REPLACE TRIGGER UsunPojazdyPoUsunieciuKlienta
BEFORE DELETE ON Klient
FOR EACH ROW
BEGIN
    DELETE FROM Pojazd WHERE Klient_ID_Klienta = :OLD.ID_Klienta;

END UsunPojazdyPoUsunieciuKlienta;

INSERT INTO Klient (ID_Klienta, Imie, Nazwisko) VALUES (100, 'Jan', 'Kowalski');
INSERT INTO Pojazd (ID_Pojazdu, VIN, Opis, Klient_ID_Klienta) VALUES (100, 0000, 'Samochód', 100);

SELECT * FROM Klient K
JOIN Pojazd P ON K.ID_KLIENTA = P.KLIENT_ID_KLIENTA
WHERE ID_Klienta = 100;

DELETE FROM Klient WHERE ID_Klienta = 100;

-- Wyzwalacz 4 * dodatkowy:
-- nie pozwoli usuwać napraw które mają Datę zakończenia naprawy
-- nie pozwoli na zmianę ID_Naprawy oraz Daty zakończenia naprawy (jeżeli nie jest null)
CREATE OR REPLACE TRIGGER SprawdzEdycjeNaprawy
BEFORE DELETE OR UPDATE OF ID_Naprawy, Data_Zakonczenia_Naprawy ON Naprawa
FOR EACH ROW
BEGIN

    IF :OLD.Data_Zakonczenia_Naprawy IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie można usunąć ani modyfikować naprawy z ustawioną datą zakończenia.');
    END IF;

    IF :OLD.ID_Naprawy != :NEW.ID_Naprawy OR (:NEW.Data_Zakonczenia_Naprawy IS NOT NULL AND :OLD.Data_Zakonczenia_Naprawy != :NEW.Data_Zakonczenia_Naprawy) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie można zmieniać ID_Naprawy ani Daty zakończenia naprawy.');
    END IF;
END;

DELETE FROM Naprawa WHERE ID_Naprawy = 1;

UPDATE Naprawa SET ID_Naprawy = 1 WHERE ID_Naprawy = 9;

SELECT * FROM Naprawa;

UPDATE Naprawa SET Data_Zakonczenia_Naprawy = TO_DATE('2023-01-02', 'YYYY-MM-DD') WHERE ID_Naprawy = 1;
