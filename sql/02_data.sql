USE timetable_db;

-- BATCHES
INSERT INTO Batch (batch_name) VALUES ('B7'), ('B8'),('B1'),('B2'),('B3'),('B4'),('B5'),('B6');

-- teachers
INSERT INTO Teachers VALUES
('AY', 'Dr. Asmita Yadav'),
('MA', 'Mr. Amitesh'),
('DC', 'Dr. Indu Chawla'),
('DS', 'Dr. Sonal'),
('DPK', 'Dr. Parmeet Kaur'),
('MRB', 'Dr. Manas Ranjan Behera'),
('PS', 'Dr. Priya Shahi'),
('AP', 'Anupama Padha'),
('SG', 'Ms. Sarishty Gupta'),
('VS', 'Dr. Vandana Sehgal'),
('RKM', 'Rajiv Kumar Mishra'),
('THA', 'Dr. Tanvee Gautam'),
('KRL', 'Dr. K. Rajalakshmi'),
('HG', 'Dr. Himanshu Agarwal'),
('PK', 'Ms. Purti Kohli'),
('PSO', 'Mr. Prateek Soni'),
('NS', 'Neetu Singh'),
('AN', 'Dr. Anuj Bhardwaj'),
('PTK', 'Pratik Shrivastava'),
('AK', 'Ms. Amarjeet Kaur');

-- COURSES
INSERT INTO Course (course_code, course_name) VALUES
('CS212', 'Theoretical Foundations of Computer Science'),
('CI311', 'Data Structures'),
('B15CS213', 'Database Management Systems Lab'),
('HS211', 'Economics'),
('MA213', 'Mathematical Foundations for Artificial Intelligence and Data Science'),
('CI371', 'Data Structures Lab'),
('CS213', 'Database Management Systems'),
('CS214', 'Unix Programming'),
('B15CS215', 'Object Oriented Programming using Java'),
('B15CS214', 'Unix Programming Lab');

-- DaySlots 

INSERT INTO DaySlot (day_name, start_time, end_time) VALUES
('Monday', '09:00:00', '10:00:00'),
('Monday', '10:00:00', '11:00:00'),
('Monday', '11:00:00', '13:00:00'),
('Monday', '13:00:00', '14:00:00'),
('Monday', '14:00:00', '15:00:00'),
('Monday', '15:00:00', '16:00:00'),
('Monday', '16:00:00', '17:00:00'),

('Tuesday', '09:00:00', '11:00:00'),
('Tuesday', '11:00:00', '12:00:00'),
('Tuesday', '12:00:00', '13:00:00'),
('Tuesday', '14:00:00', '15:00:00'),
('Tuesday', '15:00:00', '16:00:00'),
('Tuesday', '16:00:00', '17:00:00'),

('Wednesday', '09:00:00', '10:00:00'),
('Wednesday', '10:00:00', '11:00:00'),
('Wednesday', '11:00:00', '12:00:00'),

('Thursday', '09:00:00', '10:00:00'),
('Thursday', '10:00:00', '11:00:00'),
('Thursday', '11:00:00', '12:00:00'),
('Thursday', '12:00:00', '13:00:00'),
('Thursday', '14:00:00', '15:00:00'),
('Thursday', '15:00:00', '17:00:00'),

('Friday', '11:00:00', '12:00:00'),
('Friday', '12:00:00', '13:00:00'),
('Friday', '15:00:00', '17:00:00');

-----------------------------B7 and B8 TIMETABLE DATA-----------------------------
-- MONDAY
-- Monday 09–10 CS212 for B7 & B8 (slot_id = 1)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS212', 1, 'FF4', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'AY'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS212' AND t.slot_id=1;

-- Monday 10–11 CI311 for B7 & B8 (slot_id = 2)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CI311', 2, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MA'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CI311' AND t.slot_id=2;

-- Monday 11–13 B15CS213 (DBMS LAB) for B7 & B8 (slot_id = 3)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'B15CS213', 3, 'CL06/CL07', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

-- Map multiple lab teachers (DC, DS, DPK) for each inserted tt
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DC'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS213' AND t.slot_id=3;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DS'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS213' AND t.slot_id=3;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DPK'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS213' AND t.slot_id=3;

-- Monday 14–15 HS211 (B7 only) (slot_id = 5)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'HS211', 5, 'TS17', 0
FROM Batch
WHERE batch_name = 'B7';

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MRB'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B7' AND t.course_code='HS211' AND t.slot_id=5;

