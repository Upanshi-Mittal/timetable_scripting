CREATE TABLE classes (
    day VARCHAR2(10),
    time VARCHAR2(10),
    subject VARCHAR2(50),
    room VARCHAR2(10),
    CONSTRAINT pk_class PRIMARY KEY(day, time)
);

CREATE TABLE class_log (
    log_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    action VARCHAR2(30),
    day VARCHAR2(10),
    time VARCHAR2(10)
);

