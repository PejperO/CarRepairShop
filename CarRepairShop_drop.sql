-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2022-06-23 13:41:59.74

-- foreign keys
ALTER TABLE Faktura
    DROP CONSTRAINT Faktura_Klient;

ALTER TABLE Faktura
    DROP CONSTRAINT Faktura_Sprzedawca;

ALTER TABLE Naprawa
    DROP CONSTRAINT Naprawa_Faktura;

ALTER TABLE Naprawa
    DROP CONSTRAINT Naprawa_Pojazd;

ALTER TABLE Naprawa
    DROP CONSTRAINT Naprawa_Stanowisko;

ALTER TABLE Pojazd
    DROP CONSTRAINT Pojazd_Klient;

ALTER TABLE Stanowisko
    DROP CONSTRAINT Stanowisko_Table_15;

ALTER TABLE usluga_naprawa
    DROP CONSTRAINT usluga_naprawa_Naprawa;

ALTER TABLE usluga_naprawa
    DROP CONSTRAINT usluga_naprawa_Usluga;

ALTER TABLE zaloga_podejmujaca
    DROP CONSTRAINT zaloga_podejmujaca_Mechanik;

ALTER TABLE zaloga_podejmujaca
    DROP CONSTRAINT zaloga_podejmujaca_Naprawa;

-- tables
DROP TABLE Faktura;

DROP TABLE Klient;

DROP TABLE Mechanik;

DROP TABLE Naprawa;

DROP TABLE Pojazd;

DROP TABLE Specjalizacja;

DROP TABLE Sprzedawca;

DROP TABLE Stanowisko;

DROP TABLE Usluga;

DROP TABLE usluga_naprawa;

DROP TABLE zaloga_podejmujaca;

-- End of file.
