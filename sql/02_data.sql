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
-- Monday 09–10 CS212 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS212',1,'FF4'),
((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS212',1,'FF4');

-- Map teachers for Monday 09–10 (CS212 -> AY)
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AY' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7' OR 'B8') AND course_code='CS212' AND slot_id=1 LIMIT 1;

-- Monday 10–11 CI311 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CI311',2,'FF7'),
((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CI311',2,'FF7');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='CI311' AND slot_id=2 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') AND course_code='CI311' AND slot_id=2 LIMIT 1;

-- Monday 11–13 B15CS213 (DBMS LAB) (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'B15CS213',3,'CL06/CL07');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'B15CS213',3,'CL06/CL07');

-- Map DBMS lab teachers (DC, DS, DPK) for both batches
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='B15CS213' AND slot_id=3 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DS' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='B15CS213' AND slot_id=3 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DPK' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='B15CS213' AND slot_id=3 LIMIT 1;

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') AND course_code='B15CS213' AND slot_id=3 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DS' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') AND course_code='B15CS213' AND slot_id=3 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DPK' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') AND course_code='B15CS213' AND slot_id=3 LIMIT 1;

-- Monday 14–15 HS211 (B7 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'HS211',5,'TS17');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MRB' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='HS211' AND slot_id=5 LIMIT 1;

-- Monday 15–16 MA213 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'MA213',6,'G3');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'MA213',6,'G3');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PS' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='MA213' AND slot_id=6 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PS' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') AND course_code='MA213' AND slot_id=6 LIMIT 1;

-- TUESDAY
-- Tuesday 9–11 CI371 (Data Structures Lab) (B7)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CI371',8,'CL04');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AP' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='CI371' AND slot_id=8 LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'SG' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='CI371' AND slot_id=8 LIMIT 1;

-- Tuesday 11–12 CI311 (B7 only tutorial)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CI311',9,'TS11');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable
WHERE batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') AND course_code='CI311' AND slot_id=9 LIMIT 1;
---------------------
-- Tuesday 12–13 CS213 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS213',10,'FF7');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS213',10,'FF7');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable
WHERE course_code='CS213' AND slot_id=10 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable
WHERE course_code='CS213' AND slot_id=10 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Tuesday 14–15 CI311 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CI311',11,'G3');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CI311',11,'G3');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable WHERE course_code='CI311' AND slot_id=11 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable WHERE course_code='CI311' AND slot_id=11 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Tuesday 15–16 MA213 (B8 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'MA213',12,'TS10');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'HG' FROM Timetable WHERE course_code='MA213' AND slot_id=12 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Tuesday 16–17 HS211 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'HS211',13,'FF7');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'HS211',13,'FF7');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MRB' FROM Timetable WHERE course_code='HS211' AND slot_id=13 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MRB' FROM Timetable WHERE course_code='HS211' AND slot_id=13 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- WEDNESDAY
-- Wednesday 09–10 CS212 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS212',14,'FF8');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS212',14,'FF8');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AY' FROM Timetable WHERE course_code='CS212' AND slot_id=14 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AY' FROM Timetable WHERE course_code='CS212' AND slot_id=14 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Wednesday 10–11 MA213 (B7 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'MA213',15,'TS20');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AN' FROM Timetable WHERE course_code='MA213' AND slot_id=15 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;

