USE timetable_db;

DELIMITER $$

-- GET NEXT CLASS
CREATE PROCEDURE get_next_class(IN bname VARCHAR(64))
BEGIN
    SELECT 
        b.batch_name AS batch,
        c.course_code,
        c.course_name,
        c.teacher_name,
        d.day_name,
        d.start_time,
        d.end_time,
        t.room
    FROM Timetable t
    JOIN Batch b ON t.batch_id = b.batch_id
    JOIN Course c ON t.course_id = c.course_id
    JOIN DaySlot d ON t.slot_id = d.slot_id
    WHERE b.batch_name = bname
      AND d.day_name = DAYNAME(CURRENT_DATE())
      AND d.start_time > CURRENT_TIME()
    ORDER BY d.start_time
    LIMIT 1;
END$$

-- GET TODAY'S FULL TIMETABLE
CREATE PROCEDURE get_today_schedule(IN bname VARCHAR(64))
BEGIN
    SELECT 
        d.day_name,
        d.start_time,
        d.end_time,
        c.course_code,
        c.course_name,
        c.teacher_name,
        t.room
    FROM Timetable t
    JOIN Batch b ON t.batch_id = b.batch_id
    JOIN Course c ON t.course_id = c.course_id
    JOIN DaySlot d ON t.slot_id = d.slot_id
    WHERE b.batch_name = bname
      AND d.day_name = DAYNAME(CURRENT_DATE())
    ORDER BY d.start_time;
END$$

-- GET FULL TIMETABLE ANY DAY
CREATE PROCEDURE get_full_timetable(IN bname VARCHAR(64))
BEGIN
    SELECT 
        d.day_name,
        d.start_time,
        d.end_time,
        c.course_code,
        c.course_name,
        c.teacher_name,
        t.room
    FROM Timetable t
    JOIN Batch b ON t.batch_id = b.batch_id
    JOIN Course c ON t.course_id = c.course_id
    JOIN DaySlot d ON t.slot_id = d.slot_id
    WHERE b.batch_name = bname
    ORDER BY 
        FIELD(d.day_name, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
        d.start_time;
END$$

DELIMITER ;
