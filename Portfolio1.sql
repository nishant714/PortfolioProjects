select * from PortfolioProject..[CovidDeaths]
order by 1,2

--Looking at total Cases vs Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
order by 1,2

--Shows likelihood of dying if you contract Covid in India

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2


--Looking at countries with Highest Infection rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select location,population,max(cast(total_deaths as int)) as TotalDeathCount,Max((cast(total_deaths as int)/population))*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by TotalDeathCount desc

--Showing Continents with Highest Death Count per Population 

select continent,sum(TotalDeathCount) as DeathCount from 
(select location,continent,max(cast(total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths
where continent is not null
group by location,continent) t
group by continent
order by 2 desc

-- Global Numbers

Select date,sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where continent is not null

select * from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on 
dea.date = vac.date and dea.location = vac.location

-- Vaccinations

select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on 
dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 2,3

--CTE

with PopVac as 
(select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on 
dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2,3
)

select *,RollingTotalVaccination/population*100 as PercentPopulationVaccinated from Popvac
order by location,date

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVaccination numeric
)

Insert into #PercentPopulationVaccinated
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on 
dea.date = vac.date and dea.location = vac.location
where dea.continent is not null

select *,RollingTotalVaccination/population*100 as PercentPopulationVaccinated from #PercentPopulationVaccinated
order by location,date

-- View

CREATE VIEW PopulationVaccinated AS 
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingTotalVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on 
dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
