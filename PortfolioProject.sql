SELECT * 
FROM PortfolioProject..[covid-deaths]
Where continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProject..[covid-vaccinations]
--ORDER BY 3,4

--SELECT Data we will be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[covid-deaths]
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Death in certain country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..[covid-deaths]
WHERE location like '%states%' 
order by 1,2

-- Looking at % of total_cases in certain country
SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..[covid-deaths]
WHERE location like '%Myanmar%'
order by 1,2

-- Looking at max cases of countries
SELECT Location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentOfPopulationInfected
FROM PortfolioProject..[covid-deaths]
group by location,population
order by PercentOfPopulationInfected desc

--lets break things down by continent
SELECT location , MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[covid-deaths]
Where continent is null
group by location
order by TotalDeathCount desc

-- showing countries with highest death count per population
SELECT Location,population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[covid-deaths]
Where continent is not null
group by location,population
order by TotalDeathCount desc

--Global Numbers 
SELECT  SUM(new_cases) as totalNewCases, SUM (cast(new_deaths as int))as totalNewDeaths, (SUM (cast(new_deaths as int))/SUM(new_cases)) *100 as DeathPercentage
FROM PortfolioProject..[covid-deaths]
WHERE continent is not null
--Group by date
order by 1,2



--Covid Vaccination

--join tables and looking at Total Population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..[covid-deaths] as dea
JOIN PortfolioProject..[covid-vaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2,3

--looking at Total Population vs vaccinations
--USE CTE
With PopVsVac (Continent, location, date, population,New_Vaccination, RollingPeopleVaccinated)
as ( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[covid-deaths] dea
JOIN PortfolioProject..[covid-vaccinations] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac --WHERE location like '%Singapore%'

--TEMP Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(Continent varchar(255), location varchar(255), date datetime,
population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[covid-deaths] dea
JOIN PortfolioProject..[covid-vaccinations] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated --WHERE location like '%Singapore%'

--Creatubg View
Create View PercentPoulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[covid-deaths] dea
JOIN PortfolioProject..[covid-vaccinations] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 


SELECT * FROM PercentPoulationVaccinated
