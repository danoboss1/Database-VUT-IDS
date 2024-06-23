-- SQL script na druhu cast projektu
-- xpalen06 Peter Páleník
-- xsehno02 Daniel Sehnoutek
-- zadanie 13 - Restaurace

DROP TABLE zakaznik CASCADE CONSTRAINTS;
DROP TABLE rezervacia CASCADE CONSTRAINTS;
DROP TABLE jedlo CASCADE CONSTRAINTS;
DROP TABLE menu CASCADE CONSTRAINTS;
DROP TABLE zamestnanec CASCADE CONSTRAINTS;
DROP TABLE obsahuje CASCADE CONSTRAINTS;
DROP TABLE pozostava CASCADE CONSTRAINTS;



CREATE TABLE zakaznik (
    id_zakaznika INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    meno VARCHAR(64) NOT NULL,
    priezvisko VARCHAR(64) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefonne_cislo VARCHAR(10) NOT NULL,

    CONSTRAINT check_email CHECK (
        REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        ),
    CONSTRAINT check_telefonne_cislo CHECK (
        REGEXP_LIKE(telefonne_cislo, '^[0-9]{10}$')
        )
);


CREATE TABLE zamestnanec (
    id_zamestnanca INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    meno VARCHAR(64) NOT NULL,
    priezvisko VARCHAR(64) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefonne_cislo VARCHAR(10) NOT NULL,
    mesto VARCHAR(255) NOT NULL,
    ulica VARCHAR(255) NOT NULL,
    rodne_cislo VARCHAR(11) NULL
);

CREATE TABLE rezervacia (
    id_rezervacie INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    datum_konania DATE NOT NULL,
    pocet_osob INT NOT NULL,
    stav VARCHAR2(32) CHECK(stav IN ('nepotvrdena', 'potvrdena', 'zrusena')),
    cislo_salonu INT NULL,
    cislo_stola INT NULL,
    id_zakaznika INT NOT NULL,
    id_zamestnanca INT NOT NULL,

    CONSTRAINT typ_rezervacie CHECK (
        ((cislo_salonu IS NULL) AND (cislo_stola IS NOT NULL) OR
        (cislo_salonu IS NOT NULL) AND (cislo_stola IS NULL))
        ),

    CONSTRAINT FK_id_zakaznika_rezervacia FOREIGN KEY (id_zakaznika) REFERENCES zakaznik,
    CONSTRAINT FK_id_zamestnanca_rezervacia FOREIGN KEY (id_zamestnanca) REFERENCES zamestnanec

);

CREATE TABLE jedlo (
    id_jedla INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    nazov VARCHAR2(64) NOT NULL,
    druh VARCHAR2(32) CHECK(druh IN ('hlavne jedlo','predkrm','polievka','priloha','dezert')),
    cena DECIMAL(6,2) NOT NULL,
    id_zamestnanca INT NOT NULL,

    CONSTRAINT FK_id_zamestnanca_jedlo FOREIGN KEY (id_zamestnanca) REFERENCES zamestnanec
);

CREATE TABLE menu (
    id_menu INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    datum DATE NOT NULL,
    typ VARCHAR2(32) CHECK(typ IN ('ranajkove','denne'))
);

CREATE TABLE obsahuje (
    id_rezervacie INT NOT NULL,
    id_jedla INT NOT NULL,
    pocet_porcii INT NOT NULL,

    CONSTRAINT FK_id_rezervacie_obsahuje FOREIGN KEY (id_rezervacie) REFERENCES rezervacia,
    CONSTRAINT FK_id_jedla_obsahuje FOREIGN KEY (id_jedla) REFERENCES jedlo,
    CONSTRAINT PK_obsahuje PRIMARY KEY (id_rezervacie, id_jedla)
);

