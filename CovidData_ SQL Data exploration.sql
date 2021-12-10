--Dataset: OurWorldinData/Covid deaths
--		   OurWorldinData/Covid deaths
--Time line: Jan 28, 2020 - 3rd Dec, 2020
--My First Project


--select *
--from PortfolioProject..covid_Vaccination
--order by 3,4

--select *
--from PortfolioProject..covid_deaths
--order by 3,4

select location,date,population,total_cases,new_cases,total_deaths
from PortfolioProject..covid_deaths
order by 1,2

--looking at total deaths v/s total cases
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..covid_deaths
where location = 'India'
order by 1,2

--looking at total cases v/s population
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
where location = 'India'
order by 1,2

--looking at countries with highest infection rate as compared to its popuation
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covid_deaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's see interms of continent
--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date,SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
				AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
				AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total population v/s vaccination
--Use CTE's
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as decimal)) over (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_Vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for visualization
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as decimal)) over (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths dea
	JOIN PortfolioProject..covid_Vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated