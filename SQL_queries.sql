--Znajdz klientów z nazwiskiem zaczynającym się na N
SELECT nazwisko FROM KLIENT
WHERE nazwisko LIKE 'N%';

--Znajdz naprawy które zaczęły się po 2020-10-01
SELECT * FROM NAPRAWA
WHERE DATA_ROZPOCZECIA_NAPRAWY > '2020-10-01';

--Znajdz pojazdy klienta o ID 5
SELECT ID_Pojazdu FROM POJAZD
WHERE KLIENT_ID_KLIENTA = 5;

--Znajdz średnią kwotę na fakturach wystawionych przez Leszka
SELECT AVG(cena) FROM FAKTURA
WHERE sprzedawca = 'Leszek';

--Znajdz pojady których naprawę opłaca faktura nr 4
SELECT Pojazd_ID FROM NAPRAWA
WHERE FAKTURA_ID_FAKTURY = 4;

--Znajdz informacje o pojazdach klienta o id 8
SELECT * FROM POJAZD
WHERE KLIENT_ID_KLIENTA = 8;

--Znajdz wszystkie opisy usterki oraz opisy samochodu
SELECT N.Opis_usterki, P.Opis FROM Naprawa N
JOIN Pojazd P ON N.Pojazd_ID = P.ID_Pojazdu;

--Znajdz informacje o fakturach droższych od 4k
SELECT K.Imie, K.Nazwisko, F.Cena, F.Sprzedawca FROM Faktura F
JOIN Klient K ON F.Klient_ID_Klienta = K.ID_Klienta
WHERE F.Cena > 4000;

-- Znajdz naprawy wykonane przez mechanika o ID 1
SELECT N.ID_Naprawy, N.Opis_usterki FROM Naprawa N
JOIN Pojazd P ON N.Pojazd_ID = P.ID_Pojazdu
JOIN zaloga_podejmujaca ZP ON N.ID_Naprawy = ZP.Naprawa_ID
JOIN Mechanik M ON ZP.Mechanik_ID_Mechanika = M.ID_Mechanika
WHERE M.ID_Mechanika = 2;

--Znajdz wszystkie naprawy silnika wykonane na tym warsztacie
SELECT N.ID_Naprawy, N.Opis_usterki FROM Naprawa N
JOIN usluga_naprawa UN ON N.ID_Naprawy = UN.Naprawa_ID_Naprawy
JOIN Usluga U ON UN.Usluga_ID_Uslugi = U.ID_Uslugi
WHERE U.ID_Uslugi = 3

--Znajdz naprawy i usługi wykonane dla każdej naprawy
SELECT N.ID_Naprawy, N.Opis_usterki, U.Usluga FROM Naprawa N
JOIN usluga_naprawa UN ON N.ID_Naprawy = UN.Naprawa_ID_Naprawy
JOIN Usluga U ON UN.Usluga_ID_Uslugi = U.ID_Uslugi
ORDER BY N.ID_Naprawy DESC

--Znajdz sumę cen faktur dla każdego sprzedawcy, którzy mają więcej niż 10 faktur
SELECT Sprzedawca, SUM(Cena) AS SumaCenFaktur FROM Faktura
GROUP BY Sprzedawca
HAVING COUNT(ID_Faktury) > 2;

--Znajdz liczbę pojazdów posiadanych przez każdego klienta
SELECT Klient_ID_Klienta, COUNT(*) AS LiczbaPojazdow FROM Pojazd
GROUP BY KLIENT_ID_KLIENTA;

--Znajdz klientów, których liczba faktur wynosi 2
SELECT Klient_ID_Klienta, COUNT(*) AS LiczbaFaktur FROM Faktura
GROUP BY Klient_ID_Klienta
HAVING COUNT(*) = 2;

--Znajdz Mercedesy
SELECT ID_Pojazdu, Opis FROM Pojazd
WHERE Opis LIKE '%ercedes%'
GROUP BY ID_Pojazdu, Opis;

--Znajdz sprzedawców, którzy dokonali sprzedaży o łącznej wartości powyżej 5k
SELECT Sprzedawca, SUM(Cena) AS SumaSprzedazy FROM Faktura
GROUP BY Sprzedawca
HAVING SUM(Cena) > 5000;

--Znajdz klientów posiadających więcej niż 1 pojazd
SELECT Imie, Nazwisko FROM Klient
WHERE ID_Klienta IN (
    SELECT Klient_ID_Klienta FROM Pojazd
    GROUP BY Klient_ID_Klienta
    HAVING COUNT(*) > 1
);

