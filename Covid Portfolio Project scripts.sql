SELECT *
FROM PortfolioProject..CovidDeathsRight$
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Selct the Data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeathsRight$
Order By 1,2

--Looking at the Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeathsRight$
WHERE continent is not null
Order By 1,2

--Looking at Total Cases vs Population in United States
--Shows what percentage of United States population contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as percentage_of_population
FROM PortfolioProject..CovidDeathsRight$
Order By 1,2

--Looking at Countries with highest infection rate compared to Population

SELECT location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_population_infected
FROM PortfolioProject..CovidDeathsRight$
GROUP BY location, population
Order By percentage_population_infected desc


--This is showing the Countries with the highest Death Count per Population

SELECT location, population, max(cast(total_deaths as int)) as death_count
FROM PortfolioProject..CovidDeathsRight$
WHERE continent is not null
GROUP BY location, population
Order By death_count desc


--Break down by Continent with highest death count

SELECT continent, max(cast(total_deaths as int)) as death_count
FROM PortfolioProject..CovidDeathsRight$
WHERE continent is not null
GROUP BY continent
Order By death_count desc


--Global Numbers

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeathsRight$
WHERE continent is not null
GROUP BY date
Order By 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population)
FROM PortfolioProject..CovidDeathsRight$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 


--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population)
FROM PortfolioProject..CovidDeathsRight$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaccinated)/population)*100
FROM PopvsVac


--Temp Table

Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeathsRight$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *,(rolling_people_vaccinated)/(population)*100
FROM #PercentPopulationVaccinated


--Creating View for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/dea.population)
FROM PortfolioProject..CovidDeathsRight$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


