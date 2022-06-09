
--Used basic SQL skills, created a CTE to help with analysis and organization, JOINS, WHERE, Aggregate Functions

select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by location, date;

select location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject.. CovidDeaths
Where continent is not null
order by location date;


--Looking at percentage of deaths to cases under the covid deaths table
--Shows likelihood of death in the US after getting covid
select location, date, total_cases, total_deaths, (total_deaths/ total_cases)* 100 as DeathPercentage
From PortfolioProject.. CovidDeaths
where location like '%states%'
and continent is not null
order by location, date;

--Looking at total cases vs population for the U.S
--Showin in DESC to show most recent numbers at top
--Shows what percent of population got covid
select location, date,population, total_cases, (total_cases/ population)* 100 as PercentPopulation
From PortfolioProject.. CovidDeaths
where location like '%states%'
and continent is not null
order by location, date;

--Comparing countries with highest infection rate to  their population
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as 
	PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentOfPopulationInfected desc;


--Shows continent with the highest death count to population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc;

select continent, MAX(convert(int,total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc;

--GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths,SUM(cast 
	(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
--where location like '%states%'
where continent is not null
--group by date 
order by 1,2

--Joining both covdeaths table and covvaccinations table to look at data side by side
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date;

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
--order by 2, 3;



--USE CTE; Running US Total and percentage of population vaxed
With PopvsVac (Continent, Location, Date, Population, RollingPeopleVaccinated, new_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
)

select *, (RollingPeopleVaccinated/Population)*100 as PopVac
from PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopualtionVaccinated
CREATE TABLE #PercentPopualtionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopualtionVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
order by 2, 3


select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopualtionVaccinated


--Creating View to store data for later viualizations

Create View PercentPopualtionVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL

select *
from PercentPopualtionVaccinated


create view HighestInfectedCount as
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as 
	PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
--order by PercentPopulationInfected desc

create view PercentPopulation as 
select location, date,population, total_cases, (total_cases/ population)* 100 as PercentPopulation
From PortfolioProject.. CovidDeaths
where location like '%states%'
and continent is not null
--order by 1,2


 











