DELIMITER $$
CREATE procedure monthly_billing()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE owner_cnic INT;
  DECLARE total_rent FLOAT;
  DECLARE total_gym_payment FLOAT;
  DECLARE total_pool_payment FLOAT;
  DECLARE total_parking_payment FLOAT;
  DECLARE total_food_payment FLOAT;
  DECLARE total_amount FLOAT;
  DECLARE owner_cursor CURSOR FOR SELECT cnic FROM owner;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN owner_cursor;

  owner_loop: LOOP
    FETCH owner_cursor INTO owner_cnic;

    IF done THEN
      LEAVE owner_loop;
    END IF;

   SET total_rent = (SELECT SUM(a.rent) FROM owner o
                 INNER JOIN apartment a ON a.roomno = o.roomno
                 WHERE o.cnic = owner_cnic group by o.cnic);
   
    SET total_gym_payment = (SELECT COUNT(*) * price FROM gym AS g INNER JOIN service AS s ON s.type = 'gym' INNER JOIN resident AS r ON r.cnic = g.cnic WHERE r.owner_cnic = owner_cnic);
    SET total_pool_payment = (SELECT COUNT(*) * price FROM pool AS p INNER JOIN service AS s ON s.type = 'swimming_pool' INNER JOIN resident AS r ON r.cnic = p.cnic WHERE r.owner_cnic = owner_cnic);
    SET total_parking_payment = (SELECT COUNT(*) * price FROM parking AS p INNER JOIN service AS s ON s.type = 'parking' WHERE p.owner_cnic = owner_cnic);
 SET total_food_payment = (SELECT SUM(amount) FROM foodOrder AS fo
                         INNER JOIN orderContains AS oc ON fo.order_id = oc.order_id
                         WHERE fo.owner_cnic = owner_cnic AND fo.date_placed BETWEEN
                            CONCAT(YEAR(CURRENT_TIMESTAMP()), '-', MONTH(CURDATE()), '-01') AND
                            LAST_DAY(CONCAT(YEAR(CURRENT_TIMESTAMP()), '-', MONTH(CURDATE()), '-01')));

    SET total_amount = total_rent + total_gym_payment + total_pool_payment + total_parking_payment + total_food_payment;

    INSERT INTO bill (owner_cnic, month, year, rent, gym_payment, pool_payment, parking_payment, food_payment, total_amount, isPaid)
    VALUES (owner_cnic, MONTHNAME(CURRENT_TIMESTAMP()), YEAR(CURRENT_TIMESTAMP()), total_rent, total_gym_payment, total_pool_payment, total_parking_payment, total_food_payment, total_amount, FALSE);
  END LOOP;

  CLOSE owner_cursor;
END$$

DELIMITER ;