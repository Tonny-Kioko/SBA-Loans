SELECT * FROM dbo.codes;

--Data Cleansing Process

SELECT naics_industry_description, 
SUBSTRING ((naics_industry_description), 8, 2) lookup_codes 
FROM dbo.codes
WHERE naics_codes IS NULL
AND NAICS_Industry_Description LIKE 'S%';


SELECT naics_industry_description, 
SUBSTRING ((naics_industry_description), 8, 2) lookup_codes,
SUBSTRING ((naics_industry_description), CHARINDEX ('–', NAICS_Industry_Description) +1, LEN(naics_industry_description)) Sector
FROM dbo.codes
WHERE naics_codes IS NULL
AND NAICS_Industry_Description LIKE 'S%'


SELECT * INTO sba_naics_codes_description
FROM (SELECT naics_industry_description, 
SUBSTRING ((naics_industry_description), 8, 2) lookup_codes,
SUBSTRING ((naics_industry_description), CHARINDEX ('–', NAICS_Industry_Description) +1, LEN(naics_industry_description)) Sector
FROM dbo.codes
WHERE naics_codes IS NULL
AND NAICS_Industry_Description LIKE 'S%')



--DATA EXPLORATION
SELECT * FROM sba_public_data

--Summary of all approved loans

SELECT 
    COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data

--968538	515514166608.808	532260.134975404
--Loans approved in various years

SELECT 
     YEAR (DateApproved) Year_Approved,
    COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE YEAR (DateApproved) = 2020
GROUP BY YEAR (DateApproved) 

UNION

SELECT 
    YEAR (DateApproved) Year_Approved,
    COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE YEAR (DateApproved) = 2021
GROUP BY YEAR (DateApproved)

--2020	659452	377635548254.08	 572650.546596386
--2021	309086	137878618354.753	446084.967791336

--Originating lenders in 2020 and 2021 (Fin. Institutions Involved)

SELECT 
     COUNT (DISTINCT OriginatingLender) Originating_Lender,
     YEAR (DateApproved) Year_Approved,
    COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE YEAR (DateApproved) = 2020
GROUP BY YEAR (DateApproved) 

UNION

SELECT 
    COUNT (DISTINCT OriginatingLender) Originating_Lender,
    YEAR (DateApproved) Year_Approved,
    COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE YEAR (DateApproved) = 2021
GROUP BY YEAR (DateApproved)

--4181	2020	659452	377635548254.08	572650.546596386
--3854	2021	309086	137878618354.75	446084.967791327

--Top 15 Originating lenders by loan count, approved amount adn average loan size (2020 & 2021)
--2020
SELECT TOP 15
     OriginatingLender,
     COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE YEAR (DateApproved) = 2020
GROUP BY OriginatingLender
ORDER BY 3 DESC

--2021
SELECT 
     OriginatingLender,
     COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
--WHERE YEAR (DateApproved) = 2021
GROUP BY OriginatingLender
ORDER BY 3 DESC

--Of the given loans, how much was forgiven by the lender
--2020
SELECT
     COUNT (loannumber) Number_of_Approved, 
	SUM (CurrentApprovalAmount) Current_Approved_amount, 
	AVG (CurrentApprovalAmount) Current_Average_loan_Size, 
	SUM (ForgivenessAmount) Amount_Forgiven,
	SUM (ForgivenessAmount) / SUM (CurrentApprovalAmount) * 100 Percentage_Forgiven
FROM sba_public_data
WHERE YEAR (DateApproved) = 2020
ORDER BY 3 DESC
--659452	376041992586.192	570234.061897138	353473592078.518	93.9984360915487

--2021
SELECT
     COUNT (loannumber) Number_of_Approved, 
	SUM (CurrentApprovalAmount) Current_Approved_amount, 
	AVG (CurrentApprovalAmount) Current_Average_loan_Size, 
	SUM (ForgivenessAmount) Amount_Forgiven,
	SUM (ForgivenessAmount) / SUM (CurrentApprovalAmount) * 100 Percentage_Forgiven
FROM sba_public_data
WHERE YEAR (DateApproved) = 2021
ORDER BY 3 DESC
--309086	137892053514.603	446128.435175334	76962938066.3602	55.8139037781532

--Overall forgiven loans
SELECT
     COUNT (loannumber) Number_of_Approved, 
	SUM (CurrentApprovalAmount) Current_Approved_amount, 
	AVG (CurrentApprovalAmount) Current_Average_loan_Size, 
	SUM (ForgivenessAmount) Amount_Forgiven,
	SUM (ForgivenessAmount) / SUM (CurrentApprovalAmount) * 100 Percentage_Forgiven
FROM sba_public_data
--968538	513934046100.77	530628.685813845	430436530144.874	83.7532623904967

--Year, Month the highest loans were approved
SELECT
     YEAR (DateApproved) Year_Approved, 
	 MONTH (DateApproved) Month_Approved, 
	 COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
GROUP BY YEAR (DateApproved),
          MONTH (DateApproved)
ORDER BY 4 DESC

--Loans received by each state
SELECT 
       BorrowerState,
	   COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE BorrowerState IS NOT NULL
	GROUP BY (BorrowerState)
	ORDER BY 2 DESC

--For Visualization
SELECT BorrowerState, Ethnicity, Gender, Race, 
     YEAR (DateApproved) Year_Approved, 
	 MONTH (DateApproved) Month_Approved, 
	 COUNT (loannumber) Number_of_Approved, 
	SUM (InitialApprovalAmount) Approved_amount, 
	SUM (ForgivenessAmount) Amount_Forgiven,
	AVG (InitialApprovalAmount) Average_loan_Size
FROM sba_public_data
WHERE BorrowerState IS NOT NULL
AND Ethnicity IS NOT NULL
AND Gender IS NOT NULL
AND Race IS NOT NULL
GROUP BY YEAR (DateApproved),
          MONTH (DateApproved), 
		  BorrowerState, Ethnicity, Gender, Race
ORDER BY 4 DESC