use PortfolioProject



select*
from [dbo].[CovidDeaths]
order by 3,4

--select*
--from [dbo].[CovidVaccinations]
--order by 3,4

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

/*
To check data type
select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
*/

 --(both total cases and total deaths are nvarchar)

 select location, date, total_cases, total_deaths, 
 (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
 from dbo.CovidDeaths
 where location like '%states'
 order by 1,2

 
 -- looking at total cases vs population 
 -- shows what % of population got Covid
 select location, date, population, total_cases, 
 (cast(total_cases as float)/population) * 100 as PercentPopulationInfected
 from dbo.CovidDeaths
  where continent is not null
 --where location like '%states'
 order by 1,2


 -- Looking at countries with highest infection rate compared to population 
 select location, population, max(cast(total_cases as float)) as HighestInfectionCount, 
 max((cast(total_cases as float)/population)) * 100 as PercentPopulationInfected
 from dbo.CovidDeaths
  where continent is not null
 --where location like '%states'
 group by location, population
 order by PercentPopulationInfected desc


 -- showing countries with highest death count per population
 select location, max(cast(total_deaths as float)) as TotalDeathCount
 from dbo.CovidDeaths
 where continent is not null 
 group by location
 order by TotalDeathCount desc


 -- let's break things down by continent
 select continent, max(cast(total_deaths as float)) as TotalDeathCount
 from dbo.CovidDeaths
 where continent is not null 
 group by continent
 order by TotalDeathCount desc

 -- showing continents with the highest death count per population 


 -- Global numbers
select date, sum(new_cases), sum(new_deaths),
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1

-- new_cases has null or 0, use case when statement 

/*
select date, sum(new_cases), sum(new_deaths),
(select
	case
		when sum(new_cases) = 0 or sum(new_cases) is null then null
		else sum(new_deaths)/sum(new_cases)
	end as result
	from covidDeaths),
	sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
group by date
order by 1
*/

-- use case when as subquery !! 
select total_cases, total_deaths, result * 100 as Deathpercentage
from (select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
	  case
		when sum(new_cases) = 0 or sum(new_cases) is null then null
		else sum(new_deaths)/sum(new_cases)
	end as result
	from covidDeaths
	group by date) as subquery
order by 1,2


------------------------

--looking at total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100 
-- going to use a CTE/Tem table to store the column that i just created which is rollingpeoplevaccinated
from Coviddeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3

--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100 
-- going to use a CTE/Tem table to store the column that i just created which is rollingpeoplevaccinated
from Coviddeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population) * 100 
from PopvsVac

-- order by clause can't be used in views, dt, subq, cte.. unless TOP, OFFSET

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from Coviddeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
--where d.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/Population) * 100 
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from Coviddeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
--where d.continent is not null
--order by 2,3
