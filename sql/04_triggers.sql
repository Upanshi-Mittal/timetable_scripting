USE timetable_db;

DELIMITER $$

-- PREVENT DOUBLE BOOKING OF SAME SLOT FOR SAME BATCH
CREATE TRIGGER prevent_double_slot
BEFORE INSERT ON Timetable
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Timetable 
        WHERE batch_id = NEW.batch_id 
          AND slot_id = NEW.slot_id
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: This batch already has a class in this slot.';
    END IF;
END$$

-- AUTO LOG ON NEW TIMETABLE ENTRY
CREATE TRIGGER log_timetable_entry
AFTER INSERT ON Timetable
FOR EACH ROW
BEGIN
    INSERT INTO NotificationLog(batch_id, message)
    VALUES (NEW.batch_id, CONCAT('New class added for batch at slot ', NEW.slot_id));
END$$

DELIMITER ;
