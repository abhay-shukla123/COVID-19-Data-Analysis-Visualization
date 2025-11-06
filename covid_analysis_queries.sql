CREATE TABLE covid_cases (
    date DATE,
    state VARCHAR(150),
    confirmed INTEGER,
    cured INTEGER,
    deaths INTEGER,
    active_cases INTEGER
);

CREATE TABLE covid_vaccination (
    vaccine_date DATE,
    state VARCHAR(150),
    male_vaccinated BIGINT,
    female_vaccinated BIGINT,
    total_vaccinated BIGINT
);


-- 1. Show total confirmed, cured, and deaths in India
SELECT SUM(confirmed) AS total_confirmed, SUM(cured) AS total_cured, SUM(deaths) AS total_deaths
FROM covid_cases;

-- 2. Top 10 states by confirmed cases
SELECT state, MAX(confirmed) AS total_confirmed
FROM covid_cases
GROUP BY state
ORDER BY total_confirmed DESC
LIMIT 10;

-- 3. Top 10 states by active cases
SELECT state, MAX(active_cases) AS total_active
FROM covid_cases
GROUP BY state
ORDER BY total_active DESC
LIMIT 10;

-- 4. Top 10 states by deaths
SELECT state, MAX(deaths) AS total_deaths
FROM covid_cases
GROUP BY state
ORDER BY total_deaths DESC
LIMIT 10;

-- 5. Overall Recovery Rate
SELECT (SUM(cured)::float / SUM(confirmed)) * 100 AS recovery_rate_percent
FROM covid_cases;

-- 6. Overall Mortality Rate
SELECT (SUM(deaths)::float / SUM(confirmed)) * 100 AS mortality_rate_percent
FROM covid_cases;

-- 7. State-wise Recovery Rate
SELECT state, (SUM(cured)::float / SUM(confirmed)) * 100 AS recovery_rate_percent
FROM covid_cases
GROUP BY state
ORDER BY recovery_rate_percent DESC;

-- 8. State-wise Mortality Rate
SELECT state, (SUM(deaths)::float / SUM(confirmed)) * 100 AS mortality_rate_percent
FROM covid_cases
GROUP BY state
ORDER BY mortality_rate_percent DESC;

-- 9. Monthly confirmed case trend
SELECT DATE_TRUNC('month', date) AS month, SUM(confirmed) AS monthly_confirmed
FROM covid_cases
GROUP BY month
ORDER BY month;

-- 10. Daily new case trend
SELECT date, SUM(confirmed) AS daily_confirmed
FROM covid_cases
GROUP BY date
ORDER BY date;

-- 11. Total male vs female vaccination in India
SELECT SUM(male_vaccinated) AS total_male, SUM(female_vaccinated) AS total_female
FROM covid_vaccination;

-- 12. Top 10 states by total vaccination
SELECT state, SUM(total_vaccinated) AS total_vaccinated
FROM covid_vaccination
GROUP BY state
ORDER BY total_vaccinated DESC
LIMIT 10;

-- 13. Vaccination gender ratio by state
SELECT state, SUM(male_vaccinated) AS male_total, SUM(female_vaccinated) AS female_total
FROM covid_vaccination
GROUP BY state
ORDER BY male_total DESC;

-- 14. States with highest female vaccination dominance
SELECT state, SUM(female_vaccinated) AS female_total
FROM covid_vaccination
GROUP BY state
ORDER BY female_total DESC
LIMIT 10;

-- 15. Combined table - latest data per state (for Tableau dashboard)
SELECT DISTINCT ON (state) state, date, confirmed, cured, deaths, active_cases
FROM covid_cases
ORDER BY state, date DESC;

-- 16. Compare top affected states trend (Maharashtra, Karnataka, Kerala, Tamil Nadu, UP)
SELECT state, date, confirmed, active_cases
FROM covid_cases
WHERE state IN ('Maharashtra','Karnataka','Kerala','Tamil Nadu','Uttar Pradesh')
ORDER BY date;

-- 17. Highest peak active cases date per state
SELECT state, date, active_cases
FROM covid_cases c
WHERE active_cases = (
    SELECT MAX(active_cases) FROM covid_cases c2 WHERE c2.state = c.state
);

-- 18. States where mortality rate > 2%
SELECT state, (SUM(deaths)::float / SUM(confirmed)) * 100 AS mortality_rate_percent
FROM covid_cases
GROUP BY state
HAVING (SUM(deaths)::float / SUM(confirmed)) * 100 > 2
ORDER BY mortality_rate_percent DESC;

-- 19. States where recovery rate < 80%
SELECT state, (SUM(cured)::float / SUM(confirmed)) * 100 AS recovery_rate_percent
FROM covid_cases
GROUP BY state
HAVING (SUM(cured)::float / SUM(confirmed)) * 100 < 80
ORDER BY recovery_rate_percent;

-- 20. Vaccination progress trend over time
SELECT vaccine_date, SUM(total_vaccinated) AS daily_vaccination
FROM covid_vaccination
GROUP BY vaccine_date
ORDER BY vaccine_date;

--21. Top 5 states with highest confirmed case
SELECT state, MAX(confirmed) AS confirmed
FROM covid_cases
GROUP BY state
ORDER BY confirmed DESC
LIMIT 5;

--22. Top 5 states with highest active cases
SELECT state, MAX(active_cases) AS active_cases
FROM covid_cases
GROUP BY state
ORDER BY active_cases DESC
LIMIT 5;

--23. Top 5 states by mortality rate (only where confirmed>1000):
SELECT state,
       SUM(deaths)::float / NULLIF(SUM(confirmed),0) * 100 AS mortality_pct,
       SUM(confirmed) as confirmed_total
FROM covid_cases
GROUP BY state
HAVING SUM(confirmed) > 1000
ORDER BY mortality_pct DESC
LIMIT 5;

--24. Compare Male vs Female vaccination per state
SELECT
  state,
  SUM(male_vaccinated) AS male_total,
  SUM(female_vaccinated) AS female_total
FROM covid_vaccination
GROUP BY state
ORDER BY (SUM(male_vaccinated)+SUM(female_vaccinated)) DESC;

--25 Top 5 states with highest total vaccinations
SELECT
  state,
  SUM(total_vaccinated) AS total_vaccinated
FROM covid_vaccination
GROUP BY state
ORDER BY total_vaccinated DESC
LIMIT 5;