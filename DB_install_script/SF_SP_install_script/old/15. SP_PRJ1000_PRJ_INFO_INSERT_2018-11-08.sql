/*------------------------------------------------------------------------------
-- ��ü �̸�: SP_PRJ1000_PRJ_INFO_INSERT
-- ���� ��¥: 2018-07-02 ���� 1:44:57
-- ������ ���� ��¥: 2018-10-18 ���� 6:53:57
-- ����: VALID
------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE SP_PRJ1000_PRJ_INFO_INSERT
(
		I_PRJ_GRP_CHK	IN VARCHAR2
	,	I_PRJ_GRP_ID	IN VARCHAR2
   	,	I_LIC_GRP_ID	IN	VARCHAR2
	,	I_PRJ_NM		IN	VARCHAR2
    ,	I_START_DT		IN	VARCHAR2
	,	I_END_DT		IN	VARCHAR2

	,	I_ORD			IN	VARCHAR2
	,	I_PRJ_DESC		IN	VARCHAR2
	,	I_USE_CD		IN	VARCHAR2
    ,	I_PRJ_TYPE		IN  VARCHAR2
    , I_PRJ_ACRM		IN  VARCHAR2
	,	I_REG_USR_ID	IN	VARCHAR2
	,	I_REG_USR_IP	IN	VARCHAR2

	,	I_MODIFY_USR_ID	IN	VARCHAR2
	,	I_MODIFY_USR_IP	IN	VARCHAR2
    ,	O_PRJ_ID		OUT	VARCHAR2
    ,	O_CODE			OUT	VARCHAR2
    ,	O_MSG			OUT	VARCHAR2
)
/*******************************************************************************************************
 PROCEDURE ��      :	SP_PRJ1000_PRJ_INFO_INSERT
 PROCEDURE ����    : PRJ1000�� ������Ʈ ������ ������Ʈ ������ ���ÿ� �ʿ��� ���� �������� �ڵ� ����
 					- ������Ʈ �����ڸ� ������ ������Ʈ�� AUT2018082100001 �������� �ڵ� ������.
 					- 1. ADM1100 - ���ѱ׷�����(ROOTSYSTEM_PRJ �����ؼ� PRJ_ID�� ���θ��� PRJ_ID��)
					- 2. ADM1300 - ����������Ʈ�� ����� ����(������Ʈ ������ ID�� AUT2018082100001�� �����. 1 ROW)
					- 3. ADM1200 - �޴��� ���ٱ���(�ڽ��� LIC_GRP_ID, ROOTSYSTEM_PRJ �����ؼ� ���θ��� LIC_GRP_ID, PRJ_ID�� ����)
                    - 4. REQ4000 - �䱸���� �з������� ��Ʈ �䱸���� �з� ����(������Ʈ������ ����)
                    - 5. PRJ1100 - ������Ʈ �۾��帧 ���� ����(ROOTSYSTEM_PRJ �����ؼ� PRJ_ID�� ���θ��� PRJ_ID��)
                    - 6. COMTNCOPSEQ - ���� ID ������ ���� �ʱ� �� �ҷ�����
					- 7. PRJ3000 - ������Ʈ ǥ��/ǰ�� ���⹰ ���� ����(ROOTSYSTEM_PRJ �����ؼ� PRJ_ID�� ���θ��� PRJ_ID��, ATCH_FILE_ID = 6�� �� ����+1��)
                    - 8. COMTNCOPSEQ - �߰��� �� ��ŭ �� ����
                    - 9. COMTNFILE - 6�� �ʱ� �� ���� 8�� ������ ������ ATCH_FILE_ID �߰�
                    - 10. COMTNCOPSEQ - �ɼ� ID ������ ���� �ʱ� �� �ҷ����� ( �÷� �� : OPTINFO )
          - 11. PRJ6000 - ������Ʈ �ɼ� ���� ���� (ROOTSYSTEM_PRJ �����ؼ� PRJ_ID�� ���θ��� PRJ_ID��, OPT_ID = 11���� ���� + 1��)
          					- 12.  COMTNCOPSEQ - �߰��� �� ��ŭ �� ����
                    - 13. COMTNFILE - 10�� �ʱ� �� ���� 11�� ������ ������ OPT_ID �ϳ� �߰�

 ���ȭ��          :
 �ۼ���/�ۼ���     : ������ / 2016-01-26
 INPUT             :	I_PRJ_GRP_CHK = 'Y' OR 'N' ������Ʈ ���� ������ ���, ������Ʈ �׷������� ���� ������.
 OUTPUT            : O_CODE		   	            	�����ڵ�		(1: ���� , -1: ����)
                     O_MSG		                	���� �޼���
 �������̺�        :	ADM1200, ADM1100, ADM1300
 ������/������/����: 1.������ / 2016-07-11 / ������Ʈ ǥ��-ǰ�� ���⹰ ���� ���� �߰�
                     2.������ / 2016-12-20 / ������Ʈ �۾��帧 ���� ���� ����
                     3.���ֿ� / 2017-04-16 / ���⹰ ���� �� atch_file_id ���� ����
                     4.������ / 2017-06-30 / ������Ʈ �ɼ� ���� ���� �߰�
                     5.���ֿ� / 2018-08-16 / ������Ʈ �׷� ���� �߰�
										 6.����� / 2018-09-13 / ���⹰ DOC_ED_DTM �÷� �߰�
                     7.���뿵 / 2018-09-27 / ������Ʈ Ÿ���� ���� �޴����� ���� ��
                     8.����� / 2018-10-18 / ������Ʈ ��� �߰�

*******************************************************************************************************/

