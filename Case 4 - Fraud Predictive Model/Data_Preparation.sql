--→ CRM Source & Channel → CRM Channel
--→ SLAs: between Install App and eKYC, between eKYC and Account Creation, between Account Creation and First Transaction
--→ Transactional behaviours: Transaction No, First Transaction Range
--→ eKYC data: 
	--+ Nationality: Is it a foreigner or not?
	--+ DOB: Age Group
	--+ Address: Region
	--+ Scores (Sanity, Tampering, Liveness, Matching)

WITH N AS
(
	SELECT F.[CRM_Channel]
		  ,F.[Customer_ID]
		  ,C.[Install_App_DT]
		  ,F.[eKYC_DT]
		  ,[Account_Created_DT]
		  ,[FIRST_TRANS]
		  ,[TRANS_CNT]
		  ,IIF(T.[Transaction_Range] = 'LOW', '1 - LOW'
				,IIF(T.[Transaction_Range] = 'MEDIUM LOW','2 - MEDIUM LOW'
						,IIF(T.[Transaction_Range] = 'MEDIUM HIGH','3 - MEDIUM HIGH'
							,IIF(T.[Transaction_Range] = 'HIGH','4 - HIGH', '0 - NO TRANS')))) [First_Transaction_Range]
		  ,E.[OCR_Nationality]
		  ,DATEDIFF(YEAR, E.[OCR_Dob], SYSDATETIME()) [AGE]
		  ,E.[SCORE_Liveness]
		  ,E.[SCORE_Matching]
		  ,E.[SCORE_Sanity]
		  ,E.[SCORE_Tampering]
		  ,[FRAUD_TYPE]
	  FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES] F
	  --LEFT JOIN [DWH].[dbo].[DIM_CRM] C ON C.[App_ID] =  F.[App_ID]
	  LEFT JOIN  [DWH].[dbo].[DIM_EKYC] E ON E.[Customer_ID] = F.[Customer_ID]
	  LEFT JOIN [DWH].[dbo].[DIM_CRM] C ON C.eKYC_ID = E.eKYC_ID
	  LEFT JOIN  (SELECT [Customer_ID], [Transaction_Range]
						, ROW_NUMBER() OVER (PARTITION BY [Customer_ID] ORDER BY [Transaction_DT]) ROW_
				   FROM [DWH].[dbo].[DIM_TRANSACTIONS]) T ON ROW_ = 1 AND T.[Customer_ID] = F.[Customer_ID]
	  LEFT JOIN [VIETNAM].[dbo].[Region] R ON R.[Province_Name] = E.[OCR_Address]
 )

SELECT  [Customer_ID]
		,[CRM_Channel]
		, ISNULL(DATEDIFF(DAY,[Install_App_DT], [eKYC_DT]),1000) DT_TO_EKYC
		, ISNULL(DATEDIFF(DAY,[eKYC_DT], [Account_Created_DT]),1000) DT_TO_CREATE_ACC
		, ISNULL(DATEDIFF(DAY,[Account_Created_DT], [FIRST_TRANS]),1000) DT_TO_FT
		, ISNULL([TRANS_CNT],0) [TRANS_CNT]
		, [First_Transaction_Range]
		, IIF([OCR_Nationality]<>'VIETNAMESE','FOREIGNER',[OCR_Nationality]) [Nationality]
		, IIF(AGE < 22, '21-', IIF(AGE<26, '22-25', IIF(AGE<30, '26-29', IIF(AGE<34, '30-33','34+')))) AGE_GROUP_range
		, [SCORE_Liveness]
		, [SCORE_Matching]
		, [SCORE_Sanity]
		, [SCORE_Tampering]
		, IIF([FRAUD_TYPE]<>'CHECKED' OR  [FRAUD_TYPE] IS NULL, 'NORMAL', 'FRAUD') [LABEL]
FROM N