CREATE TABLE pozostava (
    id_menu INT NOT NULL,
    id_jedla INT NOT NULL,

    CONSTRAINT FK_id_menu_pozostava FOREIGN KEY (id_menu) REFERENCES menu,
    CONSTRAINT FK_id_jedla_pozostava FOREIGN KEY (id_jedla) REFERENCES jedlo,
    CONSTRAINT PK_pozostava PRIMARY KEY (id_menu, id_jedla)
);


-- triggery

-- Trigger na zmenu formatu rodneho cisla na format s /
CREATE OR REPLACE TRIGGER Format_rodneho_cisla
    BEFORE INSERT OR UPDATE OF rodne_cislo  ON ZAMESTNANEC
    FOR EACH ROW
    declare
        position Integer;

    BEGIN
        position := INSTR(:NEW.rodne_cislo, '/');
        IF position IS NULL OR position = 0 then
           :NEW.rodne_cislo := substr(:NEW.rodne_cislo,1,6) || '/' || substr(:NEW.rodne_cislo,7,4);

        end if;
    END;
/


CREATE OR REPLACE TRIGGER Uprava_rezervacie
    BEFORE INSERT OR UPDATE OF pocet_osob ON REZERVACIA
    FOR EACH ROW
    BEGIN
        IF :NEW.pocet_osob <> :OLD.pocet_osob THEN
            :NEW.stav := 'nepotvrdena';
        END IF;
    END;
/



-- vlozenie testovacich dat

-- Zakaznici
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('Roman', 'Zahalka', 'zahalka@gmail.com', '0771119123');
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('David', 'Prekop', 'prekop2@gmail.com', '0771119123');
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('Eva', 'Fojtikova', 'evus.fojtik@gmail.com', '0771119123');
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('Martin', 'Spano', 'martinkoklingac@gmail.com', '0771119123');
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('Peder', 'Ragula', 'pragula@gmail.com', '7711191023');
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('Adela', 'Briatkova', 'adelab@gmail.com', '7711190123');
INSERT INTO ZAKAZNIK(meno, priezvisko, email, telefonne_cislo)
VALUES('Stefan', 'Harabin', 'stevohar@gmail.com', '7711109123');

-- Zamestnanci
INSERT INTO ZAMESTNANEC(meno, priezvisko, email, telefonne_cislo, mesto, ulica, rodne_cislo)
VALUES('Martin', 'Dolinsky', 'marlinsky@gmail.com', '7885562210', 'Brno', 'Nerudova', '040503/0010');
INSERT INTO ZAMESTNANEC(meno, priezvisko, email, telefonne_cislo, mesto, ulica, rodne_cislo)
VALUES('Andreja', 'Kvorkova', 'physicsmaster@gmail.com', '1115545210', 'Presov', 'Hlavna', '071503/2010');
INSERT INTO ZAMESTNANEC(meno, priezvisko, email, telefonne_cislo, mesto, ulica, rodne_cislo)
VALUES('Adriana', 'Biolek', 'pascal@gmail.com', '7852562990', 'Sedmerovec', 'Kapitana Nalepku', '096503/3010');
INSERT INTO ZAMESTNANEC(meno, priezvisko, email, telefonne_cislo, mesto, ulica, rodne_cislo)
VALUES('Jan', 'Svitana', 'mercedesvito@gmail.com', '4564564560', 'Brno', 'Vlhka', '040563/0070');

