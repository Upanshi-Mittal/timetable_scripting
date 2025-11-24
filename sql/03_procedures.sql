USE timetable_db;

DELIMITER $$

-- NEXT CLASS PROCEDURE
CREATE PROCEDURE get_next_class(IN bname VARCHAR(64))
BEGIN
    SELECT 
        b.batch_name,
        c.course_code,
        c.course_name,
        GROUP_CONCAT(tch.teacher_name SEPARATOR ', ') AS teachers,
        d.day_name,
        d.start_time,
        d.end_time,
        t.room
    FROM Timetable t
    JOIN Batch b ON t.batch_id = b.batch_id
    JOIN Course c ON t.course_code = c.course_code
    JOIN DaySlot d ON t.slot_id = d.slot_id
    LEFT JOIN Timetable_Teachers tt ON t.tt_id = tt.tt_id
    LEFT JOIN Teachers tch ON tt.teacher_code = tch.teacher_code
    WHERE b.batch_name = bname
      AND d.day_name = DAYNAME(CURDATE())
      AND d.start_time > CURTIME()
    GROUP BY t.tt_id
    ORDER BY d.start_time
    LIMIT 1;
END $$

-- TODAY'S FULL SCHEDULE
CREATE PROCEDURE get_today_schedule(IN bname VARCHAR(64))
BEGIN
    SELECT 
        d.day_name,
        d.start_time,
        d.end_time,
        c.course_code,
        c.course_name,
        GROUP_CONCAT(tch.teacher_name SEPARATOR ', ') AS teachers,
        t.room
    FROM Timetable t
    JOIN Batch b ON t.batch_id = b.batch_id
    JOIN Course c ON t.course_code = c.course_code
    JOIN DaySlot d ON t.slot_id = d.slot_id
    LEFT JOIN Timetable_Teachers tt ON t.tt_id = tt.tt_id
    LEFT JOIN Teachers tch ON tt.teacher_code = tch.teacher_code
    WHERE b.batch_name = bname
      AND d.day_name = DAYNAME(CURDATE())
    GROUP BY t.tt_id
    ORDER BY d.start_time;
END $$


CREATE PROCEDURE add_extra_class_today(
    IN bname VARCHAR(64),
    IN courseCode VARCHAR(32),
    IN teacherName VARCHAR(64),
    IN roomName VARCHAR(16)
)
main_block: BEGIN
    DECLARE bid INT;
    DECLARE teacherCode VARCHAR(32);
    DECLARE todayName VARCHAR(16);
    DECLARE selectedSlot INT;

    SET todayName = DAYNAME(CURDATE());

    -- get batch id
    SELECT batch_id INTO bid
    FROM Batch
    WHERE batch_name = bname;

    -- get teacher code
    SELECT teacher_code INTO teacherCode
    FROM Teachers
    WHERE teacher_name = teacherName
    LIMIT 1;

    IF teacherCode IS NULL THEN
        SELECT 'TEACHER_NOT_FOUND' AS status;
        LEAVE main_block;
    END IF;

    -- find common free slot
    SELECT d.slot_id INTO selectedSlot
    FROM DaySlot d
    WHERE d.day_name = todayName
      AND d.slot_id NOT IN (
        SELECT slot_id FROM Timetable WHERE batch_id = bid
      )
      AND d.slot_id NOT IN (
        SELECT t.slot_id
        FROM Timetable t
        JOIN Timetable_Teachers tt ON t.tt_id = tt.tt_id
        WHERE tt.teacher_code = teacherCode
      )
      AND d.slot_id NOT IN (
        SELECT slot_id FROM Timetable WHERE room = roomName
      )
    ORDER BY d.start_time
    LIMIT 1;

    IF selectedSlot IS NULL THEN
        SELECT 'NO_COMMON_FREE_SLOT' AS status;
        LEAVE main_block;
    END IF;

    -- insert extra class
    INSERT INTO Timetable(batch_id, slot_id, course_code, room, is_extra)
    VALUES (bid, selectedSlot, courseCode, roomName, 1);

    SELECT CONCAT('EXTRA_CLASS_ADDED:', selectedSlot) AS status;

END main_block$$




DELIMITER ;
