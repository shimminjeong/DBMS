DROP TABLE OLD_CUSTOMER;
DROP TABLE CSS_LOG;

--�α����̺� ����
CREATE TABLE CSS_LOG(
    LOG_DATE VARCHAR2(8) DEFAULT TO_CHAR(SYSDATE,'YYYYMMDD'), -- �α� ��� ���� YYYYMMDD
    LOG_TIME VARCHAR2(6) DEFAULT TO_CHAR(SYSDATE,'HH24MISS'), -- �α� ��� �ð� HH24MISS
    PROGRAM_NAME VARCHAR2(100), -- �߻� ���α׷�
    MESSAGE VARCHAR2(250), -- MESSAGE
    DESCRIPTION VARCHAR2(250) -- ��� ����
);

--�α� ���ν��� ����
CREATE OR REPLACE PROCEDURE 
    WRITE_LOG(A_PROGRAM_NAME IN VARCHAR2,A_MESSAGE IN VARCHAR2,A_DESCRIPTION IN VARCHAR2) AS
    PRAGMA AUTONOMOUS_TRANSACTION; -- Autonomous Ʈ����� ����
--    CSS_LOG���̺� ������ INSERT (LOG_DATE, LOG_TIME�� DEFAULT)
BEGIN
    INSERT INTO CSS_LOG(PROGRAM_NAME,MESSAGE,DESCRIPTION)
    VALUES(A_PROGRAM_NAME,A_MESSAGE,A_DESCRIPTION);
    COMMIT;
--����ó��
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('�α� ���ν������� ���� �߻�: ' || SQLERRM);
        -- ���� �߻��� ROLLBACK
        ROLLBACK;
END WRITE_LOG;
/


--Ż��ȸ�� ���̺� ����(���� CUSTOMER TABLE + DELETE_DATE �÷� �߰�)
CREATE TABLE OLD_CUSTOMER(
    ID           VARCHAR2(20) NOT NULL,
    PWD          VARCHAR2(20) NOT NULL,
    NAME         VARCHAR2(20) NOT NULL,
    ZIPCODE      VARCHAR2(7),
    ADDRESS1     VARCHAR2(100),
    ADDRESS2     VARCHAR2(100),
    MOBILE_NO    VARCHAR2(14),
    PHONE_NO     VARCHAR2(14),
    CREDIT_LIMIT NUMBER(9),
    EMAIL        VARCHAR2(30),
    ACCOUNT_MGR  NUMBER(4),
    BIRTH_DT     DATE,
    ENROLL_DT    DATE,
    GENDER       VARCHAR2(1),
    DELETE_DATE  DATE -- ȸ�� Ż�� ���� �߰�
);


--ȸ�� Ż�� Trigger
CREATE OR REPLACE TRIGGER DELETE_CUST_TRIGGER
--DELETE ���� �����
BEFORE DELETE ON CUSTOMER
--��� �࿡ ���� ����
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION; -- Autonomous Ʈ����� ����
--    ���� ���� OLD_CUSTOMER ���̺� ȸ�� ���� INSERT
BEGIN
    INSERT INTO OLD_CUSTOMER(ID,PWD,NAME,ZIPCODE,ADDRESS1,ADDRESS2,MOBILE_NO,
    PHONE_NO,CREDIT_LIMIT,EMAIL,ACCOUNT_MGR,BIRTH_DT,ENROLL_DT,GENDER, DELETE_DATE)
    VALUES (:OLD.ID, :OLD.PWD, :OLD.NAME, :OLD.ZIPCODE,:OLD.ADDRESS1,:OLD.ADDRESS2,:OLD.MOBILE_NO,
    :OLD.PHONE_NO,:OLD.CREDIT_LIMIT,:OLD.EMAIL,:OLD.ACCOUNT_MGR,:OLD.BIRTH_DT,:OLD.ENROLL_DT,:OLD.GENDER, SYSDATE);
    COMMIT;
--����ó��
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ʈ���ſ��� ���� �߻�: ' || SQLERRM);
        -- ���� �߻��� ROLLBACK
        ROLLBACK;
END;
/



-- CUSTOMER ������ ó�� Package Header
CREATE OR REPLACE PACKAGE CUSTOMER_MNG AS
    -- ȸ�� Ż��
    PROCEDURE DELETE_CUST(P_ID CUSTOMER.ID%TYPE); 
    -- ȸ�� ���
    PROCEDURE INSERT_CUST(P_ID CUSTOMER.ID%TYPE,P_PWD CUSTOMER.PWD%TYPE,P_NAME CUSTOMER.NAME%TYPE);
    --ȸ�� ���� ����
    PROCEDURE UPDATE_CUST(P_ID CUSTOMER.ID%TYPE,P_PWD CUSTOMER.PWD%TYPE,P_NAME CUSTOMER.NAME%TYPE);
END CUSTOMER_MNG;
/

-- CUSTOMER ������ ó�� Package Body
CREATE OR REPLACE PACKAGE BODY CUSTOMER_MNG AS
    --ȸ��Ż�� DELETE�� ID�� ���� CUSTOMER ���̺� �����ϴ��� CURSOR�� ID�� �����ͼ� ó��
    PROCEDURE DELETE_CUST(P_ID CUSTOMER.ID%TYPE) IS
        CURSOR cust_cursor IS
            SELECT * FROM CUSTOMER WHERE ID = P_ID;
        cust_rec CUSTOMER%ROWTYPE;
    BEGIN 
        OPEN cust_cursor;
        FETCH cust_cursor INTO cust_rec;
