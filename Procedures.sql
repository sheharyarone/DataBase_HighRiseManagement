
DELIMITER $$
CREATE PROCEDURE addVehicleToParking(IN plate_no VARCHAR(255), IN type ENUM('car', 'bike'), IN owner_cnic INT)
BEGIN
    INSERT INTO parking (plate_no, type, owner_cnic)
    VALUES (plate_no, type, owner_cnic);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE addGuest(
    IN owner_cnic INT,
    IN guest_name VARCHAR(255),
    IN guest_cnic INT
)
BEGIN
    -- Insert a new row into the guest table with the provided information
    INSERT INTO guest (cnic, name, owner_cnic)
    VALUES (guest_cnic, guest_name, owner_cnic);
END$$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE addResident(IN p_name VARCHAR(255), IN p_cnic INT, IN p_age INT, IN p_dob DATE, IN p_owner_cnic INT)
BEGIN
INSERT INTO resident (name, cnic, age, dob, owner_cnic)
VALUES (p_name, p_cnic, p_age, p_dob, p_owner_cnic);
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE removeResident(IN resident_cnic INT)
BEGIN
    DELETE FROM resident WHERE cnic = resident_cnic;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE removeVehicle(IN plate_no VARCHAR(255))
BEGIN
    DELETE FROM parking WHERE plate_no = plate_no;
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE removeGuest(IN guest_cnic INT)
BEGIN
    -- Delete the row from the guest table where the CNIC matches the provided guest_cnic
    DELETE FROM guest WHERE cnic = guest_cnic;
END$$
DELIMITER ;



DELIMITER $$
CREATE PROCEDURE orderFood(IN owner_cnic INT, IN food_id VARCHAR(5), IN number INT)
BEGIN
    SET @price = 0;
    SET @order_id = 0;
    SET @total_amount = 0;

    SELECT getFood(food_id) INTO @price;

    INSERT INTO foodOrder (owner_cnic, date_placed)
    VALUES (owner_cnic, CURDATE());

    SET @order_id = LAST_INSERT_ID();

    SET @total_amount = @price * number;

    INSERT INTO orderContains (order_id, food_id, number, amount)
    VALUES (@order_id, food_id, number, @total_amount);
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE manageMembership(IN action VARCHAR(10), IN cnic INT, IN type VARCHAR(10))
BEGIN
    DECLARE join_date DATE;
    DECLARE expiry_date DATE;
    SET join_date = CURDATE();
    SET expiry_date = setExpiryDate(join_date);

    IF action = 'add' THEN
        IF type = 'gym' THEN
            INSERT INTO gym (join_date, expiry_date, CNIC)
            VALUES (join_date, expiry_date, cnic);
        ELSEIF type = 'pool' THEN
            INSERT INTO pool (join_date, expiry_date, CNIC)
            VALUES (join_date, expiry_date, cnic);
        END IF;
    ELSEIF action = 'remove' THEN
        IF type = 'gym' THEN
            DELETE FROM gym
            WHERE CNIC = cnic;
        ELSEIF type = 'pool' THEN
            DELETE FROM pool
            WHERE CNIC = cnic;
        END IF;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE updateApartmentRent(IN percentage FLOAT)
BEGIN
    UPDATE apartment SET rent = rent * (1 + percentage/100);
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE updateServicePrice(IN type ENUM('parking', 'gym', 'swimming_pool'), IN price FLOAT)
BEGIN
    UPDATE service r SET r.price = price WHERE r.type = type;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE deleteOwner(IN owner_cnic INT)
