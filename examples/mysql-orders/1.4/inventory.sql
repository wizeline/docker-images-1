# In production you would almost certainly limit the replication user must be on the follower (slave) machine,
# to prevent other clients accessing the log from other machines. For example, 'replicator'@'follower.acme.com'.
#
# However, this grant is equivalent to specifying *any* hosts, which makes this easier since the docker host
# is not easily known to the Docker container. But don't do this in production.
#
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicator' IDENTIFIED BY 'replpass';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium' IDENTIFIED BY 'dbz';

# Create the database that we'll use to populate data and watch the effect in the binlog
CREATE DATABASE inventory;
GRANT ALL PRIVILEGES ON inventory.* TO 'mysqluser'@'%';

# Switch to this database
USE inventory;

# Create and populate our products using a single insert with many rows
CREATE TABLE products (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(512),
  weight FLOAT
);
ALTER TABLE products AUTO_INCREMENT = 101;

INSERT INTO products
VALUES (default,"scooter","Small 2-wheel scooter",3.14),
       (default,"car battery","12V car battery",8.1),
       (default,"12-pack drill bits","12-pack of drill bits with sizes ranging from #40 to #3",0.8),
       (default,"hammer","12oz carpenter's hammer",0.75),
       (default,"hammer","14oz carpenter's hammer",0.875),
       (default,"hammer","16oz carpenter's hammer",1.0),
       (default,"rocks","box of assorted rocks",5.3),
       (default,"jacket","water resistent black wind breaker",0.1),
       (default,"spare tire","24 inch spare tire",22.2);

# Create and populate the products on hand using multiple inserts
CREATE TABLE products_on_hand (
  product_id INTEGER NOT NULL PRIMARY KEY,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO products_on_hand VALUES (101,3);
INSERT INTO products_on_hand VALUES (102,8);
INSERT INTO products_on_hand VALUES (103,18);
INSERT INTO products_on_hand VALUES (104,4);
INSERT INTO products_on_hand VALUES (105,5);
INSERT INTO products_on_hand VALUES (106,0);
INSERT INTO products_on_hand VALUES (107,44);
INSERT INTO products_on_hand VALUES (108,2);
INSERT INTO products_on_hand VALUES (109,5);

# Create some customers ...
CREATE TABLE customers (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE KEY
) AUTO_INCREMENT=1001;


INSERT INTO customers
VALUES (default,"Sally","Thomas","sally.thomas@acme.com"),
       (default,"George","Bailey","gbailey@foobar.com"),
       (default,"Edward","Walker","ed@walker.com"),
       (default,"Anne","Kretchmar","annek@noanswer.org");

# Create some fake addresses
CREATE TABLE addresses (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  state VARCHAR(255) NOT NULL,
  zip VARCHAR(255) NOT NULL,
  type enum('SHIPPING','BILLING','LIVING') NOT NULL,
  FOREIGN KEY address_customer (customer_id) REFERENCES customers(id)
) AUTO_INCREMENT = 10;

INSERT INTO addresses
VALUES (default,1001,'3183 Moore Avenue','Euless','Texas','76036','SHIPPING'),
       (default,1001,'2389 Hidden Valley Road','Harrisburg','Pennsylvania','17116','BILLING'),
       (default,1002,'281 Riverside Drive','Augusta','Georgia','30901','BILLING'),
       (default,1003,'3787 Brownton Road','Columbus','Mississippi','39701','SHIPPING'),
       (default,1003,'2458 Lost Creek Road','Bethlehem','Pennsylvania','18018','SHIPPING'),
       (default,1003,'4800 Simpson Square','Hillsdale','Oklahoma','73743','BILLING'),
       (default,1004,'1289 University Hill Road','Canehill','Arkansas','72717','LIVING');

# Create some very simple orders
CREATE TABLE orders (
  order_number INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_date DATE NOT NULL,
  purchaser INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  FOREIGN KEY order_customer (purchaser) REFERENCES customers(id),
  FOREIGN KEY ordered_product (product_id) REFERENCES products(id)
) AUTO_INCREMENT = 10001;

INSERT INTO orders
VALUES (default, '2016-01-16', 1001, 1, 102),
       (default, '2016-01-17', 1002, 2, 105),
       (default, '2016-02-19', 1002, 2, 106),
       (default, '2016-02-21', 1003, 1, 107);

# Create table with Spatial/Geometry type
CREATE TABLE geom (
	id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	g GEOMETRY NOT NULL,
	h GEOMETRY);

INSERT INTO geom
VALUES(default, ST_GeomFromText('POINT(1 1)'), NULL),
      (default, ST_GeomFromText('LINESTRING(2 1, 6 6)'), NULL),
      (default, ST_GeomFromText('POLYGON((0 5, 2 5, 2 7, 0 7, 0 5))'), NULL);

CREATE TABLE online_orders (
  order_number int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_date date NOT NULL,
  order_time_cst time NOT NULL,
  purchaser int(11) NOT NULL,
  quantity int(11) NOT NULL,
  product_id int(11) NOT NULL,
  billing_address varchar(512) NOT NULL,
  FOREIGN KEY online_order_customer (purchaser) REFERENCES customers(id),
  FOREIGN KEY online_order_product (product_id) REFERENCES products(id)
) AUTO_INCREMENT=20001 DEFAULT CHARSET=latin1;

INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-06-11', '08:51:28', 1001, 14, 105, '1604 Hicks Mills New Stephanie, FL 49625');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-06-15', '02:11:26', 1002, 17, 103, '61509 Scott Turnpike Garciaside, SC 84999');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-02-02', '10:54:06', 1003, 16, 102, '361 Jennifer Brook Apt. 579 Serranoville, ND 83503');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-09-05', '09:59:52', 1004, 13, 109, '94768 Carey Fort Suite 515 Travisstad, CA 30205');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-01-27', '09:51:02', 1001, 10, 104, '67824 Diaz Parkways South Donald, UT 21511');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-07-21', '02:29:01', 1002, 18, 108, '423 Cindy Heights Christianshire, WY 61099');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-03-23', '07:15:37', 1003, 20, 108, '8829 Smith Mountains Apt. 704 Alexandraberg, ND 56523');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-02-04', '02:16:55', 1004, 18, 106, '0405 Michele River South Michael, SD 62368');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-04-26', '09:39:13', 1001, 24, 108, '1693 Francis Court Apt. 757 Leefurt, NH 85486');
INSERT INTO online_orders (order_date, order_time_cst, purchaser, quantity, product_id, billing_address) VALUES('2020-08-15', '09:10:36', 1003, 21, 104, '6343 Bryan Route Sullivantown, MS 82724');
