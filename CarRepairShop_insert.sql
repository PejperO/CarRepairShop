ALTER SESSION SET nls_date_format = 'yyyy-mm-dd';

insert into KLIENT values(1, 'Leszek', 'Kozlowski');
insert into KLIENT values(2, 'Miłosz', 'Baran');
insert into KLIENT values(3, 'Emil', 'Marciniak');
insert into KLIENT values(4, 'Mikolaj', 'Czereśniak');
insert into KLIENT values(5, 'Stanislaw', 'Wlodarczyk');
insert into KLIENT values(6, 'Marta', 'Nowakowska');
insert into KLIENT values(7, 'Krzysztof', 'Nowak');
insert into KLIENT values(8, 'Artur', 'Makowski');

insert into POJAZD values(1, 1293 ,'bmw po tuningu', 1);
insert into POJAZD values(2, 6234 ,'volvo bez wydechu',2 );
insert into POJAZD values(3, 5456 ,'mazda miatka ^^', 3);
insert into POJAZD values(4, 7895 ,'Mercedes prezesa', 4);
insert into POJAZD values(5, 0721 ,'opel do poprawy blacharskiej', 5);
insert into POJAZD values(6, 4561 ,'cithroen od francuza', 5);
insert into POJAZD values(7, 2347 ,'dodge Czarnoskórego', 7);
insert into POJAZD values(8, 5582 ,'bmw Sebastiana z Otwocka', 8);
insert into POJAZD values(9, 7824 ,'mazda suv mamusi z chorom curkom', 6);
insert into POJAZD values(10, 5656 ,'mercedes bezdomnego z torunia', 8);
insert into POJAZD values(11, 7777 ,'fiat nauczycieli od polskiego', 6);

insert into SPRZEDAWCA values(1, 10);
insert into SPRZEDAWCA values(2, 20);
insert into SPRZEDAWCA values(3, 30);

insert into FAKTURA values(1, 6,'Leszek' ,1200,10);
insert into FAKTURA values(2, 8,'Leszek' ,2400,10);
insert into FAKTURA values(3, 6,'Leszek' ,8700,10);
insert into FAKTURA values(4, 8,'Leszek' ,12500,10);
insert into FAKTURA values(5, 7,'Miłosz' ,2300,20);
insert into FAKTURA values(6, 5,'Miłosz' ,3500,20);
insert into FAKTURA values(7, 5,'Miłosz' ,9200,20);
insert into FAKTURA values(8, 4,'Artur' ,350,30);
insert into FAKTURA values(9, 2,'Artur' ,1100,30);

insert into USLUGA values(1,'Naprawa blacharska');
insert into USLUGA values(2,'Naprawa układu wydehwego');
insert into USLUGA values(3,'Naprawa silnika');
insert into USLUGA values(4,'Wulkanizacja');
insert into USLUGA values(5,'Diagnostyka');
insert into USLUGA values(6,'Elektryka');
insert into USLUGA values(7,'Naprawa Układu zawieszenia');

insert into SPECJALIZACJA values(1, 1828724);
insert into SPECJALIZACJA values(2, 1828724);
insert into SPECJALIZACJA values(3, 1828724);
insert into SPECJALIZACJA values(4, 1828724);

insert into STANOWISKO values(1, 1);
insert into STANOWISKO values(2, 1);
insert into STANOWISKO values(3, 1);
insert into STANOWISKO values(4, 2);
insert into STANOWISKO values(5, 3);
insert into STANOWISKO values(6, 4);

insert into NAPRAWA values(1,'2020-09-15','2020-09-18'  ,1,1,'Nie działa przęgło' ,1);
insert into NAPRAWA values(2,'2020-09-15','2020-09-16'  ,3,2,'Silnik bierze olej' ,2);
insert into NAPRAWA values(3,'2020-09-16','2020-10-01'  ,4,3,'Zawierzenie stuka' ,3);
insert into NAPRAWA values(4,'2020-09-19' ,'2020-09-24'  ,8,1,'Wymiana tłumika wydechu' ,3);
insert into NAPRAWA values(5,'2020-09-17' ,'2020-09-18'  ,7,2,'Wymiana Świec' ,4);
insert into NAPRAWA values(6,'2020-10-02' ,'2020-10-03'  ,6,3,'Wymiana amortyzatorów przednich' ,4);
insert into NAPRAWA values(7,'2020-09-29' ,'2020-10-03'  ,2,4,'Lakierowanie zderzaka' ,4);
insert into NAPRAWA values(8,'2020-10-01' , NULL,5,5,'Diagnostyka ogólna' ,5);
insert into NAPRAWA values(9,NULL ,NULL  ,10,6,'Nie działa kamera cofania' ,6);
insert into NAPRAWA values(10,'2020-09-25' ,'2020-10-02'  ,9,1, 'Wał korbowy pęknięty',7);
insert into NAPRAWA values(11,'2020-09-19' ,'2020-09-21'  ,11,2,'Wymiana tarcz haulcowych' ,8);
insert into NAPRAWA values(12,'2020-10-03' , NULL,1,3,'Wymiana panewek' ,9);

insert into USLUGA_NAPRAWA values(3,1);
insert into USLUGA_NAPRAWA values(3,2);
insert into USLUGA_NAPRAWA values(7,3);
insert into USLUGA_NAPRAWA values(2,4);
insert into USLUGA_NAPRAWA values(3,5);
insert into USLUGA_NAPRAWA values(7,6);
insert into USLUGA_NAPRAWA values(1,7);
insert into USLUGA_NAPRAWA values(5,8);
insert into USLUGA_NAPRAWA values(6,9);
insert into USLUGA_NAPRAWA values(7,10);
insert into USLUGA_NAPRAWA values(7,11);
insert into USLUGA_NAPRAWA values(3,12);

insert into MECHANIK values (1, 'Jerzy', 'Zieliński');
insert into MECHANIK values (2, 'Maciej', 'Kowalczyk');
insert into MECHANIK values (3, 'Józef', 'Lis');

insert into ZALOGA_PODEJMUJACA values(1, 1);
insert into ZALOGA_PODEJMUJACA values(2, 1);
insert into ZALOGA_PODEJMUJACA values(3, 1);
insert into ZALOGA_PODEJMUJACA values(4, 2);
insert into ZALOGA_PODEJMUJACA values(5, 1);
insert into ZALOGA_PODEJMUJACA values(5, 2);
insert into ZALOGA_PODEJMUJACA values(6, 3);
insert into ZALOGA_PODEJMUJACA values(6, 2);
insert into ZALOGA_PODEJMUJACA VALUES(7, 1);
insert into ZALOGA_PODEJMUJACA values(7, 3);
insert into ZALOGA_PODEJMUJACA values(8, 1);
insert into ZALOGA_PODEJMUJACA values(9, 2);
insert into ZALOGA_PODEJMUJACA values(10, 3);
insert into ZALOGA_PODEJMUJACA values(11, 1);
insert into ZALOGA_PODEJMUJACA values(12, 2);