BEGIN
  -- Delete all rows in the foodOrder and orderContains tables that are related to the owner
  DELETE FROM foodOrder WHERE owner_cnic = owner_cnic;
  DELETE FROM orderContains WHERE order_id IN (SELECT order_id FROM foodOrder WHERE owner_cnic = owner_cnic);

  -- Delete all rows in the bill table that are related to the owner
  DELETE FROM bill WHERE owner_cnic = owner_cnic;

  -- Delete all rows in the parking, guest, resident, pool, and gym tables that are related to the owner
  DELETE FROM parking WHERE owner_cnic = owner_cnic;
  DELETE FROM guest WHERE owner_cnic = owner_cnic;
  DELETE FROM resident WHERE owner_cnic = owner_cnic;
  DELETE FROM pool WHERE cnic IN (SELECT cnic FROM resident WHERE owner_cnic = owner_cnic);
  DELETE FROM gym WHERE cnic IN (SELECT cnic FROM resident WHERE owner_cnic = owner_cnic);

  SELECT username INTO @username FROM accountsInfo WHERE owner_cnic = owner_cnic;

    -- Delete the user account associated with the owner
    SET @query = CONCAT('DROP USER ''', @username, '''@''localhost''');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
	DELETE FROM accountsInfo WHERE owner_cnic = owner_cnic;
      
	DELETE FROM owner WHERE cnic = owner_cnic;

END$$
DELIMITER ;



CREATE PROCEDURE addApartmentOwner(
    IN owner_name VARCHAR(255),
    IN owner_cnic INT,
    IN owner_age INT,
    IN owner_dob date,
    IN owner_phone INT,
    IN owner_roomno INT,
    IN username VARCHAR(255),
    IN password VARCHAR(255)
)
BEGIN
     -- Insert a new row into the owner table with the provided information
    INSERT INTO owner (name, cnic, age,dob, phone, roomno,username)
    VALUES (owner_name, owner_cnic, owner_age,owner_dob, owner_phone, owner_roomno,username);

    INSERT INTO resident
    VALUES ( owner_name,owner_cnic,owner_cnic,owner_age,owner_dob);

    SET @create_user_query = CONCAT('CREATE USER ''', username, '''@''localhost'' IDENTIFIED BY ''', password, '''');
    PREPARE stmt FROM @create_user_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE grantPermissionsToOwner(IN username VARCHAR(255))
BEGIN
    
    SET @grant_stmt = CONCAT('GRANT SELECT ON monthly_billing TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @grant_stmt = CONCAT('GRANT SELECT ON cafemenu TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @grant_stmt = CONCAT('GRANT SELECT ON serviceprices TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @grant_stmt = CONCAT('GRANT SELECT ON foodorderhistory TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @grant_stmt = CONCAT('GRANT SELECT ON guest_view TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @grant_stmt = CONCAT('GRANT SELECT ON resident_apartment_view TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @grant_stmt = CONCAT('GRANT SELECT ON pool_memberships TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @grant_stmt = CONCAT('GRANT SELECT ON gym_memberships TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @grant_stmt = CONCAT('GRANT SELECT ON parking_view TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Grant EXECUTE privilege on getMonthlyBill procedure to the user
    SET @grant_stmt = CONCAT('GRANT EXECUTE ON PROCEDURE addGuest TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @grant_stmt = CONCAT('GRANT EXECUTE ON PROCEDURE addVehicleToParking TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
     SET @grant_stmt = CONCAT('GRANT EXECUTE ON PROCEDURE orderFood TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @grant_stmt = CONCAT('GRANT EXECUTE ON PROCEDURE removeVehicle TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @grant_stmt = CONCAT('GRANT EXECUTE ON PROCEDURE removeGuest TO ''', username, '''@''localhost''');
    PREPARE stmt FROM @grant_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    
    
END$$
DELIMITER ;



DELIMITER $$
CREATE PROCEDURE updateFoodItemPrice(
    IN food_id VARCHAR(5),
    IN new_price FLOAT
)
BEGIN
    UPDATE foodItem fo
    SET fo.price = new_price
    WHERE fo.food_id = food_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE addFoodItem(
    IN item_id VARCHAR(5),
    IN description VARCHAR(50),
    IN price FLOAT
)
BEGIN
    -- Insert a new row into the foodItem table with the provided information
    INSERT INTO foodItem (food_id, description, price)
    VALUES (item_id, description, price);
END$$

DELIMITER ;

