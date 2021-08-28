USE [PortfolioProject]
GO

SELECT *
FROM PortfolioProject..CovidDeaths;

SELECT * 
FROM PortfolioProject..CovidVaccinations;

-- Analyzing the data set

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Calculating percentage of dying by covid in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Calculating what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared per population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC;

-- Looking at countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Looking at continents with Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- LOOKING GLOBALLY INSTEAD OF LOCATION OR CONTNENT WISE

-- Death Percentage date wise/per day

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2;

-- Overall Death Percentage across the world

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL;


SELECT *
FROM PortfolioProject..CovidVaccinations

-- Looking at Total Population vs Vaccinations

SELECT D.continent, D.location, D.date, D.population, v.new_vaccinations,
SUM(CAST(V.new_vaccinations as int)) OVER(Partition by D.location ORDER BY D.date) AS TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location AND D.date = V.Date
WHERE D.continent is not NULL;

-- Creating CTE of above query to find TotalPeopleVaccinated per TotalPopulation

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT D.continent, D.location, D.date, D.population, v.new_vaccinations,
SUM(CAST(V.new_vaccinations as int)) OVER(Partition by D.location ORDER BY D.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location AND D.date = V.Date
WHERE D.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(40), 
location nvarchar(40), 
date datetime, 
population bigint, 
new_vaccinations bigint, 
RollingPeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, v.new_vaccinations,
SUM(CAST(V.new_vaccinations as int)) OVER(Partition by D.location ORDER BY D.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location AND D.date = V.Date
WHERE D.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population)*100 as TotalVaccinated
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, v.new_vaccinations,
SUM(CAST(V.new_vaccinations as int)) OVER(Partition by D.location ORDER BY D.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location AND D.date = V.Date
WHERE D.continent is not NULL;
