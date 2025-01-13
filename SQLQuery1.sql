-- Portofolio Exploratory Data Analysis

select *
from portofolioProject..CovidDeaths
order by 3,4


-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from portofolioProject..CovidDeaths
order by location, date

-- Looking at total cases vs total deaths
-- show location at Indonesia
select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from portofolioProject..CovidDeaths
where location like '%nesia'
order by location, date

-- Looking at percentage got covid

select location, date,population, total_cases, (total_cases/population)*100 as PercentagePopulationgotCovid
from portofolioProject..CovidDeaths
where location like '%nesia'
order by location, date

-- Looking at countries with Highest Infection Rate compared to population
 
select location,population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageInfection
from portofolioProject..CovidDeaths
group by location, population
order by PercentageInfection desc

-- Showing Countries with Highest Death Count per Pupulation

select location, Max(cast(total_deaths as int)) as DeathTotalPerCountry
from portofolioProject..CovidDeaths
where continent is not null
group by location
order by DeathTotalPerCountry desc


-- Break down by Continent
-- Showing continents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as DeathTotalPercontinent
from portofolioProject..CovidDeaths
where continent is not null
group by continent
order by DeathTotalPercontinent desc


-- Global Numbers

select  SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from portofolioProject..CovidDeaths
where continent is not null
--group by date 
order by 1,2


-- Table vaccinations

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portofolioProject..CovidVacination vac
join portofolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac
(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portofolioProject..CovidVacination vac
join portofolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac
	

--Temporary Table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portofolioProject..CovidVacination vac
join portofolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated