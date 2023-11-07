Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2



--Looking at Total Cases VS Total Deaths 
--Shows the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths,
CAST(total_deaths AS float) / CAST(total_cases AS float) AS death_rate
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the Total Cases VS the Population
--Shows percentage of the population got COVID

SELECT location, date,population, total_cases, 
CAST(total_cases AS float) / CAST(population AS float) AS PercentofPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
CAST(MAX(total_cases) AS float) / CAST(population AS float) AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY location, population
ORDER BY PercentofPopulationInfected desc


-- Lets Break things down by continent 


SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--  GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM
(new_cases),0)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

--Looking at total population vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--CTE
With PopsvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
) 
Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac

--Temp Table
Drop Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3
Select *, (RollingPeopleVaccinated/Population)*100
From #percentPopulationVaccinated

-- Creating View for later to store data for visualizations 
USE PortfolioProject
GO
Create View percentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

select *
from percentPopulationVaccinated