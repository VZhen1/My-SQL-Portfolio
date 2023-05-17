/* 

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
From PortfolioProject1..CovidDeaths
-- where continent is not null
order by 3,4

--Select * 
--From PortfolioProject1..CovidVaccinations
--order by 3,4

ALTER TABLE PortfolioProject1..CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject1..CovidDeaths
ALTER COLUMN total_cases float

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject1..CovidDeaths
order by 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, ROUND((total_cases/population)*100,2) as CovidPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 

Select Location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) as CovidPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
GROUP BY location, population
order by CovidPercentage desc

-- Looking at Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing continents with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
where continent is not null 
Group by date
order by 1,2

-- Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
-- , (RollingVaccinatedCount/population)*100
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

-- Using CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedCount) as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
from PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingVaccinatedCount/Population)*100 as RollingVaccinatedPercentage
From PopvsVac

-- Using Temp Table instead for previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinatedCount
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingVaccinatedCount/Population)*100 as RollingVaccinatedPercentage
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinatedCount
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated

Create View CovidPopulationPercentage as 
Select Location, date, population, total_cases, ROUND((total_cases/population)*100,2) as CovidPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
--order by 1,2

Create View GlobalCovidCasesAndDeaths as
Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
-- Where location like '%states%'
where continent is not null 
Group by date
--order by 1,2
