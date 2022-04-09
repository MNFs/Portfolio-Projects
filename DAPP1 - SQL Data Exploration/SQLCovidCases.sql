
SELECT date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,5) AS DeathPercentage
FROM PortfolioProjekt..CovidDeaths
where location = 'World'
order by 4 DESC



--SELECT *
--FROM PortfolioProjekt..CovidVaccination
--ORDER BY 3,4

-- Select the data we are using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjekt..CovidDeaths
ORDER BY 1,2

--Change columns datatype from nvarchar to float
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_cases FLOAT

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_deaths FLOAT

--Looking at Total Cases vs Total Deaths 
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at Total Cases vs population
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN [population] FLOAT

SELECT location, date, total_cases,  population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProjekt..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at Total Deaths vs population VS Case VS DeathPertenctage
SELECT location, date, population, 
total_cases, ROUND((total_cases/population)*100, 3) as CasePercentage,
total_deaths, ROUND((total_deaths/population)*100,3) as DeathPercentage,
ROUND((total_deaths/total_cases)*100,3) as DeathCasePercentage
FROM PortfolioProjekt..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Search for the highest infections
SELECT location, population,
MAX(total_cases) as MaxCases,
ROUND(MAX(total_cases/population)*100, 3) as CasePercentage,
ROUND(MAX(total_deaths/population)*100,3) as DeathPercentage
FROM PortfolioProjekt..CovidDeaths
GROUP BY location, population
ORDER BY 5 DESC

-- Continent Data

SELECT continent, MAX(total_deaths) as ContinentDeaths
FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

--CONTINENT (World population number not correct)
/*SELECT continent, MAX(population) AS Popultion, MAX(CAST(total_deaths AS INT)) AS TotalDeaths, ROUND(MAX(CAST(total_deaths AS INT))/MAX(population),4) AS DeathPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE  continent IS NOT NULL 
GROUP BY continent
ORDER BY 4 DESC*/

SELECT location, MAX(population) AS Popultion, MAX(CAST(total_deaths AS INT)) AS TotalDeaths, ROUND(MAX(CAST(total_deaths AS INT))/MAX(population),4) AS DeathPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE  location = 'World'
GROUP BY continent, location
ORDER BY 4 DESC

SELECT SUM(Popultion)
From (
Select MAX(population) AS Popultion
FROM PortfolioProjekt..CovidDeaths
WHERE  continent IS NULL AND location <> 'WORLD' AND location <> 'European Union' AND location <> 'High income'
AND location <> 'Upper middle income' AND location <> 'Lower middle income' AND location <> 'Low income'
AND location <> 'International'
GROUP BY location) t



SELECT location, MAX(population) AS Popultion, MAX(CAST(total_deaths AS INT)) AS TotalDeaths, ROUND(MAX(CAST(total_deaths AS INT))/MAX(population),4) AS DeathPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE  continent IS NULL AND location <> 'WORLD' AND location <> 'European Union' AND location <> 'High income'
AND location <> 'Upper middle income' AND location <> 'Lower middle income' AND location <> 'Low income'
AND location <> 'International'
GROUP BY location
ORDER BY 4 DESC


SELECT  Location, MAX(population) AS Popultion, MAX(CAST(total_deaths AS INT)) AS TotalDeaths, ROUND(MAX(CAST(total_deaths AS INT))/MAX(population),4) AS DeathPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NULL AND location <> 'European Union' AND location <> 'High income'
AND location <> 'Upper middle income' AND location <> 'Lower middle income' AND location <> 'Low income'
AND location <> 'International' 
GROUP BY  Location
ORDER BY 4 DESC

-- Covid fertõzés és halálesetek számának idõbeli alakulása a világon

SELECT date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,5) AS DeathPercentage
FROM PortfolioProjekt..CovidDeaths
where location = 'World'
order by 1 

--VAKCINÁS ADATTÁBLA

SELECT  date, total_vaccinations
FROM [PortfolioProjekt]..[CovidVaccination]
where location = 'World'
order by 1  

-- KÉT ADATTÁBLA ÖSSZEOLVASZTÁSA
SELECT dea.date, dea.population, MAX(dea.total_cases) as TotalCases, MAX(dea.total_deaths) AS TotalDeaths, MAX(ROUND((dea.total_deaths/dea.total_cases)*100,5)) AS DeathPercentage, 
MAX(vac.people_vaccinated) AS TotalVac, MAX(ROUND((vac.people_vaccinated/dea.population)*100,5)) AS Vacinated 
FROM PortfolioProjekt..CovidDeaths dea
JOIN [PortfolioProjekt]..[CovidVaccination] vac
	ON dea.date = vac.date
	and dea.location = vac.location
where vac.location = 'World'
GROUP BY dea.date, dea.population
ORDER BY 1

