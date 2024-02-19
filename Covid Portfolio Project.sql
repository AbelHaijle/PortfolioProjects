


--select *
--from PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject.dbo.CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%netherlands'
order by 1,2

select location, date, total_cases, population, (total_cases/population) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%netherlands'
order by 1,2


select location, population, MAX(total_cases) as HighestInfection,  MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%netherlands'
group by location, population
order by PercentPopulationInfected desc

--Countries with highest deathcount per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%netherlands'
where continent is null
group by location
order by TotalDeathCount desc


--showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%netherlands'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%netherlands'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE


Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated