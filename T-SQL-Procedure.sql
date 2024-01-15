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