-- Rezervacie
INSERT INTO REZERVACIA(datum_konania, pocet_osob, stav, cislo_salonu, cislo_stola, id_zakaznika, id_zamestnanca)
VALUES(TO_DATE('2024-06-01', 'YYYY-MM-DD'), '2', 'nepotvrdena', '', '14', '1', '3');
INSERT INTO REZERVACIA(datum_konania, pocet_osob, stav, cislo_salonu, cislo_stola, id_zakaznika, id_zamestnanca)
VALUES(TO_DATE('2024-06-01', 'YYYY-MM-DD'), '1', 'zrusena', '1', '', '2', '3');
INSERT INTO REZERVACIA(datum_konania, pocet_osob, stav, cislo_salonu, cislo_stola, id_zakaznika, id_zamestnanca)
VALUES(TO_DATE('2024-08-02', 'YYYY-MM-DD'), '4', 'potvrdena', '2', '', '7', '1');
INSERT INTO REZERVACIA(datum_konania, pocet_osob, stav, cislo_salonu, cislo_stola, id_zakaznika, id_zamestnanca)
VALUES(TO_DATE('2025-06-03', 'YYYY-MM-DD'), '5', 'potvrdena', '', '7', '2', '4');
INSERT INTO REZERVACIA(datum_konania, pocet_osob, stav, cislo_salonu, cislo_stola, id_zakaznika, id_zamestnanca)
VALUES(TO_DATE('2025-07-15', 'YYYY-MM-DD'), '5', 'potvrdena', '', '4', '7', '2');
INSERT INTO REZERVACIA(datum_konania, pocet_osob, stav, cislo_salonu, cislo_stola, id_zakaznika, id_zamestnanca)
VALUES(TO_DATE('2024-06-05', 'YYYY-MM-DD'), '6', 'nepotvrdena', '', '4', '3', '4');

-- Jedla
INSERT INTO JEDLO(nazov, druh, cena, id_zamestnanca)
VALUES('bryndzove halusky','hlavne jedlo', 14.99, '1');
INSERT INTO JEDLO(nazov, druh, cena, id_zamestnanca)
VALUES('Jarny zavitok so salatom a sladkokyslou omackou','predkrm', 4.99, '2');
INSERT INTO JEDLO(nazov, druh, cena, id_zamestnanca)
VALUES('kulajda','polievka', 3.59, '3');
INSERT INTO JEDLO(nazov, druh, cena, id_zamestnanca)
VALUES('ryza','priloha', 1.99, '4');
INSERT INTO JEDLO(nazov, druh, cena, id_zamestnanca)
VALUES('eclair','dezert', 6.29, '2');
INSERT INTO JEDLO(nazov, druh, cena, id_zamestnanca)
VALUES('creme brulee so zlatom','dezert', 106.29, '3');

-- Menu
INSERT INTO MENU(datum, typ)
VALUES(TO_DATE('2024-06-01', 'YYYY-MM-DD'), 'ranajkove');
INSERT INTO MENU(datum, typ)
VALUES(TO_DATE('2024-06-01', 'YYYY-MM-DD'), 'denne');
INSERT INTO MENU(datum, typ)
VALUES(TO_DATE('2024-06-02', 'YYYY-MM-DD'), 'ranajkove');
INSERT INTO MENU(datum, typ)
VALUES(TO_DATE('2024-06-02', 'YYYY-MM-DD'), 'denne');
INSERT INTO MENU(datum, typ)
VALUES(TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'denne');
INSERT INTO MENU(datum, typ)
VALUES(TO_DATE('2024-06-04', 'YYYY-MM-DD'), 'ranajkove');

-- Obsahuje
INSERT INTO obsahuje(id_rezervacie, id_jedla, pocet_porcii)
VALUES('1', '1', '4');
INSERT INTO obsahuje(id_rezervacie, id_jedla, pocet_porcii)
VALUES('1', '2', '8');
INSERT INTO obsahuje(id_rezervacie, id_jedla, pocet_porcii)
VALUES('1', '3', '1');
INSERT INTO obsahuje(id_rezervacie, id_jedla, pocet_porcii)
VALUES('1', '4', '3');
INSERT INTO obsahuje(id_rezervacie, id_jedla, pocet_porcii)
VALUES('2', '4', '7');
INSERT INTO obsahuje(id_rezervacie, id_jedla, pocet_porcii)
VALUES('3', '2', '4');

