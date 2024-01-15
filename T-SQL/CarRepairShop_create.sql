-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2022-06-23 13:41:59.74

-- tables
-- Table: Faktura
CREATE TABLE Faktura (
    ID_Faktury number  NOT NULL,
    Klient_ID_Klienta number  NOT NULL,
    Sprzedawca varchar2(40)  NOT NULL,
    Cena number  NOT NULL,
    Sprzedawca_ID number  NOT NULL,
    CONSTRAINT Faktura_pk PRIMARY KEY (ID_Faktury)
) ;

-- Table: Klient
CREATE TABLE Klient (
    ID_Klienta number  NOT NULL,
    Imie varchar2(40)  NOT NULL,
    Nazwisko varchar2(40)  NOT NULL,
    CONSTRAINT Klient_pk PRIMARY KEY (ID_Klienta)
) ;

-- Table: Mechanik
CREATE TABLE Mechanik (
    ID_Mechanika number  NOT NULL,
    Imie varchar2(40)  NOT NULL,
    Nazwisko varchar2(40)  NOT NULL,
    CONSTRAINT Mechanik_pk PRIMARY KEY (ID_Mechanika)
) ;

-- Table: Naprawa
CREATE TABLE Naprawa (
    ID_Naprawy number  NOT NULL,
    Data_Rozpoczecia_Naprawy date  NULL,
    Data_Zakonczenia_Naprawy date  NULL,
    Pojazd_ID number  NOT NULL,
    Stanowisko_ID_Stanowiska number  NOT NULL,
    Opis_usterki varchar2(50)  NOT NULL,
    Faktura_ID_Faktury number  NOT NULL,
    CONSTRAINT Naprawa_pk PRIMARY KEY (ID_Naprawy)
) ;

-- Table: Pojazd
CREATE TABLE Pojazd (
    ID_Pojazdu number  NOT NULL,
    VIN number  NOT NULL,
    Opis varchar2(50)  NOT NULL,
    Klient_ID_Klienta number  NOT NULL,
    CONSTRAINT Pojazd_pk PRIMARY KEY (ID_Pojazdu)
) ;

-- Table: Specjalizacja
CREATE TABLE Specjalizacja (
    ID number  NOT NULL,
    Specjalizacja number  NOT NULL,
    CONSTRAINT Specjalizacja_pk PRIMARY KEY (ID)
) ;

-- Table: Sprzedawca
CREATE TABLE Sprzedawca (
    ID number  NOT NULL,
    Sprzedawca number  NOT NULL,
    CONSTRAINT Sprzedawca_pk PRIMARY KEY (ID)
) ;

-- Table: Stanowisko
CREATE TABLE Stanowisko (
    ID_Stanowiska number  NOT NULL,
    Specjalizacja_ID number  NOT NULL,
    CONSTRAINT Stanowisko_pk PRIMARY KEY (ID_Stanowiska)
) ;

-- Table: Usluga
CREATE TABLE Usluga (
    ID_Uslugi number  NOT NULL,
    Usluga varchar2(100)  NOT NULL,
    CONSTRAINT Usluga_pk PRIMARY KEY (ID_Uslugi)
) ;

-- Table: usluga_naprawa
CREATE TABLE usluga_naprawa (
    Usluga_ID_Uslugi number  NOT NULL,
    Naprawa_ID_Naprawy number  NOT NULL,
    CONSTRAINT usluga_naprawa_pk PRIMARY KEY (Usluga_ID_Uslugi,Naprawa_ID_Naprawy)
) ;

-- Table: zaloga_podejmujaca
CREATE TABLE zaloga_podejmujaca (
    Naprawa_ID number  NOT NULL,
    Mechanik_ID_Mechanika number  NOT NULL,
    CONSTRAINT zaloga_podejmujaca_pk PRIMARY KEY (Naprawa_ID,Mechanik_ID_Mechanika)
) ;

-- foreign keys
-- Reference: Faktura_Klient (table: Faktura)
ALTER TABLE Faktura ADD CONSTRAINT Faktura_Klient
    FOREIGN KEY (Klient_ID_Klienta)
    REFERENCES Klient (ID_Klienta);

-- Reference: Faktura_Sprzedawca (table: Faktura)
ALTER TABLE Faktura ADD CONSTRAINT Faktura_Sprzedawca
    FOREIGN KEY (Sprzedawca_ID)
    REFERENCES Sprzedawca (ID);

-- Reference: Naprawa_Faktura (table: Naprawa)
ALTER TABLE Naprawa ADD CONSTRAINT Naprawa_Faktura
    FOREIGN KEY (Faktura_ID_Faktury)
    REFERENCES Faktura (ID_Faktury);

-- Reference: Naprawa_Pojazd (table: Naprawa)
ALTER TABLE Naprawa ADD CONSTRAINT Naprawa_Pojazd
    FOREIGN KEY (Pojazd_ID)
    REFERENCES Pojazd (ID_Pojazdu);

-- Reference: Naprawa_Stanowisko (table: Naprawa)
ALTER TABLE Naprawa ADD CONSTRAINT Naprawa_Stanowisko
    FOREIGN KEY (Stanowisko_ID_Stanowiska)
    REFERENCES Stanowisko (ID_Stanowiska);

-- Reference: Pojazd_Klient (table: Pojazd)
ALTER TABLE Pojazd ADD CONSTRAINT Pojazd_Klient
    FOREIGN KEY (Klient_ID_Klienta)
    REFERENCES Klient (ID_Klienta);

-- Reference: Stanowisko_Table_15 (table: Stanowisko)
ALTER TABLE Stanowisko ADD CONSTRAINT Stanowisko_Table_15
    FOREIGN KEY (Specjalizacja_ID)
    REFERENCES Specjalizacja (ID);

-- Reference: usluga_naprawa_Naprawa (table: usluga_naprawa)
ALTER TABLE usluga_naprawa ADD CONSTRAINT usluga_naprawa_Naprawa
    FOREIGN KEY (Naprawa_ID_Naprawy)
    REFERENCES Naprawa (ID_Naprawy);

-- Reference: usluga_naprawa_Usluga (table: usluga_naprawa)
ALTER TABLE usluga_naprawa ADD CONSTRAINT usluga_naprawa_Usluga
    FOREIGN KEY (Usluga_ID_Uslugi)
    REFERENCES Usluga (ID_Uslugi);

-- Reference: zaloga_podejmujaca_Mechanik (table: zaloga_podejmujaca)
ALTER TABLE zaloga_podejmujaca ADD CONSTRAINT zaloga_podejmujaca_Mechanik
    FOREIGN KEY (Mechanik_ID_Mechanika)
    REFERENCES Mechanik (ID_Mechanika);

-- Reference: zaloga_podejmujaca_Naprawa (table: zaloga_podejmujaca)
ALTER TABLE zaloga_podejmujaca ADD CONSTRAINT zaloga_podejmujaca_Naprawa
    FOREIGN KEY (Naprawa_ID)
    REFERENCES Naprawa (ID_Naprawy);

-- End of file.
