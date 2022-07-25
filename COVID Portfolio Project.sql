Select*
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4 

--Select*
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

--Total Cases vs Population

Select Location, date, total_cases, population, (Total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
order by 1,2

--Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases)as HighestInfectionCount, population, Max(Total_cases/population)*100 as 
PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

--Highest Death Count Per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--By Continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Where Continent is NULL

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Continents with Highest Death Rate Per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc

--Global Numbers (1)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Global Numbers (2)

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2

--Total Population vs Vaccinations 

Select *
From [Portfolio Project]..CovidDeaths
Join [Portfolio Project]..CovidVaccinations
	On CovidDeaths.Location = CovidVaccinations.Location
	and CovidDeaths.date = CovidVaccinations.date

Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
From [Portfolio Project]..CovidDeaths
Join [Portfolio Project]..CovidVaccinations
	On CovidDeaths.Location = CovidVaccinations.Location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 1,2,3 
-- Afghanistan = (Order by 1,2)

Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(CONVERT(bigint,CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location,
CovidDeaths.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths
Join [Portfolio Project]..CovidVaccinations
	On CovidDeaths.Location = CovidVaccinations.Location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3

-- With CTE

With PopulationvsVaccinations (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(CONVERT(bigint,CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location,
CovidDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths
Join [Portfolio Project]..CovidVaccinations
	On CovidDeaths.Location = CovidVaccinations.Location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationvsVaccinations

--With Temp Table

DROP Table if exists #PercentPopulationVaccinated -- DROP Table is used to make any alterations
Create Table #PercentPopulationVaccinated 
(
Contintent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(CONVERT(bigint,CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location,
CovidDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths
Join [Portfolio Project]..CovidVaccinations
	On CovidDeaths.Location = CovidVaccinations.Location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View To Store Data for Later Visualizations

Create View PercentPopulationVaccinated as 
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(CONVERT(bigint,CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location,
CovidDeaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths
Join [Portfolio Project]..CovidVaccinations
	On CovidDeaths.Location = CovidVaccinations.Location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3





