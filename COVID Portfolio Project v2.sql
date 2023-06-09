/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- Selcet data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 As PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestestInfectionCount, MAX((total_cases/population))*100 As PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
Order BY PercentagePopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
ORDER BY 1,2


-- Total Poulation vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated, 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE to perform Calculation on Partition By in previous query

With PopvsVas (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVas



-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
lovation nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL


Create View TestsVsTotalCases AS
SELECT dea.date, vac.total_tests, dea.total_cases
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE vac.total_tests is not NULL AND dea.total_cases is not NULL


CREATE VIEW HandingwashingVSTotalCases AS
SELECT dea.date, dea.location, vac.handwashing_facilities, dea.total_cases
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE vac.handwashing_facilities is not NULL and dea.total_cases is not NULL