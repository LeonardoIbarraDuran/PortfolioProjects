select *
from PortafolioProject..CovidDeaths
where continent is not null 
order by 3,4

SELECT *
FROM PortafolioProject..CovidVaccinations
order by 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING

select location, date, total_cases, new_cases, total_deaths, population
from PortafolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOW LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

Select location, date, total_cases,  total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortafolioProject..CovidDeaths
WHERE location like '%mex%' and continent is not null 
order by 1,2


-- Looking at total cases vs population
-- Show what percentage of population got covid
  
Select location, date, population, total_cases, (total_cases/population) * 100 as totalcasesbyPercentage
from PortafolioProject..CovidDeaths
--WHERE location like '%states%' and continent is not null 
order by 1,2


--- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

Select location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)) * 100 as PercentpulationInfected
from PortafolioProject..CovidDeaths
--WHERE location like '%states%'
group by location,population
order by PercentpulationInfected desc


-- Showing the countries with higuest death count per population

Select location, MAX(cast(total_deaths as int)) AS totaldeathCount
from PortafolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null 
group by location
order by totaldeathCount desc


-- LET´S BREAK THINGS DOWN BY CONTINENT(NO DIO LOS RESULTADOS) THEN BY LOCATION 

Select location, MAX(cast(total_deaths as int)) AS totaldeathCount
from PortafolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is  null 
group by location
order by totaldeathCount desc
 

 --SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

 Select continent, MAX(cast(total_deaths as int)) AS totaldeathCount
from PortafolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null 
group by continent
order by totaldeathCount desc


--GLOBAL NUMBERS W/out date

Select  sum(new_cases)as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortafolioProject..CovidDeaths
--WHERE location like '%mex%' 
WHERE continent is not null 
--group by date
order by 1,2

--- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT  DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, 
 SUM(CAST(VAC.new_vaccinations AS INT)) over ( partition by DEA.location ORDER BY DEA.location,DEA.date) as RollingPeopleVaccinated --- add consecutives ones with sum by day and location
 --(RollingPeopleVaccinated/population) * 100 --- NO FUNCIONA, CREAR UNA TABLA TEMPORAL PARA CONSULTAR o CTE
 from PortafolioProject..CovidDeaths DEA
 JOIN PortafolioProject..CovidVaccinations VAC
 on DEA.location = VAC.location AND DEA.date
 = VAC.date 
 WHERE dea.continent is not null 
 order by 2,3

 --USE CTE 

 WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated) 
 as 
 (
 SELECT  DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, 
 SUM(CAST(VAC.new_vaccinations AS INT)) over ( partition by DEA.location ORDER BY DEA.location,DEA.date) as RollingPeopleVaccinated --- add consecutives ones with sum by day and location
 from PortafolioProject..CovidDeaths DEA
 JOIN PortafolioProject..CovidVaccinations VAC
 on DEA.location = VAC.location AND DEA.date
 = VAC.date 
 WHERE dea.continent is not null 
 --order by 2,3
 )
  SELECT *,(RollingPeopleVaccinated/population) * 100 as Percentage
  FROM PopvsVac


  -- TEMP TABLE

  DROP TABLE IF EXISTS #poblacionvacunada
  CREATE TABLE #poblacionvacunada
  ( 
    continent nvarchar (255),
    location nvarchar  (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	
  INSERT INTO #poblacionvacunada
  SELECT  DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, 
 SUM(CAST(VAC.new_vaccinations AS INT)) over ( partition by DEA.location ORDER BY DEA.location,DEA.date) as RollingPeopleVaccinated --- add consecutives ones with sum by day and location
 from PortafolioProject..CovidDeaths DEA
 JOIN PortafolioProject..CovidVaccinations VAC
 on DEA.location = VAC.location AND DEA.date
 = VAC.date 
 --WHERE dea.continent is not null 
 --order by 2,3

 SELECT *,(RollingPeopleVaccinated/population) * 100 as perc
  FROM #poblacionvacunada


  -- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS 

  use PortafolioProject

  create view poblacionvacunada as

  SELECT  DEA.continent, DEA.location, DEA.date, DEA.population,VAC.new_vaccinations, 
 SUM(CAST(VAC.new_vaccinations AS INT)) over ( partition by DEA.location ORDER BY DEA.location,DEA.date) as RollingPeopleVaccinated --- add consecutives ones with sum by day and location
 from PortafolioProject..CovidDeaths DEA
 JOIN PortafolioProject..CovidVaccinations VAC
 on DEA.location = VAC.location AND DEA.date
 = VAC.date 
 WHERE dea.continent is not null 
 --order by 2,3


 ---
 select *
 from poblacionvacunada