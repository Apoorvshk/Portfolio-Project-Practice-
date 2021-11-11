SELECT *
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--where continent is not null
--order by 3,4

-- Selecting the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show how likely you will die if you get infected by covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location= 'India'
order by 1,2

--Looking at the Total cases vs Populaiton 
--Shows what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [Portfolio Project]..CovidDeaths
where location= 'India'
order by 1,2


-- Countries with highest percentage of infected people till date
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null and date='2021-11-07 00:00:00.000'
order by 5 desc


--Showing Countries with the Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as Total_deaths
From [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by 2 desc

--Death Percentage by location till date
select location, date, total_deaths, population, (total_deaths/population)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null and date='2021-11-07 00:00:00.000'
order by 5 desc

--LETS BREAK THINGS DOWN FOR CONTINENT

--Showing continents with the highest death count per population
select location, Max(cast(total_deaths as int)) as Total_deaths
From [Portfolio Project]..CovidDeaths
where continent is null
group by location
order by 2 desc

--GLOBAL NUMBERS

SELECT  SUM(new_cases) as Total_casees, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM((new_cases))*100 as Death_percentage
FROM [Portfolio Project]..CovidDeaths
where continent is not null


-- COVID VACCINATIONS DATA
--Loading the tabe
select *
From [Portfolio Project]..CovidVaccinations

select *
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date

--Looking at total populations vs vaccinationns
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
order by 2,3

--Rolling count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rolling_count
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not  null
--and dea.location = 'India'
order by 2,3

--USE CTE (Common Table Expression)

With PopvsVac (Continent, location, Date,population, New_Vaccinations, Rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rolling_count
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not  null)

select *, (rolling_count/population)*100 as Percentage_of_people_vaccinated
from PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PeopleVaccinatedPercentage  --Deletes the table fromed earlier
CREATE TABLE #PeopleVaccinatedPercentage
(
continet varchar(255),
location varchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingcount bigint
)


INSERT INTO #PeopleVaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rolling_count
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not  null

select *, (Rollingcount/population)*100 as Percentage_of_people_vaccinated
from #PeopleVaccinatedPercentage
where date = '2021-04-07 00:00:00.000' and
location = 'Gibraltar'
order by 7 desc

select --date, 
sum(cast(new_vaccinations as int))
from [Portfolio Project]..CovidVaccinations
where location = 'Gibraltar'
--group by date

--CREATING VIEW TO SAVE DATA FOR LATER VISUALIZATIONS


CREATE VIEW PeopleVaccinatedPercentage_V as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as Rolling_count
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not  null

SELECT * 
FROM PeopleVaccinatedPercentage_V
