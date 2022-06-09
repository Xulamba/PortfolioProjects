SELECT * 
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT * FROM PortfolioProject1..covid_vaccinations
--ORDER BY 3,4;

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..covid_deaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract COVID 
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float))/(CAST(total_cases AS float))*100 AS death_percentage
FROM PortfolioProject1..covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths - Canada
-- Shows the likelyhood of dying if you contract COVID in Canada
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float))/(CAST(total_cases AS float))*100 AS death_percentage
FROM PortfolioProject1..covid_deaths
WHERE location LIKE '%canada%'
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths - Brazil
-- Shows the likelyhood of dying if you contract COVID in Brazil
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float))/(CAST(total_cases AS float))*100 AS death_percentage
FROM PortfolioProject1..covid_deaths
WHERE location LIKE '%brazil%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID in the World
SELECT location, date, population, total_cases, (CAST(total_cases AS float))/(CAST(population AS float))*100 AS infected_percentage
FROM PortfolioProject1..covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID in Canada
SELECT location, date, population, total_cases, (CAST(total_cases AS float))/(CAST(population AS float))*100 AS infected_percentage
FROM PortfolioProject1..covid_deaths
WHERE location LIKE '%canada%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID in Brazil
SELECT location, date, population, total_cases, (CAST(total_cases AS float))/(CAST(population AS float))*100 AS infected_percentage
FROM PortfolioProject1..covid_deaths
WHERE location LIKE '%brazil%'
ORDER BY 1,2;

-- Looking at Countries with highest infection rate compared to Population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((CAST(total_cases AS float))/(CAST(population AS float)))*100 AS infected_percentage
FROM PortfolioProject1..covid_deaths
GROUP BY location, population
ORDER BY infected_percentage DESC;

-- Looking at Countries with highest death count per Population
SELECT location, MAX(CAST(total_deaths AS float)) AS total_death_count
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Let's break things down by Continent
-- Showing the Continents with the highest death count per Popuplation
SELECT continent, MAX(CAST(total_deaths AS float)) AS total_death_count
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- Global numbers
SELECT date, SUM(CAST(new_cases AS float)) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths, SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) *100 AS death_percentage
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(CAST(new_cases AS float)) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths, SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) *100 AS death_percentage
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using a CTE

WITH popvsvac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM popvsvac;


-- Temp Table
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated;


-- Creating view to store data for later visualizations
CREATE VIEW percent_population_vaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM percent_population_vaccinated