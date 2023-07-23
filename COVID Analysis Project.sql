/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not NULL 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProjects..CovidDeaths
ORDER BY 1, 2

-- Examining Total Cases vs Total Deaths 
	-- DeathPercentage relays the likelihood of dying from COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
FROM PortfolioProjects..CovidDeaths
ORDER BY 1, 2

-- Examining Total Cases vs Population 
	-- Relays what percentage of the population has been contracted COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageOfPopulationInfected 
FROM PortfolioProjects..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Examining countries with highest infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentageOfPopulationInfected 
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population 
ORDER BY PercentageOfPopulationInfected DESC

-- Examining Total Death Count by Country  

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Examining Total Death Count by Continent   
 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not NULL 
GROUP BY continent 
ORDER BY TotalDeathCount DESC

-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

-- Joining CovidDeaths table with Covid Vaccinations table  

SELECT *
FROM PortfolioProjects..CovidDeaths AS Dea
JOIN PortfolioProjects..CovidVaccinations AS Vac
	ON dea.location = vac.location
	AND dea.date = vac.date 

-- Examining Total Population vs Vaccinations 
	-- Relays percentage of population that has recieved at least 1 COVID vaccine 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationRate
FROM PopvsVac

-- Using Temp Table to perform calculation on Partition By in the previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentOfPopulationVaccinated 
From #PercentPopulationVaccinated

-- Creating a View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 