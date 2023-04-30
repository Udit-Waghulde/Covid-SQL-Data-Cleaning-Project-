-- Selecting data that we need --


SELECT 
    location, continent, date, total_deaths, new_cases, population
FROM
    dataanalysisproject.coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY location , date;

-- Looking at total cases vs total deaths -- 
-- Shows the likelyhood of dying if you contract covid in India -- 

SELECT 
    location,
    date,
    total_deaths,
    total_cases,
    (total_deaths / total_cases) * 100 AS Death_percentage
FROM
    dataanalysisproject.coviddeaths
WHERE
    location = 'India'
ORDER BY location;

-- Looking at total cases vs population -- 
-- Shows what % of population got covid -- 
SELECT 
    location,
    date,
    total_deaths,
    total_cases,
    population,
    (total_cases / population) * 100 AS Infected_percentage
FROM
    dataanalysisproject.coviddeaths
WHERE location = 'India';

-- Looking at countries with highest infection rate compared to population -- 
SELECT 
    location,
    MAX(total_cases) AS Highest_infection_count,
    population,
    MAX((total_cases / population)) * 100 AS Infected_percentage
FROM
    dataanalysisproject.coviddeaths
GROUP BY location , population
ORDER BY Infected_percentage DESC;


-- Showing countries with highest death count per population -- 
SELECT 
    location,
    MAX(CAST(total_deaths AS DECIMAL)) AS Total_death_count
FROM
    dataanalysisproject.coviddeaths
WHERE NOT
    location IN ('Africa', 'Asia', 'Europe', 'North america', 'European Union', 'South America', 'High income', 'Low Income')
GROUP BY location
ORDER BY Total_death_count DESC;

-- Breaking things down by continent
SELECT 
    continent,
    MAX(CAST(total_deaths AS DECIMAL)) AS Total_death_count
FROM
    dataanalysisproject.coviddeaths
GROUP BY continent
ORDER BY Total_death_count DESC;


-- Global Numbers --

SELECT 
    sum(new_cases) as total_cases,
    sum(cast(new_deaths as decimal)) as total_deaths,
    sum(cast(new_deaths as decimal))/sum(new_cases)*100 as Death_percentage
FROM
    dataanalysisproject.coviddeaths
ORDER BY location;

-- Total population vs vaccination -- 

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
    
FROM
    dataanalysisproject.coviddeaths AS dea
        JOIN
    dataanalysisproject.covidvaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    NOT dea.location IN ('Africa' , 'Asia',
        'Europe',
        'North america',
        'European Union',
        'South America',
        'High income',
        'Low Income');


-- Using CTE to find out the percentage of population actually vaccinated --

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    SUM(cast(vac.new_vaccinations AS DECIMAL))  OVER ( PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from 
    dataanalysisproject.coviddeaths AS dea JOIN dataanalysisproject.covidvaccinations AS vac 
    ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    NOT dea.location IN ('Africa' , 'Asia',
        'Europe',
        'North america',
        'European Union',
        'South America',
        'High income',
        'Low Income')
;

--------------------------------------------------------------------------------------------------------------------------

WITH PopvsVac as (
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population as population,
    vac.new_vaccinations, 
    SUM(cast(vac.new_vaccinations AS DECIMAL))  OVER ( PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from 
    dataanalysisproject.coviddeaths AS dea JOIN dataanalysisproject.covidvaccinations AS vac 
    ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    NOT dea.location IN ('Africa' , 'Asia',
        'Europe',
        'North america',
        'European Union',
        'South America',
        'High income',
        'Low Income')
        
ORDER BY dea.location, dea.date        
) 

select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac
;