-- Pozostava
INSERT INTO pozostava(id_menu, id_jedla)
VALUES('3', '5');
INSERT INTO pozostava(id_menu, id_jedla)
VALUES('1', '4');
INSERT INTO pozostava(id_menu, id_jedla)
VALUES('4', '3');
INSERT INTO pozostava(id_menu, id_jedla)
VALUES('1', '1');
INSERT INTO pozostava(id_menu, id_jedla)
VALUES('2', '4');
INSERT INTO pozostava(id_menu, id_jedla)
VALUES('4', '2');

-- 3. cast projektu

-- Ktore rezervacie potvrdil zamestnanec Jan Svitana?
SELECT id_rezervacie, datum_konania, pocet_osob, stav
FROM  rezervacia NATURAL JOIN  zamestnanec
WHERE meno = 'Jan' AND priezvisko = 'Svitana' AND stav = 'potvrdena';

-- Ktore jedla NEvytvorila Andreja Kvorkova?
SELECT id_jedla, nazov, druh
FROM jedlo NATURAL JOIN zamestnanec
WHERE meno <> 'Andreja' AND priezvisko <> 'Kvorkova';

-- Ktore jedla su na dennom menu s datumom 2.6.2024?
SELECT nazov, druh, cena
FROM jedlo NATURAL JOIN pozostava NATURAL JOIN menu
WHERE datum = TO_DATE('2024-06-02', 'YYYY-MM-DD') AND typ = 'denne';

-- Celkovy pocet jedal, ktore boli zaradene v nejakej rezervacii zoradeny zostupne
SELECT nazov, druh, cena, SUM(pocet_porcii) AS celkove_porcie
FROM jedlo NATURAL JOIN obsahuje
GROUP BY cena, nazov, druh
ORDER BY celkove_porcie DESC;

-- Ktori zakaznici rezervovali stol a aj salon?
SELECT Z.meno, Z.priezvisko
FROM zakaznik Z, rezervacia R
WHERE Z.id_zakaznika = R.id_zakaznika AND R.cislo_stola IS NOT NULL AND EXISTS(
    SELECT *
    FROM rezervacia R
    WHERE Z.id_zakaznika = R.id_zakaznika AND R.cislo_salonu IS NOT NULL
);

-- Kolko jedal vytvorili jednotlivy zamestnanci zoradene zostupne
SELECT meno, priezvisko, COUNT(*) AS pocet_jedal
FROM jedlo NATURAL JOIN zamestnanec
GROUP BY meno, priezvisko
ORDER BY COUNT(*) DESC;

-- Ktory zakaznici vytvorili rezervaciu 1.6.2024
SELECT id_zakaznika, meno, priezvisko
FROM zakaznik
WHERE id_zakaznika IN
    (SELECT id_zakaznika FROM rezervacia
     WHERE datum_konania = TO_DATE('2024-06-01', 'YYYY-MM-DD'));


GRANT ALL ON ZAKAZNIK TO XSEHNO02;
GRANT ALL ON REZERVACIA TO XSEHNO02;
GRANT ALL ON JEDLO TO XSEHNO02;
GRANT ALL ON MENU TO XSEHNO02;
GRANT ALL ON ZAMESTNANEC TO XSEHNO02;
GRANT ALL ON OBSAHUJE TO XSEHNO02;
GRANT ALL ON POZOSTAVA TO XSEHNO02;

/* update tabulky na kontrolu triggeru
UPDATE rezervacia
SET pocet_osob = 7
WHERE id_rezervacie = 4;
*/

-- vypis mena a priezviska a sumy ceny jedal, ktore boli pridane danymi zamestnancami
EXPLAIN PLAN FOR
SELECT meno, priezvisko, SUM(cena)
FROM zamestnanec NATURAL JOIN jedlo
GROUP BY meno, priezvisko;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);


-- to iste, ale s pridanim indexov

