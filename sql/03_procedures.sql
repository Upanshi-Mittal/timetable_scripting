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

DELIMITER ;
