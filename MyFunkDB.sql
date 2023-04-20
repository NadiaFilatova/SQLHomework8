-- В данной базе данных создать 3 таблиц,
-- В 1-й содержатся имена и номера телефонов сотрудников некой компании
-- Во 2-й Ведомости об их зарплате, и должностях: главный директор, менеджер, рабочий.
-- В 3-й семейном положении, дате рождения, где они проживают.

DROP DATABASE IF EXISTS myFunkDB;
CREATE DATABASE IF NOT EXISTS myFunkDB;

USE myFunkDB;

CREATE TABLE IF NOT EXISTS person
(
    id_person    int AUTO_INCREMENT NOT NULL PRIMARY KEY,
    name_person  varchar(60)        NOT NULL,
    phone_person varchar(12)        NOT NULL
);

CREATE TABLE IF NOT EXISTS salary
(
    id_salary        int auto_increment NOT NULL PRIMARY KEY,
    salary_person    float(10, 2)       ,
    position         varchar(40)        NOT NULL


);

CREATE TABLE IF NOT EXISTS personalInfo
(
    id_personalInfo        int auto_increment NOT NULL PRIMARY KEY,
    familyStatus           varchar(30)        NOT NULL,
    birthday               date               NOT NULL,
    address                varchar(50)        NOT NULL
);

INSERT INTO person
(id_person, name_person, phone_person)
VALUES (1, 'Анна Антонюк', '(099)7142212'),
       (2, 'Саша Фіц', '(097)4302001'),
       (3, 'Марія Карась', '(098)6202990'),
       (4, 'Оля Чиж', '(098)7181236'),
       (5, 'Коля ФІл', '(098)2133217');

INSERT INTO salary
(id_salary, salary_person, position)
VALUES (1, 3000.20, 'Manager'),
       (2, 2500.50, 'Worker'),
       (3, 6000.25, 'Manager'),
       (4, 2000.50, 'Worker'),
       (5, 2900.50, 'Director');

INSERT INTO personalInfo
(id_personalInfo, familyStatus, birthday, address)
VALUES (1, 'Single', '1999-01-23', 'Address st, 88'),
       (2, 'Divorced', '1998-02-19', 'Address st, 527'),
       (3, 'Married', '1994-03-22', 'Address st, 1'),
       (4, 'Divorced', '1996-02-22', 'Address st, 949'),
       (5, 'Married', '1998-02-22', 'Address st, 29');

SELECT *
FROM person;
SELECT *
FROM salary;
SELECT *
FROM personalInfo;
-- Выполните ряд записей вставки в виде транзакции в хранимой процедуре.

DELIMITER /
DROP PROCEDURE IF EXISTS transactMyFunkDB;
/

CREATE PROCEDURE  transactMyFunkDB(IN name varchar(20), IN phone varchar(15),
                                   IN salary mediumint, IN position_p varchar(20),
                                   IN status varchar(30), IN Date date, IN address_p varchar(30))

BEGIN
    -- declare id smallint;
    start transaction ;
    insert person(name_person, phone_person)
        value (name, phone);

    insert salary(salary_person, position)
        value (salary, position_p);

    insert personalInfo(familyStatus, birthday, address)
        value (status, Date, address_p);
    commit;
end /

call transactMyFunkDB('Test 1', '0991084433', '2150', 'Manager', 'Married', '2000-05-02',
                      'Address, st 36');
/

call transactMyFunkDB('Test 2', '0988786116', '2120', 'Manager', 'Married', '1989-09-03',
                      'Address, st 245');
/


select *
from person;
/

select *
from salary;
/

select *
from personalInfo;
/
--

-- Если такой сотрудник имеется откатите базу данных обратно.
drop procedure if exists transactEmployees;
/

create procedure transactEmployees(IN name varchar(20), IN phone varchar(15),
                                   IN salary mediumint, IN position_p varchar(20),
                                   IN status varchar(30), IN Date date, IN address_p varchar(50))

begin
    declare id smallint;
    start transaction;
    insert person(name_person, phone_person)
        value (name, phone);
    SET id = @@IDENTITY;

    insert salary(salary_person, position)
        value (salary, position_p);

    insert personalInfo(familyStatus, birthday, address)
        value (status, Date, address_p);

    if exists(select * from person WHERE name_person = name and id_person != id)
    then
        rollback;
    end if;
    commit;
end /

-- даний співробітник вже э в базі, тому від не буде повторно доданий
call transactEmployees('Test 2', '0988786116', '2120', 'Manager', 'Married', '1989-09-03',
                       'Address, st 245');
/
--  плюс додаэмо нового спывробытника
call transactEmployees(' Test 3', '0953451270', '0000', 'Manager', 'Все складно) ', '1993-11-14',
                       'Address, st 245');
/

select *
from person;
/

select *
from salary;
/

select *
from personalInfo;
/
-- Создайте триггер в базе данных “MyFunkDB”,
-- который будет удалять записи со 2-й и 3-й таблиц перед удалением записей из таблиц сотрудников (1-й таблицы),
-- чтобы не нарушить целостность данных.


drop trigger if exists delete_employees;

DELIMITER /
create trigger delete_employees
    before delete on person
    for each row
begin
    delete from salary where id_salary = OLD.id_person;
    delete from personalInfo where id_personalInfo = OLD.id_person;
end; /

select * from person;/

delete from person where id_person = 4;/
delete from person where id_person = 9;/

select * from person;/
select * from salary;/
select * from personalInfo;/