-- *** Nivel 1 ***
-- ** Ejercicio 1 **
USE transactions;
 -- Creamos una nueva tabla
CREATE TABLE IF NOT EXISTS  credit_card (
        id VARCHAR(15) PRIMARY KEY ,
        iban VARCHAR(50),
        pan VARCHAR(50),
        pin CHAR(4),
        cvv int,
        expiring_date varchar(10)
    );

SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE  transaction
	ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id) ;
    
-- Insertamos datos de credit_card del archivo ¨datos_introducir_credit.sql¨
-- Luego se puede convertir el campo expiring_date al formato de fecha  STR_TO_DATE(expiring_date, "%m/%e/%y")

-- ** Ejercicio 2 **
-- Correjimos un error en el numero de cuenta del cliente con credit_card_id 'CcU-2938'

UPDATE transactions.credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

-- ** Ejercicio 3 **
-- Insertamos un registro nuevo a la tabla transaction y tambien tenemos que incluir este nuevo cliente a las tablas de dimensiones company y credit_card
-- Preguntamos los datos addicionales para rellenar los campos de otras dos tablas (de momento les pongo nulls)

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
SELECT '108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, 111.11, 0
WHERE NOT EXISTS (
    SELECT 1 FROM transaction 
    WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'
);

INSERT INTO company (id,company_name,phone,email,country,website)
SELECT 'b-9999', null, null, null, null, null
WHERE NOT EXISTS (
    SELECT 1 FROM company 
    WHERE id = 'b-9999'
);

INSERT INTO  credit_card (id, iban, pan, pin, cvv, expiring_date) 
SELECT 'CcU-9999', null, null, null, null, null
WHERE NOT EXISTS (
    SELECT 1 FROM credit_card 
    WHERE id = 'CcU-9999'
);

-- ** Ejercicio 4 **
-- Eliminamos la columna "pan" de la tabla credit_card
ALTER TABLE credit_card
DROP COLUMN pan;

-- *** Nivel 2 ***
-- ** Ejercicio 1 **
-- Eliminamos el registro id = '02C6201E-D90A-1859-B4EE-88D2986D3B02' de la tabla transaction
DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SET FOREIGN_KEY_CHECKS=1;

-- ** Ejercicio 2 **
CREATE VIEW VistaMarketing AS
SELECT 
    c.company_name as Company, 
    c.phone as Phone_Number, 
    c.country as Country, 
    ROUND(AVG(t.amount),2) as Avg_Transaction
FROM 
    company c
JOIN 
    transaction t ON c.id = t.company_id
WHERE declined=0
GROUP BY 
    c.company_name, c.phone, c.country
;

SELECT * FROM transactions.vistamarketing
ORDER BY Avg_Transaction DESC;

-- ** Ejercicio 3 **
SELECT *
FROM VistaMarketing
WHERE country = 'Germany';

-- *** Nivel 3 ***
-- ** Ejercicio 1 **
-- Creamos la tabla user

CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );

SET foreign_key_checks = 0;

ALTER TABLE  transaction
	ADD FOREIGN KEY (user_id) REFERENCES user(id) ;

SET foreign_key_checks = 1;

ALTER TABLE user RENAME TO data_user;

ALTER TABLE data_user RENAME COLUMN email TO personal_email;

ALTER TABLE credit_card modify id varchar(20);

ALTER TABLE credit_card add column fecha_actual  date;

ALTER TABLE company drop column website;

-- ** Ejercicio 2 **
CREATE VIEW InformeTecnico AS
SELECT 
    t.id as 'ID de la transacció', 
    u.name as 'Nombre usuario', 
	u.surname as 'Apellido usuario', 
	cc.iban as 'IBAN',
    c.company_name as 'Nombre compañia'
FROM transaction t 
		LEFT OUTER JOIN company c ON c.id = t.company_id
		LEFT OUTER JOIN credit_card cc ON cc.id = t.credit_card_id
		LEFT OUTER JOIN data_user u ON u.id = t.user_id
;

SELECT * FROM transactions.InformeTecnico
ORDER BY 'ID de la transacció' DESC
;