--        DELETE�� ID�� CUSTOMER���̺� �����ϴ� ��� ���� �۵�
        IF cust_cursor%FOUND THEN
            DELETE FROM CUSTOMER WHERE ID = P_ID;
            WRITE_LOG('ȸ��Ż��','�����۵�','VALUES : [ID]=> '||P_ID);
            COMMIT;
--        DELETE�� ID�� CUSTOMER���̺� �������� �ʴ� ���
        ELSE
            WRITE_LOG('ȸ��Ż�� �� ����','ȸ�� ���� ����','VALUES : [ID]=> '||P_ID);
            -- ���� �߻��� ROLLBACK
            ROLLBACK;
        END IF;
        
        CLOSE cust_cursor;
--    ����ó��
    EXCEPTION
        WHEN OTHERS THEN
            WRITE_LOG('ȸ��Ż�� �� ����',SQLERRM,'VALUES : [ID]=> '||P_ID);
            -- ���� �߻��� ROLLBACK
            ROLLBACK;
    END DELETE_CUST;


    --ȸ�� ��� INSERT�� ID�� ���� CUSTOMER ���̺� �����ϴ��� CURSOR�� ID�� �����ͼ� ó��
    PROCEDURE INSERT_CUST(P_ID CUSTOMER.ID%TYPE, P_PWD CUSTOMER.PWD%TYPE, P_NAME CUSTOMER.NAME%TYPE) IS
    CURSOR cust_cursor IS
        SELECT * FROM CUSTOMER WHERE ID = P_ID;
    cust_rec CUSTOMER%ROWTYPE;
    BEGIN
        OPEN cust_cursor;
        FETCH cust_cursor INTO cust_rec;
--        INSERT�� ID�� CUSTOMER���̺� �����ϴ� ���
        IF cust_cursor%FOUND THEN
            WRITE_LOG('ȸ����� �� ����','�̹� �����ϴ� ID�Դϴ�.','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            ROLLBACK;
--        INSERT�� ID�� CUSTOMER���̺� �������� �ʴ� ��� ���� ���
        ELSE
            BEGIN
                INSERT INTO CUSTOMER (ID, PWD, NAME) VALUES (P_ID, P_PWD, P_NAME);
                WRITE_LOG('ȸ�����','�����۵�','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
                COMMIT;
            END;
        END IF;
    
        CLOSE cust_cursor;
--    ����ó��
    EXCEPTION
        WHEN OTHERS THEN
            WRITE_LOG('ȸ����� �� ����', SQLERRM, 'VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            -- ���� �߻��� ROLLBACK
            ROLLBACK;
    END INSERT_CUST;

    

    --ȸ�� ���� ���� UPDATE�� ID�� ���� CUSTOMER ���̺� �����ϴ��� CURSOR�� ID�� �����ͼ� ó��
    PROCEDURE UPDATE_CUST(P_ID CUSTOMER.ID%TYPE, P_PWD CUSTOMER.PWD%TYPE, P_NAME CUSTOMER.NAME%TYPE) IS
    CURSOR cust_cursor IS
        SELECT * FROM CUSTOMER WHERE ID = P_ID;
    cust_rec CUSTOMER%ROWTYPE;
    BEGIN
        OPEN cust_cursor;
        FETCH cust_cursor INTO cust_rec;
--        UPDATE�� ID�� CUSTOMER ���̺� �����ϴ� ���
        IF cust_cursor%FOUND THEN
            UPDATE CUSTOMER SET PWD = P_PWD, NAME = P_NAME WHERE ID = P_ID;
            WRITE_LOG('ȸ����������','�����۵�','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            COMMIT;
--        UPDATE�� ID�� CUSTOMER ���̺� �������� �ʴ� ��� ���� ���
        ELSE
            WRITE_LOG('ȸ���������� �� ����','ȸ�� ���� ����','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            ROLLBACK;
        END IF;
    
        CLOSE cust_cursor;
--    ����ó��
    EXCEPTION
        WHEN OTHERS THEN
            WRITE_LOG('ȸ���������� �� ����', SQLERRM, 'VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            -- ���� �߻��� ROLLBACK
            ROLLBACK;
    END UPDATE_CUST;

END CUSTOMER_MNG;
/


------------------- TEST CODE

-- ȸ�� ����
BEGIN
    CUSTOMER_MNG.INSERT_CUST('scott', 'tiger', 'minjeong');
    CUSTOMER_MNG.INSERT_CUST('scott2', 'tiger', 'youngjun');
    CUSTOMER_MNG.INSERT_CUST('scott', 'tiger', 'sungyeon'); -- �̹� �����ϴ� ID �϶�
END;
/

-- ȸ�� ���� ����
BEGIN
    CUSTOMER_MNG.UPDATE_CUST('scott','GOOD','SIMMINJEONG');
    CUSTOMER_MNG.UPDATE_CUST('MJ','GOOD','MJSIM');  --ȸ�� ������ ���� ��
END;
/

-- ȸ�� Ż��
BEGIN
    CUSTOMER_MNG.DELETE_CUST('scott');
    CUSTOMER_MNG.DELETE_CUST('MJ'); --ȸ�� ������ ���� ��
END;
/

SELECT * FROM CUSTOMER WHERE ID LIKE 'scott%';

SELECT * FROM OLD_CUSTOMER;

SELECT * FROM CSS_LOG;
