# 1. Introduction

In this case, I will delve into the customer journey from their initial interaction with the service to performing transactions. The focus will be on designing a suitable data model that ensures flexibility and scalability. I will study data requirements, identify entities and their relationships, and establish rules and standards for data collection and storage.

Skills: Data Modeling, Data Quality Management
Tools: SSIS, SQL and Excel

# 2. Create Schema for STAGING zone:

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/b535d495-02b4-45d9-b90a-79ab6b74f032)

# 3. Create schema for RECONCILIATION zone:

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/ec948087-260b-42d3-9f44-05f518867e60)

# 4. Integrate data by using ETL Tools:
## 4.1. Transform and filter data:
Please refer to the Excel file ([Source-Targer Mapping](https://github.com/baoan102/Customer-Onboading/blob/main/Case%202%20-%20Metadata%20-%20Security%20and%20Quality/Source-Target_Mapping.xlsx)) for a better understanding of the BA's requirements regarding data mapping between tables.
## 4.2. ETL:

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/e2eee1b4-d662-4d43-9611-e32520339464)

In addition to the one-to-one mapping tables, there are other tables that need to be filtered according to requirements:

-	 [dbo].[STAGING_eKYC_Information]:
``` sql
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
```
-	 [dbo].[STAGING_Digital_Account]:
  ``` sql
SELECT  [CREATED_DT]
      ,[Transaction_Account]
      ,[Account_Category]
      ,[CUSTOMER_ID]
      ,[ACCOUNT_STATUS]
FROM [CORE_T24].[dbo].[T24_ACCOUNT]
WHERE Account_Category in ('1001','1002')
```
-	[dbo].[DIM_TRANSACTION_TYPE]:
```sql
SELECT  [Transaction_Type]
      ,[Transaction_Group]
FROM [CORE_T24].[dbo].[T24_TRANSACTION]
GROUP BY  [Transaction_Type]
      ,[Transaction_Group]
```
-	[dbo].[STAGING_Digital_Account]
```sql
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
```
-	[dbo].[FACT_DIGITAL_PROFILES]
```sql
SELECT e.[eKYC_DT], e.[Customer_ID]
			, c.[CRM_Source], c.[CRM_Channel]
			, a.[Account_Created_DT], a.[Account_Number], a.[Account_Category], a.[Account_Status]
			, t.FIRST_TRANS, t.TRANS_CNT, t.TRANS_AMT
			, p.[PosteKYC_created_DT]
			, p.[Fraud_Type] 
			, p.[KYC_DT] 
			--, 
	FROM [DWH].[dbo].[DIM_EKYC] e
	LEFT JOIN [DWH].[dbo].[DIM_CRM] c on e.[eKYC_ID] = c.[eKYC_ID]
	LEFT JOIN [DWH].[dbo].[DIM_ACCOUNTS] a on e.[Customer_ID] = a.[Customer_ID]
	LEFT JOIN (SELECT [Customer_ID],[Account_Number]
						, min([Transaction_DT]) FIRST_TRANS
						, count(distinct [Transaction_ID]) TRANS_CNT
						, sum([Transaction_Amount]) TRANS_AMT
				FROM [DWH].[dbo].[DIM_TRANSACTIONS]
				GROUP BY  [Customer_ID],[Account_Number]
					) t on e.[Customer_ID] = t.[Customer_ID] 
					AND a.[Account_Number] = t.[Account_Number]
	LEFT JOIN [DWH].[dbo].[DIM_POST_EKYC] p on   e.[Customer_ID] = p.[Customer_ID]
	WHERE e.[Customer_ID] IS NOT NULL
```
## 4.3. Some issues encountered during the data ETL process:

- Data type conflicts:
  - During the data loading process from CORE_T24 into the table [STAGING Digital Transaction], a data type conflict arises because the input data (CORE_T24) in the Transaction_Range column is of type String, while the Transaction_Range column in the STAGING Digital Transaction table in the database is of type nvarchar. Therefore, it's necessary to convert the input data to Unicode string [DT_WSTR].

<p align="center">
  <img src="https://github.com/baoan102/Customer-Onboading/assets/154876263/5dbfeaab-cced-4775-949f-df2e517fc9a4" width="230" >
</p>

 - During the data loading process from an Excel file into the table [STAGING_Post_eKYC_Information], the input data type for the IS_KYC column is String. However, in the database, its data type is varchar, which means ASCII. Therefore, it's necessary to change the code page for the Data Conversion from 1258 to 1252.

<p align="center">
  <img src="https://github.com/baoan102/Customer-Onboading/assets/154876263/6939ee02-3e8a-462e-a9c5-094b659ccdaa" width="230" >
</p>

# 5. Data quality:
## 5.1. Data Accuracy Report:
- 	Write a query with the following fields:
 - `IS_TIME_ALERT`: Evaluate the timestamps when customers perform actions to determine if they are reasonable (click -> install -> eKYC -> Account Created -> First Transaction).
 - `IS_SCORE_ALERT`: Customers have completed KYC, but their scores do not meet the required criteria.
 - `IS_ONFO_ALERT`: Customers have completed KYC, but the data from OCR does not match the data entered by the customers.
 - `IS_CATEGORY_ALERT`: Customer accounts are not of type 1001 and 1002.
 - `Fraud_Type`: Classification of customers

```sql
select F.Customer_ID
	, IIF(C.Click_Ads_DT>C.Install_App_DT OR C.Click_Ads_DT > F.eKYC_DT OR C.Click_Ads_DT > F.Account_Created_DT OR C.Click_Ads_DT > F.FIRST_TRANS
		OR C.Install_App_DT> F.eKYC_DT OR C.Install_App_DT > F.Account_Created_DT OR C.Install_App_DT > F.FIRST_TRANS
		OR F.eKYC_DT > F.Account_Created_DT OR F.eKYC_DT > F.FIRST_TRANS
		OR F.Account_Created_DT > F.FIRST_TRANS, 1,0) IS_TIME_ALERT
	, IIF(E.[SCORE_Sanity] < 0.85  
		OR E.[SCORE_Tampering] < 0.85 
		OR E.[SCORE_Liveness] < 0.85 
		OR E.[SCORE_Matching] < 0.85 , 1 , 0) IS_SCORE_ALERT
	, IIF( [OCR_Name]<>[INPUT_Name]
		OR [OCR_Dob] <> [INPUT_Dob]
		OR [OCR_Gender] <> [INPUT_Gender]
        OR [OCR_Address] <> [INPUT_Address]
        OR [OCR_Nationality]<>[INPUT_Nationality],1,0) IS_INFO_ALERT
	, IIF(F.Account_Category NOT IN ('1001','1002'),1,0) IS_CATEGORY_ALERT
	, F.Fraud_Type
FROM FACT_DIGITAL_PROFILES F
LEFT JOIN DIM_EKYC E ON E.Customer_ID=F.Customer_ID
LEFT JOIN DIM_CRM C ON C.eKYC_ID=E.eKYC_ID
```