-- ZAMESTNANEC_INDEX je vytvoreny kvoli prikazu GROUP BY, v tabulke zamestnanec potrebujeme pristup iba k tym stlpcom
-- JEDLO_INDEX, z tabulky jedlo potrebujeme iba stlpec jedlo
-- obidva tieto indexy sluzia na zrychlenie pristupu
CREATE INDEX ZAMESTNANEC_INDEX on zamestnanec(meno, priezvisko);
CREATE INDEX JEDLO_INDEX on jedlo(cena);


EXPLAIN PLAN FOR
SELECT meno, priezvisko, SUM(cena)
FROM zamestnanec NATURAL JOIN jedlo
GROUP BY meno, priezvisko;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

DROP INDEX ZAMESTNANEC_INDEX;
DROP INDEX JEDLO_INDEX;


-- materializovany pohlad

CREATE MATERIALIZED VIEW pocet_poloziek_v_menu AS
    SELECT DRUH, COUNT(*) as pocet
    FROM XPALEN06.MENU NATURAL JOIN XPALEN06.POZOSTAVA NATURAL JOIN XPALEN06.JEDLO
    GROUP BY DRUH;


SELECT * FROM pocet_poloziek_v_menu;

DROP MATERIALIZED VIEW pocet_poloziek_v_menu;

-- procedury


CREATE OR REPLACE PROCEDURE cena_jedla_rezervacie(id_rezervacie_proc IN rezervacia.id_rezervacie%TYPE) AS
    celkova_cena DECIMAL(10, 2) := 0;
BEGIN
    FOR jedlo_rezervacie IN (
        SELECT j.cena * o.pocet_porcii AS cena_jedla
        FROM obsahuje o
        JOIN jedlo j ON o.id_jedla = j.id_jedla
        WHERE o.id_rezervacie = id_rezervacie_proc
    )
    LOOP
        celkova_cena := celkova_cena + jedlo_rezervacie.cena_jedla;
    END LOOP;

    -- Print total food price for the reservation
    DBMS_OUTPUT.PUT_LINE('Celkova suma jedla v rezervacii  ' || id_rezervacie_proc || ': ' || celkova_cena);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ID Rezervacie: ' || id_rezervacie_proc || ' nebolo najdene.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Procedúra vypise rezervacie, ktore sa konaju dany den
CREATE OR REPLACE PROCEDURE VYPIS_REZERVACIE_TOHOTO_DNA AS
    C_ID_REZERVACIE REZERVACIA.ID_REZERVACIE%TYPE;
    C_DATUM_KONANIA REZERVACIA.DATUM_KONANIA%TYPE;

    CURSOR C_REZERVACIE IS
        SELECT ID_REZERVACIE, DATUM_KONANIA
        FROM REZERVACIA
        WHERE TRUNC(DATUM_KONANIA) = TO_DATE('2024-06-01', 'YYYY-MM-DD');

BEGIN
    OPEN C_REZERVACIE;
    LOOP
        FETCH C_REZERVACIE INTO C_ID_REZERVACIE, C_DATUM_KONANIA;
        EXIT WHEN C_REZERVACIE%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Rezervacia ' ||  C_ID_REZERVACIE || ' sa kona dna ' || TO_CHAR(C_DATUM_KONANIA, 'DD.MM.YYYY'));
    END LOOP;
    CLOSE C_REZERVACIE;
END;
/

BEGIN
    cena_jedla_rezervacie(1);
END;
/

BEGIN
    VYPIS_REZERVACIE_TOHOTO_DNA;
END;
/

-- dotaz pracuje so stlpcami nazov, druh, cena z tabulky JEDLO
-- vracia DPH vypocitane na zaklade DRUHU JEDLA
WITH dph_jedla AS (
    SELECT nazov, druh, cena,
    CASE
        WHEN druh = 'hlavne jedlo' THEN cena * 0.3
        WHEN druh = 'polievka' THEN cena * 0.1
        ELSE cena * 0.2
    END AS dph
    FROM jedlo
)
SELECT  nazov, druh, cena, dph
FROM dph_jedla;
