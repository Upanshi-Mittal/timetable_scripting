-- schema.sql
DROP DATABASE IF EXISTS timetable_db;
CREATE DATABASE timetable_db;
USE timetable_db;

-- BATCH TABLE
CREATE TABLE Batch (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_name VARCHAR(64) NOT NULL UNIQUE
);

-- COURSE TABLE
CREATE TABLE Course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(128) NOT NULL,
    teacher_name VARCHAR(128)
);

-- DAYSLOT TABLE
CREATE TABLE DaySlot (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    day_name VARCHAR(16) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CHECK (start_time < end_time)
);

-- TIMETABLE TABLE
CREATE TABLE Timetable (
    tt_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    course_id INT NOT NULL,
    slot_id INT NOT NULL,
    room VARCHAR(64),

    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES DaySlot(slot_id) ON DELETE CASCADE
);

-- LOG TABLE
CREATE TABLE NotificationLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT,
    message TEXT,
    time_sent DATETIME DEFAULT CURRENT_TIMESTAMP
);
