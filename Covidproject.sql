--9/5/2023 data Covid 

--a.continentwise cases
select location, max(total_cases) as total_cases from "CovidDeaths" 
where continent is null group by location order by total_cases desc;

--b.continentwise deaths
select location, max(total_deaths) as total_deaths from "CovidDeaths" 
where continent is null 
group by location order by total_deaths desc;

--c. country with highest death as % of population
select location,(max(total_deaths))/avg(cast(population as bigint))*100 as percentage 
from "CovidDeaths" 
group by location 
order by percentage desc;

--d.  infection rate of countries (9/5/2023)
select location, max(total_cases)/avg(cast(population as bigint))*100 as percentagepositive 
from "CovidDeaths" 
group by location 
order by percentagepositive desc;

--e.countrywise total vaccinated persons
select "CovidDeaths".location as country,
(max("covidvaccinations_3".people_fully_vaccinated)) as Fully_vaccinated 
from "CovidDeaths" join "covidvaccinations_3" 
on "CovidDeaths".iso_code ="covidvaccinations_3".iso_code 
and "CovidDeaths".date ="covidvaccinations_3".date 
where "CovidDeaths".continent is not null 
group by "CovidDeaths".location 
order by Fully_vaccinated;

--f.Rolling sum the number of vaccinations,
-- USE CTE
WITH popvsVac(continent,location, date,population,new_vaccinations,Rolling_Peoplevaccinated)
as
(
select "CovidDeaths".continent, "CovidDeaths".location, 
TO_DATE("CovidDeaths".date, 'DD-MM-YYYY'),"CovidDeaths".population,"covidvaccinations_3".new_vaccinations
,SUM("covidvaccinations_3".new_vaccinations::int)
OVER(partition by "CovidDeaths".location order by TO_DATE("CovidDeaths".date, 'DD-MM-YYYY')) 
as Rolling_Peoplevaccinated
from "CovidDeaths" join "covidvaccinations_3" 
on "CovidDeaths".location ="covidvaccinations_3".location 
and "CovidDeaths".date ="covidvaccinations_3".date 
where "CovidDeaths".continent is not null)
select *,(Rolling_Peoplevaccinated/CAST(population AS NUMERIC)) * 100 AS rollingpercentage_vaccinated
from popvsVac;

-- Temp table 
Drop Table if exists percentPopulationVac;
Create TEMP Table percentPopulationVac
(
continent TEXT,
location TEXT,
date DATE,
population numeric,
	new_vaccinations numeric,
Rolling_Peoplevaccinated numeric
);

insert into percentPopulationVac(continent, location, date, population, new_vaccinations,Rolling_PeopleVaccinated)
select "CovidDeaths".continent, "CovidDeaths".location, 
TO_DATE("CovidDeaths".date, 'DD-MM-YYYY'),CAST("CovidDeaths".population AS numeric),"covidvaccinations_3".new_vaccinations
,SUM("covidvaccinations_3".new_vaccinations::int)
OVER(partition by "CovidDeaths".location order by TO_DATE("CovidDeaths".date, 'DD-MM-YYYY')) 
as Rolling_Peoplevaccinated
from "CovidDeaths" join "covidvaccinations_3" 
on "CovidDeaths".location ="covidvaccinations_3".location 
and "CovidDeaths".date ="covidvaccinations_3".date 
where "CovidDeaths".continent is not null;

select *,(Rolling_Peoplevaccinated/population)* 100 AS rollingpercentage_vaccinated
from percentPopulationVac;

--g. likelihood of dying if you contract covid in China
select location, date, total_deaths,total_cases,(total_deaths/cast(total_cases as float))*100 as Deathpercentage
from "CovidDeaths" 
where location like '%China%';

--h. Total % of deaths out of entire population in China 
select max(total_deaths)/avg(cast(population as integer))*100 
from "CovidDeaths" 
where location like '%China%';
--verify b by getting info separately
-- select total_deaths, population from "CovidDeaths" where location like '%China%'

--i. latest infection rate of China
select max(total_cases)/avg(cast(population as bigint))*100 
as percentagepositive from "CovidDeaths" 
where location like '%China%';


--j.Daily newcases vs hospitalization vs icu_patients-China
select date, new_cases,hosp_patients,icu_patients 
from "CovidDeaths" 
where location like '%China%';


--k. world death rate
select SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))::FLOAT/SUM(new_cases)*100 as DeathPercentage
FROM "CovidDeaths" 
Where continent is not null;

-- countrywise age 65>
-- select "CovidDeaths".location,"CovidDeaths".date, "covidvaccinations_3".aged_65_older 
-- from "CovidDeaths" join "covidvaccinations_3" on "CovidDeaths".iso_code ="covidvaccinations_3".iso_code 
-- and "CovidDeaths".date ="covidvaccinations_3".date;
---continetnt

--L.Creating View to store data for later visualizations
Create view rollingpercentage_vaccinated as
select "CovidDeaths".continent, "CovidDeaths".location, 
TO_DATE("CovidDeaths".date, 'DD-MM-YYYY'),CAST("CovidDeaths".population AS numeric),"covidvaccinations_3".new_vaccinations
,SUM("covidvaccinations_3".new_vaccinations::int)
OVER(partition by "CovidDeaths".location order by TO_DATE("CovidDeaths".date, 'DD-MM-YYYY')) 
as Rolling_Peoplevaccinated
from "CovidDeaths" 
join "covidvaccinations_3" 
on "CovidDeaths".location ="covidvaccinations_3".location 
and "CovidDeaths".date ="covidvaccinations_3".date 
where "CovidDeaths".continent is not null;

select*
From rollingpercentage_vaccinated


