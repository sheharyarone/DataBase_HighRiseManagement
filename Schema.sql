-- create schema dbsproject;

CREATE TABLE apartment (
roomno INT PRIMARY KEY,
type ENUM('studio', 'convertible', 'penthouse'),
floor INT,
size FLOAT,
rent FLOAT
);

CREATE TABLE owner (
name VARCHAR(255),
cnic int primary key,
age int not null,
dob date not null,
phone int not null,
roomno INT,
username varchar(45) UNIQUE,
FOREIGN KEY (roomno) REFERENCES apartment(roomno)
on delete cascade
on update cascade
);

CREATE TABLE resident (
name VARCHAR(255),
cnic int primary key,
owner_cnic int,
age int not null,
dob date not null,
FOREIGN KEY (owner_cnic) REFERENCES owner (cnic)
on delete cascade
on update cascade
);

CREATE TABLE guest (
cnic int PRIMARY KEY,
name VARCHAR(255),
owner_cnic INT,
FOREIGN KEY (owner_cnic) REFERENCES owner (cnic)
on delete cascade
on update cascade
);

Create TABLE pool (
pool_id int Primary Key Auto_Increment,
join_date date,
expiry_date date,
CNIC int,
foreign key (CNIC) references resident(cnic)
on delete cascade
on update cascade
);

Create TABLE gym (
gym_id int Primary Key Auto_INCREMENT,
join_date date,
expiry_date date,
CNIC int,
foreign key (CNIC) references resident(cnic)
on delete cascade
on update cascade
);

Create Table parking (
plate_no varchar(255) primary key,
type enum ('car','bike'),
owner_cnic int,
Foreign Key(owner_cnic) References owner (cnic)
on delete cascade
on update cascade
);

CREATE TABLE service (
id INT PRIMARY KEY AUTO_INCREMENT,
type ENUM('parking', 'gym', 'swimming_pool'),
price FLOAT
);

CREATE TABLE foodItem (
food_id varchar(5) PRIMARY KEY,
description VARCHAR(50),
price FLOAT
);

CREATE TABLE foodOrder (
order_id INT PRIMARY KEY AUTO_INCREMENT,
owner_cnic int,
date_placed date,
foreign key (owner_cnic) references owner (cnic)
on delete cascade
on update set null
);

create table orderContains (
order_id int,
food_id varchar(5),
number int,
amount float,
primary key (order_id,food_id),
foreign key (order_id) references foodOrder(order_id)
on delete cascade
on update cascade,
foreign key (food_id) references foodItem(food_id)
on delete no action
on update no action
);

create table bill (
billno int primary key auto_increment,
owner_cnic int,
month varchar(3),
year int,
rent float,
gym_payment float,
pool_payment float,
parking_payment float,
food_payment float,
total_amount float,
isPaid bool,
foreign key (owner_cnic) references owner(cnic)
on delete set null
on update cascade
);