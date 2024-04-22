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