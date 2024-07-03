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

- [dbo].[STAGING_eKYC_Information]
- [dbo].[STAGING_Digital_Account]
- [dbo].[DIM_TRANSACTION_TYPE]
- [dbo].[STAGING_Digital_Account]
- [dbo].[FACT_DIGITAL_PROFILES]

[Link to code](https://github.com/baoan102/Customer-Onboading/blob/main/Case%202%20-%20Metadata%20-%20Security%20and%20Quality/ETL_SQL_SCRIPTS.sql)

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

Write a query with the following fields:
- `IS_TIME_ALERT`: Evaluate the timestamps when customers perform actions to determine if they are reasonable (click -> install -> eKYC -> Account Created -> First Transaction).
- `IS_SCORE_ALERT`: Customers have completed KYC, but their scores do not meet the required criteria.
- `IS_ONFO_ALERT`: Customers have completed KYC, but the data from OCR does not match the data entered by the customers.
- `IS_CATEGORY_ALERT`: Customer accounts are not of type 1001 and 1002.
- `Fraud_Type`: Classification of customers

[Link to code.](https://github.com/baoan102/Customer-Onboading/blob/main/Case%202%20-%20Metadata%20-%20Security%20and%20Quality/Data%20Accuracy.sql)

With the data obtained from the query above and using an Excel Pivot Table, we have the following two tables :

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/9388577f-b480-4ff9-9b2f-9c5e90589698)

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/a5a374dc-a343-4869-a522-bc0eb29c867a)

- Evaluate: 
	 - Based on the report, we can observe that there are no violations in the IS_INFO_ALERT and IS_CATEGORY_ALERT fields, indicating consistency between OCR data and customer-entered data. Additionally, all customers have accounts belonging to categories 1001 and 1002.
	 - However, for the IS_SCORE_ALERT and IS_TIME_ALERT fields, the number of customers violating these criteria is quite high, especially among customers labeled as NORMAL in the IS_SCORE_ALERT field, reaching up to 1504 customers. Therefore, it is necessary to review and verify this customer segment to prevent them from causing negative impacts on the bank. - 
	 - Additionally, when calculating the percentage of customers relative to the total, the IS_SCORE_ALERT field also accounts for a relatively high proportion (4-5%). Therefore, it is essential to check whether the OCR system is functioning properly or if the criteria for scores are not appropriate.

## 5.2. Data Consistency Report:
- Create a report table with the following columns:
	- `eKYC_MONTH`: month of eKYC execution
	- `FRAUD_NOT_CLOSED`: customers flagged as Fraud but whose accounts are not closed
	 - `RISK_NOT_SUSPENDED`: customers flagged as Risk but whose activities are not suspended or warned
	 - `CHECK_NOT_ACTIVE`: normal customers whose accounts are not allowed to operate
	 - `RISK_TRANS`: transactions performed by Risk-labeled customers that should have been restricted
	 - `FRAUD_TRANS`: transactions performed by Fraud-labeled customers

[Link to code.](https://github.com/baoan102/Customer-Onboading/blob/main/Case%202%20-%20Metadata%20-%20Security%20and%20Quality/Data%20Consistancy.sql)

For the data obtained from the query above and using an Excel Pivot Table, we have the following report:

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/d79e8627-b09f-4234-8bae-660bfc51e743)

Detail report on transactions by customers labeled as FRAUD:

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/7b441170-b95e-4966-b038-c2543e047159)
