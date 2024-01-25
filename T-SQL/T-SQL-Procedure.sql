-- Procedura 1: Dodaj Klienta Z Pojazdem i zleceniem naprawy i faktura
ALTER PROCEDURE DodajKlienta (
    @p_Imie NVARCHAR(255),
    @p_Nazwisko NVARCHAR(255),
    @p_VIN INT,
    @p_Opis NVARCHAR(255),
    @p_OpisNaprawy NVARCHAR(255),
    @p_Cena DECIMAL(18,2)
)
AS
BEGIN
    DECLARE @v_ID_Klienta INT, @v_ID_Pojazdu INT, @v_ID_Faktury INT, @v_ID_Naprawy INT;

    INSERT INTO Klient (Imie, Nazwisko) VALUES (@p_Imie, @p_Nazwisko);
    SET @v_ID_Klienta = SCOPE_IDENTITY();

    INSERT INTO Pojazd (VIN, Opis, Klient_ID_Klienta) VALUES (@p_VIN, @p_Opis, @v_ID_Klienta);
    SET @v_ID_Pojazdu = SCOPE_IDENTITY();

    INSERT INTO Faktura (Klient_ID_Klienta, Sprzedawca, Cena, Sprzedawca_ID) VALUES (@v_ID_Klienta, 'Leszek', @p_Cena, 1);
    SET @v_ID_Faktury = SCOPE_IDENTITY();

    INSERT INTO Naprawa (DATA_ROZPOCZECIA_NAPRAWY, DATA_ZAKONCZENIA_NAPRAWY, POJAZD_ID, STANOWISKO_ID_STANOWISKA, OPIS_USTERKI, FAKTURA_ID_FAKTURY)
    VALUES (GETDATE(), NULL, @v_ID_Pojazdu, 1, @p_OpisNaprawy, @v_ID_Faktury);

    PRINT 'Dodano klienta z pojazdem, naprawą i fakturą.';
END;

--Test
SELECT * FROM Klient K
JOIN Pojazd P ON K.ID_Klienta = P.Klient_ID_Klienta;

--Wykonaj
EXEC DodajKlienta 'Adaś', 'Niezgódka', 1946, 'Tramwaj', 'nie działa', 0;

-- Procedura 2: Aktualizuj Status Naprawy
ALTER PROCEDURE AktualizujStatusNaprawy (
    @p_ID_Naprawy INT,
    @p_Cena DECIMAL(18,2),
    @v_ID_Faktury INT
)
AS
BEGIN
    BEGIN
        UPDATE Naprawa SET DATA_ZAKONCZENIA_NAPRAWY = GETDATE() WHERE ID_Naprawy = @p_ID_Naprawy;

        UPDATE Faktura SET Cena = @p_Cena WHERE ID_FAKTURY = @v_ID_Faktury;

        PRINT 'Zaktualizowano status naprawy.';
    END;
END;

--Test
SELECT * FROM Faktura;
SELECT * FROM Naprawa;

--Wykonaj
EXEC AktualizujStatusNaprawy 8, 12000, 5;

-- Procedura 3: Usun klienta wraz z jego pojazdami, naprawami i fakturami
ALTER PROCEDURE UsunKlienta (
    @p_ID_Klienta INT
)
AS
BEGIN
    BEGIN
        DELETE FROM Naprawa WHERE POJAZD_ID IN (
            SELECT ID_Pojazdu FROM Pojazd WHERE Klient_ID_Klienta = @p_ID_Klienta
        );

        DELETE FROM Faktura WHERE Klient_ID_Klienta = @p_ID_Klienta;

        DELETE FROM Pojazd WHERE Klient_ID_Klienta = @p_ID_Klienta;

        DELETE FROM Klient WHERE ID_Klienta = @p_ID_Klienta;

        PRINT 'Usunięto klienta wraz z pojazdami, naprawami i fakturami.';
    END;
END;

--Test
SELECT k.ID_Klienta, k.Imie, k.Nazwisko, p.ID_Pojazdu, p.VIN, p.Opis, n.ID_NAPRAWY
FROM Klient k
JOIN Pojazd p ON k.ID_Klienta = p.Klient_ID_Klienta
LEFT JOIN Naprawa n ON p.ID_Pojazdu = n.Pojazd_ID
WHERE k.ID_Klienta = 9;

--Wykonaj
EXEC UsunKlienta 9;

-- Procedura 4: Zwieksz cene na wszystkich fakturach o 20%
ALTER PROCEDURE ZwiekszCeneFaktur (
    @p_ID_Klienta INT
)
AS
BEGIN
    UPDATE Faktura
    SET Cena = Cena * 1.2
    WHERE Klient_ID_Klienta = @p_ID_Klienta;

    PRINT 'Zwiększono cenę faktur dla klienta o ID ' + CAST(@p_ID_Klienta AS NVARCHAR) + ' o 20%.';
END;

--Test
SELECT * FROM Faktura

--Wykonaj
EXEC ZwiekszCeneFaktur 7;

