-- Create the customer, salesperson, car, and mechanic tables to start

CREATE TABLE IF NOT EXISTS customer(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50) UNIQUE,
	date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS salesperson(
	salesperson_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	years_of_experience INTEGER NOT NULL
);


CREATE TABLE IF NOT EXISTS car(
	car_id SERIAL PRIMARY KEY,
	make VARCHAR(25) NOT NULL,
	model VARCHAR(25) NOT NULL,
	color VARCHAR(25) NOT NULL,
	price INTEGER,
	used BOOL NOT NULL,
	serviced BOOL DEFAULT FALSE -- Making this boolean allows us TO use it later in STORED PROCEDURES.
); 


CREATE TABLE IF NOT EXISTS mechanic(
	mechanic_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	years_of_experience INTEGER NOT NULL
);


-- Now, we can create the car_invoice table with FK's connected to customer, car, and salesperson.
-- NOTE: ON DELETE CASCADE was added to the customer_id FK to ensure that if any customer records are 
-- deleted, the invoices are deleted as well. We are assuming here that we would want to delete 
-- customer records if they receive a refund for cars purchased.

CREATE TABLE IF NOT EXISTS car_invoice(
	invoice_id SERIAL PRIMARY KEY,
	customer_id INTEGER NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
	car_id INTEGER UNIQUE NOT NULL, -- Assumption IS that ALL sales ARE FINAL, so EVERY car_id IS UNIQUE IN this table
	FOREIGN KEY (car_id) REFERENCES car(car_id),
	salesperson_id INTEGER NOT NULL,
	FOREIGN KEY (salesperson_id) REFERENCES salesperson(salesperson_id),
	amount INTEGER NOT NULL
);


-- Next, we'll create our service_ticket table, which has foreign keys to the customer and car tables

CREATE TABLE IF NOT EXISTS service_ticket(
	service_id SERIAL PRIMARY KEY,
	service VARCHAR NOT NULL,
	amount INTEGER NOT NULL,
	customer_id INTEGER NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
	car_id INTEGER NOT NULL,
	FOREIGN KEY (car_id) REFERENCES car(car_id)
);


-- Our mechanic table is lonely...it has no children!! :( 
-- We'll need to create a service_history table to keep a log of all services performed
-- This will connect the car and service_ticket tables to available mechanics.

CREATE TABLE IF NOT EXISTS service_history(
	car_id INTEGER NOT NULL,
	FOREIGN KEY (car_id) REFERENCES car(car_id),
	service_id INTEGER UNIQUE NOT NULL, -- Service history rows will ALWAYS have a UNIQUE service ticket reference
	FOREIGN KEY (service_id) REFERENCES service_ticket(service_id),
	mechanic_id INTEGER NOT NULL,
	FOREIGN KEY (mechanic_id) REFERENCES mechanic(mechanic_id)
);


-- Finally, we'll need a table that keeps track of income for our services and cars sold!
-- NOTE: service_id and invoice_id need to be unique, as each one references a different payment made.
-- However, they are allowed to be null. This is because a customer may purchase a car but not get
-- service on the car. Or, a customer can just get their car serviced without purchasing a car.
-- Additionally, the ON DELETE CASCADE statement for the invoice_id FK to ensure that if an invoice
-- is deleted, we can delete the associated payment records as well. This is again under the assumption 
--that customer records will be deleted if they receive a refund.

CREATE TABLE IF NOT EXISTS payment(
	payment_id SERIAL PRIMARY KEY,
	service_id INTEGER UNIQUE,
	FOREIGN KEY (service_id) REFERENCES service_ticket(service_id),
	invoice_id INTEGER UNIQUE,
	FOREIGN KEY (invoice_id) REFERENCES car_invoice(invoice_id) ON DELETE CASCADE,
	amount INTEGER NOT NULL
);



--DROP TABLE IF EXISTS payment;
--DROP TABLE IF EXISTS service_history;
--DROP TABLE IF EXISTS service_ticket;
--DROP TABLE IF EXISTS car_invoice;
--DROP TABLE IF EXISTS salesperson;
--DROP TABLE IF EXISTS customer;
--DROP TABLE IF EXISTS car;
--DROP TABLE IF EXISTS mechanic;