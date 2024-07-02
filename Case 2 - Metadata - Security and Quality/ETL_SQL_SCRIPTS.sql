-- [dbo].[STAGING_eKYC_Information]

SELECT [eKYC_ID]
      ,[eKYC_DT]
      ,JSON_VALUE([OCR_INFO],'$.name') [OCR_Name]
	  ,JSON_VALUE([OCR_INFO],'$.dob') [OCR_Dob]
	  ,JSON_VALUE([OCR_INFO],'$.gender') [OCR_Gender]
	  ,JSON_VALUE([OCR_INFO],'$.nationality') [OCR_Nationality]
	  ,JSON_VALUE([OCR_INFO],'$.address') [OCR_Address]
	  ,JSON_VALUE([INPUT_INFO],'$.name') [INPUT_Name]
	  ,JSON_VALUE([INPUT_INFO],'$.dob') [INPUT_Dob]
	  ,JSON_VALUE([INPUT_INFO],'$.gender') [INPUT_Gender]
	  ,JSON_VALUE([INPUT_INFO],'$.address') [INPUT_Address]
	  ,JSON_VALUE([INPUT_INFO],'$.nationality') [INPUT_Nationality]
      ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Sanity]
	  ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Tampering]
	  ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Liveness]
	  ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Matching]
      ,[CUSTOMER_ID]
FROM [ONBOARDING].[dbo].[ONBOARDING_Data]


-- [dbo].[STAGING_Digital_Account]

SELECT  [CREATED_DT]
      ,[Transaction_Account]
      ,[Account_Category]
      ,[CUSTOMER_ID]
      ,[ACCOUNT_STATUS]
FROM [CORE_T24].[dbo].[T24_ACCOUNT]
WHERE Account_Category in ('1001','1002')

  -- [dbo].[DIM_TRANSACTION_TYPE]

SELECT  [Transaction_Type]
      ,[Transaction_Group]
FROM [CORE_T24].[dbo].[T24_TRANSACTION]
GROUP BY  [Transaction_Type]
      ,[Transaction_Group]


  -- [dbo].[STAGING_Digital_Account]

--IF  [Transaction_Amount] < 10,000,000 => LOW
--IF  [Transaction_Amount] >= 10,000,000 & [Transaction_Amount] < 100,000,000  =>  MEDIUM LOW
--IF  [Transaction_Amount] >= 100,000,000 & [Transaction_Amount] < 1,000,000,000  => MEDIUM HIGH
--IF  [Transaction_Amount] > 1,000,000,000  => HIGH

SELECT [Transaction_ID]
      ,[Transaction_Account]
      ,[CUSTOMER_ID]
      --,[Channel]
	  ,[Transaction_Amount]
	  , IIF([Transaction_Amount] < 1000000, 'LOW'
			, IIF([Transaction_Amount] < 10000000, 'MEDIUM LOW'
				, IIF([Transaction_Amount] < 100000000, 'MEDIUM HIGH', 'HIGH')))   [Transaction_Range]
	  ,[Transaction_DT]
      ,[Transaction_Type]
      ,[Transaction_Group]
  FROM [CORE_T24].[dbo].[T24_TRANSACTION]
  WHERE [Channel] = 'APP'

-- FACT
SELECT E.[eKYC_DT], E.[Customer_ID]
			, C.[CRM_Source], c.[CRM_Channel]
			, A.[Account_Created_DT], A.[Account_Number], A.[Account_Category], A.[Account_Status]
			, T.FIRST_TRANS, T.TRANS_CNT, T.TRANS_AMT
			, P.[PosteKYC_created_DT]
			, P.[Fraud_Type] 
			, P.[KYC_DT] 
			--, 
	FROM [DWH].[dbo].[DIM_EKYC] E
	LEFT JOIN [DWH].[dbo].[DIM_CRM] c on E.[eKYC_ID] = C.[eKYC_ID]
	LEFT JOIN [DWH].[dbo].[DIM_ACCOUNTS] A on E.[Customer_ID] = A.[Customer_ID]
	LEFT JOIN (SELECT [Customer_ID],[Account_Number]
						, MIN([Transaction_DT]) FIRST_TRANS
						, COUNT(distinct [Transaction_ID]) TRANS_CNT
						, SUM([Transaction_Amount]) TRANS_AMT
				FROM [DWH].[dbo].[DIM_TRANSACTIONS]
				GROUP BY  [Customer_ID],[Account_Number]
					) T ON E.[Customer_ID] = T.[Customer_ID] 
					AND A.[Account_Number] = T.[Account_Number]
	LEFT JOIN [DWH].[dbo].[DIM_POST_EKYC] P ON   E.[Customer_ID] = P.[Customer_ID]
	WHERE E.[Customer_ID] IS NOT NULL

-- CLEAN
--- STAGING
SELECT COUNT(*) --66967
FROM [DWH].[dbo].[STAGING_eKYC_Information]
SELECT COUNT(*) --108000
FROM [DWH].[dbo].[STAGING_CRM]
SELECT COUNT(*) --189320
FROM [DWH].[dbo].[STAGING_Digital_Account]
SELECT COUNT(*) --171088
FROM [DWH].[dbo].[STAGING_Digital_Transaction]
SELECT COUNT(*) --11336
FROM [DWH].[dbo].[STAGING_Post_eKYC_Information]

DELETE FROM [DWH].[dbo].[STAGING_eKYC_Information]
DELETE FROM [DWH].[dbo].[STAGING_CRM]
DELETE FROM [DWH].[dbo].[STAGING_Digital_Account]
DELETE FROM [DWH].[dbo].[STAGING_Digital_Transaction]
DELETE FROM [DWH].[dbo].[STAGING_Post_eKYC_Information]

--- RECONCILIATION
SELECT COUNT(*) --66967
FROM [DWH].[dbo].[DIM_EKYC]
SELECT COUNT(*) --108000
FROM [DWH].[dbo].[DIM_CRM]
SELECT COUNT(*) --189320
FROM [DWH].[dbo].[DIM_ACCOUNTS]
SELECT COUNT(*) --9
FROM [DWH].[dbo].[DIM_TRANSACTION_TYPE]
SELECT COUNT(*) --171088
FROM [DWH].[dbo].[DIM_TRANSACTIONS]
SELECT COUNT(*) --11336
FROM [DWH].[dbo].[DIM_POST_EKYC]

DELETE FROM [DWH].[dbo].[DIM_EKYC]
DELETE FROM [DWH].[dbo].[DIM_CRM]
DELETE FROM [DWH].[dbo].[DIM_ACCOUNTS]
DELETE FROM [DWH].[dbo].[DIM_TRANSACTION_TYPE]
DELETE FROM [DWH].[dbo].[DIM_TRANSACTIONS]
DELETE FROM [DWH].[dbo].[DIM_POST_EKYC]

--- FACT
SELECT count(*) -- 47116
FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]

DELETE FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]