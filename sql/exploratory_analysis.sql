-- ==========================================================
-- Global Layoffs Exploratory Data Analysis
-- ==========================================================
-- Author: Joel Chukwudi Okolie
-- Database: MySQL Server 8.0
-- SQL Editor: Visual Studio Code

-- Description:
-- This project explores the cleaned World Layoffs dataset
-- to identify trends in workforce reductions across
-- companies, industries, countries, and time.

-- Dataset:
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


-- ==========================================================
-- STEP 1: REVIEW THE CLEANED DATASET
-- ==========================================================
-- Objective:
-- Verify the cleaned dataset before beginning exploratory analysis.

SELECT *
FROM layoffs_clean;

-- ==========================================================
-- STEP 2: DATASET OVERVIEW
-- ==========================================================
-- Business Questions:
-- • What period does the dataset cover?
-- • How many companies, industries and countries were affected?
-- • What was the largest single layoff event?
-- • What was the highest percentage of employees laid off?
-- • How many employees were laid off globally?

-- ----------------------------------------------------------
-- Date range of the dataset
SELECT
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_clean;
-- ----------------------------------------------------------
-- Number of company, industry and country the layoff spanned across
SELECT
    COUNT(DISTINCT company) AS num_of_companies,
    COUNT(DISTINCT industry) AS num_of_industries,
    COUNT(DISTINCT country) AS num_of_countries
FROM layoffs_clean;
-- ----------------------------------------------------------
-- Max single-company layoff event
SELECT MAX(total_laid_off) AS max_single_layoff
FROM layoffs_clean;
-- ----------------------------------------------------------
-- Max percentage laid off
SELECT MAX(percentage_laid_off) AS max_percentage
FROM layoffs_clean;
-- ----------------------------------------------------------
-- Overall total layoff
SELECT SUM(total_laid_off) AS global_total_layoff
FROM layoffs_clean;
/*
=============================================================
Key Observations:
-   The dataset spans approximately three years.
-   The largest recorded single-company layoff involved 12,000 employees.
-   Several companies reported laying off their entire workforce.
-   More than 383,000 employees were laid off during the period covered.
=============================================================
*/

-- ==========================================================
-- STEP 3: COMPANY ANALYSIS
-- ==========================================================
-- Business Questions:
-- • Which companies experienced the highest total layoffs?
-- • Which companies laid off their entire workforce?

-- ----------------------------------------------------------
-- 10 companies with the highest total layoff
SELECT
    company,
    SUM(total_laid_off) AS total,
    ROUND(SUM(total_laid_off)/SUM(SUM(total_laid_off)) OVER ()*100,2)
    AS percent_of_total
FROM layoffs_clean
GROUP BY company
ORDER BY total DESC
LIMIT 10;

-- -----------------------------------------------------------
-- Companies that laid off their entire staff
SELECT
    DISTINCT company,
    industry,
    total_est_employees,
    total_laid_off,
    ROUND(percentage_laid_off) AS percentage_laid_off,
    country
FROM layoffs_clean
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
/*
=============================================================
Key Observations:
-   The top 10 companies with the highest layoff accounts for
    approx. 26% of all recorded layoffs, indicating that workforce
    reduction was concentrated among relatively few organization.
-   Approximately 7% of the total companies affected shut down
    completely.
=============================================================
*/

-- ==========================================================
-- STEP 4: INDUSTRY ANALYSIS
-- ==========================================================
-- Business Questions:
-- • Which industries experienced the largest layoffs?
-- • Which industries were least affected?
-- • Which industries had companies that shut down completely?

-- -----------------------------------------------------------
-- 10 industries with the highest total layoff
SELECT
    industry,
    SUM(total_laid_off) AS total,
    ROUND(SUM(total_laid_off)/SUM(SUM(total_laid_off)) OVER ()*100, 2)
    AS percent_of_total
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY percent_of_total DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 10 industries that had the fewest total layoff
SELECT
    industry,
    SUM(total_laid_off) AS total,
    ROUND(SUM(total_laid_off)/SUM(SUM(total_laid_off)) OVER ()*100, 2)
    AS percent_of_total
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY percent_of_total ASC
LIMIT 10;

