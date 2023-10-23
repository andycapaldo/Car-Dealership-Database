-- First, let's create procedures to add customers, salespeople, and mechanics to our dealership


CREATE OR REPLACE PROCEDURE new_customer(
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(50)
)
LANGUAGE plpgsql
AS $new_customer$
BEGIN 
	INSERT INTO customer(first_name, last_name, email)
	VALUES (first_name, last_name, email);
END
$new_customer$;


CREATE OR REPLACE PROCEDURE new_salesperson(
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	years_of_experience INTEGER
)
LANGUAGE plpgsql
AS $new_salesperson$
BEGIN 
	INSERT INTO salesperson (first_name, last_name, years_of_experience)
	VALUES (first_name, last_name, years_of_experience);
END
$new_salesperson$;


CREATE OR REPLACE PROCEDURE new_mechanic(
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	years_of_experience INTEGER
)
LANGUAGE plpgsql
AS $new_mechanic$
BEGIN 
	INSERT INTO mechanic (first_name, last_name, years_of_experience)
	VALUES (first_name, last_name, years_of_experience);
END
$new_mechanic$;


-- Now, let's add 5 customers, 2 salespersons, and 2 mechanics

CALL new_customer('John', 'Madden', 'jmoney123@football.com');
CALL new_customer('Jimmy', 'Buckets', 'jimmyb22@miamiheat.com');
CALL new_customer('Barack', 'Obama', 'number44@usa.com');
CALL new_customer('Leonardo', 'Decaprio', 'treelover@enviornment.com');
CALL new_customer('Rick', 'Ross', 'rosstheboss@money.com');

CALL new_salesperson('Saul', 'Goodman', 3);
CALL new_salesperson('Donald', 'Draper', 8);

CALL new_mechanic('Kelly', 'Kapowski', 2);
CALL new_mechanic('Marshall', 'Mathers', 5);


-- Next, we'll create a procedure to add cars to the dealership, and we'll add 5 cars to our database.
-- This procedure can be used to add cars that are avaiable for sale OR to add customer cars that
-- were serviced by us. The default value for whether or not a car will be serviced is FALSE.

CREATE OR REPLACE PROCEDURE add_car(
	make VARCHAR(25),
	model VARCHAR(25),
	color VARCHAR(25),
	price INTEGER,
	used BOOL,
	serviced BOOL DEFAULT FALSE
)
LANGUAGE plpgsql
AS $add_car$
BEGIN 
	INSERT INTO car (make, model, color, price, used, serviced)
	VALUES (make, model, color, price, used, serviced);
END
$add_car$;

CALL add_car('Mazda', 'CX-5', 'Black', 9999, TRUE);
CALL add_car('Lamborghini', 'Aventador', 'Green', 498258, FALSE);
CALL add_car('Ferrari', 'Spider F8', 'Yellow', 324342, FALSE);
CALL add_car('Rolls-Royce', 'Ghost', 'Silver', 348500, TRUE);
CALL add_car('Aston Martin', 'DBS', 'Red', 0, FALSE);



-- Next, we can add a procedure that updates the car_invoice table when a car is sold to a customer.
-- It will take in customer_id, car_id, and salesperson_id.

CREATE OR REPLACE PROCEDURE sold_car(
	customer_id INTEGER,
	sold_car_id INTEGER,
	salesperson_id INTEGER
)
LANGUAGE plpgsql
AS $sold_car$
	DECLARE amount INTEGER;
BEGIN 
	SELECT price INTO amount
	FROM car
	WHERE car.car_id = sold_car_id;
	
	INSERT INTO car_invoice (customer_id, car_id, salesperson_id, amount)
	VALUES (customer_id, sold_car_id, salesperson_id, amount);
END
$sold_car$;


-- Now, let's sell some cars!!

CALL sold_car(1,1,1);
CALL sold_car(3, 2, 1);
CALL sold_car(5,4, 2);


-- The below DML statements will add the invoices to our payment table.
-- Since no services have been performed yet, the service_id column data will be NULL.

INSERT INTO payment (invoice_id, amount)
VALUES (1, 9999);

INSERT INTO payment (invoice_id, amount)
VALUES (2, 498258);

INSERT INTO payment (invoice_id, amount)
VALUES (3, 348500);


-- Next up, we'll want to create a service ticket for any car that receives services from us
-- First, we'll update the car table for the cars that we want to service

UPDATE car
SET serviced = TRUE
WHERE car_id IN (3, 5);

-- Now we can create the service tickets for the two cars!

INSERT INTO service_ticket (service, amount, customer_id , car_id)
VALUES ('Installed New Windshield', 2000, 2, 3);

INSERT INTO service_ticket (service, amount, customer_id , car_id)
VALUES ('Oil Change', 300, 4, 5);

-- Now we can add these services to our payment table. Since no cars were sold in these transactions,
-- the invoice_id column data will be NULL.

INSERT INTO payment (service_id, amount)
VALUES (1, 2000);

INSERT INTO payment (service_id, amount)
VALUES (2, 300);


-- And finally, we update our service_history table to keep record of our services provided, 
-- and to tie each service_id to a mechanic who worked on the specific service ticket.

INSERT INTO service_history (car_id, service_id, mechanic_id)
VALUES (3, 1, 1);

INSERT INTO service_history (car_id, service_id, mechanic_id)
VALUES (5, 2, 2);


--DELETE FROM payment;
--DELETE FROM service_history;
--DELETE FROM service_ticket;
--DELETE FROM car_invoice;
--DELETE FROM salesperson;
--DELETE FROM customer;
--DELETE FROM car;
--DELETE FROM mechanic;
--
--DROP PROCEDURE new_customer;
--DROP PROCEDURE new_salesperson;
--DROP PROCEDURE new_mechanic;
--DROP PROCEDURE add_car;