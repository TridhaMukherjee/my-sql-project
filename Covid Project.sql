Select * 
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
order by 3,4

Select * 
From PortfolioProjectCovid..CovidVaccinations
order by 3,4

--Selecting data that I am going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows what %age of population got covid

Select location, date, total_cases, total_deaths, population,Convert(Decimal(18,2),total_deaths)/Convert(Decimal(18,2),total_cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where location like '%States%'
and continent is not null
order by 1,2

--looking at countries with highest infections rate compared to population

Select location, MAX(total_cases) as HighestInfections, population, MAX((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death counts per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
--to get rid of world, upper middle class and middle class values
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Let's break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Convert(Decimal(18,2),SUM(cast(new_deaths as int)))/Convert(Decimal(18,2),SUM(new_cases))*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
--Where location like '%States%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

