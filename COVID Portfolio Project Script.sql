USE Project1

select *
from CovidDeath
order by 3,4;

--select *
--from CovidVaccination
--order by 3,4;

--selecting the data to be used in the project

select location,date,population,total_cases,total_deaths,new_cases
from CovidDeath
order by 1,2

--Lookinng for total cases vs total deaths
--show likelihood death ratio in my country

select location,date,total_cases,total_deaths,(cast(total_deaths as decimal)/total_cases)*100 as Death_Ratio
from project1.dbo.CovidDeath
where location = 'egypt'
order by 1,2

--Lookinng for total cases vs population
--show likelihood infection ratio in my country

select location,date,total_cases,total_deaths,population,(cast(total_cases as decimal)/population)*100 as Infection_Ratio
from project1.dbo.CovidDeath
where location = 'egypt'
order by 1,2

--Looking for country with highest infection rate compared to population

select location,population,MAX(total_cases) as max_cases,(max(cast(total_cases as decimal)/population)*100) as Highest_Infection_Ratio
from project1.dbo.CovidDeath
group by location,population
order by 4 desc

--Looking for country with highest death count compared to population

select location,population,MAX(total_deaths) as max_deaths,(max(cast(total_deaths as decimal)/population)*100) as Highest_Death_Ratio
from project1.dbo.CovidDeath
where continent is not null
group by location,population
order by 3 desc

--Looking for continent with highest death count compared to population

select continent,MAX(total_deaths) as max_deaths,(max(cast(total_deaths as decimal)/population)*100) as Highest_Death_Ratio
from project1.dbo.CovidDeath
where continent is not null
group by continent
order by 3 desc

--Global numbers

Select date,SUM(new_cases) new_case,SUM(new_deaths) new_death,SUM(total_cases) total_case, SUM(cast(new_deaths as decimal))/SUM(new_cases)
from CovidDeath
where continent is not null
group by date
order by 1

--Join tables

Select *
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	AND dea.date = vac.date

--Looking for total vaccination vs population

Select dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date) as Cum_Vacci, vac.total_vaccinations
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
	AND vac.new_vaccinations is not null
order by 1,2

--Use CTE

WITH POPvsVAC (location,date,population,new_vaccinations,Cum_Vacci,total_vaccinations)
as (
Select dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date) as Cum_Vacci, vac.total_vaccinations
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
	AND vac.new_vaccinations is not null
--order by 1,2
)
Select *, (Cum_Vacci/population)*100 as Vac_Ratio
FROM POPvsVAC


--USE TEMP TABLE

DROP TABLE if exists #POPvsVAC
Create table #POPvsVAC
(
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
Cum_Vacci numeric,
total_vaccinations numeric
)

Insert into #POPvsVAC

Select dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date) as Cum_Vacci, vac.total_vaccinations
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
	AND vac.new_vaccinations is not null

Select *, (Cum_Vacci/population)*100 as Vac_Ratio
FROM #POPvsVAC

--Create View

Create view POPvsVAC as
Select dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date) as Cum_Vacci, vac.total_vaccinations
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
	AND vac.new_vaccinations is not null

select *
from POPvsVAC
