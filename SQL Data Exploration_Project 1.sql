--SELECT *
--FROM CovidDeaths
-- where continent is not null
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
where continent is not null 
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeaths
where continent is not null 
and 
WHERE location like '%iran%'

ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date,population, total_cases, (total_deaths/population)*100 as Death_Percentage
FROM CovidDeaths
where continent is not null 
-- WHERE location like '%iran%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_Population_Infected
FROM CovidDeaths
where continent is not null 
GROUP BY location, population
ORDER BY Percentage_Population_Infected desc

-- Showing Countries with Highest Death Count per Population 

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidDeaths
where continent is not null 
GROUP BY location
ORDER BY Total_Death_Count desc

-- LET'S BREAK THINGS DOWN BY LOCATION


SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidDeaths 
where continent is null
GROUP BY location
ORDER BY Total_Death_Count desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with Highest death ount per population

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidDeaths 
where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From CovidDeaths
where continent is not null
Group By date
order by 1,2

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vactinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vacinated
-- (Rolling_People_Vacinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (continent, location, Date, population, new_vaccinations, Rolling_People_Vacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as Rolling_People_Vacinated
-- (Rolling_People_Vacinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)

Select *, (Rolling_People_Vacinated/population)*100
From PopvsVac



--TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


