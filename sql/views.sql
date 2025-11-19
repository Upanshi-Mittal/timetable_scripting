USE timetable_db;

CREATE OR REPLACE VIEW final_timetable_view AS
SELECT 
    b.batch_name,
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
ORDER BY 
    b.batch_name,
    FIELD(d.day_name,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    d.start_time;