-- Monday 15–16 MA213 (B7 & B8) (slot_id = 6)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'MA213', 6, 'G3', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PS'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='MA213' AND t.slot_id=6;

-- Tuesday 9–11 CI371 (slot_id = 8) (B7)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CI371', 8, 'CL04', 0
FROM Batch
WHERE batch_name = 'B7';

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'AP'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B7' AND t.course_code='CI371' AND t.slot_id=8;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'SG'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B7' AND t.course_code='CI371' AND t.slot_id=8;

-- Tuesday 11–12 CI311 (slot_id = 9) (B7 tutorial)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CI311', 9, 'TS11', 0
FROM Batch
WHERE batch_name = 'B7';

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MA'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B7' AND t.course_code='CI311' AND t.slot_id=9;

-- Tuesday 12–13 CS213 (slot_id = 10) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS213', 10, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DC'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS213' AND t.slot_id=10;

-- Tuesday 14–15 CI311 (slot_id = 11) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CI311', 11, 'G3', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MA'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CI311' AND t.slot_id=11;

-- Tuesday 15–16 MA213 (slot_id = 12) (B8 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'MA213', 12, 'TS10', 0
FROM Batch
WHERE batch_name = 'B8';

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'HG'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B8' AND t.course_code='MA213' AND t.slot_id=12;

-- Tuesday 16–17 HS211 (slot_id = 13) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'HS211', 13, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MRB'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='HS211' AND t.slot_id=13;

-- Wednesday 09–10 CS212 (slot_id = 14) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS212', 14, 'FF8', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'AY'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS212' AND t.slot_id=14;

-- Wednesday 10–11 MA213 (slot_id = 15) (B7 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'MA213', 15, 'TS20', 0
FROM Batch
WHERE batch_name = 'B7';

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'AN'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B7' AND t.course_code='MA213' AND t.slot_id=15;

-- Wednesday 10–11 CI311 (slot_id = 15) (B8 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CI311', 15, 'F10', 0
FROM Batch
WHERE batch_name = 'B8';

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'KRL'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name = 'B8' AND t.course_code='CI311' AND t.slot_id=15;

-- Wednesday 11–12 CI311 (slot_id = 16) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CI311', 16, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MA'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CI311' AND t.slot_id=16;

-- Thursday 09–10 MA213 (slot_id = 17) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'MA213', 17, 'F6', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PS'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='MA213' AND t.slot_id=17;

-- Thursday 10–11 CS212 (slot_id = 18) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS212', 18, 'G1', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'AY'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS212' AND t.slot_id=18;

-- Thursday 11–12 HS211 (slot_id = 19) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'HS211', 19, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'MRB'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='HS211' AND t.slot_id=19;

-- Thursday 12–13 CS214 (slot_id = 20) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS214', 20, 'G8', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PK'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS214' AND t.slot_id=20;

-- Thursday 14–15 CS213 (slot_id = 21) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS213', 21, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DC'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS213' AND t.slot_id=21;

-- Thursday 15–17 B15CS215 Lab (slot_id = 22) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'B15CS215', 22, 'CL05/CL06', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PTK'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS215' AND t.slot_id=22;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'NS'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS215' AND t.slot_id=22;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'THA'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS215' AND t.slot_id=22;

-- Friday 11–12 MA213 (slot_id = 23) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'MA213', 23, 'FF8', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PS'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='MA213' AND t.slot_id=23;

-- Friday 12–13 CS213 (slot_id = 24) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS213', 24, 'FF7', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DC'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='CS213' AND t.slot_id=24;

-- Friday 15–17 B15CS214 (slot_id = 25) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'B15CS214', 25, 'CL17/CL18', 0
FROM Batch
WHERE batch_name IN ('B7','B8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'AK'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS214' AND t.slot_id=25;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PSO'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS214' AND t.slot_id=25;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'PK'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B7','B8') AND t.course_code='B15CS214' AND t.slot_id=25;


-----------------------------------------B1 and B2 TIMETABLE DATA-----------------------------------------
-- MONDAY
-- B1 & B2: CS213 at slot_id = 4 in FF8
INSERT INTO Timetable (batch_id, course_code, slot_id, room, is_extra)
SELECT batch_id, 'CS213', 4, 'FF8', 0
FROM Batch
WHERE batch_name IN ('B1','B2');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT t.tt_id, 'DPK'
FROM Timetable t
JOIN Batch b ON t.batch_id = b.batch_id
WHERE b.batch_name IN ('B1','B2') AND t.course_code='CS213' AND t.slot_id=4;


