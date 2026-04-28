-- ============================================================
-- ACTIVE VS PASSIVE FUND ANALYSIS
-- Source: AIC Top 20 Most Viewed Investment Trusts
-- Benchmarks: FTSE 100, S&P 500, FTSE All World
-- Period: May 2023 - April 2026 (3 Years)
-- Data: Yahoo Finance via yfinance, rebased to 1.0 at start
-- Table: active_vs_passive_long (Date, Fund, Value)
-- ============================================================


-- ============================================================
-- QUERY 1: TOP PERFORMING FUNDS
-- Ranks all funds by final value after 3 years
-- Shows return % and £1,000 invested outcome
-- Output: top_performing_funds.csv
-- ============================================================

SELECT 
    Fund,
    Value AS Final_Value,
    ROUND((Value - 1) * 100, 2) AS Return_Pct,
    ROUND(Value * 1000, 2) AS GBP_1000_invested
FROM active_vs_passive_long
WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long)
ORDER BY Final_Value DESC;


-- ============================================================
-- QUERY 2: COUNT FUNDS THAT BEAT EACH PASSIVE BENCHMARK
-- Answers: what % of active funds beat the market?
-- ============================================================

SELECT
    'Beat S&P 500' AS Benchmark,
    COUNT(*) AS Funds_That_Beat_It,
    ROUND(COUNT(*) * 100.0 / 18, 1) AS Percentage
FROM active_vs_passive_long
WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long)
AND Fund NOT IN ('S&P 500', 'FTSE 100', 'FTSE All World', 'Active Fund Average')
AND Value > (
    SELECT Value FROM active_vs_passive_long 
    WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long) 
    AND Fund = 'S&P 500'
)

UNION ALL

SELECT
    'Beat FTSE All World',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / 18, 1)
FROM active_vs_passive_long
WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long)
AND Fund NOT IN ('S&P 500', 'FTSE 100', 'FTSE All World', 'Active Fund Average')
AND Value > (
    SELECT Value FROM active_vs_passive_long 
    WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long) 
    AND Fund = 'FTSE All World'
)

UNION ALL

SELECT
    'Beat FTSE 100',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / 18, 1)
FROM active_vs_passive_long
WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long)
AND Fund NOT IN ('S&P 500', 'FTSE 100', 'FTSE All World', 'Active Fund Average')
AND Value > (
    SELECT Value FROM active_vs_passive_long 
    WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long) 
    AND Fund = 'FTSE 100'
);


-- ============================================================
-- QUERY 3: MAX DRAWDOWN
-- Worst peak to trough decline for each fund over 3 years
-- Output: drawdown.csv
-- ============================================================

WITH peak_values AS (
    SELECT
        a.Fund,
        a.Date,
        a.Value,
        MAX(b.Value) AS Peak_Value
    FROM active_vs_passive_long a
    JOIN active_vs_passive_long b
        ON a.Fund = b.Fund
        AND b.Date <= a.Date
    GROUP BY a.Fund, a.Date, a.Value
),
drawdowns AS (
    SELECT
        Fund,
        Date,
        Value,
        Peak_Value,
        ROUND((Value - Peak_Value) / Peak_Value * 100, 2) AS Drawdown_Pct
    FROM peak_values
)
SELECT
    Fund,
    MIN(Drawdown_Pct) AS Max_Drawdown_Pct
FROM drawdowns
GROUP BY Fund
ORDER BY Max_Drawdown_Pct ASC;


-- ============================================================
-- QUERY 4: FUND CONSISTENCY
-- How many months did each fund spend above its starting value?
-- Output: fund_consistency.csv
-- ============================================================

SELECT
    Fund,
    SUM(CASE WHEN Value >= 1.0 THEN 1 ELSE 0 END) AS Months_Above_Start,
    SUM(CASE WHEN Value < 1.0 THEN 1 ELSE 0 END) AS Months_Below_Start,
    ROUND(SUM(CASE WHEN Value >= 1.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Pct_Time_Positive
FROM active_vs_passive_long
GROUP BY Fund
ORDER BY Pct_Time_Positive DESC;


-- ============================================================
-- QUERY 5: SHARPE RATIO
-- Risk adjusted return for each fund
-- Risk free rate: 4.5% (UK base rate approximation)
-- Output: sharpe_ratio.csv
-- ============================================================

WITH monthly_returns AS (
    SELECT
        a.Fund,
        ROUND((a.Value - b.Value) / b.Value, 4) AS Monthly_Return
    FROM active_vs_passive_long a
    JOIN active_vs_passive_long b
        ON a.Fund = b.Fund
        AND b.Date = (
            SELECT MAX(Date) 
            FROM active_vs_passive_long c 
            WHERE c.Fund = a.Fund 
            AND c.Date < a.Date
        )
),
stats AS (
    SELECT
        Fund,
        AVG(Monthly_Return) AS Avg_Monthly_Return,
        AVG(Monthly_Return * Monthly_Return) - AVG(Monthly_Return) * AVG(Monthly_Return) AS Variance
    FROM monthly_returns
    GROUP BY Fund
)
SELECT
    Fund,
    ROUND(Avg_Monthly_Return * 12 * 100, 2) AS Annualised_Return_Pct,
    ROUND(Variance, 6) AS Volatility,
    ROUND((Avg_Monthly_Return * 12 - 0.045) / (Variance * 12), 2) AS Sharpe_Ratio
FROM stats
ORDER BY Sharpe_Ratio DESC;


-- ============================================================
-- QUERY 6: FUND VOLATILITY
-- Standard deviation proxy using variance of monthly returns
-- Output: fund_volatility.csv
-- ============================================================

WITH monthly_returns AS (
    SELECT
        a.Fund,
        a.Date,
        ROUND((a.Value - b.Value) / b.Value, 4) AS Monthly_Return
    FROM active_vs_passive_long a
    JOIN active_vs_passive_long b
        ON a.Fund = b.Fund
        AND b.Date = (
            SELECT MAX(Date) 
            FROM active_vs_passive_long c 
            WHERE c.Fund = a.Fund 
            AND c.Date < a.Date
        )
)
SELECT
    Fund,
    COUNT(*) AS Months,
    ROUND(AVG(Monthly_Return) * 100, 2) AS Avg_Monthly_Return_Pct,
    ROUND(AVG(Monthly_Return * Monthly_Return) - AVG(Monthly_Return) * AVG(Monthly_Return), 6) AS Variance,
    ROUND(AVG(Monthly_Return) * 12 * 100, 2) AS Annualised_Return_Pct
FROM monthly_returns
GROUP BY Fund
ORDER BY Variance DESC;


-- ============================================================
-- QUERY 7: £1,000 PORTFOLIO COMPARISON
-- Equal split across all 18 active trusts vs S&P 500
-- Output: portfolio_comparison_1000.csv
-- ============================================================

WITH final_values AS (
    SELECT
        Fund,
        Value AS Final_Value
    FROM active_vs_passive_long
    WHERE Date = (SELECT MAX(Date) FROM active_vs_passive_long)
    AND Fund NOT IN ('S&P 500', 'FTSE 100', 'FTSE All World', 'Active Fund Average')
),
portfolio AS (
    SELECT
        ROUND(1000.0 / 18, 2) AS Investment_Per_Fund,