-- --------------------------------------------------------------
-- Industries that had complete company shut down

SELECT
    DISTINCT industry,
    ROUND(percentage_laid_off) AS percentage_laid_off,
    COUNT(company) AS num_of_companies
FROM layoffs_clean
GROUP BY industry, percentage_laid_off
HAVING percentage_laid_off = 1
ORDER BY num_of_companies DESC;
/*
=============================================================
Key Observations:
-   About 74% of total layoff came from the top 10 most laid off industries,
    this means layoff was highly concentrated among companies within these few
    industries, especially the Consumer and Retail industries which together
    have about 23% of the total.
-   The top 10 industries with least layoff barely made 4.4% of the entire
    layoff, this could indicate that companies in these industries droped a very 
    minimal amount of their workforce.
-   The Food, Retail and Finance industries saw about 33% company shut down
=============================================================
*/

-- ==========================================================
-- STEP 5: GEOGRAPHIC ANALYSIS
-- ==========================================================
-- Business Questions:
-- • Which countries experienced the highest layoffs?
-- • Which countries experienced the fewest layoffs?
-- • Which countries had the most complete company closures?

-- --------------------------------------------------------------
-- 10 countries with the highest total layoff
SELECT
    country,
    SUM(total_laid_off) AS total,
    ROUND(SUM(total_laid_off)/SUM(SUM(total_laid_off)) OVER ()*100, 2)
    AS percent_of_total
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY percent_of_total DESC
LIMIT 10;

-- ---------------------------------------------------------------
-- 10 countries with the lowest total layoff
SELECT
    country,
    SUM(total_laid_off) AS total,
    ROUND(SUM(total_laid_off)/SUM(SUM(total_laid_off)) OVER ()*100, 2)
    AS percent_of_total
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY percent_of_total, total ASC
LIMIT 10;

-- ----------------------------------------------------------
-- Countries that had complete company closure
SELECT 
    DISTINCT country,
    ROUND(percentage_laid_off) AS percentage_laid_off,
    COUNT(company) AS num_of_companies
FROM layoffs_clean
GROUP BY country, percentage_laid_off
HAVING percentage_laid_off = 1
ORDER BY num_of_companies DESC;
/*
=============================================================
Key Observations:
-   More than half of total layoff was in the United States.
-   The top 10 countries that had fewest layoff didnt make up
    half a percent of the total layoff.
-   With United States having more than half of the total layoff,
    it is no suprise they had 73 company closure, that's about 63%
    of company closure.
=============================================================
*/

-- ==========================================================
-- STEP 6: TIME ANALYSIS
-- ==========================================================
-- Business Questions:
-- • How did layoffs change over time?
-- • Which years experienced the largest workforce reductions?
-- • Which industries dominated layoffs each year?
-- • Which countries were most affected each year?

-- -----------------------------------------------------------
-- Monthly layoff trend
SELECT
    year(`date`) AS 'year',
    month(`date`) AS 'month',
    SUM(total_laid_off) AS total,
    SUM(SUM(total_laid_off)) OVER(ORDER BY year(`date`),month(`date`))
    AS cummulative_total
FROM layoffs_clean
GROUP BY `year`, `month`
ORDER BY `year`, `month`;

-- --------------------------------------------------------------
-- Annual layoff trend
SELECT
    year(`date`) AS 'year',
    SUM(total_laid_off) AS total,
    SUM(SUM(total_laid_off)) OVER(ORDER BY year(`date`)) AS rolling_total
FROM layoffs_clean
GROUP BY `year`
ORDER BY `year`;

-- ---------------------------------------------------------------
-- Industry yearly layoff trend and ranking
WITH industries_per_year AS (
    SELECT
        industry,
        year(`date`) AS 'year',
        SUM(total_laid_off) AS total,
        DENSE_RANK() OVER(PARTITION BY year(`date`) ORDER BY SUM(total_laid_off) DESC)
        AS yearly_rank
    FROM layoffs_clean
    WHERE total_laid_off IS NOT NULL
    GROUP BY industry, `year`)
