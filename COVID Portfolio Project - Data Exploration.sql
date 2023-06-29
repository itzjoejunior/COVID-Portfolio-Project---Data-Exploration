

--Covid 19 Data Exploration

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

select *
from ProtfoioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with
Select Location, date, total_cases,total_deaths, population
From ProtfoioProject..CovidDeaths
order by 1,2

-- Total Cases vs Population
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, population, (total_deaths/total_cases)*100 as DeathPercentage
From ProtfoioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PreceagePopulationInfected
From ProtfoioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases)  as HighestInfectionCount, max(total_cases/population)*100 as PreceagePopulationInfected
From ProtfoioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PreceagePopulationInfected desc


 --Countries with Highest Death Count per Population

 Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From ProtfoioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProtfoioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProtfoioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select Death.continent, Death.location, Death.date, Death.population, Vaci.new_vaccinations
,sum(convert(int,Vaci.new_vaccinations)) over (partition by Death.location order by Death.location, Death.date) as RollingPeopleVaccinated
from ProtfoioProject..CovidDeaths Death
join ProtfoioProject..CovidVaccinations Vaci
on Death.location = Vaci.location
and Death.date = Vaci.date
where Death.continent is not null
--order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select Death.continent, Death.location, Death.date, Death.population, Vaci.new_vaccinations
,sum(convert(int,Vaci.new_vaccinations)) over (partition by Death.location order by Death.location, Death.date) as RollingPeopleVaccinated
from ProtfoioProject..CovidDeaths Death
join ProtfoioProject..CovidVaccinations Vaci
on Death.location = Vaci.location
and Death.date = Vaci.date
where Death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
select Death.continent, Death.location, Death.date, Death.population, Vaci.new_vaccinations
,sum(convert(int,Vaci.new_vaccinations)) over (partition by Death.location order by Death.location, Death.date) as RollingPeopleVaccinated
from ProtfoioProject..CovidDeaths Death
join ProtfoioProject..CovidVaccinations Vaci
on Death.location = Vaci.location
and Death.date = Vaci.date
--where Death.continent is not null
----order by 2,3

select *
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as

select Death.continent, Death.location, Death.date, Death.population, Vaci.new_vaccinations
,sum(convert(int,Vaci.new_vaccinations)) over (partition by Death.location order by Death.location, Death.date) as RollingPeopleVaccinated
from ProtfoioProject..CovidDeaths Death
join ProtfoioProject..CovidVaccinations Vaci
on Death.location = Vaci.location
and Death.date = Vaci.date
where Death.continent is not null
