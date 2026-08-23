-- UK COVID-19 Household Analysis — pgAdmin queries
-- Source: Understanding Society COVID-19 Survey (UK Data Service)
-- Tables: xbaseline (survey responses), xsample (demographics), joined on pidp
--
-- Key columns:
--   xsample:   pidp, sex_dv (1=Male, 2=Female), birthy (birth year)
--   xbaseline: pidp, blhhearn_amount_dv (household earnings), blpay_amount_dv (individual pay),
--              blwork_dv (1=Employed, 2=Self-Employed, 3=Furloughed, 4=Not Working),
--              blwah_dv (working-from-home indicator),
--              nhsshield_dv (1=Shielding, 2=Not Shielding),
--              blbenchange_dv (1=Increased, 2=Stayed Same, 3=Decreased)

-- 1. Sanity checks
SELECT * FROM xbaseline LIMIT 5;
SELECT * FROM xsample LIMIT 5;

-- 2. Employment status breakdown
SELECT
    CASE blwork_dv
        WHEN 1 THEN 'Employed' WHEN 2 THEN 'Self-Employed'
        WHEN 3 THEN 'Furloughed' WHEN 4 THEN 'Not Working'
    END AS employment_status,
    COUNT(*) AS total_respondents,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM xbaseline
WHERE blwork_dv > 0
GROUP BY blwork_dv
ORDER BY total_respondents DESC;

-- 3. Working-from-home adoption rate
SELECT
    blwah_dv,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM xbaseline
WHERE blwah_dv > 0
GROUP BY blwah_dv
ORDER BY total DESC;

-- 4. Average pay by employment status
SELECT
    blwork_dv,
    ROUND(AVG(blpay_amount_dv)::numeric, 2) AS avg_pay,
    COUNT(*) AS total_respondents
FROM xbaseline
WHERE blpay_amount_dv > 0 AND blwork_dv > 0
GROUP BY blwork_dv
ORDER BY avg_pay DESC;

-- 5. Gender pay gap (household earnings + individual pay)
SELECT
    CASE s.sex_dv WHEN 1 THEN 'Male' WHEN 2 THEN 'Female' END AS gender,
    ROUND(AVG(b.blhhearn_amount_dv) FILTER (WHERE b.blhhearn_amount_dv > 0)::numeric, 2) AS avg_household_earnings,
    ROUND(AVG(b.blpay_amount_dv) FILTER (WHERE b.blpay_amount_dv > 0)::numeric, 2) AS avg_individual_pay,
    COUNT(*) FILTER (WHERE b.blpay_amount_dv > 0) AS earners_in_avg
FROM xbaseline b
JOIN xsample s ON b.pidp = s.pidp
WHERE s.sex_dv > 0
GROUP BY s.sex_dv
ORDER BY avg_individual_pay DESC;

-- 6. Employment status by gender
SELECT
    s.sex_dv, b.blwork_dv,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY s.sex_dv), 2) AS percentage
FROM xbaseline b
JOIN xsample s ON b.pidp = s.pidp
WHERE b.blwork_dv > 0 AND s.sex_dv > 0
GROUP BY s.sex_dv, b.blwork_dv
ORDER BY s.sex_dv, total DESC;

-- 7. Average pay by age group
SELECT * FROM (
    SELECT
        CASE
            WHEN 2020 - s.birthy BETWEEN 18 AND 30 THEN '1_18-30'
            WHEN 2020 - s.birthy BETWEEN 31 AND 45 THEN '2_31-45'
            WHEN 2020 - s.birthy BETWEEN 46 AND 60 THEN '3_46-60'
            WHEN 2020 - s.birthy > 60 THEN '4_60+'
            ELSE NULL
        END AS age_group,
        COUNT(*) AS total,
        ROUND(AVG(b.blpay_amount_dv)::numeric, 2) AS avg_pay
    FROM xbaseline b
    JOIN xsample s ON b.pidp = s.pidp
    WHERE b.blpay_amount_dv > 0 AND s.birthy > 0
    GROUP BY age_group
) sub
WHERE age_group IS NOT NULL
ORDER BY age_group;

-- 8. Benefits change during COVID
SELECT
    CASE
        WHEN blbenchange_dv = 1 THEN 'Benefits Increased'
        WHEN blbenchange_dv = 2 THEN 'Benefits Stayed Same'
        WHEN blbenchange_dv = 3 THEN 'Benefits Decreased'
        ELSE 'No Benefits'
    END AS benefits_change,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM xbaseline
WHERE blbenchange_dv > 0
GROUP BY blbenchange_dv
ORDER BY total DESC;

-- 9. NHS shielding status vs employment status
SELECT
    CASE WHEN nhsshield_dv = 1 THEN 'Shielding' WHEN nhsshield_dv = 2 THEN 'Not Shielding' ELSE 'Unknown' END AS shield_status,
    CASE
        WHEN blwork_dv = 1 THEN 'Employed' WHEN blwork_dv = 2 THEN 'Self-Employed'
        WHEN blwork_dv = 3 THEN 'Furloughed' WHEN blwork_dv = 4 THEN 'Not Working'
        ELSE 'Unknown'
    END AS employment_status,
    COUNT(*) AS total
FROM xbaseline
WHERE nhsshield_dv > 0 AND blwork_dv > 0
GROUP BY nhsshield_dv, blwork_dv
ORDER BY shield_status, total DESC;