--SELECT dea.date, dea.total_cases, dea.total_deaths, vac.total_vaccinations
--FROM PortfolioProjekt..CovidDeaths dea
--JOIN [PortfolioProjekt]..[CovidVaccination] vac
--	ON dea.date = vac.date
--where dea.location = 'World'
--ORDER BY 1

SELECT dea.date, Max(vac.total_vaccinations)
FROM PortfolioProjekt..CovidDeaths dea
JOIN [PortfolioProjekt]..[CovidVaccination] vac
	ON dea.date = vac.date
where vac.location = 'World'
GROUP BY dea.date
ORDER BY 1


SELECT  *
FROM [PortfolioProjekt]..[CovidVaccination]
where location = 'World'
order by 1  


-- PARTITION BY napi beadott új oltások
SELECT dea.location, dea.date, dea.population, dea.total_cases as TotalCases, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location  ORDER BY dea.date), vac.total_vaccinations
FROM PortfolioProjekt..CovidDeaths dea
JOIN [PortfolioProjekt]..[CovidVaccination] vac
	ON dea.date = vac.date
	and dea.location = vac.location
where vac.location = 'World'
ORDER BY 1


select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as TotalInjectedVaccines
from PortfolioProjekt..CovidDeaths dea 
join PortfolioProjekt..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL and dea.location = 'Hungary'
order by 1, 2



/*
USE CTE 
hogy egy épp létrehozott oszloppal (Itt a TotalInjectedVAccines) tudjunk mûveletet 
végezni, mert egyébként nem lehet
Az ideiglenes táblában azonos számú oszlopot kell megadni, mint amennyit oszlopot át akarunk vinni,
majd a külsö Selectben tudunk új oszlopokat is létrehozni
*/

With PopvsVAC (Continent, Location, Date, Population, NewVac, TotalInjectedVac)
as (
select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
from PortfolioProjekt..CovidDeaths dea 
join PortfolioProjekt..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL and dea.location = 'Hungary'
)
Select *, ROUND((TotalInjectedVac/Population)*100,3) As VacinationsPercentage
from PopvsVAC
order by 1, 2


/* USE TEMP

*/
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population float, 
NewVac float, 
TotalInjectedVac float,
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
from PortfolioProjekt..CovidDeaths dea 
join PortfolioProjekt..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL and dea.location = 'Hungary'

SELECT *, ROUND((TotalInjectedVac/Population)*100,3) As PercentPopulationVaccinated
from #PercentPopulationVaccinated


--Create View

CREATE VIEW PPV as
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as Totality
from PortfolioProjekt..CovidDeaths dea 
join PortfolioProjekt..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL and dea.location = 'Hungary'

Select *
from PPV



---------- DATA FOR TABLEOU -----------

--Kontinensek adatai

--Select location, SUM(CAST(new_cases as numeric)) as TotalCases, 
--MAX(total_cases) as TC, SUM(CONVERT(numeric, new_deaths)) as TotalDeaths,
--MAX(total_deaths) as TD, 
--ROUND(SUM(CONVERT(numeric, new_deaths))/SUM(CAST(new_cases as numeric))*100,3) 
--as DeathPercentage
--from [PortfolioProjekt]..[CovidDeaths]
--WHERE  continent IS NOT NULL  AND location <> 'European Union' AND location <> 'High income'
--AND location <> 'Upper middle income' AND location <> 'Lower middle income' AND location <> 'Low income'
--group by location
--order by ROUND(SUM(CONVERT(numeric, new_deaths))/SUM(CAST(new_cases as numeric))*100,3) DESC

Select SUM(CAST(new_cases as numeric)) as TotalCases, 
SUM(CONVERT(numeric, new_deaths)) as TotalDeaths,
ROUND(SUM(CONVERT(numeric, new_deaths))/SUM(CAST(new_cases as numeric))*100,3) as DeathPercentage
from [PortfolioProjekt]..[CovidDeaths]
WHERE  continent IS NOT NULL  AND location <> 'European Union' AND location <> 'High income'
AND location <> 'Upper middle income' AND location <> 'Lower middle income' AND location <> 'Low income'

Select location,
SUM(CONVERT(numeric, new_deaths)) as TotalDeaths
from [PortfolioProjekt]..[CovidDeaths]
WHERE  continent IS NULL  AND location  not in ('European Union', 'High income', 'Upper middle income',
'Lower middle income', 'Low income', 'World')
group by location
order by TotalDeaths DESC

SELECT continent, location, population, MAX(total_cases) AS TotalCases, 
ROUND((MAX(total_cases)/population)*100,3) AS InfectionPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, continent
ORDER BY InfectionPercentage DESC


SELECT location, population, date, MAX(total_cases) AS TotalCases, 
ROUND((MAX(total_cases)/population)*100,3) AS InfectionPercentage
FROM PortfolioProjekt..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY InfectionPercentage DESC
