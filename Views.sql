

CREATE VIEW available_apartments AS
SELECT roomno, type, floor, size, rent
FROM apartment
WHERE roomno NOT IN (SELECT roomno FROM owner);

CREATE VIEW foodOrderHistory AS
SELECT fo.order_id, fo.owner_cnic, fo.date_placed, oc.food_id, oc.number, oc.amount
FROM foodorder fo
INNER JOIN ordercontains oc ON fo.order_id = oc.order_id
ORDER BY fo.order_id ASC;


CREATE VIEW guest_view AS
SELECT a.roomno, g.name AS guest_name, g.cnic AS guest_cnic, o.name AS host_name, o.cnic AS host_cnic
FROM guest g
INNER JOIN owner o ON g.owner_cnic = o.cnic
INNER JOIN apartment a ON o.roomno = a.roomno;

CREATE VIEW monthly_billing AS
SELECT b.billno, o.name AS owner_name, b.owner_cnic, b.month, b.year, b.rent, b.gym_payment, b.pool_payment, b.parking_payment, b.food_payment, b.total_amount, b.isPaid
FROM bill b
INNER JOIN owner o ON b.owner_cnic = o.cnic;

CREATE VIEW gym_memberships AS
SELECT g.gym_id, r.cnic AS resident_cnic, r.name AS resident_name, g.join_date, g.expiry_date, o.cnic AS owner_cnic
FROM gym g
INNER JOIN resident r ON g.cnic = r.cnic
INNER JOIN owner o ON r.owner_cnic = o.cnic
ORDER BY g.gym_id ASC;


CREATE VIEW pool_memberships AS
SELECT p.pool_id, r.cnic, r.name, p.join_date, p.expiry_date, o.cnic AS owner_cnic
FROM pool p
INNER JOIN resident r ON p.CNIC = r.cnic
INNER JOIN owner o ON r.owner_cnic = o.cnic
ORDER BY p.pool_id ASC;

CREATE VIEW resident_apartment_view AS
SELECT r.cnic, r.name, o.cnic AS owner_cnic, a.roomno, a.floor
FROM resident r
INNER JOIN owner o ON r.owner_cnic = o.cnic
INNER JOIN apartment a ON o.roomno = a.roomno
ORDER BY a.floor ASC;


CREATE VIEW parking_view AS
SELECT p.plate_no, p.type, o.cnic AS owner_cnic, o.name AS owner_name, a.roomno
FROM parking p
INNER JOIN owner o ON p.owner_cnic = o.cnic
INNER JOIN apartment a ON o.roomno = a.roomno
ORDER BY p.plate_no, p.type, o.name;


CREATE VIEW servicePrices AS
SELECT s.type, s.price
FROM service s;

CREATE VIEW CafeMenu AS
SELECT food_id, description, price
FROM foodItem;


