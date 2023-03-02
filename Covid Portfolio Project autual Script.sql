/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From CovidDeaths
--Where continent is not null 
order by 3,4



-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%vietnam%'
--and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCout, MAX((total_cases/population))*100 AS Percentpopulationinfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY Percentpopulationinfected DESC

--Showing Countries with Highest Deaths Count per Population

SELECT Location, Population, MAX(total_deaths) AS TotalDeathCount--, MAX((total_deaths/population)) * 100 AS PercentpopulationDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

SELECT continent,  MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBER
Select SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS Deathpercentage
From CovidDeaths
--Where location like '%vietnam%'
WHERE continent is not null 
order by 1,2


-- Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,
	SUM(cast(Vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.date) AS RollingPeopleVacinated
FROM CovidDeaths dea
JOIN CovidVaccinations Vac
	ON dea.location = Vac.location AND dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location, dea.date,dea.population,Vac.new_vaccinations
ORDER BY 2,3


-- USE CTE
WITH PopVsVac(Continent, Location, Date, Population,New_vaccinations, RollingPeopleVacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,
	SUM(cast(Vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY   dea.date) AS RollingPeopleVacinated
FROM CovidDeaths dea
JOIN CovidVaccinations Vac
	ON dea.location = Vac.location AND dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVacinated/Population)*100
FROM PopVsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
date date,
Population float,
New_vaccinations float,
RollingPeopleVacinated float
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,
	SUM(cast(Vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVacinated
FROM CovidDeaths dea
JOIN CovidVaccinations Vac
	ON dea.location = Vac.location AND dea.date = Vac.date
--WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVacinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,
	SUM(cast(Vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVacinated
FROM CovidDeaths dea
JOIN CovidVaccinations Vac
	ON dea.location = Vac.location AND dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


