CREATE OR REPLACE PROCEDURE add_class(
    p_day VARCHAR2,
    p_time VARCHAR2,
    p_subject VARCHAR2,
    p_room VARCHAR2
) AS
BEGIN
    INSERT INTO classes VALUES (p_day, p_time, p_subject, p_room);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Slot already booked!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error adding class');
END;