-- Procedura 6 * dodatkowa:
-- Procedura ma:
-- wypisać średnią wartość wszystkich faktur
-- wypisać średnią wartość wszystkich faktur względem Sprzedawca_ID
-- zwiększyć o 5% wartość wszystkich faktur Sprzedawcy którego średnia jest największa
-- zwiększyć o 10% wartość wszystkich faktur Sprzedawcy którego średnia jest najmniejsza.
-- wypisać dla których Sprzedawców faktury zostały podniesione i zmniejszone.
-- zwiększyć o 20% każdą fakturę która sumarycznie została wyceniona na mniej niż 1000.
-- wypisać każdą fakturę która została zwiększona o 20%.
CREATE PROCEDURE ModyfikujFaktury AS
BEGIN
    DECLARE @v_SredniaMin DECIMAL(18, 2);
    DECLARE @v_PodniesionoSprzedawcaID INT;
    DECLARE @v_ZmniejszonoSprzedawcaID INT;
    DECLARE @v_SprzedawcaID INT;
    DECLARE @v_Srednia DECIMAL(18, 2);
    DECLARE @v_MinimalnaSuma DECIMAL(18, 2) = 1000;
    DECLARE @v_PodniesionaFakturaID INT;

    SELECT @v_SredniaMin = AVG(Cena)
    FROM Faktura;

    PRINT 'Średnia wartość wszystkich faktur: ' + CAST(@v_SredniaMin AS VARCHAR(20));

    DECLARE sprzedawca_cursor CURSOR FOR
    SELECT DISTINCT Sprzedawca_ID FROM Faktura;

    OPEN sprzedawca_cursor;
    FETCH NEXT FROM sprzedawca_cursor INTO @v_SprzedawcaID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @v_Srednia = AVG(Cena)
        FROM Faktura
        WHERE Sprzedawca_ID = @v_SprzedawcaID;

        PRINT 'Średnia wartość faktur dla Sprzedawcy ' + CAST(@v_SprzedawcaID AS VARCHAR(10)) + ': ' + CAST(@v_Srednia AS VARCHAR(20));

        FETCH NEXT FROM sprzedawca_cursor INTO @v_SprzedawcaID;
    END

    CLOSE sprzedawca_cursor;
    DEALLOCATE sprzedawca_cursor;

    SELECT TOP 1 @v_PodniesionoSprzedawcaID = Sprzedawca_ID
    FROM Faktura
    GROUP BY Sprzedawca_ID
    ORDER BY AVG(Cena) DESC;

    UPDATE Faktura
    SET Cena = Cena * 1.05
    WHERE Sprzedawca_ID = @v_PodniesionoSprzedawcaID;

    PRINT 'Zwiększono wartość faktur dla Sprzedawcy ' + CAST(@v_PodniesionoSprzedawcaID AS VARCHAR(10)) + ' o 5%';

    SELECT TOP 1 @v_ZmniejszonoSprzedawcaID = Sprzedawca_ID
    FROM Faktura
    GROUP BY Sprzedawca_ID
    ORDER BY AVG(Cena);

    UPDATE Faktura
    SET Cena = Cena * 1.10
    WHERE Sprzedawca_ID = @v_ZmniejszonoSprzedawcaID;

    PRINT 'Zwiększono wartość faktur dla Sprzedawcy ' + CAST(@v_ZmniejszonoSprzedawcaID AS VARCHAR(10)) + ' o 10%';

    DECLARE faktura_cursor CURSOR FOR
    SELECT ID_Faktury
    FROM Faktura
    WHERE Cena <= @v_MinimalnaSuma * 1.20;

    OPEN faktura_cursor;
    FETCH NEXT FROM faktura_cursor INTO @v_PodniesionaFakturaID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'ID_Faktury zwiększone o 20%: ' + CAST(@v_PodniesionaFakturaID AS VARCHAR(10));

        FETCH NEXT FROM faktura_cursor INTO @v_PodniesionaFakturaID;
    END

    CLOSE faktura_cursor;
    DEALLOCATE faktura_cursor;

    UPDATE Faktura
    SET Cena = Cena * 1.20
    WHERE Sprzedawca_ID IS NOT NULL AND Cena <= @v_MinimalnaSuma * 1.20;

END;

Exec ModyfikujFaktury;

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
    @v_SprzedawcaID INT,
    @v_Srednia DECIMAL(18, 2);

DECLARE sprzedawca_cursor CURSOR FOR
    SELECT ID, Sprzedawca
    FROM Sprzedawca;

OPEN sprzedawca_cursor;

FETCH NEXT FROM sprzedawca_cursor INTO @v_SprzedawcaID, @v_Srednia;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @v_Srednia = AVG(Cena)
    FROM Faktura
    WHERE Sprzedawca_ID = @v_SprzedawcaID;

    PRINT 'Średnia wartość faktur dla Sprzedawcy ' + CAST(@v_SprzedawcaID AS NVARCHAR(10)) + ' ' + CAST(@v_Srednia AS NVARCHAR(20));

    IF @v_Srednia < 5000
    BEGIN
        DELETE FROM Faktura WHERE Sprzedawca_ID = @v_SprzedawcaID;
        DELETE FROM Sprzedawca WHERE ID = @v_SprzedawcaID;

        PRINT 'Usunięto Sprzedawcę ' + CAST(@v_SprzedawcaID AS NVARCHAR(10)) + ' i jego faktury ze względu na niską średnią.';
    END;

    FETCH NEXT FROM sprzedawca_cursor INTO @v_SprzedawcaID, @v_Srednia;
END

CLOSE sprzedawca_cursor;
DEALLOCATE sprzedawca_cursor;


SELECT Sprzedawca_ID, AVG(Cena) AS Srednia FROM Faktura
GROUP BY Sprzedawca_ID;

INSERT INTO Sprzedawca VALUES (4);
INSERT INTO Faktura VALUES (1, 'do usuniecia', 100, 4);

SELECT * FROM Sprzedawca;

SELECT * FROM Faktura;
