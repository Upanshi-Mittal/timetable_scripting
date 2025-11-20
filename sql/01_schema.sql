DROP DATABASE IF EXISTS timetable_db;
CREATE DATABASE timetable_db;
USE timetable_db;

-- BATCH TABLE
CREATE TABLE IF NOT EXISTS Batch (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_name VARCHAR(64) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- TEACHERS TABLE
CREATE TABLE IF NOT EXISTS Teachers (
    teacher_code VARCHAR(10) PRIMARY KEY,
    teacher_name VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- COURSE TABLE
CREATE TABLE IF NOT EXISTS Course (
    course_code VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(128) NOT NULL
) ENGINE=InnoDB;

-- DAYSLOT TABLE
CREATE TABLE IF NOT EXISTS DaySlot (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    day_name VARCHAR(16) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CHECK (start_time < end_time)
) ENGINE=InnoDB;

-- TIMETABLE TABLE
CREATE TABLE IF NOT EXISTS Timetable (
    tt_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    slot_id INT NOT NULL,
    room VARCHAR(64),
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id),
    FOREIGN KEY (course_code) REFERENCES Course(course_code),
    FOREIGN KEY (slot_id) REFERENCES DaySlot(slot_id)
) ENGINE=InnoDB;

-- TIMETABLE ↔ TEACHERS (MANY–TO–MANY)
CREATE TABLE IF NOT EXISTS Timetable_Teachers (
    tt_id INT NOT NULL,
    teacher_code VARCHAR(10) NOT NULL,
    FOREIGN KEY (tt_id) REFERENCES Timetable(tt_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_code) REFERENCES Teachers(teacher_code) ON DELETE CASCADE,
    PRIMARY KEY (tt_id, teacher_code)
) ENGINE=InnoDB;

-- LOG TABLE
CREATE TABLE IF NOT EXISTS NotificationLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT,
    message TEXT,
    time_sent DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
