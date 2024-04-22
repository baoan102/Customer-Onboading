SELECT App_ID
	, IIF(F.FIRST_TRANS IS NOT NULL, '6. Make Transaction',
		IIF(F.Account_Created_DT IS NOT NULL, '5. Create Account',
		IIF(F.Customer_ID IS NOT NULL, '4. Create CIF',
		IIF(E.eKYC_DT IS NOT NULL, '3. Register eKYC',
		IIF(C.Install_App_DT IS NOT NULL, '2. Install Apps',
		IIF(C.Click_Ads_DT IS NOT NULL, '1. Click Ads',NULL)))))) FINAL_STAGE
	, Stage_1
	, Stage_2
	, Stage_3
	, Stage_4
	, Stage_5
	, Stage_6
	FROM DIM_CRM C
	LEFT JOIN DIM_EKYC E ON C.eKYC_ID=E.eKYC_ID
	LEFT JOIN FACT_DIGITAL_PROFILES F ON E.Customer_ID=F.Customer_ID
	LEFT JOIN FUNNEL FU ON FU.[Key] = IIF(F.FIRST_TRANS IS NOT NULL, '6. Make Transaction',
										IIF(F.Account_Created_DT IS NOT NULL, '5. Create Account',
										IIF(F.Customer_ID IS NOT NULL, '4. Create CIF',
										IIF(E.eKYC_DT IS NOT NULL, '3. Register eKYC',
										IIF(C.Install_App_DT IS NOT NULL, '2. Install Apps',
										IIF(C.Click_Ads_DT IS NOT NULL, '1. Click Ads',NULL))))))
------------------------------------
SELECT CONVERT(VARCHAR(6),C.Click_Ads_DT,112) CLICK_MONTH
	, App_ID
	, IIF(F.FIRST_TRANS IS NOT NULL, '6. Make Transaction',
		IIF(F.Account_Created_DT IS NOT NULL, '5. Create Account',
		IIF(F.Customer_ID IS NOT NULL, '4. Create CIF',
		IIF(E.eKYC_DT IS NOT NULL, '3. Register eKYC',
		IIF(C.Install_App_DT IS NOT NULL, '2. Install Apps',
		IIF(C.Click_Ads_DT IS NOT NULL, '1. Click Ads',NULL)))))) FINAL_STAGE
	, IIF(Stage_1 IS NOT NULL,Stage_1,'1.1. Not Click Ads') Stage_1
	, IIF(Stage_2 IS NOT NULL,Stage_2,'2.1. Not Install Apps') Stage_2
	, IIF(C.Install_App_DT IS NOT NULL,CONCAT('2. Install Apps within ',DATEDIFF(MONTH,C.Click_Ads_DT,C.Install_App_DT),' months'),'') Stage_2_
	, IIF(Stage_3 IS NOT NULL,Stage_1,'3.1. Not eKYC') Stage_3
	, IIF(E.eKYC_DT IS NOT NULL,CONCAT('3. eKYC within ',DATEDIFF(MONTH,C.Install_App_DT,E.eKYC_DT),' months'),'') Stage_3_
	, IIF(Stage_4 IS NOT NULL,Stage_1,'4.1. Not create CIF') Stage_4
	, IIF(F.Customer_ID IS NOT NULL,'4. Create CIF','4.1 Not create CIF') Stage_4_
	, IIF(Stage_5 IS NOT NULL,Stage_5,'5.1. Not create Account') Stage_5
	, IIF(F.Account_Created_DT IS NOT NULL,CONCAT('5. Create CIF within ',DATEDIFF(MONTH,C.Install_App_DT,E.eKYC_DT),' months'),'') Stage_5_
	, IIF(Stage_6 IS NOT NULL,Stage_6,'6.1. No trans yet') Stage_6
	,IIF(F.FIRST_TRANS IS NOT NULL,CONCAT('6. Make transactions in ',DATEDIFF(MONTH,F.Account_Created_DT,F.FIRST_TRANS),' months'),'') Stage_6_
	FROM DIM_CRM C
	LEFT JOIN DIM_EKYC E ON C.eKYC_ID=E.eKYC_ID
	LEFT JOIN FACT_DIGITAL_PROFILES F ON E.Customer_ID=F.Customer_ID
	LEFT JOIN FUNNEL FU ON FU.[Key] = IIF(F.FIRST_TRANS IS NOT NULL, '6. Make Transaction',
										IIF(F.Account_Created_DT IS NOT NULL, '5. Create Account',
										IIF(F.Customer_ID IS NOT NULL, '4. Create CIF',
										IIF(E.eKYC_DT IS NOT NULL, '3. Register eKYC',
										IIF(C.Install_App_DT IS NOT NULL, '2. Install Apps',
										IIF(C.Click_Ads_DT IS NOT NULL, '1. Click Ads',NULL))))))