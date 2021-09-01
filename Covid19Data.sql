
/*
Covid 19 Data Exploration 
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Changing data type 
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE PortfolioProject..CovidDeaths 
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population float

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

-- Selecting Data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths (shows the percentage of deaths in relation to the number of cases in a given country)

Select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
order by 1,2


-- Total cases vs Population (shows what percentage of population got infected in a given country)

Select location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
order by 1,2


-- Countries with Highest Infection Rate comparing with their Population 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
Group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Deaths Countn per Population 

Select location, population, MAX(total_deaths) as HighestDeathsCount, MAX((total_deaths/population))*100 AS DeathsCases
From PortfolioProject..CovidDeaths
Where location = 'Poland'
Group by location, population
order by DeathsCases desc


-- Countries with Highest Deaths Count

Select location, MAX(total_deaths) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
Where continent is not null 
Group by location
order by TotalDeathsCount desc


-- Total Deaths Count by Continent (Showing contintents with the highest death count)

Select location, MAX(total_deaths) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathsCount desc


-- Worldwide numbers

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Poland'
where continent is not null 
--Group By date
order by 1,2


-- Population vs Vaccination (at least one vaccine) 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Percentage of vaccinated (Using CTE to perform Calculation on Partition By in previous query)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location= 'Poland'
)

Select *, (PeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac


-- Number of vaccinated persons in a given country

Select location, SUM(Cast(new_vaccinations as float)) as HighestDeathsCount
From PortfolioProject..CovidVaccinations
--Where location = 'Poland'
where continent is not null
Group by location
order by Location


-- Using Temp Table to perform Calculation on Partition By

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


