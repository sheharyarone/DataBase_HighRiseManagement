DELIMITER $$

CREATE TRIGGER calculate_rent
BEFORE INSERT ON apartment
FOR EACH ROW
BEGIN
DECLARE base_rent FLOAT;
DECLARE floor_factor FLOAT;
DECLARE type_factor FLOAT;
DECLARE size_factor FLOAT;
DECLARE final_rent FLOAT;

SET base_rent =
CASE
WHEN NEW.size < 500 THEN 500
WHEN NEW.size BETWEEN 500 AND 1000 THEN 1000
ELSE 1500
END;

SET floor_factor =
CASE
WHEN NEW.floor < 5 THEN 1
WHEN NEW.floor BETWEEN 5 AND 10 THEN 1.5
ELSE 2
END;

SET type_factor =
CASE
WHEN NEW.type = 'studio' THEN 1
WHEN NEW.type = 'convertible' THEN 1.5
WHEN NEW.type = 'penthouse' THEN 2
ELSE 1
END;

SET size_factor = NEW.size / 10;

SET final_rent = ((base_rent + (base_rent * floor_factor)) * type_factor) + size_factor;
SET NEW.rent = final_rent;
END$$

DELIMITER ;
