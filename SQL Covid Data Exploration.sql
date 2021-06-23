select *
from PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4

----select *
----from PortfolioProject..CovidVaccinations$
----order by 3,4

--select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at Total Cases vs Total Deaths 
-- shows likelikehood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at the total cases vs population
-- shows what percentage of population got covid 

select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
order by 1,2


-- Looking at Countries wiht highest infection rate compared to population


select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
Group BY Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with highest Death Count per population


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
Where continent is not null 
Group BY Location
order by TotalDeathCount desc


-- Let's break things down by continent 


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
Where continent is not null 
Group BY continent
order by TotalDeathCount desc


-- Global Numbers


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as tota_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
Where continent is not null
-- Group by date
order by 1,2


-- Looking at total population vs vaccinations 


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 order by 2,3


-- Use CTE 

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 -- order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac


 -- Temp Table 

 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert Into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
-- Where dea.continent is not null
 -- order by 2,3 

 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


 -- Creating View to Store date for later visualizations

 Create View PercentPopulationVaccinated as 
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3 


Select *
From PercentPopulationVaccinated