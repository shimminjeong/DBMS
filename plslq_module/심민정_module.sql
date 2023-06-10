DROP TABLE OLD_CUSTOMER;
DROP TABLE CSS_LOG;

--로그테이블 생성
CREATE TABLE CSS_LOG(
    LOG_DATE VARCHAR2(8) DEFAULT TO_CHAR(SYSDATE,'YYYYMMDD'), -- 로그 기록 일자 YYYYMMDD
    LOG_TIME VARCHAR2(6) DEFAULT TO_CHAR(SYSDATE,'HH24MISS'), -- 로그 기록 시간 HH24MISS
    PROGRAM_NAME VARCHAR2(100), -- 발생 프로그램
    MESSAGE VARCHAR2(250), -- MESSAGE
    DESCRIPTION VARCHAR2(250) -- 비고 사항
);

--로그 프로시저 생성
CREATE OR REPLACE PROCEDURE 
    WRITE_LOG(A_PROGRAM_NAME IN VARCHAR2,A_MESSAGE IN VARCHAR2,A_DESCRIPTION IN VARCHAR2) AS
    PRAGMA AUTONOMOUS_TRANSACTION; -- Autonomous 트랜잭션 적용
--    CSS_LOG테이블에 데이터 INSERT (LOG_DATE, LOG_TIME은 DEFAULT)
BEGIN
    INSERT INTO CSS_LOG(PROGRAM_NAME,MESSAGE,DESCRIPTION)
    VALUES(A_PROGRAM_NAME,A_MESSAGE,A_DESCRIPTION);
    COMMIT;
--예외처리
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('로그 프로시저에서 오류 발생: ' || SQLERRM);
        -- 예외 발생시 ROLLBACK
        ROLLBACK;
END WRITE_LOG;
/


--탈퇴회원 테이블 생성(기존 CUSTOMER TABLE + DELETE_DATE 컬럼 추가)
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
    DELETE_DATE  DATE -- 회원 탈퇴 일자 추가
);


--회원 탈퇴 Trigger
CREATE OR REPLACE TRIGGER DELETE_CUST_TRIGGER
--DELETE 전에 실행됨
BEFORE DELETE ON CUSTOMER
--모든 행에 각각 적용
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION; -- Autonomous 트랜잭션 적용
--    삭제 전에 OLD_CUSTOMER 테이블에 회원 정보 INSERT
BEGIN
    INSERT INTO OLD_CUSTOMER(ID,PWD,NAME,ZIPCODE,ADDRESS1,ADDRESS2,MOBILE_NO,
    PHONE_NO,CREDIT_LIMIT,EMAIL,ACCOUNT_MGR,BIRTH_DT,ENROLL_DT,GENDER, DELETE_DATE)
    VALUES (:OLD.ID, :OLD.PWD, :OLD.NAME, :OLD.ZIPCODE,:OLD.ADDRESS1,:OLD.ADDRESS2,:OLD.MOBILE_NO,
    :OLD.PHONE_NO,:OLD.CREDIT_LIMIT,:OLD.EMAIL,:OLD.ACCOUNT_MGR,:OLD.BIRTH_DT,:OLD.ENROLL_DT,:OLD.GENDER, SYSDATE);
    COMMIT;
--예외처리
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('트리거에서 오류 발생: ' || SQLERRM);
        -- 예외 발생시 ROLLBACK
        ROLLBACK;
END;
/



-- CUSTOMER 데이터 처리 Package Header
CREATE OR REPLACE PACKAGE CUSTOMER_MNG AS
    -- 회원 탈퇴
    PROCEDURE DELETE_CUST(P_ID CUSTOMER.ID%TYPE); 
    -- 회원 등록
    PROCEDURE INSERT_CUST(P_ID CUSTOMER.ID%TYPE,P_PWD CUSTOMER.PWD%TYPE,P_NAME CUSTOMER.NAME%TYPE);
    --회원 정보 변경
    PROCEDURE UPDATE_CUST(P_ID CUSTOMER.ID%TYPE,P_PWD CUSTOMER.PWD%TYPE,P_NAME CUSTOMER.NAME%TYPE);
END CUSTOMER_MNG;
/

-- CUSTOMER 데이터 처리 Package Body
CREATE OR REPLACE PACKAGE BODY CUSTOMER_MNG AS
    --회원탈퇴 DELETE할 ID가 현재 CUSTOMER 테이블에 존재하는지 CURSOR로 ID를 가져와서 처리
    PROCEDURE DELETE_CUST(P_ID CUSTOMER.ID%TYPE) IS
        CURSOR cust_cursor IS
            SELECT * FROM CUSTOMER WHERE ID = P_ID;
        cust_rec CUSTOMER%ROWTYPE;
    BEGIN 
        OPEN cust_cursor;
        FETCH cust_cursor INTO cust_rec;
--        DELETE할 ID가 CUSTOMER테이블에 존재하는 경우 정상 작동
        IF cust_cursor%FOUND THEN
            DELETE FROM CUSTOMER WHERE ID = P_ID;
            WRITE_LOG('회원탈퇴','정상작동','VALUES : [ID]=> '||P_ID);
            COMMIT;