-- Wednesday 10–11 CI311 (B8 only)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CI311',15,'F10');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'KRL' FROM Timetable WHERE course_code='CI311' AND slot_id=15 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Wednesday 11–12 CI311 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CI311',16,'FF7');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CI311',16,'FF7');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable WHERE course_code='CI311' AND slot_id=16 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MA' FROM Timetable WHERE course_code='CI311' AND slot_id=16 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- THURSDAY
-- Thursday 09–10 MA213 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'MA213',17,'F6');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'MA213',17,'F6');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PS' FROM Timetable WHERE course_code='MA213' AND slot_id=17 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PS' FROM Timetable WHERE course_code='MA213' AND slot_id=17 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Thursday 10–11 CS212
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS212',18,'G1');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS212',18,'G1');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AY' FROM Timetable WHERE course_code='CS212' AND slot_id=18  AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AY' FROM Timetable WHERE course_code='CS212' AND slot_id=18  AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Thursday 11–12 HS211
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'HS211',19,'FF7');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'HS211',19,'FF7');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MRB' FROM Timetable WHERE course_code='HS211' AND slot_id=19 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'MRB' FROM Timetable WHERE course_code='HS211' AND slot_id=19 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Thursday 12–13 CS214
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS214',20,'G8');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS214',20,'G8');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PK' FROM Timetable WHERE course_code='CS214' AND slot_id=20 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PK' FROM Timetable WHERE course_code='CS214' AND slot_id=20 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Thursday 14–15 CS213
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS213',21,'FF7');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS213',21,'FF7');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable WHERE course_code='CS213' AND slot_id=21 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable WHERE course_code='CS213' AND slot_id=21 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Thursday 15–17 B15CS215 Lab (B7 + B8) -> multiple teachers (Pratik, Neetu, Tanvee)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'B15CS215',22,'CL05/CL06');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'B15CS215',22,'CL05/CL06');

-- Map lab teachers PTK, NS, THA for both batches
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PTK' FROM Timetable WHERE course_code='B15CS215' AND slot_id=22 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'NS' FROM Timetable WHERE course_code='B15CS215' AND slot_id=22 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'THA' FROM Timetable WHERE course_code='B15CS215' AND slot_id=22 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PTK' FROM Timetable WHERE course_code='B15CS215' AND slot_id=22 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'NS' FROM Timetable WHERE course_code='B15CS215' AND slot_id=22 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'THA' FROM Timetable WHERE course_code='B15CS215' AND slot_id=22 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- FRIDAY
-- Friday 11–12 MA213 (B7 + B8)
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'MA213',23,'FF8');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'MA213',23,'FF8');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PS' FROM Timetable WHERE course_code='MA213' AND slot_id=23 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PS' FROM Timetable WHERE course_code='MA213' AND slot_id=23 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

-- Friday 12–13 CS213
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'CS213',24,'FF7');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'CS213',24,'FF7');
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable WHERE course_code='CS213' AND slot_id=24 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DC' FROM Timetable WHERE course_code='CS213' AND slot_id=24 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;

INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B7'),'B15CS214',25,'CL17/CL18');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B8'),'B15CS214',25,'CL17/CL18');



INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AK' FROM Timetable WHERE course_code='B15CS214' AND slot_id=25 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PSO' FROM Timetable WHERE course_code='B15CS214' AND slot_id=25 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PK' FROM Timetable WHERE course_code='B15CS214' AND slot_id=25 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B7') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'AK' FROM Timetable WHERE course_code='B15CS214' AND slot_id=25 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PSO' FROM Timetable WHERE course_code='B15CS214' AND slot_id=25 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PK' FROM Timetable WHERE course_code='B15CS214' AND slot_id=25 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B8') LIMIT 1;


-----------------------------------------B1 and B2 TIMETABLE DATA-----------------------------------------

INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B1'),'CS213',4,'FF8');
INSERT INTO Timetable (batch_id, course_code, slot_id, room)
VALUES ((SELECT batch_id FROM Batch WHERE batch_name='B2'),'CS213',4,'FF8');

INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'DPK' FROM Timetable WHERE course_code='CS213' AND slot_id=4 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B1') LIMIT 1;
INSERT INTO Timetable_Teachers (tt_id, teacher_code)
SELECT tt_id, 'PK' FROM Timetable WHERE course_code='CS213' AND slot_id=4 AND batch_id=(SELECT batch_id FROM Batch WHERE batch_name='B2') LIMIT 1;
ALTER TABLE Timetable ADD COLUMN is_extra TINYINT DEFAULT 0;

