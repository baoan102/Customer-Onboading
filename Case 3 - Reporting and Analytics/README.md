# 1. Performance of Marketing Campaign (by Digital Source)
## 1.1. The customer onboarding journey:
### 1.1.1.  Conversion Rate report:

Meaning of the fields:

|Field|	Description|
|-----------|-----------|
|`CRM_Source`|	Source|
|`CRM_Channel`|	Channel|
|`INSTALL`|	Number of customers who downloaded the app / number of customers who clicked on the advertisement.|
|`EKYC`|	Number of customers who completed eKYC / number of customers who downloaded the app.|
|`CUSTOMER`|	Number of customers who became official bank customers / number of customers who completed eKYC.|
|`FIRST_TRANS`|	Percentage of official customers who completed their first transaction.|
|`TRANS_IN_2_MONTH`|	Number of customers who made transactions in the last 2 months / number of official customers who completed their first transaction.|

[Link to code.](https://github.com/baoan102/Customer-Onboading/blob/main/Case%203%20-%20Reporting%20and%20Analytics/The%20customer%20onboarding%20journey.sql)

To further understand customers across different Channels and Sources, I propose adding a Service Level Agreements (SLAs) report to demonstrate service levels by transaction:

[Link to code](https://github.com/baoan102/Customer-Onboading/blob/main/Case%203%20-%20Reporting%20and%20Analytics/The%20customer%20onboarding%20journey.sql)

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/220a8655-44c6-4651-a4c5-05873dc0dbf2)

From the Conversion Rate report, we can observe the following:
- The conversion rate of customers completing their first transaction from VNDIRECT is the lowest at 24.46%
- The conversion rate of customers who made transactions in the last 2 months from Access Trade is the lowest at 92.96%.

From the Conversion Rate report, we see that customers from the two sources VNDIRECT and Access Trade have relatively low conversion rates. Continuing to examine these two customer sources in the Service Level Agreements (SLAs) report we find:
- Customers from Access Trade in December have the lowest transaction completion rate compared to all sources. This explains why the value of this customer group in the Conversion Rate Report by channel, specifically the TRANS_IN_2_MONTHS metric, is low.

⇨ Need to investigate in December what reasons caused the customer volume from this source to be so low (possibly due to the advertising campaign not reaching enough people or becoming less effective after a period of operation, the promotion program not being attractive, system glitches, ...)
  
- Customers from VNDIRECT in the last 4 months of 2022 had transaction completion rates not higher than the average rates of all sources. It seems this customer group wasn't well cared for, so there's a need to improve their care (promote promotional programs, incentives).

### 1.1.2.  Latency report:

To monitor conversion latency between stages to detect potential issues in these processes. 

[Link to code.](https://github.com/baoan102/Customer-Onboading/blob/main/Case%203%20-%20Reporting%20and%20Analytics/The%20customer%20onboarding%20journey.sql)

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/da967c3c-19bb-43fe-9ee1-e48aad26980b)

## 1.2. Profit and Loss report:

For each transaction corresponding to each transaction group, we have the profit margin as follows:

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/e7c1d04c-0a1a-4f4d-8b37-ae2a7abbef99)

The costs that the bank must pay for various sources include infrastructure costs and advertising costs corresponding to the current stage of the customer. 

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/523e35f5-54b2-494a-bc3b-89f2b6e342d8)

Meaning of the fields:

|Field|	Description|
|------|----------|
|`CRM_Source`|	Source.|
|`CRM_Channel`|	Channel.|
|`TOTAL_PROFIT`|	Total profit.|
|`TOTAL_COST`|	Total cost.|
|`NET_PROFIT`|	Total net profit.|
|`ROI`|	Return on Investment (ROI) = total net profit / total costs.|
|`ACTIVE_CUS`|	The number of customers conducting transactions in the last 2 months.|
|`COST_PER_ACTIVE_CUS`|	The cost incurred by the bank per active customer.|
|`NET_PROFIT_PER_ACTIVE_CUS`|	The net profit earned per active customer.|
|`GROSS_PROFIT_MAGIN`|	Gross profit margin.|

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/76b8596b-acd1-4d26-a848-3e397fbcf273)

![image](https://github.com/baoan102/Customer-Onboading/assets/154876263/62c25365-770a-440b-8c54-88a34fe020f6)

From the Profit and Loss report and chart, we can see that for customers from the Ecosystem and Partnership channels, whether they transact or operate on their own platform, we incur significant costs. Specifically, for every dollar spent, we only gain about 10-12 dollars in profit. Therefore, it's crucial to regularly monitor these customers, possibly checking their churn rates.

Meanwhile, the RB and Telesale channels are very cost-effective, especially RB, which performs exceptionally well in every aspect: highest ROI, lowest costs, and highest profit per customer. This reflects the reality that the RB channel leverages the bank's branch staff, which is a readily available resource with moderate costs.