--        DELETE할 ID가 CUSTOMER테이블에 존재하지 않는 경우
        ELSE
            WRITE_LOG('회원탈퇴 중 오류','회원 정보 없음','VALUES : [ID]=> '||P_ID);
            -- 오류 발생시 ROLLBACK
            ROLLBACK;
        END IF;
        
        CLOSE cust_cursor;
--    예외처리
    EXCEPTION
        WHEN OTHERS THEN
            WRITE_LOG('회원탈퇴 중 오류',SQLERRM,'VALUES : [ID]=> '||P_ID);
            -- 예외 발생시 ROLLBACK
            ROLLBACK;
    END DELETE_CUST;


    --회원 등록 INSERT할 ID가 현재 CUSTOMER 테이블에 존재하는지 CURSOR로 ID를 가져와서 처리
    PROCEDURE INSERT_CUST(P_ID CUSTOMER.ID%TYPE, P_PWD CUSTOMER.PWD%TYPE, P_NAME CUSTOMER.NAME%TYPE) IS
    CURSOR cust_cursor IS
        SELECT * FROM CUSTOMER WHERE ID = P_ID;
    cust_rec CUSTOMER%ROWTYPE;
    BEGIN
        OPEN cust_cursor;
        FETCH cust_cursor INTO cust_rec;
--        INSERT할 ID가 CUSTOMER테이블에 존재하는 경우
        IF cust_cursor%FOUND THEN
            WRITE_LOG('회원등록 중 오류','이미 존재하는 ID입니다.','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            ROLLBACK;
--        INSERT할 ID가 CUSTOMER테이블에 존재하지 않는 경우 정상 등록
        ELSE
            BEGIN
                INSERT INTO CUSTOMER (ID, PWD, NAME) VALUES (P_ID, P_PWD, P_NAME);
                WRITE_LOG('회원등록','정상작동','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
                COMMIT;
            END;
        END IF;
    
        CLOSE cust_cursor;
--    예외처리
    EXCEPTION
        WHEN OTHERS THEN
            WRITE_LOG('회원등록 중 오류', SQLERRM, 'VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            -- 예외 발생시 ROLLBACK
            ROLLBACK;
    END INSERT_CUST;

    

    --회원 정보 변경 UPDATE할 ID가 현재 CUSTOMER 테이블에 존재하는지 CURSOR로 ID를 가져와서 처리
    PROCEDURE UPDATE_CUST(P_ID CUSTOMER.ID%TYPE, P_PWD CUSTOMER.PWD%TYPE, P_NAME CUSTOMER.NAME%TYPE) IS
    CURSOR cust_cursor IS
        SELECT * FROM CUSTOMER WHERE ID = P_ID;
    cust_rec CUSTOMER%ROWTYPE;
    BEGIN
        OPEN cust_cursor;
        FETCH cust_cursor INTO cust_rec;
--        UPDATE할 ID가 CUSTOMER 테이블에 존재하는 경우
        IF cust_cursor%FOUND THEN
            UPDATE CUSTOMER SET PWD = P_PWD, NAME = P_NAME WHERE ID = P_ID;
            WRITE_LOG('회원정보변경','정상작동','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            COMMIT;
--        UPDATE할 ID가 CUSTOMER 테이블에 존재하지 않는 경우 정상 등록
        ELSE
            WRITE_LOG('회원정보변경 중 오류','회원 정보 없음','VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            ROLLBACK;
        END IF;
    
        CLOSE cust_cursor;
--    예외처리
    EXCEPTION
        WHEN OTHERS THEN
            WRITE_LOG('회원정보변경 중 오류', SQLERRM, 'VALUES : [ID]=>'||P_ID ||'[PWD]=>'||P_PWD||'[NAME]=>'||P_NAME);
            -- 예외 발생시 ROLLBACK
            ROLLBACK;
    END UPDATE_CUST;

END CUSTOMER_MNG;
/


------------------- TEST CODE

-- 회원 가입
BEGIN
    CUSTOMER_MNG.INSERT_CUST('scott', 'tiger', 'minjeong');
    CUSTOMER_MNG.INSERT_CUST('scott2', 'tiger', 'youngjun');
    CUSTOMER_MNG.INSERT_CUST('scott', 'tiger', 'sungyeon'); -- 이미 존재하는 ID 일때
END;
/

-- 회원 정보 변경
BEGIN
    CUSTOMER_MNG.UPDATE_CUST('scott','GOOD','SIMMINJEONG');
    CUSTOMER_MNG.UPDATE_CUST('MJ','GOOD','MJSIM');  --회원 정보가 없을 때
END;
/

-- 회원 탈퇴
BEGIN
    CUSTOMER_MNG.DELETE_CUST('scott');
    CUSTOMER_MNG.DELETE_CUST('MJ'); --회원 정보가 없을 때
END;
/

SELECT * FROM CUSTOMER WHERE ID LIKE 'scott%';

SELECT * FROM OLD_CUSTOMER;

SELECT * FROM CSS_LOG;