--Znajdz wszystkie naprawy pojazdów klienta Makowski
SELECT * FROM Naprawa
WHERE Pojazd_ID IN (
    SELECT ID_Pojazdu FROM Pojazd
    JOIN Klient ON Pojazd.Klient_ID_Klienta = Klient.ID_Klienta
    WHERE Nazwisko = 'Makowski'
);

--Znajdz wszystkie naprawy, których koszt jest wyższy niż średni koszt
SELECT * FROM Naprawa n
JOIN FAKTURA f ON f.ID_FAKTURY = n.FAKTURA_ID_FAKTURY
WHERE f.Cena > (SELECT AVG(Cena) FROM Faktura);

--Znajdz klientów, którzy mają pojazd o największej wartości VIN w systemie:
SELECT * FROM Klient
WHERE (
	SELECT MAX(VIN) FROM Pojazd
	WHERE Klient_ID_Klienta = Klient.ID_Klienta
) = (SELECT MAX(VIN) FROM Pojazd);

--Znajdz pojazdy, których klientowie mają więcej niż 1 fakturę:
SELECT * FROM Pojazd
WHERE Klient_ID_Klienta IN (
    SELECT Klient_ID_Klienta FROM Faktura
    GROUP BY Klient_ID_Klienta
    HAVING COUNT(DISTINCT ID_Faktury) > 1
);

--STARE ZAPYTANIA

--Znajdz klientow, ktorzy zaplacili za fakture wiecej niz najwyzsza cena za wymiane oleju
SELECT Imie, Nazwisko FROM Klient, Faktura a
WHERE Cena > (
    SELECT MAX(Cena) FROM Faktura b
    JOIN Usluga c ON a.Cena = b.Cena
    WHERE c.Usluga = 'Wymiana_oleju'
);

--Znajdz sredni koszt za fakture, ktora jest za wiecej niż 2 naprawy
SELECT AVG(cena), ID_Faktury FROM Faktura
JOIN Naprawa ON Faktura.ID_Faktury = Naprawa.Faktura_ID_Faktury
GROUP BY Faktura.ID_Faktury
HAVING COUNT(*) > 2;

--Znajdz faktury z najniższą kwotą
SELECT ID_Faktury FROM Faktura
WHERE Cena = (
	SELECT MIN(Cena) FROM Faktura
);

--Znajdz faktury z wieksza kwota niz srednia cena na fakturach wystawionych dla
-- klientow ktorych imie konczy sie na a ale tez z cena mniejsza niz maksymalna
-- cena na fakturze wystawionej przez sprzedawce z ID 1 albo 2
SELECT ID_Faktury FROM Faktura
WHERE Cena > (
    SELECT AVG(Cena) FROM Faktura, Klient
    WHERE Imie = '%a'
) AND Cena < (
    SELECT MAX(Cena) FROM Faktura
    WHERE Sprzedawca_ID != 1 AND Sprzedawca_ID != 2
);

--Znajdz ile kazdy z klientow otrzymal faktur
SELECT Imie, Nazwisko, (
	SELECT COUNT(ID_Faktury) FROM Faktura b
	WHERE a.ID_Klienta = b.Klient_ID_Klienta
) as Liczba_Faktur
FROM  Klient a

--Zmniejsz cenę faktur do 70% gdzie byla wykonana usluga nr 5
UPDATE Faktura SET Cena=Cena*0.7
WHERE Sprzedawca_ID = (
    SELECT Sprzedawca_ID FROM Faktura
    WHERE ID_Faktury = (
        SELECT Faktura_ID_Faktury FROM Naprawa
        WHERE Faktura_ID_Faktury = (
            SELECT Naprawa_ID_Naprawy FROM usluga_naprawa
            WHERE Usluga_ID_Uslugi = 5
        )
    )
);
UPDATE Faktura SET Cena=Cena*0.7
WHERE ID_Faktury = (
    SELECT Faktura_ID_Faktury FROM Naprawa
    WHERE ID_Naprawy = (
        SELECT Naprawa_ID_Naprawy FROM usluga_naprawa
        WHERE Usluga_ID_Uslugi = 5
    )
);

--Usun wszystkie faktury wystawione przed 01.01.1995
DELETE FROM Faktura
WHERE ID_Faktury = (
    SELECT Faktura_ID_Faktury FROM Naprawa
    WHERE Data_Zakonczenia_Naprawy < '01.01.1995'
);