SELECT *,
    SUM(total) OVER(PARTITION BY `year` ORDER BY total DESC) AS yearly_rolling_total
FROM industries_per_year
ORDER BY `year`, total DESC;

-- --------------------------------------------------------------
-- Country yearly layoff trend and ranking
WITH country_per_year AS (
    SELECT
        country,
        year(`date`) AS 'year',
        SUM(total_laid_off) AS total,
        DENSE_RANK() OVER(PARTITION BY year(`date`) ORDER BY SUM(total_laid_off) DESC)
    FROM layoffs_clean
    WHERE total_laid_off IS NOT NULL
    GROUP BY country, `year`)
SELECT *,
    SUM(total) OVER(PARTITION BY `year` ORDER BY total DESC) AS yearly_rolling_total
FROM country_per_year
ORDER BY `year`, total DESC;
/*
=============================================================
Key Observations:
-   Layoff were minimal through the year 2021, it ramped up in 2022.
-   The layoffs in 2023 is only three months but it accounts
    for about 33% of total layoff since 2020.
-   Retail, Consumer, and Food industries consistently ranked among
    the highest for annual layoffs, indicating these sectors were
    disproportionately affected during the period.
=============================================================
*/

-- ==========================================================
-- STEP 7: COMPANY STAGE ANALYSIS
-- ==========================================================
-- Business Questions:
-- • Which funding stages experienced the highest layoffs?
-- • Which stages experienced the highest percentage of workforce reductions?

-- ----------------------------------------------------------
-- Stages with the highest number of workforce reduction
WITH stage_layoffs AS (
    SELECT
        stage,
        COUNT(DISTINCT company) AS num_of_companies,
        SUM(total_laid_off) AS total_laid_off,
        SUM(total_est_employees) AS total_est_employees
    FROM layoffs_clean
    WHERE stage IS NOT NULL
    GROUP BY stage)
SELECT
    stage,
    num_of_companies,
    total_laid_off,
    ROUND((total_laid_off / total_est_employees) * 100, 2) AS percent_of_laid,
    total_est_employees
FROM stage_layoffs
ORDER BY total_laid_off DESC;

-- ------------------------------------------------------------
-- Stages with highest percentage of workforce reduction
WITH stage_layoffs AS (
    SELECT
        stage,
        COUNT(DISTINCT company) AS num_of_companies,
        SUM(total_laid_off) AS total_laid_off,
        SUM(total_est_employees) AS total_est_employees
    FROM layoffs_clean
    GROUP BY stage
    HAVING stage IS NOT NULL)
SELECT
    stage,
    num_of_companies,
    total_laid_off,
    ROUND((total_laid_off / total_est_employees) * 100, 2) AS percent_of_laid,
    total_est_employees
FROM stage_layoffs
ORDER BY percent_of_laid DESC;
/*
=============================================================
Key Observations:
-   The post-IPO stage consisting 285 companies have the highest
    number of workforce layoff of 203,632 employees and also the
    least percentage layoff of 6.55% compared to the seed stage which
    consists of just 51 companies, with 1,636 laid off employees
    amounting to 59.21% of all employees in the seed stage companies.
=============================================================
*/

-- ==========================================================
-- STEP 8: SUMMARY STATISTICS
-- ==========================================================
-- Objective:
-- Provide an overall summary of the cleaned dataset.

-- ----------------------------------------------------------
-- Summary statistics
SELECT 
    COUNT(DISTINCT company) AS unique_companies,
    COUNT(DISTINCT industry) AS unique_industries,
    COUNT(DISTINCT country) AS unique_countries,
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date,
    SUM(total_laid_off) AS total_laid_off_global,
    ROUND(AVG(percentage_laid_off), 2) AS avg_percentage_laid_off,
    ROUND(AVG(total_est_employees), 0) AS avg_company_size
FROM layoffs_clean;