IS

		V_NEW_PRJ_ID 		VARCHAR2(16);
		V_NEW_REQ_CLS_ID	VARCHAR2(16);

    V_BEGIN_ATCH_ID		NUMBER;
    V_END_ATCH_ID		NUMBER;

BEGIN

	--OUT ���� �ʱ�ȭ
    O_CODE := '-1';
    O_MSG := '�ʱ�ȭ';

    /**
    *	���� �߱��� PRJ_ID �� ��� ����
    */
    BEGIN

		--NEW_PRJ_ID ������
    	SELECT	NVL(
                        SUBSTR(NEW_PRJ_ID, 1, 11) || LPAD( (TO_NUMBER(SUBSTR(NEW_PRJ_ID, 12, 5)) + 1) , 5, '0')
                    ,	'PRJ' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '00001'
                ) AS NEW_PRJ_ID
        INTO	V_NEW_PRJ_ID
        FROM	(
                    SELECT	MAX(PRJ_ID)  AS NEW_PRJ_ID
                    FROM	PRJ1000 A
                    WHERE	1=1
                    AND		A.PRJ_ID LIKE 'PRJ' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '%'
                )
        ;

    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
          O_CODE := '-1';
          O_MSG := '������ PRJ_ID�� ����� �����ϴ�.';
          ROLLBACK;
          RETURN;
    END;


	--������Ʈ ���� ���� ����
	BEGIN
    	-- ������Ʈ ���� ����
    	INSERT INTO PRJ1000 A
        (
                PRJ_ID		,	PRJ_GRP_ID	,	LIC_GRP_ID		,	PRJ_NM			,	START_DT		,	END_DT
            ,	ORD			,	PRJ_DESC	,	USE_CD			,	PRJ_TYPE	, PRJ_ACRM	,	PRJ_GRP_CD 		,	REG_DTM
            ,	REG_USR_ID  ,	REG_USR_IP	,	MODIFY_DTM		,	MODIFY_USR_ID	,	MODIFY_USR_IP
        )VALUES(
                V_NEW_PRJ_ID,	I_PRJ_GRP_ID,	I_LIC_GRP_ID	,	I_PRJ_NM    	,	REPLACE(I_START_DT, '-', '')		,	REPLACE(I_END_DT, '-', '')
            ,	I_ORD		,	I_PRJ_DESC	,	I_USE_CD		,	I_PRJ_TYPE	,I_PRJ_ACRM 		,	'02'			,	SYSDATE
            ,	I_REG_USR_ID,	I_REG_USR_IP,	SYSDATE			,	I_MODIFY_USR_ID ,	I_MODIFY_USR_ID
        );

        IF SQL%FOUND = FALSE THEN
        	O_CODE := '-1';
            O_MSG := '����� ������Ʈ ������ �����ϴ�.';
            ROLLBACK;
        	RETURN;
        END IF;

    EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;


	--���ѱ׷� ���� ���� ����
	BEGIN
    	-- ���ѱ׷� ���� ����
    	INSERT INTO ADM1100 A
        (
            LIC_GRP_ID,	PRJ_ID,		AUTH_GRP_ID,	AUTH_GRP_NM,	AUTH_GRP_DESC,		CREATE_DT,
            USE_CD,		ORD,	USR_TYP,		REG_DTM,		REG_USR_ID,			REG_USR_IP,
            MODIFY_DTM,	MODIFY_USR_ID,	MODIFY_USR_IP
        )
        SELECT	I_LIC_GRP_ID
        	,	V_NEW_PRJ_ID
            ,	B.AUTH_GRP_ID
            ,	B.AUTH_GRP_NM
            ,	B.AUTH_GRP_DESC
            ,	B.CREATE_DT
            ,	B.USE_CD
            ,	B.ORD
            , B.USR_TYP
            ,	SYSDATE
            ,	I_REG_USR_ID
            ,	I_REG_USR_IP
            ,	SYSDATE
            ,	I_MODIFY_USR_ID
            ,	I_MODIFY_USR_IP
        FROM	ADM1100 B
        WHERE	1=1
        AND  	B.LIC_GRP_ID = I_LIC_GRP_ID
        AND		B.PRJ_ID = 'ROOTSYSTEM_PRJ'
        ;

        IF SQL%FOUND = FALSE THEN
        	O_CODE := '-1';
            O_MSG := '����� ���ѱ׷� ������ �����ϴ�.';
            ROLLBACK;
        	RETURN;
        END IF;

    EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;

	-- ����������Ʈ�� ����� ���� ����
	BEGIN
    	-- ����������Ʈ�� ����� ���� ����
    	INSERT INTO ADM1300 A
        (
            PRJ_ID, 		AUTH_GRP_ID,	USR_ID,
            REG_DTM,		REG_USR_ID,		REG_USR_IP,
            MODIFY_DTM,		MODIFY_USR_ID,	MODIFY_USR_IP
        )
        VALUES
        (
            V_NEW_PRJ_ID,	'AUT0000000000001',				I_REG_USR_ID,
            SYSDATE,		I_REG_USR_ID,		I_REG_USR_IP,
            SYSDATE,		I_MODIFY_USR_ID,	I_MODIFY_USR_IP
        );

        IF SQL%FOUND = FALSE THEN
        	O_CODE := '-1';
            O_MSG := '����� ����������Ʈ�� ����� ������ �����ϴ�.';
            ROLLBACK;
        	RETURN;
        END IF;

    EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;

	-- �޴��� ���ٱ��� ���� ����
	BEGIN
    	-- �޴��� ���ٱ��� ���� ����
    	INSERT INTO ADM1200 A
        (
            LIC_GRP_ID,		PRJ_ID,			AUTH_GRP_ID,	MENU_ID,	MAIN_YN,	ACCESS_YN,
            SELECT_YN,		REG_YN,			MODIFY_YN,		DEL_YN,			EXCEL_YN,
            PRINT_YN,		USE_CD,	REG_DTM,		REG_USR_ID,		REG_USR_IP,
            MODIFY_DTM,		MODIFY_USR_ID,	MODIFY_USR_IP
        )
        SELECT	I_LIC_GRP_ID,	V_NEW_PRJ_ID,	A.AUTH_GRP_ID,	A.MENU_ID, A.MAIN_YN,		A.ACCESS_YN,
                A.SELECT_YN,		A.REG_YN,			A.MODIFY_YN,		A.DEL_YN,			A.EXCEL_YN,
                A.PRINT_YN,		A.USE_CD,	SYSDATE,		I_REG_USR_ID,	I_REG_USR_IP,
                SYSDATE,		I_MODIFY_USR_ID,I_MODIFY_USR_IP
        FROM	ADM1200 A  , ADM1000 B
        WHERE	1=1
        AND		A.LIC_GRP_ID = I_LIC_GRP_ID
        AND		A.PRJ_ID = 'ROOTSYSTEM_PRJ'
        AND  A.LIC_GRP_ID = B.LIC_GRP_ID
        AND  A.MENU_ID = B.MENU_ID
				AND  ( B.PRJ_TYPE = I_PRJ_TYPE  OR    B.PRJ_TYPE = '03' ) -- 03 ����
        ;

        IF SQL%FOUND = FALSE THEN
        	O_CODE := '-1';
            O_MSG := '�޴��� ���ٱ��� ������ �����ϴ�.';
            ROLLBACK;
        	RETURN;
        END IF;

    EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;

	-- �䱸���� �з� ���� ��Ʈ �з� ����
	BEGIN
    	-- �ű� �䱸���� �з� ID �߱�
        SELECT	NVL(
                        SUBSTR(NEW_REQ_CLS_ID, 1, 11) || LPAD( (TO_NUMBER(SUBSTR(NEW_REQ_CLS_ID, 12, 5)) + 1) , 5, '0')
                    ,	'CLS' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '00001'
                ) AS NEW_REQ_CLS_ID
        INTO	V_NEW_REQ_CLS_ID
        FROM	(
                    SELECT	MAX(REQ_CLS_ID)  AS NEW_REQ_CLS_ID
                    FROM	REQ4000 A
                    WHERE	1=1
                    AND		A.PRJ_ID = V_NEW_PRJ_ID
                    AND		A.REQ_CLS_ID LIKE 'CLS' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '%'
                )
        ;


        INSERT INTO REQ4000 A
        (
            PRJ_ID,			REQ_CLS_ID,			UPPER_REQ_CLS_ID,	REQ_CLS_NM,
            LVL,			ORD,				USE_CD,				REG_DTM,
            REG_USR_ID,		REG_USR_IP,			MODIFY_DTM,			MODIFY_USR_ID,
            MODIFY_USR_IP
        )
        VALUES
        (
        	V_NEW_PRJ_ID,	V_NEW_REQ_CLS_ID,	NULL,				I_PRJ_NM,
            0,				1,					'01',				SYSDATE,
            I_REG_USR_ID,	I_REG_USR_IP,		SYSDATE,			I_MODIFY_USR_ID,
            I_MODIFY_USR_IP
        )

        ;

        IF SQL%FOUND = FALSE THEN
        	O_CODE := '-1';
            O_MSG := '�޴��� ���ٱ��� ������ �����ϴ�.';
            ROLLBACK;
        	RETURN;
        END IF;

    EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;


	-- �ʱⰪ, ������ �� ����
    BEGIN
    	SELECT NEXT_ID INTO V_BEGIN_ATCH_ID
        FROM COMTNCOPSEQ A
        WHERE A.TABLE_NAME = 'COMTNFILE';

        SELECT COUNT(0) INTO V_END_ATCH_ID
        FROM	PRJ3000 A
        WHERE	A.PRJ_ID = 'ROOTSYSTEM_PRJ'
        ;

        --��� ���̵�� ���� ���̵�
        V_END_ATCH_ID := (V_BEGIN_ATCH_ID+(V_END_ATCH_ID*2));

    EXCEPTION
    WHEN OTHERS THEN
        O_CODE := '-1';
        O_MSG := SQLCODE || ' : ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
        ROLLBACK;
        RETURN;
    END;

		-- ������Ʈ ���⹰ ����
	BEGIN

        INSERT INTO PRJ3000 A
        (
            PRJ_ID,							  DOC_ID,						  UPPER_DOC_ID,		 		DOC_NM,				DOC_DESC,
            DOC_FORM_FILE_ID,			DOC_FORM_FILE_SN,		DOC_ATCH_FILE_ID,		DOC_FILE_SN,	LVL,
            ORD,		  		  		  DOC_ED_DTM,	  		  USE_CD,  			  		REG_DTM,			REG_USR_ID,
            REG_USR_IP,				 		MODIFY_DTM,			 		MODIFY_USR_ID,		  MODIFY_USR_IP
        )
        SELECT
        		V_NEW_PRJ_ID,			DOC_ID,			  	UPPER_DOC_ID,			DOC_NM,		DOC_DESC,
            'FILE_' || LPAD((V_BEGIN_ATCH_ID+(ROWNUM-1)+ROWNUM),15, '0') AS DOC_FORM_FILE_ID,
            DOC_FORM_FILE_SN,
            'FILE_' || LPAD((V_BEGIN_ATCH_ID+(ROWNUM*2)),15, '0') AS DOC_ATCH_FILE_ID,
            DOC_FILE_SN,	LVL,
            ORD,				  		DOC_ED_DTM, 		USE_CD,		  			SYSDATE,	I_REG_USR_ID,
            I_REG_USR_IP,			SYSDATE,			  I_MODIFY_USR_ID,	I_MODIFY_USR_IP
        FROM	PRJ3000 A
        WHERE	1=1
        AND		A.PRJ_ID = 'ROOTSYSTEM_PRJ'
	    	;

        IF SQL%FOUND = FALSE THEN
        	O_CODE := '-1';
            O_MSG := '������ ������Ʈ ǥ��/ǰ�� ���⹰ ������ �����ϴ�.';
            ROLLBACK;
        	RETURN;
        END IF;

    EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;
	-- COMTNCOPSEQ �� ����
    BEGIN
    	UPDATE COMTNCOPSEQ
        SET NEXT_ID = (V_END_ATCH_ID+1)
        WHERE TABLE_NAME = 'COMTNFILE';

    EXCEPTION
        WHEN OTHERS THEN
            O_CODE := '-1';
              O_MSG := SQLCODE || ' : ' || SQLERRM;
              DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
              ROLLBACK;
            RETURN;
      END;

    --COMTNFILE ���̺��� ���ڵ� �߰�
    BEGIN
    FOR LOOP_INDEX IN V_BEGIN_ATCH_ID .. V_END_ATCH_ID
    	LOOP
    	INSERT INTO COMTNFILE(ATCH_FILE_ID,CREAT_DT,USE_AT) VALUES( 'FILE_' || LPAD(LOOP_INDEX,15, '0'), SYSDATE, 'Y');
    END LOOP;
	EXCEPTION
    	WHEN OTHERS THEN
        	O_CODE := '-1';
            O_MSG := SQLCODE || ' : ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
            ROLLBACK;
        	RETURN;
    END;



	O_PRJ_ID := V_NEW_PRJ_ID;
    O_CODE := '1';
    O_MSG := '���� ����';

EXCEPTION
	WHEN OTHERS THEN
    	O_CODE 	:= '-1';
      	O_MSG 	:= SQLCODE || ' : ' || SQLERRM;
    	DBMS_OUTPUT.PUT_LINE('����ġ ���� ���� �߻�' || CHR(13) || SQLCODE || ' : ' || SQLERRM);
    	ROLLBACK;
      RETURN;
END;

