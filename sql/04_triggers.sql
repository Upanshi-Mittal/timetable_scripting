USE timetable_db;

DELIMITER $$

CREATE TRIGGER prevent_double_slot
BEFORE INSERT ON Timetable
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Timetable
        WHERE batch_id = NEW.batch_id
          AND slot_id = NEW.slot_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SELECT 'Error: This batch already has a class in this slot.';
    END IF;
END$$


CREATE TRIGGER log_timetable_entry
AFTER INSERT ON Timetable
FOR EACH ROW
BEGIN
    INSERT INTO NotificationLog(batch_id, message)
    VALUES (
        NEW.batch_id,
        CONCAT(
            'New class added: Course ',
            NEW.course_code,
            ' at slot ',
            NEW.slot_id,
            ' (Room: ',
            NEW.room,
            ')'
        )
    );
END$$

DELIMITER ;
