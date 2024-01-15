-- Wyzwalacz 1: Przed aktualizacją ceny w Fakturze, sprawdź, czy nowa cena jest większa niż stara
CREATE TRIGGER SprawdzCenePrzedAktualizacja
ON Faktura
BEFORE UPDATE
AS
BEGIN
    IF (SELECT Cena FROM inserted) <= (SELECT Cena FROM deleted)
    BEGIN
        RAISEERROR('Nowa cena musi być większa niż stara cena', 16, 1);
    END;
END;

-- Wyzwalacz 2: Po usunięciu klienta, usuń również powiązane pojazdy i zapisz do logu
CREATE TRIGGER UsunPojazdyPoUsunieciuKlienta
ON Klient
AFTER DELETE
AS
BEGIN
    DELETE FROM Pojazd WHERE Klient_ID_Klienta IN (SELECT ID_Klienta FROM deleted);

    INSERT INTO LogUsunieciaKlienta (ID_Klienta, DataUsuniecia)
    SELECT ID_Klienta, GETDATE() FROM deleted;
END;

-- Wyzwalacz 3: Zablokowanie aktualizacji statusu, jeśli naprawa została już zakończona
CREATE TRIGGER BlokujAktualizacjeStatusu
ON Naprawa
BEFORE UPDATE
AS
BEGIN
    IF (SELECT Status FROM deleted) = 'Zakończona'
    BEGIN
        RAISEERROR('Nie można aktualizować statusu zakończonej naprawy.', 16, 1);
    END;
END;

-- Wyzwalacz 4: Zablokowanie usunięcia pracownika, jeśli ma przypisane aktywne naprawy
CREATE TRIGGER BlokujUsunieciePracownika
ON Pracownik
INSTEAD OF DELETE
AS
BEGIN
    IF (SELECT COUNT(*)
        FROM Naprawa
        WHERE Pracownik_ID_Pracownika IN (SELECT ID_Pracownika FROM deleted)
          AND Status IN ('W trakcie naprawy', 'Naprawa zlecona')) > 0
    BEGIN
        RAISEERROR('Nie można usunąć pracownika z przypisanymi aktywnymi naprawami.', 16, 1);
    END;
    ELSE
    BEGIN
        DELETE FROM Pracownik WHERE ID_Pracownika IN (SELECT ID_Pracownika FROM deleted);
    END;
END;
