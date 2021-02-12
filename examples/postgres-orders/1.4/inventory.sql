-- Create the schema that we'll use to populate data and watch the effect in the binlog
CREATE SCHEMA inventory;
SET search_path TO inventory;

-- enable PostGis 
CREATE EXTENSION postgis;

-- Create and populate our products using a single insert with many rows
CREATE TABLE products (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(512),
  weight FLOAT
);
ALTER SEQUENCE products_id_seq RESTART WITH 101;
ALTER TABLE products REPLICA IDENTITY FULL;

INSERT INTO products
VALUES (default,'scooter','Small 2-wheel scooter',3.14),
       (default,'car battery','12V car battery',8.1),
       (default,'12-pack drill bits','12-pack of drill bits with sizes ranging from #40 to #3',0.8),
       (default,'hammer','12oz carpenter''s hammer',0.75),
       (default,'hammer','14oz carpenter''s hammer',0.875),
       (default,'hammer','16oz carpenter''s hammer',1.0),
       (default,'rocks','box of assorted rocks',5.3),
       (default,'jacket','water resistent black wind breaker',0.1),
       (default,'spare tire','24 inch spare tire',22.2);

-- Create and populate the products on hand using multiple inserts
CREATE TABLE products_on_hand (
  product_id INTEGER NOT NULL PRIMARY KEY,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id)
);
ALTER TABLE products_on_hand REPLICA IDENTITY FULL;

INSERT INTO products_on_hand VALUES (101,3);
INSERT INTO products_on_hand VALUES (102,8);
INSERT INTO products_on_hand VALUES (103,18);
INSERT INTO products_on_hand VALUES (104,4);
INSERT INTO products_on_hand VALUES (105,5);
INSERT INTO products_on_hand VALUES (106,0);
INSERT INTO products_on_hand VALUES (107,44);
INSERT INTO products_on_hand VALUES (108,2);
INSERT INTO products_on_hand VALUES (109,5);

-- Create some customers ...
CREATE TABLE customers (
  id SERIAL NOT NULL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
);
ALTER SEQUENCE customers_id_seq RESTART WITH 1001;
ALTER TABLE customers REPLICA IDENTITY FULL;

INSERT INTO customers
VALUES (default,'Sally','Thomas','sally.thomas@acme.com'),
       (default,'George','Bailey','gbailey@foobar.com'),
       (default,'Edward','Walker','ed@walker.com'),
       (default,'Anne','Kretchmar','annek@noanswer.org');

-- Create some very simple orders
CREATE TABLE orders (
  id SERIAL NOT NULL PRIMARY KEY,
  order_date DATE NOT NULL,
  purchaser INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  FOREIGN KEY (purchaser) REFERENCES customers(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
ALTER SEQUENCE orders_id_seq RESTART WITH 10001;
ALTER TABLE orders REPLICA IDENTITY FULL;

INSERT INTO orders
VALUES (default, '2016-01-16', 1001, 1, 102),
       (default, '2016-01-17', 1002, 2, 105),
       (default, '2016-02-19', 1002, 2, 106),
       (default, '2016-02-21', 1003, 1, 107);

-- Create table with Spatial/Geometry type
CREATE TABLE geom (
        id SERIAL NOT NULL PRIMARY KEY,
        g GEOMETRY NOT NULL,
        h GEOMETRY);

INSERT INTO geom
VALUES(default, ST_GeomFromText('POINT(1 1)')),
      (default, ST_GeomFromText('LINESTRING(2 1, 6 6)')),
      (default, ST_GeomFromText('POLYGON((0 5, 2 5, 2 7, 0 7, 0 5))'));

CREATE TABLE online_orders (
	order_number serial NOT null primary key,
	order_local_datetime_pst_pst timestamptz NOT NULL,
	purchaser int4 NOT NULL,
	quantity int4 NOT NULL,
	product_id int4 NOT NULL,
	billing_address varchar(512) not null,
	FOREIGN KEY (product_id) REFERENCES products(id),
	FOREIGN KEY (purchaser) REFERENCES customers(id)
);

INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-10-27 06:03:42', 1001, 17, 109, 'USNV Baker FPO AA 98389');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-05-06 05:09:15', 1002, 10, 106, 'USNV KramerFPO AP 48699');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-07-26 06:34:11', 1003, 11, 103, '003 Russell Center New Patrick, OH 12063');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-04-13 08:16:25', 1004, 23, 108, '59685 Thomas Spur Stewartchester, IA 81235');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-06-27 10:40:32', 1001, 14, 103, 'Unit 9029 Box 0054 DPO AP 80157');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-07-01 12:30:29', 1002, 22, 106, '309 Bruce Skyway Apt. 650 Michaelahaven, IA 40881');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-11-20 08:11:48', 1003, 18, 107, '556 Joel Trail Suite 872 Christineburgh, ME 41726');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-06-08 08:52:36', 1004, 11, 101, '3101 Diaz Ridge Apt. 741 Lindseytown, MD 61762');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-03-14 12:16:54', 1001, 22, 102, 'PSC 1672, Box 0153 APO AP 94869');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-07-26 10:41:09', 1002, 11, 102, 'PSC 0886, Box 6668 APO AE 64228');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-05-13 09:26:47', 1003, 23, 107, '5637 Pamela Burg Charlesville, CT 47619');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-06-21 05:56:42', 1004, 19, 107, '9616 Susan Plaza Apt. 771 Dunnstad, NJ 28845');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-02-04 11:10:25', 1001, 15, 109, 'USS Ross FPO AP 63978');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-09-10 10:36:06', 1004, 14, 102, '12605 Carla Neck Suite 292 Garciaberg, VA 55442');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-06-01 10:10:49', 1004, 15, 107, '664 Dana Track Apt. 827 Sullivanland, OR 93221');
INSERT INTO online_orders (order_local_datetime_pst, purchaser, quantity, product_id, billing_address) VALUES('2020-03-14 09:14:21', 1002, 12, 103, '0804 Michael Ramp Kramerfort, NY 62039');
