USE timetable_db;

-- BATCHES
INSERT INTO Batch(batch_name) VALUES
('CSE_A'),
('CSE_B'),
('AIML_A');

-- COURSES
INSERT INTO Course(course_code, course_name, teacher_name) VALUES
('DBMS', 'Database Management Systems', 'Dr. Sharma'),
('DS', 'Data Structures', 'Ms. Rao'),
('OS', 'Operating Systems', 'Mr. Gupta'),
('ML', 'Machine Learning', 'Dr. Singh'),
('PY', 'Python Programming', 'Ms. Khanna');

-- SLOTS
INSERT INTO DaySlot(day_name, start_time, end_time) VALUES
('Monday', '09:00:00', '09:50:00'),
('Monday', '10:00:00', '10:50:00'),
('Monday', '11:00:00', '11:50:00'),
('Tuesday', '09:00:00', '09:50:00'),
('Tuesday', '10:00:00', '10:50:00'),
('Wednesday', '09:00:00', '09:50:00'),
('Friday', '14:00:00', '14:50:00');

-- TIMETABLE FOR CSE_A
INSERT INTO Timetable(batch_id, course_id, slot_id, room)
VALUES
((SELECT batch_id FROM Batch WHERE batch_name='CSE_A'),
 (SELECT course_id FROM Course WHERE course_code='DS'),
 (SELECT slot_id FROM DaySlot WHERE day_name='Monday' AND start_time='09:00:00'),
 'R201'),

((SELECT batch_id FROM Batch WHERE batch_name='CSE_A'),
 (SELECT course_id FROM Course WHERE course_code='DBMS'),
 (SELECT slot_id FROM DaySlot WHERE day_name='Monday' AND start_time='10:00:00'),
 'R201'),

((SELECT batch_id FROM Batch WHERE batch_name='CSE_A'),
 (SELECT course_id FROM Course WHERE course_code='OS'),
 (SELECT slot_id FROM DaySlot WHERE day_name='Monday' AND start_time='11:00:00'),
 'Lab1');

-- TIMETABLE FOR CSE_B
INSERT INTO Timetable(batch_id, course_id, slot_id, room)
VALUES
((SELECT batch_id FROM Batch WHERE batch_name='CSE_B'),
 (SELECT course_id FROM Course WHERE course_code='ML'),
 (SELECT slot_id FROM DaySlot WHERE day_name='Tuesday' AND start_time='10:00:00'),
 'Lab2');
